#!/usr/bin/env python3
"""
GST Monthly Report Generator (Excel)

Generates a filing-style GST workbook (Summary, Invoice Register, Day-wise
Summary, Line Items, Review) for a given month from the Supabase orders data.

Methodology mirrors apps/admin reportService.getGSTFilingReport():
  - Orders are attributed by created_at inside the IST month window
    (from 00:00 IST on day 1 to 23:59:59 IST on the last day).
  - Cancelled orders are excluded.
  - Per line item: gst_percentage = slab, base_amount = taxable value,
    gst_amount = GST. CGST = SGST = gst_amount / 2 (intra-state Kerala).
  - Invoice number: orders.invoice_number if present, else
    MAZ-{FY}-{seq} where seq is the chronological index of the order
    among ALL orders ever created (same rule the app uses).

Usage:
  python generate_gst_report.py --year 2026 --month 9 [--out path.xlsx]

Credentials (in priority order):
  1. SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY environment variables
  2. apps/admin/.env.local
"""

import argparse
import json
import os
import re
import sys
import urllib.parse
import urllib.request
from datetime import datetime, timedelta, date, timezone
from pathlib import Path

# --- skill design system (single source of truth for styling) --------------
XLSX_SKILL_DIR = os.environ.get(
    "XLSX_SKILL_DIR",
    r"C:\Users\moham\.zcode\cli\plugins\cache\zcode-plugins-official"
    r"\document-skills\0.1.4\skills\xlsx",
)
for _sub in [XLSX_SKILL_DIR, os.path.join(XLSX_SKILL_DIR, "templates")]:
    if _sub not in sys.path:
        sys.path.insert(0, _sub)

import base  # noqa: E402  (skill design tokens + style helpers)
from openpyxl import Workbook  # noqa: E402
from openpyxl.styles import Alignment, Font  # noqa: E402
from openpyxl.utils import get_column_letter  # noqa: E402
from openpyxl.worksheet.properties import PageSetupProperties  # noqa: E402

base.use_palette_explicit("professional")

REPO_ROOT = Path(__file__).resolve().parents[3]
ADMIN_ENV = Path(__file__).resolve().parents[1] / ".env.local"

IST = timedelta(hours=5, minutes=30)
IST_TZ = timezone(IST)
CUR_FMT = "#,##0.00"
DATE_FMT = "DD MMM YYYY"

MONTHS = [
    "January", "February", "March", "April", "May", "June", "July",
    "August", "September", "October", "November", "December",
]


# ─────────────────────────────────────────────────────────────────────────────
# Supabase REST access (read-only)
# ─────────────────────────────────────────────────────────────────────────────
def load_credentials():
    url = os.environ.get("SUPABASE_URL")
    key = os.environ.get("SUPABASE_SERVICE_ROLE_KEY")
    if url and key:
        return url.rstrip("/"), key
    if ADMIN_ENV.exists():
        env = {}
        for line in ADMIN_ENV.read_text().splitlines():
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                k, v = line.split("=", 1)
                env[k.strip()] = v.strip()
        url = env.get("NEXT_PUBLIC_SUPABASE_URL")
        key = env.get("SUPABASE_SERVICE_ROLE_KEY")
        if url and key:
            return url.rstrip("/"), key
    raise SystemExit(
        "Missing Supabase credentials. Set SUPABASE_URL and "
        "SUPABASE_SERVICE_ROLE_KEY or provide apps/admin/.env.local."
    )


def rest_get_all(base_url, key, table, params=None, page_size=1000):
    """GET all rows of a table, transparently paging via Range headers."""
    rows, offset = [], 0
    while True:
        q = dict(params or {})
        req = urllib.request.Request(
            f"{base_url}/rest/v1/{table}?{urllib.parse.urlencode(q)}",
            headers={
                "apikey": key,
                "Authorization": f"Bearer {key}",
                "Range": f"{offset}-{offset + page_size - 1}",
                "Prefer": "count=exact",
            },
        )
        with urllib.request.urlopen(req) as resp:
            rows.extend(json.loads(resp.read()))
            content_range = resp.headers.get("Content-Range", "")
        total = int(content_range.split("/")[-1]) if "/" in content_range else len(rows)
        offset = len(rows)
        if offset >= total:
            return rows


