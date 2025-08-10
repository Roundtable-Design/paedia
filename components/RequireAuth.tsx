"use client";

import { useEffect } from "react";
import { useRouter, usePathname } from "next/navigation";
import { useAuth } from "@/components/AuthProvider";

export default function RequireAuth({ children }: { children: React.ReactNode }) {
  const { user, loading } = useAuth();
  const router = useRouter();
  const pathname = usePathname();

  useEffect(() => {
    if (!loading && !user) {
      const redirect = encodeURIComponent(pathname ?? "/");
      router.replace(`/login?next=${redirect}`);
    }
  }, [loading, user, router, pathname]);

  if (loading) {
    return <div className="text-center">Loading...</div>;
  }
  if (!user) return null;
  return <>{children}</>;
}
