# Panduan Pindah Database dari Google Sheets ke Supabase

Aplikasi absensi ini sekarang memakai **Supabase** (PostgreSQL) sebagai database
pengganti Google Apps Script / Google Sheets.

Hanya ada 3 langkah utama:

1. Buat project Supabase.
2. Jalankan skema SQL (`supabase_schema.sql`).
3. Isi `SUPABASE_URL` dan `SUPABASE_ANON_KEY` di `index.html`.

---

## Langkah 1 - Buat Project Supabase

1. Daftar/login di [supabase.com](https://supabase.com).
2. Klik **New project**.
3. Isi:
   - **Name**: `absen-fkp` (bebas)
   - **Database Password**: buat password kuat, simpan baik-baik.
   - **Region**: pilih `Singapore` (terdekat dengan Indonesia).
4. Tunggu project selesai dibuat (± 2 menit).

## Langkah 2 - Jalankan Skema SQL

1. Buka **Table Editor** di sidebar kiri.
2. Buka **SQL Editor**.
3. Klik **New query**.
4. Buka file `supabase_schema.sql` di proyek ini, **copy semua isinya**.
5. Paste ke SQL Editor, lalu klik **RUN**.

Selesai. Terdapat 4 tabel + data awal (seed):

| Tabel | Isi |
|---|---|
| `users` | akun login (admin & peserta). Sudah ada `admin/admin2026` & `peserta/edudigital` |
| `sessions` | sesi absensi (nama, tanggal, GPS, status BUKA/TUTUP) |
| `absen_logs` | log kehadiran peserta |
| `app_settings` | pengaturan sertifikat (`cert_url`, `syarat_sesi`) |

> Untuk memastikan sukses, buka **Table Editor** — keempat tabel harus muncul.

## Langkah 3 - Set Env Variables (Bukan di Edit Manual)

Key Supabase **tidak ditulis langsung** di `index.html`. File tersebut memakai
placeholder `__SUPABASE_URL__` dan `__SUPABASE_ANON_KEY__` yang akan di-inject
otomatis saat deploy oleh `scripts/inject-env.js`.

1. Di dashboard Supabase, buka **Project Settings → API**. Salin:
   - **Project URL**
   - **anon / public** key
2. Set **dua env variables** ini di platform deploy kamu:

### Opsi A - Netlify
1. Di project Netlify: **Site configuration → Environment variables**.
2. Tambahkan:
   - `SUPABASE_URL` = `https://xxxx.supabase.co`
   - `SUPABASE_ANON_KEY` = `eyJhbGciOi...`
3. **Build settings**:
   - Build command: `node scripts/inject-env.js`
   - Publish directory: `public`
   (sudah diatur otomatis lewat file `netlify.toml`)
4. Deploy. Netlify akan menjalankan script dan mengganti placeholder.

### Opsi B - Vercel
1. Di project Vercel: **Settings → Environment Variables**.
2. Tambahkan `SUPABASE_URL` dan `SUPABASE_ANON_KEY`.
3. Build sudah otomatis terbaca dari `vercel.json` (jalankan
   `node scripts/inject-env.js`, output di `public`).
4. Deploy.

> Catatan: pastikan env var di-set **sebelum** build pertama, atau lakukan
> **Redeploy** setelah menambahkan env var.

---

## Cara Login (Data Default)

- **Admin**: `admin / admin2026`
- **Peserta**: `peserta / edudigital`

Data ini bisa diganti langsung di tabel `users` pada **Table Editor**, atau
di-upload massal lewat menu **Peserta → Upload Massal (CSV)** di aplikasi.

---

## Mode Preview (Tanpa Server)

Jika ingin mencoba tanpa konfigurasi Supabase, ubah satu baris:

```js
let IS_PREVIEW = true;
```

Mode ini memakai data dummy dan TIDAK menyimpan ke database.

---

## Tips & Catatan

- **Ubuntu password di tabel `users` masih plain text** (seperti versi Google
  Sheets dulu). Untuk keamanan produksi, gunakan **Supabase Auth**.
- **RLS dibuka lebar** di skema ini (policy `*_public`), karena app memakai
  `anon key` langsung dari halaman statis. Jangan dipakai untuk data sensitif.
- Log absen otomatis tercatat waktu rekam (`waktu` default `now()`).
- Jika `supabase-js` CDN gagal dimuat, pastikan internet aktif; library dimuat
  dari `cdn.jsdelivr.net`.
- Folder `public/` (hasil inject) TIDAK boleh di-commit — sudah dikecualikan
  via `.gitignore`.