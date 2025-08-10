"use client";

import { useAuth } from "@/components/AuthProvider";
import { db } from "@/lib/firebase";
import { doc, getDoc, serverTimestamp, setDoc } from "firebase/firestore";
import { useEffect, useState } from "react";
import { signOut } from "firebase/auth";
import { auth } from "@/lib/firebase";

interface UserDoc {
  openingStatement?: string | null;
  closingStatement?: string | null;
  startDate?: string | null;
  endDate?: string | null;
}

export default function ProfilePage() {
  const { user } = useAuth();
  const [opening, setOpening] = useState("");
  const [closing, setClosing] = useState("");
  const [startDate, setStartDate] = useState<string>("");
  const [endDate, setEndDate] = useState<string>("");
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    async function load() {
      if (!user) return;
      const ref = doc(db, "users", user.uid);
      const snap = await getDoc(ref);
      const data: UserDoc | undefined = snap.exists() ? (snap.data() as UserDoc) : undefined;
      if (data) {
        setOpening(data.openingStatement ?? "");
        setClosing(data.closingStatement ?? "");
        if (data.startDate) setStartDate(data.startDate);
        if (data.endDate) setEndDate(data.endDate);
      }
    }
    load();
  }, [user]);

  async function save() {
    if (!user) return;
    setSaving(true);
    const ref = doc(db, "users", user.uid);
    await setDoc(
      ref,
      {
        openingStatement: opening,
        closingStatement: closing,
        startDate: startDate || null,
        endDate: endDate || null,
        updatedAt: serverTimestamp(),
      },
      { merge: true }
    );
    setSaving(false);
  }

  return (
    <div className="space-y-6">
      <div className="text-center">
        <div className="text-xl font-semibold">{user?.displayName || "Profile"}</div>
        <div className="text-sm text-zinc-400">{user?.email}</div>
      </div>

      <section className="space-y-2">
        <div className="font-medium">Opening Statement</div>
        <textarea className="input min-h-40" value={opening} onChange={(e)=>setOpening(e.target.value)} />
      </section>

      <section className="space-y-2">
        <div className="font-medium">Closing Statement</div>
        <textarea className="input min-h-32" value={closing} onChange={(e)=>setClosing(e.target.value)} />
      </section>

      <section className="grid grid-cols-2 gap-4">
        <div>
          <div className="mb-2 font-medium">Start Date</div>
          <input type="date" className="input" value={startDate} onChange={(e)=>setStartDate(e.target.value)} />
        </div>
        <div>
          <div className="mb-2 font-medium">End Date</div>
          <input type="date" className="input" value={endDate} onChange={(e)=>setEndDate(e.target.value)} />
        </div>
      </section>

      <div className="flex gap-2">
        <button className="btn-primary" onClick={save} disabled={saving}>{saving ? "Saving..." : "Save"}</button>
        <button className="btn-secondary" onClick={()=>signOut(auth)}>Log out</button>
      </div>
    </div>
  );
}
