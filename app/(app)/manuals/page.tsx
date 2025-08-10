import Link from "next/link";

export default function ManualsPage() {
  return (
    <div className="space-y-4">
      <h1 className="text-center text-xl font-semibold">Manuals</h1>
      <div className="container-card p-2">
        <Link href="/manuals/participant" className="block rounded-lg p-4 hover:bg-zinc-800">Participant Manual</Link>
        <Link href="/manuals/accessory" className="block rounded-lg p-4 hover:bg-zinc-800">Accessory Manual</Link>
      </div>
    </div>
  );
}
