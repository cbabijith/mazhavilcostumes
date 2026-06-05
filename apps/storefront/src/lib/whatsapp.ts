// Shared WhatsApp ordering config for Mazhavil Costumes
export const WHATSAPP_NUMBER = "919447923234";
export const DISPLAY_PHONE = "+91 94479 23234";

export function calculateRentalPrice(
  pricePerDay: number,
  quantity: number,
  startDateStr?: string,
  endDateStr?: string
) {
  if (!startDateStr || !endDateStr) {
    return { rentalDays: 0, pricingMultiplier: 1, totalRent: pricePerDay * quantity };
  }
  const start = new Date(startDateStr + "T00:00:00");
  const end = new Date(endDateStr + "T00:00:00");
  if (isNaN(start.getTime()) || isNaN(end.getTime())) {
    return { rentalDays: 0, pricingMultiplier: 1, totalRent: pricePerDay * quantity };
  }
  const diffTime = Math.abs(end.getTime() - start.getTime());
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
  const rentalDays = Math.max(1, diffDays + 1);
  const pricingMultiplier = Math.max(1, rentalDays - 2);
  return {
    rentalDays,
    pricingMultiplier,
    totalRent: pricePerDay * quantity * pricingMultiplier,
  };
}

interface OrderDetails {
  productName: string;
  price: number;
  categoryName?: string | null;
  quantity: number;
  customerName: string;
  customerPhone: string;
  customerAddress: string;
  startDate: string;
  endDate: string;
  rentalDays?: number;
  totalRent?: number;
}

export function buildOrderMessage(o: OrderDetails): string {
  const today = new Date().toLocaleDateString("en-IN", {
    day: "2-digit",
    month: "long",
    year: "numeric",
  });

  const lines = [
    "Hello Mazhavil Costumes! 👋",
    "",
    "*New Rental Enquiry*",
    "",
    `📦 *Product:* ${o.productName}`,
  ];

  if (o.categoryName) lines.push(`🏷️ *Category:* ${o.categoryName}`);
  lines.push(`💰 *Rental Price:* ₹${o.price.toLocaleString("en-IN")}/day`);
  lines.push(`🔢 *Quantity:* ${o.quantity}`);
  lines.push("");
  lines.push(`🗓️ *Rental Start Date:* ${o.startDate}`);
  lines.push(`⏳ *Rental End Date:* ${o.endDate}`);
  if (o.rentalDays) {
    lines.push(`⏱️ *Duration:* ${o.rentalDays} days`);
  }
  if (o.totalRent) {
    lines.push(`💵 *Total Estimated Rent:* ₹${o.totalRent.toLocaleString("en-IN")}`);
  } else {
    lines.push(`💰 *Rental Price for Event:* ₹${o.price.toLocaleString("en-IN")}`);
  }
  lines.push(`📅 *Enquiry Date:* ${today}`);
  lines.push("");
  lines.push("👤 *Customer Details:*");
  lines.push(`Name: ${o.customerName}`);
  lines.push(`Phone: ${o.customerPhone}`);
  lines.push(`📍 Address: ${o.customerAddress}`);
  lines.push("");
  lines.push("Please confirm availability. Thank you! 🙏");

  return lines.join("\n");
}

export function buildWhatsAppUrl(message: string): string {
  return `https://wa.me/${WHATSAPP_NUMBER}?text=${encodeURIComponent(message)}`;
}

// Wishlist message builder
interface WishlistItem {
  name: string;
  price: number;
  startDate?: string;
  endDate?: string;
  rentalDays?: number;
  totalRent?: number;
}

export function buildWishlistMessage(items: WishlistItem[]): string {
  const lines = [
    "Hello Mazhavil Costumes! 👋",
    "",
    "*Wishlist Enquiry*",
    "",
  ];

  if (items.length === 0) {
    lines.push("I'm interested in browsing your collections.");
  } else {
    lines.push("I'm interested in these items for my event:");
    items.forEach((item, index) => {
      lines.push(`${index + 1}. ${item.name}`);
      lines.push(`   💰 Rental: ₹${item.price.toLocaleString("en-IN")}/day`);
      if (item.startDate && item.endDate) {
        if (item.rentalDays && item.totalRent) {
          lines.push(`   🗓️ Dates: ${item.startDate} to ${item.endDate} (${item.rentalDays} days)`);
          lines.push(`   💵 *Estimated Rent:* ₹${item.totalRent.toLocaleString("en-IN")}`);
        } else {
          lines.push(`   🗓️ Dates: ${item.startDate} to ${item.endDate}`);
        }
      }
    });
  }

  lines.push("");
  lines.push("Please check availability. Thank you! 🙏");

  return lines.join("\n");
}

// Cart message builder
interface CartItem extends WishlistItem {
  startDate: string;
  endDate: string;
}

export function buildCartMessage(items: CartItem[]): string {
  const lines = [
    "Hello Mazhavil Costumes! 👋",
    "",
    "*Booking Enquiry*",
    "",
  ];

  if (items.length === 0) {
    lines.push("I'd like to book some items for my event.");
  } else {
    items.forEach((item, index) => {
      lines.push(`${index + 1}. ${item.name}`);
      lines.push(`   Rental: ₹${item.price}/day`);
      lines.push(`   Dates: ${item.startDate} to ${item.endDate}`);
    });
  }

  lines.push("");
  lines.push("Please confirm availability and total cost. Thank you! 🙏");

  return lines.join("\n");
}

// Contact message builder
export function buildContactMessage(name: string, phone: string, message: string): string {
  const lines = [
    "Hello Mazhavil Costumes! 👋",
    "",
    "*New Enquiry*",
    "",
    `👤 *Name:* ${name}`,
    `📱 *Phone:* ${phone}`,
    "",
    `💬 *Message:*`,
    message,
    "",
    "Please get back to me. Thank you! 🙏",
  ];

  return lines.join("\n");
}

// Checkout message builder
interface CheckoutDetails {
  items: CartItem[];
  customerName: string;
  customerPhone: string;
  eventDate: string;
}

export function buildCheckoutMessage(details: CheckoutDetails): string {
  const lines = [
    "Hello Mazhavil Costumes! 👋",
    "",
    "*New Booking Request*",
    "",
  ];

  details.items.forEach((item, index) => {
    lines.push(`${index + 1}. ${item.name}`);
    lines.push(`   Rental: ₹${item.price}/day`);
    lines.push(`   Dates: ${item.startDate} to ${item.endDate}`);
  });

  lines.push("");
  lines.push(`📅 *Event Date:* ${details.eventDate}`);
  lines.push("");
  lines.push("👤 *Customer Details:*");
  lines.push(`Name: ${details.customerName}`);
  lines.push(`Phone: ${details.customerPhone}`);
  lines.push("");
  lines.push("Please confirm availability and final amount. Thank you! 🙏");

  return lines.join("\n");
}
