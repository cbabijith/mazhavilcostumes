/**
 * Invoice Service
 *
 * Service for generating PDF invoices for orders.
 * Uses @react-pdf/renderer with a declarative Tally-style component.
 *
 * @module services/invoiceService
 */

import React from 'react';
import { renderToBuffer } from '@react-pdf/renderer';
import { OrderWithRelations } from '@/domain/types/order';
import { orderRepository } from '@/repository';
import { createAdminClient } from '@/lib/supabase/server';
import { settingsService } from './settingsService';
import { paymentService } from './paymentService';
import { orderService } from './orderService';
import {
  TallyInvoicePDF,
  type TallyInvoiceProps,
  type InvoiceItem,
} from '@/components/admin/orders/TallyInvoicePDF';

export interface InvoiceData {
  order: OrderWithRelations;
  invoiceType: 'deposit' | 'final';
  invoiceNumber: string;
  invoiceDate: string;
  payments?: any[];
  settings: {
    invoicePrefix: string;
    paymentTerms: string;
    authorizedSignature: string;
  };
}

export class InvoiceService {
  /**
   * Generate invoice PDF and return as a Buffer alongside the invoice number.
   */
  async generateInvoice(orderId: string, invoiceType: 'deposit' | 'final'): Promise<{ buffer: Buffer; invoiceNumber: string }> {
    // Fetch order with relations
    const orderResult = await orderService.getOrderById(orderId);
    if (!orderResult.success || !orderResult.data) {
      throw new Error('Order not found');
    }

    const order = orderResult.data;

    // Fetch invoice settings
    const settings = await this.getInvoiceSettings();

    // Fetch payments for the order
    const paymentsResult = await paymentService.getPaymentsByOrder(orderId);
    const payments = paymentsResult.success ? paymentsResult.data || [] : [];

    // Fetch order status history to parse splits
    const historyResult = await orderRepository.getStatusHistory(orderId);
    const history = historyResult.success ? historyResult.data || [] : [];

    // Use stored invoice_number from the order record
    // Fall back to dynamic computation for legacy orders without invoice_number
    let invoiceNumber: string;
    if (order.invoice_number) {
      invoiceNumber = invoiceType === 'final'
        ? order.invoice_number
        : `${order.invoice_number}-DEPOSIT`;
    } else {
      // Legacy fallback: compute from fiscal year + count
      const orderDate = new Date(order.created_at || new Date());
      const year = orderDate.getFullYear();
      const month = orderDate.getMonth();
      let fiscalStartYear = year;
      if (month < 3) { fiscalStartYear = year - 1; }
      const startYY = String(fiscalStartYear).slice(-2);
      const endYY = String(fiscalStartYear + 1).slice(-2);
      const fiscalSuffix = `${startYY}${endYY}`;
      let sequentialNum = 1;
      const { count, error: countErr } = await createAdminClient()
        .from('orders')
        .select('id', { count: 'exact', head: true })
        .lte('created_at', order.created_at);
      if (!countErr && count !== null) { sequentialNum = count; }
      invoiceNumber = invoiceType === 'final'
        ? `MAZ-${fiscalSuffix}-${sequentialNum}`
        : `MAZ-${fiscalSuffix}-${sequentialNum}-DEPOSIT`;
    }
    const invoiceDate = new Date().toLocaleDateString('en-IN');

    // Build props for the React PDF component
    const props = this.buildInvoiceProps(order, invoiceType, invoiceNumber, invoiceDate, payments, settings, history);

    // Render the React component to a PDF buffer
    // Cast needed because renderToBuffer expects ReactElement<DocumentProps>
    // but our component wraps <Document> internally — this is safe.
    const element = React.createElement(TallyInvoicePDF, props) as any;
    const buffer = await renderToBuffer(element);

    return { buffer, invoiceNumber };
  }

