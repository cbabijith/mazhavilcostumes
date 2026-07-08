import type { Metadata } from "next";
import "./globals.css";
import { BRAND_CONFIG } from "shared-utils";

export const metadata: Metadata = {
  title: `${BRAND_CONFIG.name} Admin`,
  description: `Admin dashboard for ${BRAND_CONFIG.name} costumes rental system`,
  icons: {
    icon: BRAND_CONFIG.defaultLogo,
    apple: BRAND_CONFIG.defaultLogo,
  },
};

import AuthProvider from "@/components/providers/AuthProvider";

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body className="antialiased">
        <AuthProvider>
          {children}
        </AuthProvider>
      </body>
    </html>
  );
}
