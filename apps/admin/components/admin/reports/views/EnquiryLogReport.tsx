"use client";

import { useState } from "react";
import { 
  PieChart, Pie, Cell, Tooltip, Legend, ResponsiveContainer 
} from "recharts";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Plus, X } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { ReportTable } from "../ReportTable";
import { CreateEnquiryDTO } from "@/domain";
import { useAppStore } from "@/stores/appStore";

interface EnquiryLogViewProps {
  data: any[];
  loading: boolean;
  error: string | null;
  sortConfig: any;
  onSort: (key: string) => void;
  formatCell: (value: any, format?: string) => any;
  onLogEnquiry: (dto: CreateEnquiryDTO) => Promise<void>;
}

export function EnquiryLogView({ 
  data, 
  loading, 
  error, 
  sortConfig, 
  onSort, 
  formatCell,
  onLogEnquiry
}: EnquiryLogViewProps) {
  const [showForm, setShowForm] = useState(false);
  const [formLoading, setFormLoading] = useState(false);
  const [formData, setFormData] = useState<CreateEnquiryDTO>({
    product_query: "",
    customer_name: "",
    customer_phone: "",
    notes: ""
  });

  const columns = [
    { header: "Date", key: "created_at", format: "date" as const },
    { header: "Customer Query", key: "product_query" },
    { header: "Customer", key: "customer_name" },
    { header: "Phone", key: "customer_phone" },
    { header: "Logged By", key: "staff_name" }, // We'll map this in the component
    { header: "Notes", key: "notes" },
  ];

  const { showSuccess, showError } = useAppStore();

  const mappedData = data.map(d => ({
    ...d,
    staff_name: d.staff?.name || "System"
  }));

  // Prepare chart data: Frequency of queries
  const chartData = data.reduce((acc: any[], curr: any) => {
    const query = curr.product_query || "General Enquiry";
    const existing = acc.find(a => a.name === query);
    if (existing) existing.value++;
    else acc.push({ name: query, value: 1 });
    return acc;
  }, []).sort((a, b) => b.value - a.value).slice(0, 8);

  const handleSubmit = async () => {
    if (!formData.product_query.trim()) {
      showError("Please enter a product query");
      return;
    }
    setFormLoading(true);
    try {
      await onLogEnquiry(formData);
      setShowForm(false);
      setFormData({ product_query: "", customer_name: "", customer_phone: "", notes: "" });
      showSuccess("Enquiry logged successfully");
    } catch (err) {
      showError("Failed to log enquiry");
    } finally {
      setFormLoading(false);
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex justify-end">
        <Button onClick={() => setShowForm(true)} className="bg-blue-600 text-white hover:bg-blue-700 gap-2">
          <Plus className="w-4 h-4" />
          Log New Enquiry
        </Button>
      </div>

      {chartData.length > 0 && (
        <Card className="shadow-sm border-slate-200 bg-white">
          <CardHeader className="py-3 px-6 border-b border-slate-100">
            <CardTitle className="text-sm font-semibold">Common Customer Enquiries</CardTitle>
          </CardHeader>
          <CardContent className="p-6 h-[350px]">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie
                  data={chartData}
                  cx="50%"
                  cy="50%"
                  innerRadius={60}
                  outerRadius={100}
                  paddingAngle={5}
                  dataKey="value"
                  nameKey="name"
                  label={({ name }) => (name || "").length > 15 ? (name || "").slice(0, 15) + '...' : (name || "")}
                >
                  {chartData.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={["#8b5cf6", "#ec4899", "#3b82f6", "#10b981", "#f59e0b"][index % 5]} />
                  ))}
                </Pie>
                <Tooltip />
                <Legend />
              </PieChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
      )}

      <ReportTable 
        columns={columns}
        data={mappedData}
        loading={loading}
        error={error}
        sortConfig={sortConfig}
        onSort={onSort}
        formatCell={formatCell}
      />

      {showForm && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4" onClick={() => setShowForm(false)}>
          <div className="bg-white rounded-2xl shadow-2xl w-full max-w-md overflow-hidden" onClick={e => e.stopPropagation()}>
            <div className="p-6 border-b border-slate-100 flex items-center justify-between">
              <h3 className="text-lg font-bold text-slate-900">Log Customer Enquiry</h3>
              <button onClick={() => setShowForm(false)} className="text-slate-400 hover:text-slate-600"><X className="w-5 h-5" /></button>
            </div>
            <div className="p-6 space-y-4">
              <div className="space-y-1.5">
                <label className="text-sm font-medium text-slate-700">What did the customer ask for? <span className="text-red-500">*</span></label>
                <Input value={formData.product_query} onChange={e => setFormData({ ...formData, product_query: e.target.value })} placeholder="e.g., Red bridal lehenga for Dec wedding" className="border-slate-200" />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-1.5">
                  <label className="text-sm font-medium text-slate-700">Customer Name</label>
                  <Input value={formData.customer_name} onChange={e => setFormData({ ...formData, customer_name: e.target.value })} placeholder="Optional" className="border-slate-200" />
                </div>
                <div className="space-y-1.5">
                  <label className="text-sm font-medium text-slate-700">Phone</label>
                  <Input value={formData.customer_phone} onChange={e => setFormData({ ...formData, customer_phone: e.target.value })} placeholder="Optional" className="border-slate-200" />
                </div>
              </div>
              <div className="space-y-1.5">
                <label className="text-sm font-medium text-slate-700">Additional Notes</label>
                <textarea 
                  value={formData.notes} 
                  onChange={e => setFormData({ ...formData, notes: e.target.value })} 
                  placeholder="Any other details..."
                  className="w-full min-h-[100px] p-3 text-sm border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-slate-900"
                />
              </div>
            </div>
            <div className="p-6 border-t border-slate-100 flex justify-end gap-3">
              <Button variant="outline" onClick={() => setShowForm(false)} className="border-slate-200">Cancel</Button>
              <Button onClick={handleSubmit} disabled={!formData.product_query.trim() || formLoading} className="bg-slate-900 text-white hover:bg-slate-800">
                {formLoading ? "Saving..." : "Log Enquiry"}
              </Button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
