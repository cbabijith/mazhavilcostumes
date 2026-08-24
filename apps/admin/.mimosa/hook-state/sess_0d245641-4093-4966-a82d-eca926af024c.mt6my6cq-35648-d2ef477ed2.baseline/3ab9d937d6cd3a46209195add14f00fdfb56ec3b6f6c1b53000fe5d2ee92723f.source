"use client";

import { useMemo, useCallback } from "react";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { useRouter, useSearchParams, usePathname } from "next/navigation";
import { 
  Table, 
  TableBody, 
  TableCell, 
  TableHead, 
  TableHeader, 
  TableRow 
} from "@/components/ui/table";
import { useCleaningQueue } from "@/hooks/useCleaning";
import { CleaningStatus, CleaningPriority } from "@/domain";
import { Package, Sparkles, CheckCircle2, ExternalLink, ArrowUpDown, ArrowUp, ArrowDown } from "lucide-react";
import { format, formatDistanceToNow } from "date-fns";
import Link from "next/link";

interface CleaningQueueProps {
  branchId: string;
}

export function CleaningQueue({ branchId }: CleaningQueueProps) {
  const router = useRouter();
  const searchParams = useSearchParams();
  const pathname = usePathname();

  const filter = (searchParams.get("filter") || "all") as "all" | "priority";
  const sortBy = searchParams.get("sort_by") || "expected_return_date";
  const sortOrder = searchParams.get("sort_order") || "asc";

  const { data: queue, isLoading } = useCleaningQueue(branchId, {
    sort_by: sortBy || undefined,
    sort_order: sortOrder || undefined,
  });

  const updateParams = useCallback(
    (updates: Record<string, string | null>) => {
      const params = new URLSearchParams(searchParams.toString());
      Object.entries(updates).forEach(([key, value]) => {
        if (value === null) {
          params.delete(key);
        } else {
          params.set(key, value);
        }
      });
      router.replace(`${pathname}?${params.toString()}`, { scroll: false });
    },
    [searchParams, pathname, router]
  );

  const toggleSort = (field: string) => {
    if (sortBy === field) {
      updateParams({ sort_order: sortOrder === "asc" ? "desc" : "asc" });
    } else {
      updateParams({ sort_by: field, sort_order: "asc" });
    }
  };

  const SortHeader = ({ field, label }: { field: string; label: string }) => {
    const isActive = sortBy === field;
    return (
      <TableHead 
        className="text-[11px] font-bold uppercase tracking-wider cursor-pointer hover:bg-slate-100 transition-colors group"
        onClick={() => toggleSort(field)}
      >
        <div className="flex items-center gap-1">
          {label}
          {isActive ? (
            sortOrder === "asc" ? (
              <ArrowUp className="w-3 h-3 text-blue-600" />
            ) : (
              <ArrowDown className="w-3 h-3 text-blue-600" />
            )
          ) : (
            <ArrowUpDown className="w-3 h-3 text-slate-300 group-hover:text-slate-400" />
          )}
        </div>
      </TableHead>
    );
  };

  const activeItems = useMemo(() => {
    let items = queue?.filter(item => item.status !== CleaningStatus.COMPLETED) || [];
    if (filter === 'priority') {
      items = items.filter(item => item.priority === CleaningPriority.URGENT);
    }
    return items;
  }, [queue, filter]);

  const getImageUrl = (item: any) => {
    const images = item.product?.images;
    if (!images || !Array.isArray(images) || images.length === 0) return null;
    const img = images[0];
    return typeof img === "string" ? img : img?.url || null;
  };

  if (isLoading) {
    return (
      <Card className="border-slate-200 shadow-sm bg-white">
        <div className="h-[400px] flex items-center justify-center">
          <div className="flex flex-col items-center gap-2">
            <div className="w-8 h-8 border-4 border-slate-200 border-t-blue-600 rounded-full animate-spin" />
            <p className="text-sm text-slate-500 font-medium">Loading cleaning queue...</p>
          </div>
        </div>
      </Card>
    );
  }

  return (
    <Card className="border-slate-200 shadow-sm bg-white overflow-hidden flex flex-col h-full">
      <CardHeader className="border-b border-slate-100 bg-slate-50/50 py-4 px-6">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div>
            <CardTitle className="text-lg font-bold text-slate-900 flex items-center gap-2">
              <Package className="w-5 h-5 text-slate-400" />
              Cleaning Status
            </CardTitle>
            <CardDescription className="text-xs">Products in cleaning/preparation phase</CardDescription>
          </div>
          
          <div className="flex items-center gap-1 bg-slate-100 p-1 rounded-lg border border-slate-200">
            <Button 
              variant={filter === 'all' ? 'secondary' : 'ghost'} 
              size="sm" 
              onClick={() => updateParams({ filter: 'all' })}
              className={`h-8 text-xs px-3 ${filter === 'all' ? 'bg-white shadow-sm' : 'text-slate-500 hover:text-slate-900'}`}
            >
              All Items
            </Button>
            <Button 
              variant={filter === 'priority' ? 'secondary' : 'ghost'} 
              size="sm" 
              onClick={() => updateParams({ filter: 'priority' })}
              className={`h-8 text-xs px-3 ${filter === 'priority' ? 'bg-white shadow-sm text-amber-700' : 'text-slate-500 hover:text-slate-900'}`}
            >
              <Sparkles className="w-3 h-3 mr-1.5" />
              Prior Cleaning
            </Button>
          </div>
        </div>
      </CardHeader>
      
      <CardContent className="p-0">
        {activeItems.length > 0 ? (
          <Table>
            <TableHeader className="bg-slate-50/50">
              <TableRow>
                <SortHeader field="product_name" label="Product" />
                <SortHeader field="quantity" label="Qty" />
                <SortHeader field="status" label="Status" />
                <SortHeader field="expected_return_date" label="Return / Time" />
                <SortHeader field="priority" label="Urgency" />
              </TableRow>
            </TableHeader>
            <TableBody>
              {activeItems.map((item) => {
                const imgUrl = getImageUrl(item);
                const isUrgent = item.priority === CleaningPriority.URGENT;
                
                return (
                  <TableRow key={item.id} className={isUrgent ? "bg-amber-50/30 hover:bg-amber-50/50" : ""}>
                    <TableCell>
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-lg bg-slate-100 border border-slate-200 overflow-hidden flex-shrink-0">
                          {imgUrl ? (
                            <img src={imgUrl} alt={item.product?.name} className="w-full h-full object-cover" />
                          ) : (
                            <div className="w-full h-full flex items-center justify-center text-slate-300">
                              <Package className="w-5 h-5" />
                            </div>
                          )}
                        </div>
                        <div className="min-w-0">
                          <p className="font-bold text-slate-900 truncate text-sm">
                            {item.product?.name || "Unknown"}
                          </p>
                          <div className="flex items-center gap-2 mt-0.5">
                            <Link 
                              href={`/dashboard/orders/${item.order_id}`}
                              className="text-[10px] text-slate-500 hover:text-blue-600 flex items-center gap-0.5"
                            >
                              Order #{item.order_id.substring(0, 8)}
                              <ExternalLink className="w-2.5 h-2.5" />
                            </Link>
                          </div>
                        </div>
                      </div>
                    </TableCell>
                    <TableCell>
                      <span className="font-black text-slate-700 text-sm">{item.quantity}</span>
                    </TableCell>
                    <TableCell>
                      {item.status === CleaningStatus.SCHEDULED ? (
                        <Badge variant="outline" className="bg-blue-50 text-blue-600 border-blue-200 text-[10px] font-bold px-2 py-0 h-5 shadow-none">
                          Scheduled
                        </Badge>
                      ) : item.status === CleaningStatus.IN_PROGRESS ? (
                        <Badge variant="outline" className="bg-amber-50 text-amber-600 border-amber-200 text-[10px] font-bold px-2 py-0 h-5 shadow-none">
                          In Progress
                        </Badge>
                      ) : (
                        <Badge variant="outline" className="bg-emerald-50 text-emerald-600 border-emerald-200 text-[10px] font-bold px-2 py-0 h-5 shadow-none">
                          Pending
                        </Badge>
                      )}
                    </TableCell>
                    <TableCell>
                      {item.status === CleaningStatus.SCHEDULED && item.expected_return_date ? (
                        <div className="flex flex-col">
                          <span className="text-sm font-medium text-slate-900">
                            {format(new Date(item.expected_return_date), 'MMM d, yyyy')}
                          </span>
                          <span className="text-[10px] text-slate-400 font-medium">
                            Expected return
                          </span>
                        </div>
                      ) : item.status === CleaningStatus.IN_PROGRESS && item.started_at ? (
                        <div className="flex flex-col">
                          <span className="text-sm font-medium text-slate-900">
                            {format(new Date(item.started_at), 'MMM d, h:mm a')}
                          </span>
                          <span className="text-[10px] text-slate-400 font-medium">
                            Cleaning {formatDistanceToNow(new Date(item.started_at), { addSuffix: true })}
                          </span>
                        </div>
                      ) : (
                        <div className="flex flex-col">
                          <span className="text-sm font-medium text-slate-900">{format(new Date(item.created_at), 'h:mm a')}</span>
                          <span className="text-[10px] text-slate-400 font-medium">
                            {formatDistanceToNow(new Date(item.created_at), { addSuffix: true })}
                          </span>
                        </div>
                      )}
                    </TableCell>
                    <TableCell>
                      {isUrgent ? (
                        <Badge className="bg-amber-100 text-amber-700 hover:bg-amber-100 border-amber-200 text-[10px] font-black tracking-tight px-2 py-0 h-5 gap-1 shadow-none">
                          <Sparkles className="w-3 h-3 fill-amber-500" />
                          URGENT
                        </Badge>
                      ) : (
                        <Badge variant="outline" className="text-slate-500 border-slate-200 text-[10px] font-bold px-2 py-0 h-5 shadow-none">
                          NORMAL
                        </Badge>
                      )}
                    </TableCell>
                  </TableRow>
                );
              })}
            </TableBody>
          </Table>
        ) : (
          <div className="py-20 text-center">
            <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-slate-50 mb-4">
              <CheckCircle2 className="w-8 h-8 text-slate-200" />
            </div>
            <p className="text-base font-bold text-slate-900">Queue is empty</p>
            <p className="text-sm text-slate-500 mt-1">All returned items are ready for the next rental</p>
            {filter === 'priority' && (
              <Button 
                variant="link" 
                className="mt-2 text-blue-600 text-xs"
                onClick={() => updateParams({ filter: 'all' })}
              >
                Clear priority filter
              </Button>
            )}
          </div>
        )}
      </CardContent>
    </Card>
  );
}
