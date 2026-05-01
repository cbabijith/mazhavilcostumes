import type { Metadata } from "next";
import { Cormorant_Garamond, DM_Sans } from "next/font/google";
import "./globals.css";
import { cn } from "@/lib/utils";

const cormorant = Cormorant_Garamond({
  variable: "--font-cormorant",
  subsets: ["latin"],
  weight: ["300", "400", "500", "600", "700"],
  display: "swap",
});

const dmSans = DM_Sans({
  variable: "--font-dm-sans",
  subsets: ["latin"],
  weight: ["300", "400", "500", "600", "700"],
  display: "swap",
});

export const metadata: Metadata = {
  title: "Mazhavil Costumes — Premium Costumes Rental",
  description:
    "Luxury bridal costumes rental for weddings, receptions, and bridal shoots across Kerala. Premium pieces, sanitized and insured.",
  keywords: [
    "bridal costumes rental",
    "wedding costumes",
    "Kerala costumes rental",
    "Mazhavil Costumes",
    "premium costumes",
  ],
};

import MobileBottomNav from "@/components/home/MobileBottomNav";

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html
      lang="en"
      suppressHydrationWarning
      className={cn(
        "h-full antialiased",
        cormorant.variable,
        dmSans.variable
      )}
    >
      <body className="min-h-full flex flex-col bg-silk-gradient selection:bg-rosegold/20 selection:text-rosegold-dark">
        {children}
        <MobileBottomNav />
      </body>
    </html>
  );
}
