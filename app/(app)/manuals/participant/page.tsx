"use client";

import { useState } from "react";

const sections = [
  { title: "What is Paedia?", content: "Paedia is a 90-day discipleship journey in small brotherhoods." },
  { title: "The Disciplines", content: "Daily prayer, scripture reading, accountability, and service." },
  { title: "Preparing for Day 91", content: "Carry practices into ordinary life beyond the 90 days." },
];

export default function ParticipantManual() {
  const [open, setOpen] = useState<number | null>(0);
  return (
    <div className="space-y-4">
      <h1 className="text-center text-xl font-semibold">Participant Manual</h1>
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
