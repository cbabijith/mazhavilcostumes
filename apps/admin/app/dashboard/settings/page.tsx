"use client";

import { useState, useEffect, useMemo } from "react";
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
  useUpdateSetting,
  useGstSlabs,
  useUpdateGstSlabs,
} from "@/hooks";
import { useAppStore } from "@/stores";
import { DEFAULT_GST_SLABS } from "@/domain/types/category";
import { Plus, X } from "lucide-react";

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

  // GST slabs management — admin/manager only feature
  const canManageSettings = user?.role === 'admin' || user?.role === 'super_admin' || user?.role === 'manager';
  const { data: serverSlabs, isLoading: loadingSlabs } = useGstSlabs();
  const { updateGstSlabs, isPending: updatingSlabs } = useUpdateGstSlabs();
  const slabsFromServer = useMemo(() => {
    if (Array.isArray(serverSlabs) && serverSlabs.length > 0) return serverSlabs;
    return [...DEFAULT_GST_SLABS];
  }, [serverSlabs]);

  // Local editable copy — synced when server data loads
  const [slabsDraft, setSlabsDraft] = useState<number[]>([...DEFAULT_GST_SLABS]);
  const [newSlabInput, setNewSlabInput] = useState('');
  useEffect(() => {
    if (!loadingSlabs) setSlabsDraft(slabsFromServer);
  }, [slabsFromServer, loadingSlabs]);

  const slabsDirty = useMemo(() => {
    if (slabsDraft.length !== slabsFromServer.length) return true;
    return slabsDraft.some((s, i) => s !== slabsFromServer[i]);
  }, [slabsDraft, slabsFromServer]);

  const addSlab = () => {
    const n = Number(newSlabInput);
    if (!Number.isFinite(n) || n < 0 || n > 100 || !Number.isInteger(n)) {
      showError('Invalid slab', 'Enter a whole number between 0 and 100.');
      return;
    }
    if (slabsDraft.includes(n)) {
      showError('Duplicate', `${n}% is already in the list.`);
      return;
    }
    setSlabsDraft(prev => [...prev, n].sort((a, b) => a - b));
    setNewSlabInput('');
  };
  const removeSlab = (s: number) => setSlabsDraft(prev => prev.filter(x => x !== s));
  const handleSaveSlabs = () => updateGstSlabs(slabsDraft);

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
              <div className="space-y-4">
                {/* Slabs manager — admin/manager only */}
                {canManageSettings ? (
                  <div className="bg-white border border-slate-200 rounded-lg p-4 space-y-3">
                    <div className="flex items-center justify-between">
                      <div>
                        <h3 className="text-sm font-semibold text-slate-900">GST Percentage Slabs</h3>
                        <p className="text-xs text-slate-500 mt-0.5">
                          The slabs available when assigning a GST rate to a category. Add custom values (e.g. 10%) or remove unused ones.
                        </p>
                      </div>
                    </div>

                    {/* Chip list of current slabs */}
                    <div className="flex flex-wrap gap-2">
                      {slabsDraft.map((s) => (
                        <span
                          key={s}
                          className="inline-flex items-center gap-1 pl-2.5 pr-1 py-1 rounded-full bg-slate-100 border border-slate-200 text-sm font-semibold text-slate-800"
                        >
                          {s}%
                          <button
                            type="button"
                            onClick={() => removeSlab(s)}
                            disabled={updatingSlabs || slabsDraft.length <= 1}
                            className="w-5 h-5 rounded-full hover:bg-slate-300 text-slate-500 hover:text-slate-800 flex items-center justify-center disabled:opacity-30 disabled:cursor-not-allowed"
                            title={slabsDraft.length <= 1 ? 'At least one slab is required' : `Remove ${s}%`}
                          >
                            <X className="w-3 h-3" />
                          </button>
                        </span>
                      ))}
                      {slabsDraft.length === 0 && (
                        <span className="text-xs text-slate-400 italic">No slabs — add at least one below.</span>
                      )}
                    </div>

                    {/* Add new slab */}
                    <div className="flex gap-2 items-center">
                      <div className="relative w-32">
                        <Input
                          type="number"
                          min={0}
                          max={100}
                          step={1}
                          value={newSlabInput}
                          onChange={(e) => setNewSlabInput(e.target.value)}
                          onKeyDown={(e) => { if (e.key === 'Enter') { e.preventDefault(); addSlab(); } }}
                          placeholder="e.g. 10"
                          className="pr-7 bg-slate-50 border-slate-200"
                          disabled={updatingSlabs}
                        />
                        <span className="absolute right-2.5 top-1/2 -translate-y-1/2 text-xs text-slate-400 pointer-events-none">%</span>
                      </div>
                      <Button
                        type="button"
                        variant="outline"
                        size="sm"
                        onClick={addSlab}
                        disabled={updatingSlabs || !newSlabInput.trim()}
                        className="border-slate-200 text-slate-700 hover:bg-slate-50"
                      >
                        <Plus className="w-3.5 h-3.5 mr-1" /> Add
                      </Button>
                      <Button
                        type="button"
                        size="sm"
                        onClick={handleSaveSlabs}
                        disabled={updatingSlabs || !slabsDirty || slabsDraft.length === 0}
                        className="ml-auto bg-slate-900 text-white hover:bg-slate-800"
                      >
                        {updatingSlabs ? 'Saving…' : 'Save Slabs'}
                      </Button>
                    </div>
                  </div>
                ) : (
                  <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
                    <p className="text-sm text-blue-800 font-medium">💡 GST rates are set per category</p>
                    <p className="text-xs text-blue-600 mt-1">
                      Available slabs: {slabsFromServer.map(s => `${s}%`).join(', ')}. An admin can manage these in Settings.
                    </p>
                  </div>
                )}
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
