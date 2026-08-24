"use client";

import { useRouter, useSearchParams } from "next/navigation";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";

export function DashboardLocalFilter({ 
  paramName, 
  options, 
  defaultValue,
  placeholder = "Select..."
}: { 
  paramName: string, 
  options: { label: string, value: string }[],
  defaultValue: string,
  placeholder?: string
}) {
  const router = useRouter();
  const searchParams = useSearchParams();
  const currentValue = searchParams.get(paramName) || defaultValue;

  const handleChange = (value: string) => {
    const params = new URLSearchParams(searchParams.toString());
    params.set(paramName, value);
    router.push(`?${params.toString()}`, { scroll: false });
  };

  return (
    <Select value={currentValue} onValueChange={handleChange}>
      <SelectTrigger className="h-7 w-auto bg-transparent text-[10px] font-bold uppercase tracking-wider border-0 shadow-none hover:bg-slate-100/50 focus:ring-0 px-2 gap-1">
        <SelectValue placeholder={placeholder} />
      </SelectTrigger>
      <SelectContent>
        {options.map(opt => (
          <SelectItem key={opt.value} value={opt.value} className="text-[10px]">
            {opt.label}
          </SelectItem>
        ))}
      </SelectContent>
    </Select>
  );
}