def to_ist(dt_str):
    """Parse a timestrz string and return an aware IST datetime."""
    dt = datetime.fromisoformat(dt_str.replace("Z", "+00:00"))
    return dt + IST


# ─────────────────────────────────────────────────────────────────────────────
# Report model (same logic as the app's GST filing report)
# ─────────────────────────────────────────────────────────────────────────────
def fiscal_suffix(order_dt):
    """Apr–Mar fiscal year label, e.g. 2627 for FY 2026-27."""
    y = order_dt.year if order_dt.month >= 4 else order_dt.year - 1
    return f"{str(y)[2:]}{str(y + 1)[2:]}"


def build_report(year, month):
    base_url, key = load_credentials()
    project_ref = base_url.split("//")[1].split(".")[0]

    start = date(year, month, 1)
    next_month = date(year + 1, 1, 1) if month == 12 else date(year, month + 1, 1)
    end = next_month - timedelta(days=1)
    range_start = f"{start.isoformat()}T00:00:00+05:30"
    range_end = f"{end.isoformat()}T23:59:59+05:30"

    # 1. Reference data
    store = (rest_get_all(base_url, key, "stores", {"select": "*", "limit": "1"}) or [{}])[0]
    branches = {
        b["id"]: b["name"]
        for b in rest_get_all(base_url, key, "branches", {"select": "id,name"})
    }
    categories = {
        c["id"]: c["name"]
        for c in rest_get_all(base_url, key, "categories", {"select": "id,name"})
    }
    settings = {
        s["key"]: s.get("value")
        for s in rest_get_all(base_url, key, "settings", {"select": "key,value"})
    }
    is_gst_enabled = str(settings.get("is_gst_enabled", "")).lower() == "true"

    # 2. All orders (chronological) → sequential invoice index map
    all_orders = rest_get_all(
        base_url, key, "orders",
        {"select": "id,created_at", "order": "created_at.asc"},
    )
    seq_map = {o["id"]: i + 1 for i, o in enumerate(all_orders)}

    # 3. Orders created inside the IST month window, cancelled excluded.
    #    Compare parsed instants — ISO strings carry different UTC offsets
    #    (+00:00 vs +05:30) and must never be compared lexicographically.
    win_start = datetime.fromisoformat(range_start)
    win_end = datetime.fromisoformat(range_end)

    def _instant(ts):
        return datetime.fromisoformat(ts.replace("Z", "+00:00"))

    orders = [
        o for o in rest_get_all(
            base_url, key, "orders",
            {
                "select": (
                    "id,invoice_number,status,created_at,start_date,end_date,"
                    "subtotal,discount,gst_amount,security_deposit,total_amount,"
                    "branch_id,created_at_branch_id,"
                    "customer:customer_id(name,phone,gstin)"
                ),
                "created_at": f"gte.{range_start}",
                "order": "created_at.asc",
            },
        )
        if win_start <= _instant(o["created_at"]) <= win_end
        and o["status"] != "cancelled"
    ]
    order_ids = {o["id"] for o in orders}

    # 4. Line items belonging to those orders
    items = []
    for it in rest_get_all(
        base_url, key, "order_items",
        {
            "select": (
                "id,order_id,quantity,price_per_day,subtotal,gst_percentage,"
                "base_amount,gst_amount,product:product_id(name,category_id),"
                "order:order_id(id,status,created_at)"
            )
        },
    ):
        emb = it.get("order") or {}
        if emb.get("id") in order_ids and emb.get("status") != "cancelled":
            items.append(it)

    # 5. Assemble invoices
    invoices = {}
    for o in orders:
        created = to_ist(o["created_at"])
        inv_no = o.get("invoice_number") or f"MAZ-{fiscal_suffix(created)}-{seq_map.get(o['id'], 1):04d}"
        cust = o.get("customer") or {}
        branch_id = o.get("created_at_branch_id") or o.get("branch_id")
        invoices[o["id"]] = {
            "invoice_no": inv_no,
            "date": created.date(),
            "customer": cust.get("name") or "Unknown",
            "phone": cust.get("phone") or "",
            "gstin": cust.get("gstin") or "",
            "branch": branches.get(branch_id, "-"),
            "status": o["status"],
            "rental": f"{o.get('start_date', '?')} – {o.get('end_date', '?')}",
            "discount": round(float(o.get("discount") or 0), 2),
            "total": round(float(o.get("total_amount") or 0), 2),
            "taxable": 0.0, "gst": 0.0, "slabs": set(), "lines": [],
        }

    line_items = []
    for it in items:
        inv = invoices[it["order_id"]]
        slab = float(it.get("gst_percentage") or 0)
        taxable = round(float(it.get("base_amount") or 0), 2)
        gst = round(float(it.get("gst_amount") or 0), 2)
        prod = it.get("product") or {}
        if gst > 0:
            inv["taxable"] += taxable
            inv["gst"] += gst
            inv["slabs"].add(slab)
        line_items.append({
            "invoice_no": inv["invoice_no"],
            "date": inv["date"],
            "customer": inv["customer"],
            "product": prod.get("name") or "Unknown",
            "category": categories.get(prod.get("category_id"), "-"),
            "qty": int(it.get("quantity") or 0),
            "slab": slab,
            "taxable": taxable,
            "gst": gst,
            "total": round(taxable + gst, 2),
        })

    for inv in invoices.values():
        inv["taxable"] = round(inv["taxable"], 2)
        inv["gst"] = round(inv["gst"], 2)
        inv["cgst"] = round(inv["gst"] / 2, 2)
        inv["sgst"] = round(inv["gst"] / 2, 2)

    inv_list = sorted(invoices.values(), key=lambda v: (v["date"], v["invoice_no"]))

    # Slab-wise rollup (GST-bearing items only, matching the app)
    slabs = {}
    for li in line_items:
        if li["gst"] > 0:
            s = slabs.setdefault(li["slab"], {"taxable": 0.0, "gst": 0.0})
            s["taxable"] += li["taxable"]
            s["gst"] += li["gst"]
    slab_rows = [
        {
            "rate": r,
            "taxable": round(v["taxable"], 2),
            "cgst": round(v["gst"] / 2, 2),
            "sgst": round(v["gst"] / 2, 2),
            "gst": round(v["gst"], 2),
        }
        for r, v in sorted(slabs.items())
    ]

    totals = {
        "invoices": len(inv_list),
        "gst_invoices": sum(1 for v in inv_list if v["gst"] > 0),
        "invoice_value": round(sum(v["total"] for v in inv_list), 2),
        "discount": round(sum(v["discount"] for v in inv_list), 2),
        "taxable": round(sum(v["taxable"] for v in inv_list), 2),
        "cgst": round(sum(v["cgst"] for v in inv_list), 2),
        "sgst": round(sum(v["sgst"] for v in inv_list), 2),
        "gst": round(sum(v["gst"] for v in inv_list), 2),
    }

    meta = {
        "period": f"{start.strftime('%d %b %Y')} – {end.strftime('%d %b %Y')} (IST)",
        "month_name": MONTHS[month - 1],
        "year": year,
        "generated": datetime.now(IST_TZ),
        "project_ref": project_ref,
        "is_gst_enabled": is_gst_enabled,
        "store": store,
    }
    return {"meta": meta, "invoices": inv_list, "items": line_items,
            "slabs": slab_rows, "totals": totals}


