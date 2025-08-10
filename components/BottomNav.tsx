"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { Calendar, BookOpenText, Users2, User } from "lucide-react";

const tabs = [
  { href: "/groups", label: "Groups", icon: Users2 },
  { href: "/schedule", label: "Schedule", icon: Calendar },
  { href: "/manuals", label: "Manuals", icon: BookOpenText },
  { href: "/profile", label: "Profile", icon: User },
];

export default function BottomNav() {
  const pathname = usePathname();
  return (
    <nav className="fixed inset-x-0 bottom-3 z-50 mx-auto w-full max-w-2xl px-4">
      <div className="container-card flex items-center justify-between px-4 py-3">
        {tabs.map(({ href, label, icon: Icon }) => {
          const active = pathname?.startsWith(href);
          return (
            <Link key={href} href={href} className="flex flex-col items-center gap-1 text-xs">
              <Icon size={18} className={active ? "text-emerald-400" : "text-zinc-400"} />
              <span className={active ? "text-emerald-400" : "text-zinc-400"}>{label}</span>
            </Link>
          );
        })}
      </div>
    </nav>
  );
}