  /**
   * Get invoice settings
   */
  private async getInvoiceSettings() {
    const prefixResult = await settingsService.findByKey('invoice_prefix');
    const termsResult = await settingsService.findByKey('payment_terms');
    const signatureResult = await settingsService.findByKey('authorized_signature');

    return {
      invoicePrefix: prefixResult.success && prefixResult.data ? prefixResult.data.value : 'INV-',
      paymentTerms: termsResult.success && termsResult.data ? termsResult.data.value : '',
      authorizedSignature: signatureResult.success && signatureResult.data ? signatureResult.data.value : '',
    };
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────────

  /** Format date to DD-MMM-YYYY */
  private fmtDate(dateStr: string): string {
    try {
      return new Date(dateStr).toLocaleDateString('en-IN', {
        day: '2-digit',
        month: 'short',
        year: 'numeric',
      });
    } catch {
      return dateStr;
    }
  }

  /** Get product name from the order item's joined product relation */
  private getItemProductName(item: any): string {
    if (item.product && typeof item.product === 'object') {
      return item.product.name || `Item #${item.product_id.slice(0, 8)}`;
    }
    return `Item #${item.product_id.slice(0, 8)}`;
  }

  /**
   * Map raw order data into the flat props shape that TallyInvoicePDF expects.
   */
  private buildInvoiceProps(
    order: OrderWithRelations,
    invoiceType: 'deposit' | 'final',
    invoiceNumber: string,
    invoiceDate: string,
    payments: any[],
    settings: { invoicePrefix: string; paymentTerms: string; authorizedSignature: string },
    history: any[] = [],
  ): TallyInvoiceProps {
    // Build line items
    const items: InvoiceItem[] = order.items.map((item, idx) => {
      const quantity = item.quantity || 0;
      const rate = item.price_per_day || 0;
      const lineTotal = rate * quantity;
      
      const discountTotal = (item.discount_type || 'flat') === 'percent'
        ? lineTotal * ((item.discount || 0) / 100)
        : (item.discount || 0) * quantity;

      return {
        sno: idx + 1,
        name: this.getItemProductName(item),
        quantity,
        rate,
        amount: lineTotal,
        gstRate: item.gst_percentage || 0,
        gstAmount: item.gst_amount || 0,
        discount: item.discount || 0,
        discountType: item.discount_type || 'flat',
        discountTotal,
      };
    });

    // Payment calculations
    const totalPaid = payments
      .filter((p) => p.payment_type !== 'refund')
      .reduce((sum: number, p: any) => sum + Number(p.amount || 0), 0);
    
    const advancePaid = payments
      .filter((p) => p.payment_type === 'deposit' || p.payment_type === 'advance')
      .reduce((sum: number, p: any) => sum + Number(p.amount || 0), 0);

    const balanceDue = Math.max(0, Number(order.total_amount || 0) - totalPaid);

    // Find payment mode
    const depositPayment = payments.find((p) => p.payment_type === 'deposit' || p.payment_type === 'advance');
    const paymentMode = depositPayment?.payment_mode?.toUpperCase() || undefined;

    // Granular calculations
    const itemDiscountTotal = items.reduce((sum, item) => sum + (item.discountTotal || 0), 0);
    const totalDiscount = (Number(order.discount) || 0) + itemDiscountTotal;

    // Parse discount and late fee splits from return history notes
    let returnDiscount = 0;
    let additionalLateFee = 0;

    const returnHistory = history.find((h) => 
      (h.status === 'returned' || h.status === 'flagged' || h.status === 'partial') && 
      h.notes?.includes('Discount:')
    );
    if (returnHistory && returnHistory.notes) {
      const matchDiscount = returnHistory.notes.match(/Discount:\s*([\d.]+)/);
      const matchLateFee = returnHistory.notes.match(/Late Fee:\s*([\d.]+)/);
      if (matchDiscount) returnDiscount = Number(matchDiscount[1]) || 0;
      if (matchLateFee) additionalLateFee = Number(matchLateFee[1]) || 0;
    }

    const orderDiscount = Math.max(0, (Number(order.discount) || 0) - returnDiscount);
    const initialLateFee = Math.max(0, (Number(order.late_fee) || 0) - additionalLateFee);

    // Build damage charges breakdown
    const damageChargesBreakdown = order.items
      .filter((item) => (item.damage_charges || 0) > 0)
      .map((item) => ({
        productName: this.getItemProductName(item),
        charges: Number(item.damage_charges || 0),
      }));

    // Detailed transaction ledger
    const paymentsList = payments.map((p) => ({
      id: p.id,
      payment_type: p.payment_type,
      payment_mode: p.payment_mode,
      amount: Number(p.amount || 0),
      created_at: p.created_at,
      notes: p.notes,
    }));

    return {
      companyName: order.store?.name || 'Rentocostume',
      companyAddress: order.store?.address || 'Near QRS, Karamana P.O., Thiruvananthapuram - 695002',
      companyPhone: order.store?.phone || '9446961765, 9447961765',
      companyEmail: order.store?.email,
      companyGstin: order.store?.gstin,

      invoiceNumber,
      invoiceDate,
      invoiceType,
      orderId: order.invoice_number || order.id.slice(0, 8).toUpperCase(),
      paymentMode,

      buyerName: order.customer.name,
      buyerPhone: order.customer.phone,
      buyerAltPhone: (order.customer as any).alt_phone,
      buyerEmail: order.customer.email,

      rentalStart: this.fmtDate(order.start_date),
      rentalEnd: this.fmtDate(order.end_date),
      eventDate: order.event_date ? this.fmtDate(order.event_date) : null,

      items,

      subtotal: Number(order.subtotal) || 0,
      gstAmount: Number(order.gst_amount) || 0,
      discount: totalDiscount,
      lateFee: Number(order.late_fee) || 0,
      damageCharges: Number(order.damage_charges_total) || 0,
      securityDeposit: 0,
      totalAmount: Number(order.total_amount) || 0,
      totalPaid,
      advancePaid,
      balanceDue,

      // New breakdowns
      itemDiscountsTotal: itemDiscountTotal,
      orderDiscount,
      returnDiscount,
      initialLateFee,
      additionalLateFee,
      damageChargesBreakdown,
      paymentsList,

      termsAndConditions: settings.paymentTerms || undefined,
      authorizedSignature: settings.authorizedSignature || undefined,
    };
  }
}

// Singleton instance
export const invoiceService = new InvoiceService();
