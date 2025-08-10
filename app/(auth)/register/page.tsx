"use client";

import { FormEvent, Suspense, useState } from "react";
import { createUserWithEmailAndPassword, updateProfile, signInWithPopup } from "firebase/auth";
import { auth, googleProvider, db } from "@/lib/firebase";
import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import { doc, setDoc, serverTimestamp } from "firebase/firestore";

function RegisterForm() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [name, setName] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const router = useRouter();
  const params = useSearchParams();
  const next = params.get("next") ?? "/manuals";

  async function onSubmit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setError(null);
    setLoading(true);
    try {
      const cred = await createUserWithEmailAndPassword(auth, email, password);
      if (name) await updateProfile(cred.user, { displayName: name });
      await setDoc(doc(db, "users", cred.user.uid), {
        email,
        displayName: name || null,
        createdAt: serverTimestamp(),
      });
      router.replace(next);
    } catch (err) {
      const message = err instanceof Error ? err.message : "Failed to create account";
      setError(message);
    } finally {
      setLoading(false);
    }
  }

  async function signUpWithGoogle() {
    setError(null);
    setLoading(true);
    try {
      const cred = await signInWithPopup(auth, googleProvider);
      await setDoc(doc(db, "users", cred.user.uid), {
        email: cred.user.email,
        displayName: cred.user.displayName,
        photoURL: cred.user.photoURL,
        createdAt: serverTimestamp(),
      }, { merge: true });
      router.replace(next);
    } catch (err) {
      const message = err instanceof Error ? err.message : "Failed to sign up with Google";
      setError(message);
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
        <span className="border-b-2 border-emerald-500 pb-2 text-white">Create Account</span>
        <Link className="pb-2 text-zinc-400 hover:text-white" href="/login">Log In</Link>
      </div>

      <form onSubmit={onSubmit} className="space-y-4">
        <input className="input" placeholder="Name" value={name} onChange={(e)=>setName(e.target.value)} />
        <input className="input" placeholder="Email" type="email" value={email} onChange={(e)=>setEmail(e.target.value)} />
        <input className="input" placeholder="Password" type="password" value={password} onChange={(e)=>setPassword(e.target.value)} />
        {error && <div className="text-sm text-red-400">{error}</div>}
        <button type="submit" className="btn-primary w-full" disabled={loading}>Get Started</button>
      </form>

      <div className="my-6 text-center text-sm text-zinc-400">Or sign up with</div>
      <button onClick={signUpWithGoogle} className="btn-secondary w-full" disabled={loading}>Continue with Google</button>
    </div>
  );
}

export default function RegisterPage() {
  return (
    <Suspense fallback={<div className="text-center">Loading...</div>}>
      <RegisterForm />
    </Suspense>
  );
}
