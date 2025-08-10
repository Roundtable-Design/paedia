"use client";

import { FormEvent, useState } from "react";
import { signInWithEmailAndPassword, signInWithPopup } from "firebase/auth";
import { auth, googleProvider } from "@/lib/firebase";
import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";

export default function LoginPage() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const router = useRouter();
  const params = useSearchParams();
  const next = params.get("next") ?? "/manuals";

  async function onSubmit(e: FormEvent) {
    e.preventDefault();
    setError(null);
    setLoading(true);
    try {
      await signInWithEmailAndPassword(auth, email, password);
      router.replace(next);
    } catch (err: any) {
      setError(err.message ?? "Failed to log in");
    } finally {
      setLoading(false);
    }
  }

  async function signInWithGoogle() {
    setError(null);
    setLoading(true);
    try {
      await signInWithPopup(auth, googleProvider);
      router.replace(next);
    } catch (err: any) {
      setError(err.message ?? "Failed to sign in with Google");
    } finally {
      setLoading(false);
    }
  }

  return (
    <div>
      <div className="mb-6 flex items-center justify-center">
        <div className="text-2xl font-bold">Paedia</div>
      </div>
      <div className="mb-6 flex gap-6 border-b border-zinc-700">
        <Link className="pb-2 text-zinc-400 hover:text-white" href="/register">Create Account</Link>
        <span className="border-b-2 border-emerald-500 pb-2 text-white">Log In</span>
      </div>
      <form onSubmit={onSubmit} className="space-y-4">
        <input className="input" placeholder="Email" type="email" value={email} onChange={(e)=>setEmail(e.target.value)} />
        <input className="input" placeholder="Password" type="password" value={password} onChange={(e)=>setPassword(e.target.value)} />
        {error && <div className="text-sm text-red-400">{error}</div>}
        <button type="submit" className="btn-primary w-full" disabled={loading}>Sign In</button>
      </form>
      <div className="my-6 text-center text-sm text-zinc-400">Or sign in with</div>
      <button onClick={signInWithGoogle} className="btn-secondary w-full" disabled={loading}>Continue with Google</button>
    </div>
  );
}