# ─────────────────────────────────────────────────────────────────────────────
# Workbook builders
# ─────────────────────────────────────────────────────────────────────────────
def caption(ws, row, col, text, span=None, height=20):
    c = ws.cell(row=row, column=col, value=text)
    c.font = base.font_caption()
    c.alignment = Alignment(horizontal="left", vertical="top", wrap_text=True)
    if span:
        ws.merge_cells(start_row=row, start_column=col, end_row=row, end_column=col + span - 1)
    ws.row_dimensions[row].height = height
    return c


def section_title(ws, row, text):
    c = ws.cell(row=row, column=2, value=text)
    c.font = base.font_subheader()
    ws.row_dimensions[row].height = 24


def _longest_word(text):
    return max((len(w) for w in re.split(r"\s+", str(text))), default=0)


def widen_for_headers(ws, header_row, col_start, col_end, pad=3, max_width=40):
    """Ensure no header word breaks mid-word: width >= longest header word."""
    for col in range(col_start, col_end + 1):
        v = ws.cell(row=header_row, column=col).value
        if not v:
            continue
        need = min(_longest_word(v) + pad, max_width)
        letter = get_column_letter(col)
        cur = ws.column_dimensions[letter].width or 8
        if cur < need:
            ws.column_dimensions[letter].width = need


