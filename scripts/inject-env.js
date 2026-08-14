// ============================================================
// inject-env.js — mengganti placeholder di index.html dengan env
// var (SUPABASE_URL, SUPABASE_ANON_KEY) lalu menulis ke folder
// "public" sebagai output siap deploy.
//
// Dipakai oleh Netlify & Vercel saat build. Key TIDAK pernah
// disimpan di repo — hanya ada di dashboard env platform.
//
// Cara test lokal:
//   SUPABASE_URL="https://xxx.supabase.co" SUPABASE_ANON_KEY="eyJ..." node scripts/inject-env.js
// ============================================================
const fs = require('fs');
const path = require('path');

const SRC = path.join(__dirname, '..', 'index.html');
const OUT_DIR = path.join(__dirname, '..', 'public');
const OUT_FILE = path.join(OUT_DIR, 'index.html');

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY;

if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
    console.error('[inject-env] ERROR: SUPABASE_URL / SUPABASE_ANON_KEY belum di-set di environment.');
    process.exit(1);
}

let html = fs.readFileSync(SRC, 'utf8');

html = html.replaceAll('__SUPABASE_URL__', SUPABASE_URL);
html = html.replaceAll('__SUPABASE_ANON_KEY__', SUPABASE_ANON_KEY);

fs.mkdirSync(OUT_DIR, { recursive: true });
fs.writeFileSync(OUT_FILE, html, 'utf8');

console.log('[inject-env] OK -> public/index.html (env berhasil di-inject)');
