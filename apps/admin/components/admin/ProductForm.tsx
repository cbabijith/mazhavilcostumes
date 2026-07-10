/**
 * ProductForm Component — Redesigned for Speed
 *
 * Two-column layout (65/35 split). Single global stock field (no branch inventory).
 * Shows inherited GST rate when category is selected.
 * "Save & Add Another" for batch entry. Sticky action bar always visible.
 *
 * @component
 */

"use client";

import { useState, useEffect, useCallback, useRef, useMemo } from "react";
import { useRouter } from "next/navigation";
import { AlertCircle, RefreshCw, Wand2, ArrowLeft, Package, Info } from "lucide-react";

import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { FileUpload } from "@/components/ui/file-upload";
import { Switch } from "@/components/ui/switch";
import { type Category } from "@/domain/types/category";
import { type Product, type ProductWithRelations } from "@/domain/types/product";
import { useAppStore, useAppSelectors } from "@/stores";
import { useQueryClient } from "@tanstack/react-query";
import { useCreateProduct, useUpdateProduct } from "@/hooks/useProducts";
import { useCategories } from "@/hooks/useCategories";
import { useBranches } from "@/hooks/useBranches";

const MAX_IMAGES = 5;

interface ProductFormProps {
  product?: ProductWithRelations;
}

/* ── Helper: default empty form state ──────────────────────────────── */
function emptyFormData() {
  return {
    name: "",
    slug: "",
    sku: "",
    barcode: "",
    description: "",
    category_id: "",
    subcategory_id: "",
    subvariant_id: "",
    price_per_day: "" as number | string,
    purchase_price: "" as number | string,
    quantity: "" as number | string,
    is_active: true,
  };
}