def widen_for_values(ws, row, cols, pad=3.5):
    """Ensure formatted numeric values (e.g. totals) never clip to #####."""
    for col in cols:
        v = ws.cell(row=row, column=col).value
        if isinstance(v, (int, float)):
            need = len(f"{v:,.2f}") + pad
            letter = get_column_letter(col)
            cur = ws.column_dimensions[letter].width or 8
            if cur < need:
                ws.column_dimensions[letter].width = need


def kv_row(ws, row, label, value, num=False, integer=False):
    lc = ws.cell(row=row, column=2, value=label)
    lc.font = base.font_caption()
    lc.alignment = Alignment(horizontal="left", vertical="center")
    vc = ws.cell(row=row, column=3, value=value)
    vc.font = base.font_body()
    if integer:
        vc.number_format = "#,##0"
        vc.alignment = Alignment(horizontal="right", vertical="center")
    elif num:
        vc.number_format = CUR_FMT
        vc.alignment = Alignment(horizontal="right", vertical="center")
    else:
        vc.alignment = Alignment(horizontal="left", vertical="center", wrap_text=True)
    ws.row_dimensions[row].height = 20


def write_table(ws, header_row, headers, rows, num_cols=(), pct_cols=(), date_cols=()):
    """Write a styled header+data block starting at column B; returns last data row."""
    for i, h in enumerate(headers, start=2):
        ws.cell(row=header_row, column=i, value=h)
    base.style_header_row(ws, header_row, 2, len(headers) + 1)
    r = header_row
    for idx, row_data in enumerate(rows):
        r = header_row + 1 + idx
        for j, val in enumerate(row_data, start=2):
            ws.cell(row=r, column=j, value=val)
        base.style_data_row(ws, r, 2, len(headers) + 1, idx)
        for col in num_cols:
            c = ws.cell(row=r, column=col)
            c.number_format = CUR_FMT
            c.alignment = base.align_number()
        for col in pct_cols:
            c = ws.cell(row=r, column=col)
            c.number_format = "0.##%"
            c.alignment = base.align_number()
        for col in date_cols:
            c = ws.cell(row=r, column=col)
            c.number_format = DATE_FMT
            c.alignment = base.align_date()
    return r


