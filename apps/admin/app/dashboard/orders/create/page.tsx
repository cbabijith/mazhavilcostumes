import { Metadata } from "next";
import OrderForm from "@/components/admin/OrderForm";
import { BRAND_CONFIG } from "shared-utils";

export const metadata: Metadata = {
  title: `Create Order | ${BRAND_CONFIG.name}`,
  description: "Create a new rental order",
};

export default function CreateOrderPage() {
  return <OrderForm />;
}