export default function ProductForm({
  product,
}: ProductFormProps) {
  const router = useRouter();
  const isEdit = !!product;
  const showError = useAppSelectors.showError();
  const showSuccess = useAppSelectors.showSuccess();
  const user = useAppSelectors.user();
  const selectedBranchId = useAppSelectors.selectedBranchId();
  const queryClient = useQueryClient();
  const { createProduct } = useCreateProduct();
  const { updateProduct } = useUpdateProduct();
  const { categories, isLoading: isCategoriesLoading } = useCategories();
  const { branches, isLoading: isBranchesLoading } = useBranches();
  const [branchStocks, setBranchStocks] = useState<Record<string, number>>({});
  const [globalStock, setGlobalStock] = useState<string | number>("");

  // Find the active branch context (selected in switcher or user's assigned branch)
  const activeBranchId = selectedBranchId || user?.branch_id;
  const activeBranch = activeBranchId ? branches.find((b) => b.id === activeBranchId) : null;
  // Can manage all branch stock if they are a global admin or assigned to the main branch AND have not selected a sub-branch
  const isMainBranchContext = !activeBranchId || activeBranch?.is_main === true;

  // Handle global stock changes and propagate to all branches
  const handleGlobalStockChange = (val: string) => {
    const qty = val === "" ? "" : parseInt(val, 10);
    const numericQty = isNaN(qty as any) ? 0 : (qty as number);
    
    setGlobalStock(val === "" ? "" : numericQty);
    
    const updated: Record<string, number> = {};
    branches.forEach((b) => {
      updated[b.id] = numericQty;
    });
    setBranchStocks(updated);
  };

  // Populate branch stocks on load/change
  useEffect(() => {
    if (branches.length === 0) return;

    if (isEdit && product) {
      const stocks: Record<string, number> = {};
      let allEqual = true;
      let firstVal: number | null = null;

      branches.forEach((b) => {
        const inv = product.product_inventory?.find((i: any) => i.branch_id === b.id);
        const qty = inv ? inv.quantity : 0;
        stocks[b.id] = qty;

        if (firstVal === null) {
          firstVal = qty;
        } else if (qty !== firstVal) {
          allEqual = false;
        }
      });
      setBranchStocks(stocks);

      if (allEqual && firstVal !== null) {
        setGlobalStock(firstVal);
      } else {
        setGlobalStock("");
      }
    } else {
      const stocks: Record<string, number> = {};
      branches.forEach((b) => {
        stocks[b.id] = 0;
      });
      setBranchStocks(stocks);
      setGlobalStock(0);
    }
  }, [branches, product, isEdit]);

  // ── RBAC Guard: only admin/super_admin can edit products ────────
  useEffect(() => {
    if (isEdit && user?.role && user.role !== 'admin' && user.role !== 'super_admin') {
      router.push(`/dashboard/products/${product?.id}`);
    }
  }, [isEdit, user?.role, product?.id, router]);

  // ── Branch Context Guard: sub-branch users can only edit their own products ────────
  useEffect(() => {
    if (isEdit && !isMainBranchContext && product && product.branch_id !== activeBranchId) {
      showError("You are not authorized to edit products belonging to other branches.");
      router.push(`/dashboard/products/${product.id}`);
    }
  }, [isEdit, isMainBranchContext, product, activeBranchId, router, showError]);

  // ── Async-Resilience Guard ──────────────────────────────────────
  // Block submission until all async dependencies are resolved.
  const isFormReady = !isCategoriesLoading && !isBranchesLoading;

  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [slugManuallyEdited, setSlugManuallyEdited] = useState(false);

  // Barcode uniqueness validation
  const [barcodeError, setBarcodeError] = useState<string | null>(null);
  const [isCheckingBarcode, setIsCheckingBarcode] = useState(false);
  const barcodeCheckTimer = useRef<NodeJS.Timeout | null>(null);

  const existingImages: string[] = (product?.images || [])
    .map((img) => (typeof img === "string" ? img : img.url))
    .filter(Boolean) as string[];
  const [imageUrls, setImageUrls] = useState<string[]>(existingImages);

  const [formData, setFormData] = useState(() =>
    product
      ? {
          name: product.name ?? "",
          slug: product.slug ?? "",
          sku: product.sku ?? "",
          barcode: product.barcode ?? "",
          description: product.description ?? "",
          category_id: product.category_id ?? "",
          subcategory_id: product.subcategory_id ?? "",
          subvariant_id: product.subvariant_id ?? "",
          price_per_day: product.price_per_day !== undefined && product.price_per_day !== null ? product.price_per_day : ("" as number | string),
          purchase_price: (product as any).purchase_price !== undefined && (product as any).purchase_price !== null ? (product as any).purchase_price : ("" as number | string),
          quantity: (product as any).quantity !== undefined && (product as any).quantity !== null ? ((product as any).quantity ?? (product as any).total_quantity ?? "") : ("" as number | string),
          is_active: product.is_active ?? true,
        }
      : emptyFormData()
  );

  // ── Helpers ────────────────────────────────────────────────────────
  const generateSlug = (name: string): string =>
    name
      .toLowerCase()
      .trim()
      .replace(/\s+/g, "-")
      .replace(/[^a-z0-9-]/g, "")
      .replace(/--+/g, "-");

  const getTimestampStr = () => Date.now().toString(36).toUpperCase();
  const getRandomStr = () => Math.random().toString(36).substring(2, 6).toUpperCase();
  const getRandom4Digit = () => Math.floor(1000 + Math.random() * 9000);

  const generateBarcode = () => {
    const barcode = `PB${getTimestampStr()}${getRandomStr()}`;
    setFormData((prev) => ({ ...prev, barcode }));
    setBarcodeError(null);
    checkBarcodeUniqueness(barcode);
  };

  // Debounced barcode uniqueness check
  const checkBarcodeUniqueness = (barcode: string) => {
    if (barcodeCheckTimer.current) clearTimeout(barcodeCheckTimer.current);
    if (!barcode || barcode.trim().length === 0) {
      setBarcodeError(null);
      setIsCheckingBarcode(false);
      return;
    }
    setIsCheckingBarcode(true);
    barcodeCheckTimer.current = setTimeout(async () => {
      try {
        const excludeParam = product?.id ? `&exclude=${product.id}` : '';
        const res = await fetch(`/api/products/check-barcode?code=${encodeURIComponent(barcode.trim())}${excludeParam}`);
        const json = await res.json();
        if (json.success && json.data) {
          if (!json.data.unique) {
            setBarcodeError(`Already assigned to "${json.data.existing_product}"`);
          } else {
            setBarcodeError(null);
          }
        }
      } catch {
        // Silently ignore network errors for validation
      } finally {
        setIsCheckingBarcode(false);
      }
    }, 500);
  };

  const generateSKU = () => {
    const catName = categories.find((c) => c.id === formData.category_id)?.name;
    const prefix = catName ? catName.substring(0, 3).toUpperCase() : "PB";
    const random = getRandom4Digit();
    setFormData((prev) => ({ ...prev, sku: `${prefix}-${random}` }));
  };

  const clearZeroOnFocus = (e: React.FocusEvent<HTMLInputElement>) => {
    if (e.target.value === "0") e.target.value = "";
  };

  // Prevent scroll on number inputs
  useEffect(() => {
    const handleWheel = (e: WheelEvent) => {
      if (e.target instanceof HTMLInputElement && e.target.type === "number") {
        e.preventDefault();
      }
    };
    document.addEventListener("wheel", handleWheel, { passive: false });
    return () => document.removeEventListener("wheel", handleWheel);
  }, []);

  // Category hierarchy
  const mains = categories.filter((c) => !c.parent_id);
  const subs = categories.filter((c) => c.parent_id === formData.category_id);
  const variants = categories.filter(
    (c) => c.parent_id === formData.subcategory_id
  );

  const handleMainCategoryChange = (value: string) =>
    setFormData((prev) => ({
      ...prev,
      category_id: value,
      subcategory_id: "",
      subvariant_id: "",
    }));

  const handleSubCategoryChange = (value: string) =>
    setFormData((prev) => ({ ...prev, subcategory_id: value, subvariant_id: "" }));

  // ── GST Inheritance from Category ──────────────────────────────────
  // Determine the most specific category's GST rate
  const inheritedGst = useMemo(() => {
    // Priority: variant → sub → main
    const catId = formData.subvariant_id || formData.subcategory_id || formData.category_id;
    if (!catId) return null;
    const cat = categories.find((c) => c.id === catId);
    if (!cat) return null;
    return {
      percentage: cat.gst_percentage ?? 5,
      categoryName: cat.name,
    };
  }, [formData.category_id, formData.subcategory_id, formData.subvariant_id, categories]);

  // ── Submit ─────────────────────────────────────────────────────────
  const handleSubmit = useCallback(
    async (continueAdding: boolean = false) => {
      setLoading(true);
      setError("");

      try {
        // Mandatory field validation
        if (!formData.name.trim()) {
          showError("Product name is required");
          setLoading(false);
          return;
        }

        if (!formData.category_id) {
          showError("Category is required");
          setLoading(false);
          return;
        }

        if (!formData.slug.trim()) {
          showError("URL Slug is required");
          setLoading(false);
          return;
        }

        if (!/^[a-z0-9-]+$/.test(formData.slug)) {
          showError("URL Slug must contain only lowercase letters, numbers, and hyphens (e.g., bridal-necklace-set)");
          setLoading(false);
          return;
        }

        if (!formData.sku || !formData.sku.trim()) {
          showError("SKU is required");
          setLoading(false);
          return;
        }

        if (!formData.barcode || !formData.barcode.trim()) {
          showError("Barcode is required");
          setLoading(false);
          return;
        }

        const parsedPricePerDay = parseFloat(String(formData.price_per_day));
        const pricePerDay = isNaN(parsedPricePerDay) ? 0 : parsedPricePerDay;

        const parsedPurchasePrice = parseFloat(String(formData.purchase_price));
        const purchasePrice = isNaN(parsedPurchasePrice) ? 0 : parsedPurchasePrice;

        const otherBranchesQty = isMainBranchContext 
          ? 0 
          : (product?.product_inventory || [])
              .filter((inv: any) => inv.branch_id !== activeBranchId)
              .reduce((sum: number, inv: any) => sum + inv.quantity, 0);

        const subBranchQty = activeBranchId ? (branchStocks[activeBranchId] || 0) : 0;
        
        const totalQuantity = isMainBranchContext 
          ? Object.values(branchStocks).reduce((sum, qty) => sum + (qty || 0), 0)
          : otherBranchesQty + subBranchQty;

        if (pricePerDay <= 0) {
          showError("Rent amount is required and must be greater than 0");
          setLoading(false);
          return;
        }

        if (totalQuantity <= 0) {
          showError("Stock quantity is required and must be greater than 0");
          setLoading(false);
          return;
        }

        if (barcodeError) {
          showError("Please fix the barcode error before saving");
          setLoading(false);
          return;
        }

        const images = imageUrls.map((url, index) => ({
          url,
          alt_text: formData.name,
          is_primary: index === 0,
          sort_order: index,
        }));

        const branchInventoryPayload = isMainBranchContext
          ? Object.entries(branchStocks).map(([branchId, qty]) => {
              const inv = product?.product_inventory?.find((i: any) => i.branch_id === branchId);
              return {
                branch_id: branchId,
                quantity: qty || 0,
                id: inv?.id,
              };
            })
          : branches.map((branch) => {
              const inv = product?.product_inventory?.find((i: any) => i.branch_id === branch.id);
              const qty = branch.id === activeBranchId ? subBranchQty : (isEdit ? (inv?.quantity || 0) : 0);
              return {
                branch_id: branch.id,
                quantity: qty,
                id: inv?.id,
              };
            });

        const basePayload = {
          name: formData.name,
          slug: formData.slug || generateSlug(formData.name),
          images,
          category_id: formData.category_id || undefined,
          subcategory_id: formData.subcategory_id || undefined,
          subvariant_id: formData.subvariant_id || undefined,
          purchase_price: purchasePrice,
          is_featured: false,
          track_inventory: true,
          low_stock_threshold: 0,
          price_per_day: pricePerDay,
          quantity: totalQuantity,
          available_quantity: totalQuantity,
          is_active: formData.is_active,
          sku: formData.sku || undefined,
          barcode: formData.barcode || undefined,
          description: formData.description || undefined,
          branch_id: isMainBranchContext ? undefined : activeBranchId,
          branch_inventory: branchInventoryPayload,
        };

        if (isEdit && product) {
          await updateProduct({ id: product.id, data: basePayload as any });
        } else {
          await createProduct(basePayload as any);
        }

        if (continueAdding && !isEdit) {
          // Reset form for next product
          setFormData(emptyFormData());
          setBranchStocks(Object.keys(branchStocks).reduce((acc, key) => ({ ...acc, [key]: 0 }), {}));
          setGlobalStock(0);
          setImageUrls([]);
          setSlugManuallyEdited(false);
          window.scrollTo({ top: 0, behavior: "smooth" });
        } else {
          router.push("/dashboard/products");
        }
      } catch (err) {
        const message =
          err instanceof Error ? err.message : "An unexpected error occurred";
        console.error("Error saving product:", err);
        showError(message);
      } finally {
        setLoading(false);
      }
    },
     
    [
      formData,
      imageUrls,
      isEdit,
      product,
      selectedBranchId,
      branchStocks,
      isMainBranchContext,
      user,
      barcodeError,
      createProduct,
      updateProduct,
      router,
      showError,
      globalStock,
      activeBranchId,
      branches,
    ]
  );

  // ── Render ─────────────────────────────────────────────────────────
  return (
    <div className="space-y-6">
      {/* Page header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <Button
            variant="outline"
            size="icon"
            onClick={() => router.push("/dashboard/products")}
            className="w-9 h-9 border-slate-200 text-slate-500 hover:text-slate-900 bg-white"
          >
            <ArrowLeft className="h-4 w-4" />
          </Button>
          <div>
            <h1 className="text-xl font-bold tracking-tight text-slate-900">
              {isEdit ? "Edit Product" : "Add Product"}
            </h1>
            <p className="text-sm text-slate-500">
              {isEdit
                ? "Update details and stock"
                : "Fill in the essentials — you can always edit later"}
            </p>
          </div>
        </div>
      </div>

      {/* Error banner */}
      {error && (
        <div className="p-3 bg-red-50 border border-red-200 rounded-lg flex items-center gap-3">
          <AlertCircle className="w-4 h-4 text-red-600 shrink-0" />
          <p className="text-sm font-medium text-red-800">{error}</p>
        </div>
      )}

      {/* ═══ Two-column layout ═══ */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* ── LEFT COLUMN (2/3) ────────────────────────────────────── */}
        <div className="lg:col-span-2 space-y-6">
          {/* Product Name */}
          <div className="bg-white border border-slate-200 rounded-lg p-5 space-y-4">
            <div className="space-y-1.5">
              <label className="text-sm font-medium text-slate-700">
                Product Name <span className="text-red-500">*</span>
              </label>
              <Input
                value={formData.name}
                onChange={(e) => {
                  const newName = e.target.value;
                  setFormData((prev) => ({
                    ...prev,
                    name: newName,
                    slug: slugManuallyEdited
                      ? prev.slug
                      : generateSlug(newName),
                  }));
                }}
                required
                placeholder="e.g., Diamond Necklace Set"
                className="h-11 border-slate-200 focus:border-slate-900 text-base"
                autoFocus
              />
            </div>

            <div className="space-y-1.5">
              <label className="text-sm font-medium text-slate-700">
                Description
              </label>
              <textarea
                value={formData.description}
                onChange={(e) =>
                  setFormData({ ...formData, description: e.target.value })
                }
                placeholder="Materials, occasion, style details... (optional)"
                rows={3}
                className="w-full rounded-lg border border-slate-200 bg-white px-3 py-2.5 text-sm focus:border-slate-900 focus:ring-1 focus:ring-slate-900 outline-none resize-y"
              />
            </div>
          </div>

          {/* Media */}
          <div className="bg-white border border-slate-200 rounded-lg p-5 space-y-3">
            <h3 className="text-sm font-semibold text-slate-900">Images</h3>
            <FileUpload
              accept="image/*"
              multiple={true}
              maxFiles={MAX_IMAGES}
              maxSize={20 * 1024 * 1024}
              folder="products"
              value={imageUrls}
              onChange={setImageUrls}
              helperText={`Drag & drop up to ${MAX_IMAGES} images. First image = primary.`}
            />
          </div>

          {/* Rent Price + Purchase Price — side by side */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {/* Rent Price */}
            <div className="bg-white border border-slate-200 rounded-lg p-5 space-y-3">
              <h3 className="text-sm font-semibold text-slate-900">
                Rent Price <span className="text-red-500">*</span>
              </h3>
              <div className="relative">
                <span className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-500 font-semibold text-base">
                  ₹
                </span>
                <Input
                  type="number"
                  value={formData.price_per_day}
                  onChange={(e) =>
                    setFormData({
                      ...formData,
                      price_per_day: e.target.value,
                    })
                  }
                  required
                  placeholder="0"
                  className="h-12 pl-8 border-slate-200 focus:border-slate-900 font-bold text-xl"
                />
              </div>
              <p className="text-xs text-slate-400">
                Same price across all branches
              </p>
            </div>

            {/* Purchase Price */}
            <div className="bg-white border border-slate-200 rounded-lg p-5 space-y-3">
              <h3 className="text-sm font-semibold text-slate-900">
                Purchase Price
              </h3>
              <div className="relative">
                <span className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-500 font-semibold text-base">
                  ₹
                </span>
                <Input
                  type="number"
                  value={formData.purchase_price}
                  onChange={(e) =>
                    setFormData({
                      ...formData,
                      purchase_price: e.target.value,
                    })
                  }
                  placeholder="0"
                  className="h-12 pl-8 border-slate-200 focus:border-slate-900 font-bold text-xl"
                />
              </div>
              <p className="text-xs text-slate-400">
                Original cost — used for ROI calculation
              </p>
            </div>

            {/* Categories */}
            <div className="bg-white border border-slate-200 rounded-lg p-5 space-y-3">
              <h3 className="text-sm font-semibold text-slate-900">
                Category <span className="text-red-500">*</span>
              </h3>
              <select
                value={formData.category_id}
                onChange={(e) => handleMainCategoryChange(e.target.value)}
                required
                className="w-full h-10 px-3 rounded-lg border border-slate-200 bg-white text-sm focus:border-slate-900 focus:ring-1 focus:ring-slate-900 outline-none"
              >
                <option value="">Select category</option>
                {mains.map((c) => (
                  <option key={c.id} value={c.id}>
                    {c.name}
                  </option>
                ))}
              </select>
              {subs.length > 0 && (
                <select
                  value={formData.subcategory_id}
                  onChange={(e) => handleSubCategoryChange(e.target.value)}
                  className="w-full h-10 px-3 rounded-lg border border-slate-200 bg-white text-sm focus:border-slate-900 focus:ring-1 focus:ring-slate-900 outline-none"
                >
                  <option value="">Select subcategory</option>
                  {subs.map((s) => (
                    <option key={s.id} value={s.id}>
                      {s.name}
                    </option>
                  ))}
                </select>
              )}
              {variants.length > 0 && (
                <select
                  value={formData.subvariant_id}
                  onChange={(e) =>
                    setFormData({ ...formData, subvariant_id: e.target.value })
                  }
                  className="w-full h-10 px-3 rounded-lg border border-slate-200 bg-white text-sm focus:border-slate-900 focus:ring-1 focus:ring-slate-900 outline-none"
                >
                  <option value="">Select variant</option>
                  {variants.map((v) => (
                    <option key={v.id} value={v.id}>
                      {v.name}
                    </option>
                  ))}
                </select>
              )}

              {/* GST Inherited from Category */}
              {inheritedGst && (
                <div className="flex items-center gap-2 p-2.5 bg-blue-50 border border-blue-200 rounded-lg mt-2">
                  <Info className="w-3.5 h-3.5 text-blue-500 shrink-0" />
                  <p className="text-xs text-blue-700 font-medium">
                    GST Rate: <span className="font-bold">{inheritedGst.percentage}%</span>{" "}
                    <span className="text-blue-500">(from {inheritedGst.categoryName})</span>
                  </p>
                </div>
              )}
            </div>

            {/* Stock Quantity Section */}
            <div className="bg-white border border-slate-200 rounded-lg p-5 space-y-4">
              <h3 className="text-sm font-semibold text-slate-900 flex items-center gap-2">
                <Package className="w-4 h-4 text-slate-400" />
                Stock Quantity <span className="text-red-500">*</span>
              </h3>

              {isMainBranchContext ? (
                <div className="space-y-4">
                  {/* Global Stock Distributor */}
                  <div className="space-y-1.5">
                    <Input
                      type="number"
                      min={0}
                      value={globalStock}
                      onChange={(e) => handleGlobalStockChange(e.target.value)}
                      onFocus={() => {
                        if (globalStock === 0) setGlobalStock("");
                      }}
                      onBlur={() => {
                        if (globalStock === "") setGlobalStock(0);
                      }}
                      placeholder="0"
                      className="h-12 border-slate-200 focus:border-slate-900 font-bold text-xl text-center"
                    />
                    <p className="text-xs text-slate-400 text-center">
                      Type stock here to apply to all branches below, or edit branch stock individually.
                    </p>
                  </div>

                  <div className="border border-slate-100 rounded-lg divide-y divide-slate-100 mt-2">
                    {branches.map((branch) => (
                      <div key={branch.id} className="flex items-center justify-between p-3 hover:bg-slate-50/50 transition-colors">
                        <div className="space-y-0.5">
                          <span className="text-sm font-medium text-slate-700">{branch.name}</span>
                          {branch.is_main && (
                            <span className="ml-2 text-[9px] font-bold uppercase text-violet-500 bg-violet-50 px-1 py-0.5 rounded">
                              Main
                            </span>
                          )}
                        </div>
                        <div className="w-28">
                          <Input
                            type="number"
                            min={0}
                            value={branchStocks[branch.id] ?? ""}
                            onChange={(e) => {
                              const val = e.target.value;
                              const qty = val === "" ? "" : parseInt(val, 10);
                              setBranchStocks((prev) => ({
                                ...prev,
                                [branch.id]: isNaN(qty as any) ? 0 : (qty as number),
                              }));
                            }}
                            onFocus={() => {
                              if (branchStocks[branch.id] === 0) {
                                setBranchStocks((prev) => ({
                                  ...prev,
                                  [branch.id]: "" as any,
                                }));
                              }
                            }}
                            onBlur={() => {
                              if (branchStocks[branch.id] === ("" as any)) {
                                setBranchStocks((prev) => ({
                                  ...prev,
                                  [branch.id]: 0,
                                }));
                              }
                            }}
                            className="h-9 text-right font-semibold border-slate-200 focus:border-slate-900"
                            placeholder="0"
                          />
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              ) : (
                <div className="space-y-2">
                  <Input
                    type="number"
                    min={0}
                    value={activeBranchId ? (branchStocks[activeBranchId] ?? "") : ""}
                    onChange={(e) => {
                      const val = e.target.value;
                      const qty = val === "" ? "" : parseInt(val, 10);
                      if (activeBranchId) {
                        setBranchStocks((prev) => ({
                          ...prev,
                          [activeBranchId]: isNaN(qty as any) ? 0 : (qty as number),
                        }));
                      }
                    }}
                    onFocus={() => {
                      if (activeBranchId && branchStocks[activeBranchId] === 0) {
                        setBranchStocks((prev) => ({
                          ...prev,
                          [activeBranchId]: "" as any,
                        }));
                      }
                    }}
                    onBlur={() => {
                      if (activeBranchId && branchStocks[activeBranchId] === ("" as any)) {
                        setBranchStocks((prev) => ({
                          ...prev,
                          [activeBranchId]: 0,
                        }));
                      }
                    }}
                    required
                    placeholder="0"
                    className="h-12 border-slate-200 focus:border-slate-900 font-bold text-xl text-center"
                  />
                  <p className="text-xs text-slate-400">
                    Stock quantity for the active branch ({activeBranch?.name || ''})
                  </p>
                </div>
              )}
            </div>
          </div>
        </div>

        {/* ── RIGHT COLUMN (1/3) ───────────────────────────────────── */}
        <div className="space-y-6">
          {/* Status Toggle */}
          <div className="bg-white border border-slate-200 rounded-lg p-5">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-semibold text-slate-900">
                  Active Listing
                </p>
                <p className="text-xs text-slate-500 mt-0.5">
                  Visible in storefront
                </p>
              </div>
              <Switch
                checked={formData.is_active}
                onCheckedChange={(checked) =>
                  setFormData({ ...formData, is_active: checked })
                }
              />
            </div>
          </div>

          {/* Identifiers: SKU + Barcode */}
          <div className="bg-white border border-slate-200 rounded-lg p-5 space-y-4">
            <h3 className="text-sm font-semibold text-slate-900">
              Identifiers
            </h3>
            <div className="space-y-1.5">
              <label className="text-xs font-medium text-slate-500 uppercase tracking-wider flex items-center gap-1">
                SKU <span className="text-red-500">*</span>
              </label>
              <div className="flex gap-1.5">
                <Input
                  value={formData.sku}
                  onChange={(e) =>
                    setFormData({ ...formData, sku: e.target.value })
                  }
                  placeholder="e.g., PB-NK-001"
                  className="h-9 border-slate-200 focus:border-slate-900 font-mono text-xs flex-1"
                />
                <Button
                  type="button"
                  variant="outline"
                  size="icon"
                  onClick={generateSKU}
                  className="h-9 w-9 border-slate-200 text-slate-500 hover:text-slate-900 shrink-0"
                  title="Auto-generate SKU"
                >
                  <Wand2 className="w-3.5 h-3.5" />
                </Button>
              </div>
            </div>
            <div className="space-y-1.5">
              <label className="text-xs font-medium text-slate-500 uppercase tracking-wider flex items-center gap-1">
                Barcode <span className="text-red-500">*</span>
              </label>
              <div className="flex gap-1.5">
                <Input
                  value={formData.barcode}
                  onChange={(e) => {
                    const val = e.target.value;
                    setFormData({ ...formData, barcode: val });
                    checkBarcodeUniqueness(val);
                  }}
                  className={`h-9 border-slate-200 focus:border-slate-900 font-mono text-xs flex-1 ${barcodeError ? 'border-red-400 focus:border-red-500' : ''}`}
                  placeholder="Auto-generated"
                />
                <Button
                  type="button"
                  variant="outline"
                  size="icon"
                  onClick={generateBarcode}
                  className="h-9 w-9 border-slate-200 text-slate-500 hover:text-slate-900 shrink-0"
                  title="Auto-generate Barcode"
                >
                  <RefreshCw className="w-3.5 h-3.5" />
                </Button>
              </div>
              {barcodeError && (
                <p className="text-xs text-red-600 font-medium mt-1 flex items-center gap-1">
                  <AlertCircle className="w-3 h-3" />
                  {barcodeError}
                </p>
              )}
              {isCheckingBarcode && (
                <p className="text-xs text-slate-400 mt-1">Checking availability...</p>
              )}
            </div>
            {/* URL Slug (collapsed, auto-generated) */}
            <div className="space-y-1.5">
              <label className="text-xs font-medium text-slate-500 uppercase tracking-wider flex items-center gap-1">
                URL Slug <span className="text-red-500">*</span>
              </label>
              <Input
                value={formData.slug}
                onChange={(e) => {
                  setFormData((prev) => ({ ...prev, slug: e.target.value }));
                  setSlugManuallyEdited(e.target.value.length > 0);
                }}
                placeholder="auto-generated"
                className="h-9 border-slate-200 focus:border-slate-900 font-mono text-xs"
              />
            </div>
          </div>
        </div>
      </div>

      {/* ═══ Sticky Action Bar ═══ */}
      <div className="sticky bottom-0 z-10 -mx-8 px-8 py-4 bg-white/95 backdrop-blur-sm border-t border-slate-200">
        <div className="flex items-center justify-between max-w-6xl mx-auto">
          <Button
            type="button"
            variant="outline"
            onClick={() => router.push("/dashboard/products")}
            className="h-10 border-slate-200 text-slate-600 hover:text-slate-900"
          >
            Cancel
          </Button>
          <div className="flex items-center gap-3">
            {!isEdit && (
              <Button
                type="button"
                variant="outline"
                disabled={loading || !isFormReady}
                onClick={() => handleSubmit(true)}
                className="h-10 border-slate-200 text-slate-700 hover:bg-slate-50"
              >
                {loading ? "Saving..." : !isFormReady ? "Loading..." : "Save & Add Another"}
              </Button>
            )}
            <Button
              type="button"
              disabled={loading || !isFormReady}
              onClick={() => handleSubmit(false)}
              className="h-10 px-6 bg-slate-900 text-white hover:bg-slate-800 font-semibold"
            >
              {loading
                ? "Saving..."
                : !isFormReady
                ? "Loading..."
                : isEdit
                ? "Save Changes"
                : "Create Product"}
            </Button>
          </div>
        </div>
      </div>
    </div>
  );
}