def build_summary(ws, rep):
    m, t = rep["meta"], rep["totals"]
    last_col = 6  # B..F
    base.setup_sheet(ws, title=f"GST Report — {m['month_name']} {m['year']}", last_col=last_col)
    store = m["store"]

    section_title(ws, 4, "Business & Report Details")
    kv_row(ws, 5, "Business", store.get("name") or "-")
    kv_row(ws, 6, "Address", store.get("address") or "-")
    kv_row(ws, 7, "Phone", store.get("phone") or "-")
    kv_row(ws, 8, "GSTIN", store.get("gstin") or "Not configured in system")
    kv_row(ws, 9, "Report Period", m["period"])
    kv_row(ws, 10, "GST in System", "Enabled" if m["is_gst_enabled"] else "Disabled (is_gst_enabled setting)")
    kv_row(ws, 11, "Generated On", f"{m['generated'].strftime('%d %b %Y %H:%M')} IST")

    section_title(ws, 13, "Invoice Composition")
    kv_row(ws, 14, "Total Invoices (non-cancelled)", t["invoices"], integer=True)
    kv_row(ws, 15, "GST-bearing Invoices", t["gst_invoices"], integer=True)
    kv_row(ws, 16, "Non-GST Invoices", t["invoices"] - t["gst_invoices"], integer=True)

    section_title(ws, 18, "Tax Summary")
    kv_row(ws, 19, "Total Taxable Value (₹)", t["taxable"], num=True)
    cgst_row, sgst_row, gst_row = 20, 21, 22
    kv_row(ws, cgst_row, "Total CGST (₹)", t["cgst"], num=True)
    kv_row(ws, sgst_row, "Total SGST (₹)", t["sgst"], num=True)
    kv_row(ws, gst_row, "Total GST (₹)", t["gst"], num=True)
    kv_row(ws, 23, "Grand Invoice Value (₹)", t["invoice_value"], num=True)

    section_title(ws, 25, "GST Rate-wise Summary")
    headers = ["Rate", "Taxable Value (₹)", "CGST (₹)", "SGST (₹)", "Total GST (₹)"]
    for i, h in enumerate(headers, start=2):
        ws.cell(row=26, column=i, value=h)
    base.style_header_row(ws, 26, 2, last_col)
    if rep["slabs"]:
        for idx, s in enumerate(rep["slabs"]):
            r = 27 + idx
            vals = [s["rate"] / 100.0, s["taxable"], s["cgst"], s["sgst"], s["gst"]]
            for j, v in enumerate(vals, start=2):
                ws.cell(row=r, column=j, value=v)
            base.style_data_row(ws, r, 2, last_col, idx)
            ws.cell(row=r, column=2).number_format = "0.##%"
            ws.cell(row=r, column=2).alignment = base.align_number()
            for col in range(3, last_col + 1):
                c = ws.cell(row=r, column=col)
                c.number_format = CUR_FMT
                c.alignment = base.align_number()
        last = 26 + len(rep["slabs"])
    else:
        r = 27
        ws.merge_cells(start_row=r, start_column=2, end_row=r, end_column=last_col)
        c = ws.cell(row=r, column=2, value="No GST-bearing line items in this period")
        base.style_data_row(ws, r, 2, last_col, 0)
        c.alignment = Alignment(horizontal="center", vertical="center")
        last = r
    tr = last + 1
    ws.cell(row=tr, column=2, value="Total")
    for col, key in zip(range(3, last_col + 1), ["taxable", "cgst", "sgst", "gst"]):
        c = ws.cell(row=tr, column=col, value=t[key])
        c.number_format = CUR_FMT
    base.style_total_row(ws, tr, 2, last_col)
    for col in range(3, last_col + 1):
        ws.cell(row=tr, column=col).alignment = base.align_number()

    # Widths first, then fit only the table region — captions written after are
    # sized explicitly, because auto-fit over-estimates merged-cell rows.
    ws.column_dimensions["B"].width = 26
    ws.column_dimensions["C"].width = 46
    for col in ("D", "E", "F"):
        ws.column_dimensions[col].width = 16
    base.auto_fit_row_heights(ws, data_start_row=5, data_end_row=tr)
    if not rep["slabs"]:
        ws.row_dimensions[27].height = 22

    note_row = tr + 2
    if t["invoices"] == 0:
        warn = ws.cell(row=note_row, column=2, value=(
            "⚠ No transactions found for this period in the connected database. "
            "Verify this is the production database before treating this as a nil period."
        ))
        warn.font = Font(name=base.FONT_NAME, size=9, color=base.ACCENT_WARNING)
        ws.merge_cells(start_row=note_row, start_column=2, end_row=note_row, end_column=last_col)
        warn.alignment = Alignment(horizontal="left", vertical="top", wrap_text=True)
        ws.row_dimensions[note_row].height = 30
        note_row += 1
    caption(ws, note_row, 2,
            "Methodology: orders attributed by creation date (IST); cancelled orders excluded; "
            "taxable value from order_items.base_amount; CGST = SGST = GST / 2 (intra-state).",
            span=last_col - 1, height=30)
    caption(ws, note_row + 1, 2,
            f"Data source: orders database (Supabase project {m['project_ref']}). Invoice numbers "
            "follow the app's MAZ-{FY}-{seq} convention, or the stored invoice_number.",
            span=last_col - 1, height=30)

    ws.sheet_properties.pageSetUpPr = PageSetupProperties(fitToPage=True)
    ws.page_setup.orientation = "portrait"
    ws.page_setup.fitToWidth = 1
    ws.page_setup.fitToHeight = 0
    return {"cgst_row": cgst_row, "sgst_row": sgst_row, "gst_row": gst_row,
            "taxable_row": 19, "invoice_count_row": 14}


