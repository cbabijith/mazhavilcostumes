/**
 * Cleaning Queue Component
 *
 * Displays active cleaning tasks on the dashboard.
 *
 * @module components/admin/dashboard/CleaningQueue
 */

"use client";

import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { 
  useCleaningQueue, 
  useStartCleaning, 
  useCompleteCleaning 
} from "@/hooks/useCleaning";
import { CleaningStatus, CleaningPriority } from "@/domain";
import { Package, Play, CheckCircle2, Clock, Zap, AlertTriangle } from "lucide-react";
import { format } from "date-fns";

interface CleaningQueueProps {
  branchId: string;
}

export function CleaningQueue({ branchId }: CleaningQueueProps) {
  const { data: queue, isLoading } = useCleaningQueue(branchId);
  const { mutate: startCleaning, isPending: isStarting } = useStartCleaning();
  const { mutate: completeCleaning, isPending: isCompleting } = useCompleteCleaning();

  const activeItems = queue?.filter(item => item.status !== CleaningStatus.COMPLETED) || [];

  if (isLoading) {
    return (
      <Card className="border-0 shadow-sm bg-white animate-pulse">
        <div className="h-64 bg-slate-50 rounded-lg"></div>
      </Card>
    );
  }

  return (
    <Card className="border-0 shadow-sm bg-white overflow-hidden flex flex-col h-full">
      <CardHeader className="border-b border-slate-50 bg-slate-50/50 py-4 px-6">
        <div className="flex items-center justify-between">
          <div>
            <CardTitle className="text-base font-bold text-slate-900 flex items-center gap-2">
              <Package className="w-4 h-4 text-slate-400" />
              Cleaning Queue
            </CardTitle>
            <CardDescription className="text-[10px]">Items returned and needing prep</CardDescription>
          </div>
          {activeItems.length > 0 && (
            <Badge variant="secondary" className="bg-slate-100 text-slate-600 font-bold">
              {activeItems.length}
            </Badge>
          )}
        </div>
      </CardHeader>
      
      <CardContent className="p-0 flex-1 overflow-y-auto max-h-[500px]">
        {activeItems.length > 0 ? (
          <div className="divide-y divide-slate-50">
            {activeItems.map((item) => (
              <div key={item.id} className={`p-4 hover:bg-slate-50 transition-colors ${item.priority === CleaningPriority.URGENT ? 'bg-amber-50/20' : ''}`}>
                <div className="flex items-start justify-between gap-4">
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2 mb-1">
                      <h4 className="text-sm font-bold text-slate-900 truncate">
                        {item.product?.name || "Unknown Product"}
                      </h4>
                      {item.priority === CleaningPriority.URGENT && (
                        <Badge className="bg-amber-100 text-amber-700 hover:bg-amber-100 border-amber-200 text-[9px] px-1.5 h-4 gap-0.5">
                          <Zap className="w-2.5 h-2.5 fill-amber-500" />
                          URGENT
                        </Badge>
                      )}
                    </div>
                    
                    <div className="flex items-center gap-3 text-[10px] text-slate-500">
                      <span className="flex items-center gap-1">
                        <Package className="w-3 h-3" />
                        Qty: {item.quantity}
                      </span>
                      <span className="flex items-center gap-1">
                        <Clock className="w-3 h-3" />
                        {format(new Date(item.created_at), 'MMM d, h:mm a')}
                      </span>
                    </div>

                    {item.notes && (
                      <p className="mt-2 text-[10px] text-amber-700 bg-amber-50 px-2 py-1 rounded flex items-center gap-1.5 font-medium">
                        <AlertTriangle className="w-3 h-3" />
                        {item.notes}
                      </p>
                    )}
                  </div>

                  <div className="flex flex-col gap-2 shrink-0">
                    {item.status === CleaningStatus.PENDING ? (
                      <Button 
                        size="sm" 
                        variant="outline" 
                        className="h-8 text-[10px] gap-1.5 border-slate-200 hover:bg-blue-50 hover:text-blue-600 hover:border-blue-200"
                        onClick={() => startCleaning(item.id)}
                        disabled={isStarting}
                      >
                        <Play className="w-3 h-3 fill-current" />
                        Start
                      </Button>
                    ) : (
                      <Button 
                        size="sm" 
                        variant="outline" 
                        className="h-8 text-[10px] gap-1.5 bg-emerald-50 text-emerald-700 border-emerald-100 hover:bg-emerald-100"
                        onClick={() => completeCleaning(item.id)}
                        disabled={isCompleting}
                      >
                        <CheckCircle2 className="w-3 h-3" />
                        Done
                      </Button>
                    )}
                  </div>
                </div>
              </div>
            ))}
          </div>
        ) : (
          <div className="py-12 text-center">
            <div className="inline-flex items-center justify-center w-12 h-12 rounded-full bg-slate-50 mb-3">
              <CheckCircle2 className="w-6 h-6 text-slate-300" />
            </div>
            <p className="text-sm font-medium text-slate-500">Queue is empty</p>
            <p className="text-[10px] text-slate-400 mt-1">All products are prepped and ready</p>
          </div>
        )}
      </CardContent>
    </Card>
  );
}
