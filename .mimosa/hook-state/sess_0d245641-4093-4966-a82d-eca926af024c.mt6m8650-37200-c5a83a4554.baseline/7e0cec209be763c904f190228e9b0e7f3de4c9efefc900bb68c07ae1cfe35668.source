import { Metadata } from "next";
import OrderDetailsView from "@/components/admin/OrderDetailsView";

export const metadata: Metadata = {
  title: "Order Details | Mazhavil Dance Costumes",
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