def build_invoice_register(ws, rep):
    headers = ["#", "Invoice No", "Date", "Customer", "Phone", "Customer GSTIN",
               "Branch", "Status", "Rental Period", "Discount (₹)", "Invoice Total (₹)",
               "Taxable Value (₹)", "CGST (₹)", "SGST (₹)", "Total GST (₹)", "GST Rates"]
    last_col = len(headers) + 1  # data occupies B..Q
    base.setup_sheet(ws, title=f"Invoice Register — {rep['meta']['month_name']} {rep['meta']['year']}",
                     last_col=last_col)
    rows = []
    for i, inv in enumerate(rep["invoices"], 1):
        rates = ", ".join(f"{s:g}%" for s in sorted(inv["slabs"])) if inv["slabs"] else "–"
        rows.append([i, inv["invoice_no"], inv["date"], inv["customer"], inv["phone"],
                     inv["gstin"] or "–", inv["branch"], inv["status"], inv["rental"],
                     inv["discount"], inv["total"], inv["taxable"], inv["cgst"],
                     inv["sgst"], inv["gst"], rates])
    last = write_table(ws, 4, headers, rows, num_cols=range(11, 17), date_cols=(4,))
    total_row = last + 1
    ws.cell(row=total_row, column=2, value="Total")
    if rows:
        # Computed values (skill rule: verifiable without an Excel recalc engine)
        for col, key in zip(range(11, 17),
                            ["discount", "invoice_value", "taxable", "cgst", "sgst", "gst"]):
            ws.cell(row=total_row, column=col, value=rep["totals"][key]).number_format = CUR_FMT
    else:
        # Nil period: text dashes so live COUNT/SUM formulas over the data range
        # never pick up the totals row (reversed ranges normalize in Excel).
        for col in range(11, 17):
            ws.cell(row=total_row, column=col, value="–")
    base.style_total_row(ws, total_row, 2, last_col)
    for col in range(11, 17):
        ws.cell(row=total_row, column=col).alignment = base.align_number()
    base.auto_fit_columns(ws, min_width=8, max_width=28, header_row=4, data_start_row=5)
    widen_for_headers(ws, 4, 2, last_col)
    widen_for_values(ws, total_row, range(11, 17))
    base.auto_fit_row_heights(ws, header_row=4, data_start_row=5)
    if not rows:
        caption(ws, total_row + 2, 2, "No invoices were issued in this period.", span=6)
    ws.sheet_properties.pageSetUpPr = PageSetupProperties(fitToPage=True)
    ws.freeze_panes = "D5"
    ws.page_setup.orientation = "landscape"
    ws.page_setup.fitToWidth = 1
    ws.page_setup.fitToHeight = 0
    ws.print_title_rows = "4:4"
    return {"last_data_row": last if rows else 4, "total_row": total_row}


def build_daywise(ws, rep):
    headers = ["Date", "Invoices", "Taxable Value (₹)", "CGST (₹)", "SGST (₹)", "Total GST (₹)"]
    last_col = len(headers) + 1
    base.setup_sheet(ws, title=f"Day-wise GST Summary — {rep['meta']['month_name']} {rep['meta']['year']}",
                     last_col=last_col)
    by_day = {}
    for inv in rep["invoices"]:
        d = by_day.setdefault(inv["date"], {"n": 0, "taxable": 0.0, "cgst": 0.0, "sgst": 0.0, "gst": 0.0})
        d["n"] += 1
        d["taxable"] += inv["taxable"]
        d["cgst"] += inv["cgst"]
        d["sgst"] += inv["sgst"]
        d["gst"] += inv["gst"]
    rows = [[d, v["n"], round(v["taxable"], 2), round(v["cgst"], 2),
             round(v["sgst"], 2), round(v["gst"], 2)] for d, v in sorted(by_day.items())]
    last = write_table(ws, 4, headers, rows, num_cols=range(4, 8), date_cols=(2,))
    total_row = last + 1
    t = rep["totals"]
    ws.cell(row=total_row, column=2, value="Total")
    if rows:
        ws.cell(row=total_row, column=3, value=t["invoices"]).number_format = "#,##0"
        for col, key in zip(range(4, 8), ["taxable", "cgst", "sgst", "gst"]):
            ws.cell(row=total_row, column=col, value=t[key]).number_format = CUR_FMT
    else:
        for col in range(3, 8):
            ws.cell(row=total_row, column=col, value="–")
    base.style_total_row(ws, total_row, 2, last_col)
    for col in range(3, 8):
        ws.cell(row=total_row, column=col).alignment = base.align_number()
    base.auto_fit_columns(ws, min_width=10, max_width=24, header_row=4, data_start_row=5)
    widen_for_headers(ws, 4, 2, last_col)
    widen_for_values(ws, total_row, range(4, 8))
    base.auto_fit_row_heights(ws, header_row=4, data_start_row=5)
    if not rows:
        caption(ws, total_row + 2, 2, "No transactions in this period.", span=3)
    ws.sheet_properties.pageSetUpPr = PageSetupProperties(fitToPage=True)
    ws.page_setup.orientation = "portrait"
    ws.page_setup.fitToWidth = 1
    return {"last_data_row": last if rows else 4, "total_row": total_row}


