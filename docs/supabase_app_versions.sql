-- =====================================================================
-- SKRIP SETUP TABEL app_versions UNTUK AUTO-UPDATE & VERSI MINIMUM
-- =====================================================================

-- 1. Membuat tabel app_versions
CREATE TABLE IF NOT EXISTS public.app_versions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    platform TEXT NOT NULL, -- 'android', 'ios', 'web', 'windows', 'macos', 'linux'
    latest_version TEXT NOT NULL, -- Versi terbaru (contoh: '1.0.2')
    latest_build INT NOT NULL, -- Nomor build terbaru (contoh: 3)
    minimum_build INT NOT NULL, -- Nomor build minimum yang diwajibkan (contoh: 2)
    download_url TEXT NOT NULL, -- Tautan unduh aplikasi (contoh: https://play.google.com/...)
    release_notes TEXT, -- Catatan rilis/fitur baru
    is_active BOOLEAN NOT NULL DEFAULT true, -- Status keaktifan rilis versi ini
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. Mengaktifkan Row Level Security (RLS)
ALTER TABLE public.app_versions ENABLE ROW LEVEL SECURITY;

-- 3. Membuat Kebijakan RLS (Policy) agar tabel dapat dibaca oleh Publik (Anonim & Terautentikasi)
-- Catatan: Pengguna baru yang belum login/registrasi tetap harus bisa melakukan pengecekan versi di SplashScreen.
CREATE POLICY "Allow read access to active app versions for everyone" 
ON public.app_versions 
FOR SELECT 
TO public 
USING (is_active = true);

-- 4. Membuat Indeks untuk Optimalisasi Kueri
CREATE INDEX IF NOT EXISTS idx_app_versions_platform_active 
ON public.app_versions(platform, is_active);

-- 5. Menambahkan Data Contoh Awal (Seed Data) - OPSIONAL
-- Skrip di bawah ini memasukkan versi awal sebagai contoh. Silakan sesuaikan nomor build-nya.
-- INSERT INTO public.app_versions (platform, latest_version, latest_build, minimum_build, download_url, release_notes, is_active)
-- VALUES 
-- ('android', '1.0.1', 2, 1, 'https://parkircepat.page.link/android-latest', 'Peningkatan performa dan keamanan transaksi.', true),
-- ('ios', '1.0.1', 2, 1, 'https://parkircepat.page.link/ios-latest', 'Peningkatan performa dan keamanan transaksi.', true);
