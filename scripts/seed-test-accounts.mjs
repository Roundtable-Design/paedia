#!/usr/bin/env node
/**
 * Seeds Paedia dev test accounts on production Firebase (Auth + users/{uid}).
 * Safe: creates test users only; no rules or CMS changes.
 *
 * Usage:
 *   node scripts/seed-test-accounts.mjs
 *
 * Requires TEST_ACCOUNT_PASSWORD in .env.test.local or environment.
 */

import { readFileSync, existsSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const root = resolve(__dirname, '..');

const FIREBASE_API_KEY = 'AIzaSyAG0Q65Y9INmCe4EofaOfTVQpnOE8JTcCI';
const PROJECT_ID = 'paedia-fqv6h9';

function loadPassword() {
  if (process.env.TEST_ACCOUNT_PASSWORD) {
    return process.env.TEST_ACCOUNT_PASSWORD;
  }
  const envPath = resolve(root, '.env.test.local');
  if (!existsSync(envPath)) {
    throw new Error(
      'Missing .env.test.local — copy .env.test.example and set TEST_ACCOUNT_PASSWORD',
    );
  }
  const match = readFileSync(envPath, 'utf8').match(
    /^TEST_ACCOUNT_PASSWORD=(.+)$/m,
  );
  if (!match?.[1]) {
    throw new Error('TEST_ACCOUNT_PASSWORD not set in .env.test.local');
  }
  return match[1].trim().replace(/^["']|["']$/g, '');
}

function daysAgo(n) {
  const d = new Date();
  d.setHours(0, 0, 0, 0);
  d.setDate(d.getDate() - n);
  return d.toISOString();
}

const ACCOUNTS = [
  {
    email: 'dev+paedia-active@round-table.co.uk',
    displayName: 'Dev Active User',
    gender: 'Male',
    startDate: daysAgo(30),
    whyStatement: 'Testing active programme flow.',
  },
  {
    email: 'dev+paedia-onboard@round-table.co.uk',
    displayName: 'Dev Onboarding User',
  },
  {
    email: 'dev+paedia-complete@round-table.co.uk',
    displayName: 'Dev Complete User',
    gender: 'Female',
    startDate: daysAgo(100),
    whyStatement: 'Testing post-programme completion.',
  },
];

async function authRequest(path, body) {
  const res = await fetch(
    `https://identitytoolkit.googleapis.com/v1/${path}?key=${FIREBASE_API_KEY}`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body),
    },
  );
  const data = await res.json();
  if (!res.ok) {
    throw new Error(data.error?.message ?? res.statusText);
  }
  return data;
}

async function getIdToken(email, password) {
  try {
    const data = await authRequest('accounts:signUp', {
      email,
      password,
      returnSecureToken: true,
    });
    return { idToken: data.idToken, localId: data.localId, created: true };
  } catch (err) {
    if (!String(err.message).includes('EMAIL_EXISTS')) {
      throw err;
    }
    const data = await authRequest('accounts:signInWithPassword', {
      email,
      password,
      returnSecureToken: true,
    });
    return { idToken: data.idToken, localId: data.localId, created: false };
  }
}

async function patchUserDoc(idToken, uid, profile) {
  const fields = {
    email: { stringValue: profile.email },
    display_name: { stringValue: profile.displayName },
    uid: { stringValue: uid },
    created_time: { timestampValue: new Date().toISOString() },
  };
  if (profile.gender) {
    fields.gender = { stringValue: profile.gender };
  }
  if (profile.startDate) {
    fields.startDate = { timestampValue: profile.startDate };
  }
  if (profile.whyStatement) {
    fields.whyStatement = { stringValue: profile.whyStatement };
  }

  const maskPaths = ['email', 'display_name', 'uid', 'created_time'];
  if (profile.gender) maskPaths.push('gender');
  if (profile.startDate) maskPaths.push('startDate');
  if (profile.whyStatement) maskPaths.push('whyStatement');

  const patchUrl =
    `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}` +
    `/databases/(default)/documents/users/${uid}?` +
    maskPaths.map((p) => `updateMask.fieldPaths=${p}`).join('&');

  const res = await fetch(patchUrl, {
    method: 'PATCH',
    headers: {
      Authorization: `Bearer ${idToken}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ fields }),
  });

  if (!res.ok) {
    const createUrl =
      `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}` +
      `/databases/(default)/documents/users?documentId=${uid}`;
    const createRes = await fetch(createUrl, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${idToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ fields }),
    });
    if (!createRes.ok) {
      const err = await createRes.json();
      throw new Error(err.error?.message ?? createRes.statusText);
    }
  }
}

async function main() {
  const password = loadPassword();
  console.log(`Seeding ${ACCOUNTS.length} test accounts on ${PROJECT_ID}…\n`);

  for (const account of ACCOUNTS) {
    process.stdout.write(`${account.email} … `);
    const { idToken, localId, created } = await getIdToken(
      account.email,
      password,
    );
    await patchUserDoc(idToken, localId, account);
    console.log(created ? 'created' : 'updated');
  }

  console.log('\nDone. Credentials are in .env.test.local (not committed).');
}

main().catch((err) => {
  console.error('Seed failed:', err.message);
  process.exit(1);
});