def build_line_items(ws, rep):
    headers = ["Invoice No", "Date", "Customer", "Product", "Category", "Qty",
               "GST Rate", "Taxable Amount (₹)", "GST Amount (₹)", "Item Total (₹)"]
    last_col = len(headers) + 1
    base.setup_sheet(ws, title=f"Line Item Detail — {rep['meta']['month_name']} {rep['meta']['year']}",
                     last_col=last_col)
    rows = [[li["invoice_no"], li["date"], li["customer"], li["product"], li["category"],
             li["qty"], (li["slab"] / 100.0 if li["gst"] > 0 else 0), li["taxable"],
             li["gst"], li["total"]] for li in rep["items"]]
    last = write_table(ws, 4, headers, rows, num_cols=(9, 10, 11), pct_cols=(8,), date_cols=(3,))
    total_row = last + 1
    ws.cell(row=total_row, column=2, value="Total")
    if rows:
        # Column totals must equal the sum of THIS column (line-level values,
        # which are pre-discount and therefore differ from register taxable).
        ws.cell(row=total_row, column=9,
                value=round(sum(li["taxable"] for li in rep["items"]), 2)).number_format = CUR_FMT
        ws.cell(row=total_row, column=10,
                value=round(sum(li["gst"] for li in rep["items"]), 2)).number_format = CUR_FMT
        ws.cell(row=total_row, column=11,
                value=round(sum(li["total"] for li in rep["items"]), 2)).number_format = CUR_FMT
    else:
        for col in (9, 10, 11):
            ws.cell(row=total_row, column=col, value="–")
    base.style_total_row(ws, total_row, 2, last_col)
    for col in (9, 10, 11):
        ws.cell(row=total_row, column=col).alignment = base.align_number()
    base.auto_fit_columns(ws, min_width=8, max_width=28, header_row=4, data_start_row=5)
    widen_for_headers(ws, 4, 2, last_col)
    widen_for_values(ws, total_row, (9, 10, 11))
    base.auto_fit_row_heights(ws, header_row=4, data_start_row=5)
    caption(ws, total_row + 2, 2,
            "Line amounts are pre-discount line values; order-level discounts are applied on the "
            "invoice total shown in the Invoice Register.", span=5)
    if not rows:
        caption(ws, total_row + 3, 2, "No line items in this period.", span=4)
    ws.sheet_properties.pageSetUpPr = PageSetupProperties(fitToPage=True)
    ws.freeze_panes = "C5"
    ws.page_setup.orientation = "landscape"
    ws.page_setup.fitToWidth = 1
    ws.print_title_rows = "4:4"
    return {"last_data_row": last if rows else 4, "total_row": total_row}


