import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Rentocostume Admin",
  description: "Admin dashboard for Rentocostume costumes rental system",
  icons: {
    icon: "/logo.jpeg",
    apple: "/logo.jpeg",
  },
};

import AuthProvider from "@/components/providers/AuthProvider";

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className="antialiased">
        <AuthProvider>
          {children}
        </AuthProvider>
      </body>
    </html>
  );
}
