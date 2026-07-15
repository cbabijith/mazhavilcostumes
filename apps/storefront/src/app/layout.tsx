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
  title: "Mazhavil Dance Costumes — Premium Dance Costumes Rental",
  description:
    "Premium dance costumes rental for classical, folk, cinematic, and school/college festival performances across Kerala. Insured and sanitized outfits.",
  keywords: [
    "dance costumes rental",
    "classical dance costumes",
    "folk dance costumes",
    "Kerala dance costumes",
    "Mazhavil Dance Costumes",
    "school youth festival costumes",
    "premium costumes rental",
  ],
  icons: {
    icon: "/logo_mazhavil.jpeg",
    apple: "/logo_mazhavil.jpeg",
  },
};

import MobileBottomNav from "@/components/home/MobileBottomNav";
import ReviewPopup from "@/components/home/ReviewPopup";

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
        <ReviewPopup />
      </body>
    </html>
  );
}
