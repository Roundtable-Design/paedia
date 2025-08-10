import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";
import Link from "next/link";
import { AuthProvider } from "@/components/AuthProvider";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "Paedia",
  description: "A 90-day discipleship journey in small brotherhoods.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className={`${geistSans.variable} ${geistMono.variable} antialiased`}>
        <AuthProvider>
          <div className="min-h-dvh py-8">
            <div className="mx-auto max-w-2xl px-4">
              <header className="mb-8 flex items-center justify-center">
                <Link href="/" className="text-2xl font-bold">Paedia</Link>
              </header>
              {children}
            </div>
          </div>
        </AuthProvider>
      </body>
    </html>
  );
}
