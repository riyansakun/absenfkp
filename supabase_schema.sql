-- ============================================================
-- SUPABASE SCHEMA - Aplikasi Absensi PAKARMARU / FKP
-- Cara pakai: Dashboard Supabase -> SQL Editor -> New query
-- -> paste semua di bawah -> RUN
-- ============================================================

-- ------------------------------------------------------------
-- 1. TABEL PENGGUNA (users)
--    nim  -> primary key, digunakan sebagai username login
-- ------------------------------------------------------------
create table if not exists public.users (
    nim      text primary key,
    nama     text not null,
    password text not null,
    role     text not null default 'peserta' check (role in ('admin', 'peserta'))
);

-- ------------------------------------------------------------
-- 2. TABEL SESI ABSENSI (sessions)
--    butuh_gps = true berarti wajib validasi lokasi
-- ------------------------------------------------------------
create table if not exists public.sessions (
    id        text primary key,
    nama      text not null,
    tanggal   date not null,
    waktu     time not null,
    butuh_gps boolean not null default false,
    lat       double precision default 0,
    lng       double precision default 0,
    radius    integer default 0,
    status    text not null default 'TUTUP' check (status in ('BUKA', 'TUTUP')),
    created_at timestamptz not null default now()
);

-- ------------------------------------------------------------
-- 3. TABEL LOG ABSENSI (absen_logs)
--    waktu otomatis terisi waktu insert
-- ------------------------------------------------------------
create table if not exists public.absen_logs (
    id        bigint generated always as identity primary key,
    waktu     timestamptz not null default now(),
    nim       text not null,
    nama      text not null,
    sesi      text not null,
    gps       text default ''
);

-- ------------------------------------------------------------
-- 4. TABEL PENGATURAN (app_settings)
--    key: 'cert_url' | 'syarat_sesi'
-- ------------------------------------------------------------
create table if not exists public.app_settings (
    key   text primary key,
    value text not null default ''
);

-- ------------------------------------------------------------
-- DATA AWAL (seed) - WAJIB DIPERLUKAN AGAR BISA LOGIN
-- ------------------------------------------------------------
insert into public.users (nim, nama, password, role) values
    ('admin', 'Super Admin', 'admin2026', 'admin'),
    ('peserta', 'Mahasiswa Teladan', 'edudigital', 'peserta')
on conflict (nim) do nothing;

insert into public.sessions (id, nama, tanggal, waktu, butuh_gps, lat, lng, radius, status) values
    ('s1', 'Hari 1 - Pembukaan', '2026-08-10', '08:00', true, -6.200000, 106.816666, 1000, 'BUKA'),
    ('s2', 'Hari 1 - Materi Sore', '2026-08-10', '15:00', false, 0, 0, 0, 'TUTUP')
on conflict (id) do nothing;

insert into public.app_settings (key, value) values
    ('cert_url', 'https://img.freepik.com/free-vector/gradient-certificate-template_23-2148970724.jpg'),
    ('syarat_sesi', '')
on conflict (key) do nothing;

-- ------------------------------------------------------------
-- ROW LEVEL SECURITY (RLS)
-- Note: karena ini aplikasi statis (HTML di GitHub Pages) yang
-- memakai ANON KEY langsung, RLS dibuka lebar untuk kemudahan.
-- JANGAN dipakai untuk data sensitif/produksi tanpa Supabase Auth.
-- ------------------------------------------------------------
alter table public.users      enable row level security;
alter table public.sessions   enable row level security;
alter table public.absen_logs enable row level security;
alter table public.app_settings enable row level security;

create policy "p_users_public"      on public.users      for all using (true) with check (true);
create policy "p_sessions_public"   on public.sessions   for all using (true) with check (true);
create policy "p_logs_public"       on public.absen_logs for all using (true) with check (true);
create policy "p_settings_public"   on public.app_settings for all using (true) with check (true);