export default function AuthLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="mx-auto max-w-md px-4">
      <div className="container-card p-6">
        {children}
      </div>
    </div>
  );
}
