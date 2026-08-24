import { Suspense } from "react";
import BranchSwitcher from "./BranchSwitcher";

export default function TopBar() {
  return (
    <div className="h-14 border-b border-slate-200 bg-white flex items-center justify-end px-6 shrink-0">
      <Suspense fallback={<div className="h-9 w-32 bg-slate-100 animate-pulse rounded-lg" />}>
        <BranchSwitcher />
      </Suspense>
    </div>
  );
}
