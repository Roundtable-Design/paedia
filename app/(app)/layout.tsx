import BottomNav from "@/components/BottomNav";
import RequireAuth from "@/components/RequireAuth";

export default function AppLayout({ children }: { children: React.ReactNode }) {
  return (
    <RequireAuth>
      <div className="pb-24">{children}</div>
      <BottomNav />
    </RequireAuth>
  );
}
