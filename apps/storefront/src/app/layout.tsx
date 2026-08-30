import type { Metadata } from 'next';
import { Cormorant_Garamond, DM_Sans } from 'next/font/google';
import './globals.css';
import { cn } from '@/lib/utils';
import { BRAND_CONFIG } from 'shared-utils';

const cormorant = Cormorant_Garamond({
  variable: '--font-cormorant',
  subsets: ['latin'],
  weight: ['300', '400', '500', '600', '700'],
  display: 'swap',
});

const dmSans = DM_Sans({
  variable: '--font-dm-sans',
  subsets: ['latin'],
  weight: ['300', '400', '500', '600', '700'],
  display: 'swap',
});

export const metadata: Metadata = {
  title: `${BRAND_CONFIG.name} — Premium Jewellery Rental`,
  description:
    'Luxury bridal jewellery rental for weddings, receptions, and bridal shoots across Kerala. Premium pieces, sanitized and insured.',
  keywords: [
    'bridal jewellery rental',
    'wedding jewellery',
    'Kerala jewellery rental',
    BRAND_CONFIG.name,
    'premium jewellery',
  ],
  icons: {
    icon: BRAND_CONFIG.defaultLogo,
    apple: BRAND_CONFIG.defaultLogo,
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
      className={cn('h-full antialiased', cormorant.variable, dmSans.variable)}
    >
      <body className="min-h-full flex flex-col bg-silk-gradient selection:bg-rosegold/20 selection:text-rosegold-dark">
        {children}
        <MobileBottomNav />
        <ReviewPopup />
      </body>
    </html>
  );
}
