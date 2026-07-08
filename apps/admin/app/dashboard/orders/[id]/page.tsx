import { Metadata } from "next";
import OrderDetailsView from "@/components/admin/OrderDetailsView";
import { BRAND_CONFIG } from "shared-utils";

export const metadata: Metadata = {
  title: `Order Details | ${BRAND_CONFIG.name}`,
  description: "View and process returns for order",
};

export default async function OrderDetailsPage({ params }: { params: Promise<{ id: string }> }) {
  const resolvedParams = await params;
  
  return (
    <div className="space-y-6">
      <OrderDetailsView orderId={resolvedParams.id} />
    </div>
  );
}
