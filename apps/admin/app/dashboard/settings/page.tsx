"use client";

import { useState, useEffect } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Textarea } from "@/components/ui/textarea";
import { 
  useIsGSTEnabled,
  useUpdateIsGSTEnabled,
  useInvoicePrefix,
  usePaymentTerms,
  useAuthorizedSignature,
  useUpdateSetting
} from "@/hooks";
import { useAppStore } from "@/stores";

export default function SettingsPage() {
  const { data: isGstEnabledResult, isLoading: loadingGstEnabled } = useIsGSTEnabled();
  const { updateIsGSTEnabled, isLoading: updatingGstEnabled } = useUpdateIsGSTEnabled();
  
  const { updateSetting, isLoading: updatingSettings } = useUpdateSetting();
  const { showSuccess, showError, user } = useAppStore();
  
  // Invoice settings hooks
  const { data: invoicePrefixResult, isLoading: loadingPrefix } = useInvoicePrefix();
  const { data: paymentTermsResult, isLoading: loadingTerms } = usePaymentTerms();
  const { data: signatureResult, isLoading: loadingSig } = useAuthorizedSignature();
  
  // Derive GST enabled from query result
  const isGstEnabled = (isGstEnabledResult?.success && isGstEnabledResult.data !== null) ? isGstEnabledResult.data : false;
  
  // Invoice settings state
  const [invoicePrefix, setInvoicePrefix] = useState('INV-');
  const [paymentTerms, setPaymentTerms] = useState('');
  const [authorizedSignature, setAuthorizedSignature] = useState('');

  // Sync invoice hooks with state when data loads
  useEffect(() => {
    if (invoicePrefixResult?.success && invoicePrefixResult.data) setInvoicePrefix(invoicePrefixResult.data.value);
    if (paymentTermsResult?.success && paymentTermsResult.data) setPaymentTerms(paymentTermsResult.data.value);
    if (signatureResult?.success && signatureResult.data) setAuthorizedSignature(signatureResult.data.value);
  }, [invoicePrefixResult, paymentTermsResult, signatureResult]);

  const handleSaveInvoiceSettings = async () => {
    try {
      await Promise.all([
        updateSetting({ key: 'invoice_prefix', value: invoicePrefix }),
        updateSetting({ key: 'payment_terms', value: paymentTerms }),
        updateSetting({ key: 'authorized_signature', value: authorizedSignature }),
      ]);
      showSuccess("Invoice settings saved successfully");
    } catch (err) {
      // updateSetting hook will handle showing the error toast
    }
  };

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-3xl font-bold text-slate-900">Settings</h1>
        <p className="text-slate-500 mt-1">Manage your account and preferences</p>
      </div>

      {/* GST Configuration */}
      <Card className="border-0 shadow-lg">
        <CardHeader className="border-b border-slate-100">
          <CardTitle className="text-xl text-slate-900">GST Configuration</CardTitle>
        </CardHeader>
        <CardContent className="pt-6">
          <div className="space-y-6">
            <div className="flex items-center justify-between bg-slate-50 p-4 rounded-lg border border-slate-200">
              <div>
                <h3 className="text-sm font-semibold text-slate-900">Enable GST Calculation</h3>
                <p className="text-xs text-slate-500 mt-0.5">When enabled, GST will be applied to all new orders based on category GST rates (5%, 12%, or 18%).</p>
              </div>
              <label className="relative inline-flex items-center cursor-pointer">
                <input
                  type="checkbox"
                  checked={isGstEnabled}
                  onChange={(e) => updateIsGSTEnabled(e.target.checked)}
                  disabled={loadingGstEnabled || updatingGstEnabled}
                  className="sr-only peer"
                />
                <div className={`w-11 h-6 rounded-full transition-colors ${updatingGstEnabled ? 'bg-slate-300 animate-pulse' : 'bg-slate-200'} peer-checked:bg-slate-900 peer-focus:ring-2 peer-focus:ring-slate-900/20`}></div>
                <div className={`absolute left-0.5 top-0.5 w-5 h-5 bg-white rounded-full transition-transform ${isGstEnabled ? 'translate-x-5' : 'translate-x-0'}`}></div>
              </label>
            </div>

            {isGstEnabled && (
              <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
                <p className="text-sm text-blue-800 font-medium">💡 GST rates are set per category</p>
                <p className="text-xs text-blue-600 mt-1">
                  Each category has its own GST rate (5%, 12%, or 18%). Products inherit the GST rate from their category. 
                  You can configure GST rates in the Category management section.
                </p>
              </div>
            )}
          </div>
        </CardContent>
      </Card>

      {/* Invoice Settings */}
      <Card className="border-0 shadow-lg">
        <CardHeader className="border-b border-slate-100">
          <CardTitle className="text-xl text-slate-900">Invoice Settings</CardTitle>
        </CardHeader>
        <CardContent className="pt-6">
          <div className="space-y-6">
            <div className="space-y-2">
              <label className="text-sm font-semibold text-slate-700">Invoice Prefix</label>
              <Input
                type="text"
                value={invoicePrefix}
                onChange={(e) => setInvoicePrefix(e.target.value)}
                className="bg-slate-50 border-slate-200 focus:border-primary max-w-xs"
                placeholder="INV-"
              />
              <p className="text-xs text-slate-500 mt-1">
                Prefix for invoice numbers (e.g., INV-001)
              </p>
            </div>

            <div className="space-y-2">
              <label className="text-sm font-semibold text-slate-700">Payment Terms</label>
              <Textarea
                value={paymentTerms}
                onChange={(e) => setPaymentTerms(e.target.value)}
                className="bg-slate-50 border-slate-200 focus:border-primary min-h-[100px]"
                placeholder="Payment must be made before or at the time of delivery..."
              />
            </div>

            <div className="space-y-2">
              <label className="text-sm font-semibold text-slate-700">Authorized Signature</label>
              <Input
                type="text"
                value={authorizedSignature}
                onChange={(e) => setAuthorizedSignature(e.target.value)}
                className="bg-slate-50 border-slate-200 focus:border-primary"
                placeholder="Authorized Signatory"
              />
            </div>

            <Button 
              onClick={handleSaveInvoiceSettings}
              disabled={updatingSettings || loadingPrefix || loadingTerms || loadingSig}
              className="shadow-lg shadow-primary/25 bg-slate-900 text-white hover:bg-slate-800"
            >
              {updatingSettings ? "Saving..." : "Save Invoice Settings"}
            </Button>
          </div>
        </CardContent>
      </Card>

      {/* Account Settings */}
      <Card className="border-0 shadow-lg">
        <CardHeader className="border-b border-slate-100">
          <CardTitle className="text-xl text-slate-900">Account Settings</CardTitle>
        </CardHeader>
        <CardContent className="pt-6">
          <div className="space-y-6">
            <div className="space-y-2">
              <label className="text-sm font-semibold text-slate-700">Name</label>
              <Input
                type="text"
                value={user?.name || 'Unknown'}
                disabled
                className="bg-slate-50 border-slate-200 focus:border-primary opacity-60"
              />
            </div>
            <div className="space-y-2">
              <label className="text-sm font-semibold text-slate-700">Email</label>
              <Input
                type="email"
                value={user?.email || 'Not available'}
                disabled
                className="bg-slate-50 border-slate-200 focus:border-primary opacity-60"
              />
            </div>
            <div className="space-y-2">
              <label className="text-sm font-semibold text-slate-700">Role</label>
              <Input
                type="text"
                value={user?.role ? user.role.charAt(0).toUpperCase() + user.role.slice(1) : 'Unknown'}
                disabled
                className="bg-slate-50 border-slate-200 focus:border-primary opacity-60"
              />
            </div>
            <p className="text-xs text-slate-500 mt-2">
              Account settings are managed by the administrator.
            </p>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
