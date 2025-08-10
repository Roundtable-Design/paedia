"use client";

import { useState } from "react";

const sections = [
  { title: "Weekly meetings structure", content: "A suggested flow for weekly brotherhood meetings." },
  { title: "Lords supper liturgy", content: "Outline for celebrating the Lord's Supper during Paedia." },
  { title: "Exit statement brief", content: "Guidance to craft a clear, courageous closing statement." },
];

export default function AccessoryManual() {
  const [open, setOpen] = useState<number | null>(0);
  return (
    <div className="space-y-4">
      <h1 className="text-center text-xl font-semibold">Accessory Manual</h1>
      <div className="container-card divide-y divide-zinc-700/60">
        {sections.map((s, idx) => (
          <div key={s.title}>
            <button className="w-full p-4 text-left" onClick={()=>setOpen(open===idx?null:idx)}>
              <div className="font-medium">{s.title}</div>
            </button>
            {open===idx && (
              <div className="px-4 pb-4 text-sm text-zinc-300">{s.content}</div>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}