def build_review(ws, rep, refs):
    """Cross-validation sheet with live formulas — Excel recomputes on open."""
    t = rep["totals"]
    reg_last = refs["register"]["last_data_row"]
    day_last = refs["daywise"]["last_data_row"]
    li_last = refs["lineitems"]["last_data_row"]

    base.setup_sheet(ws, title="Cross-Validation Review", last_col=5)
    headers = ["Check", "Expected (from source data)", "Actual (live formula)", "Status"]
    for i, h in enumerate(headers, start=2):
        ws.cell(row=4, column=i, value=h)
    base.style_header_row(ws, 4, 2, 5)

    checks = [
        ["Invoice count matches register", t["invoices"],
         f"=COUNT('Invoice Register'!$L$5:$L${reg_last})"],
        ["Taxable value: register vs source", t["taxable"],
         f"=ROUND(SUM('Invoice Register'!$M$5:$M${reg_last}),2)"],
        ["Total GST: register vs source", t["gst"],
         f"=ROUND(SUM('Invoice Register'!$P$5:$P${reg_last}),2)"],
        ["Taxable value: day-wise vs register", t["taxable"],
         f"=ROUND(SUM('Day-wise Summary'!$D$5:$D${day_last}),2)"],
        ["GST amount: line items vs register", t["gst"],
         f"=ROUND(SUM('Line Items'!$J$5:$J${li_last}),2)"],
        ["CGST + SGST (register) match summary halves", round(t["cgst"] + t["sgst"], 2),
         f"=ROUND(SUM('Invoice Register'!$N$5:$N${reg_last})"
         f"+SUM('Invoice Register'!$O$5:$O${reg_last}),2)"],
    ]
    for idx, (name, expected, actual) in enumerate(checks):
        r = 5 + idx
        ws.cell(row=r, column=2, value=name)
        ws.cell(row=r, column=3, value=expected).number_format = CUR_FMT
        ws.cell(row=r, column=4, value=actual).number_format = CUR_FMT
        ws.cell(row=r, column=5, value=f'=IF(ROUND(C{r}-D{r},2)=0,"PASS","FAIL")')
        base.style_data_row(ws, r, 2, 5, idx)
        ws.cell(row=r, column=3).alignment = base.align_number()
        ws.cell(row=r, column=4).alignment = base.align_number()
        ws.cell(row=r, column=5).alignment = Alignment(horizontal="center", vertical="center")
    caption(ws, 5 + len(checks) + 1, 2,
            "Expected values are computed from the database at generation time; "
            "Actual values are live formulas over the sheets — Excel recalculates on open.",
            span=4)
    ws.sheet_properties.tabColor = "FFC000"
    ws.sheet_properties.pageSetUpPr = PageSetupProperties(fitToPage=True)
    ws.page_setup.orientation = "landscape"
    ws.page_setup.fitToWidth = 1
    base.auto_fit_columns(ws, min_width=12, max_width=40, header_row=4, data_start_row=5)
    base.auto_fit_row_heights(ws, header_row=4, data_start_row=5)


def main():
    ap = argparse.ArgumentParser(description="Generate monthly GST report (xlsx)")
    ap.add_argument("--year", type=int, required=True)
    ap.add_argument("--month", type=int, required=True)
    ap.add_argument("--out", default=None, help="Output .xlsx path")
    args = ap.parse_args()
    if not 1 <= args.month <= 12:
        raise SystemExit("month must be 1-12")

    rep = build_report(args.year, args.month)
    m = rep["meta"]
    out = Path(args.out) if args.out else REPO_ROOT / f"GST_Report_{m['month_name']}_{m['year']}.xlsx"

    wb = Workbook()
    ws_summary = wb.active
    ws_summary.title = "Summary"
    refs = {"summary": build_summary(ws_summary, rep)}
    refs["register"] = build_invoice_register(wb.create_sheet("Invoice Register"), rep)
    refs["daywise"] = build_daywise(wb.create_sheet("Day-wise Summary"), rep)
    refs["lineitems"] = build_line_items(wb.create_sheet("Line Items"), rep)
    build_review(wb.create_sheet("Review"), rep, refs)

    wb.properties.creator = "Z.ai"
    wb.save(out)
    t = rep["totals"]
    print(f"Saved: {out}")
    print(f"Invoices: {t['invoices']} (GST-bearing: {t['gst_invoices']}) | "
          f"Taxable: ₹{t['taxable']:,.2f} | CGST: ₹{t['cgst']:,.2f} | "
          f"SGST: ₹{t['sgst']:,.2f} | Total GST: ₹{t['gst']:,.2f}")


if __name__ == "__main__":
    main()
