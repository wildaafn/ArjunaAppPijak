# Arjuna Pijak - Frontend Dashboard

Dashboard Visualisasi dan Analisis Harga Pangan Strategis. Aplikasi ini dibangun menggunakan Vue 3, Vite, dan Tailwind CSS, serta terintegrasi dengan REST API backend untuk visualisasi grafik historis, audit model SARIMAX, dan rekomendasi AI Insight.

---

## Persyaratan Sistem
- Docker & Docker Compose (Docker Desktop / Docker WSL2)
- Node.js v20+ & npm (jika ingin menjalankan secara lokal tanpa Docker)

---

## Development Lokal Menggunakan Docker

Kontainer development frontend dikonfigurasi untuk memetakan direktori lokal ke dalam kontainer (volume mounting) sehingga fitur *Vite Hot Module Replacement (HMR)* tetap aktif dan perubahan kode instan ter-render di browser.

### 1. Jaringan Docker (Shared Network)
Sebelum menjalankan frontend, pastikan Anda telah membuat jaringan Docker eksternal yang sama dengan backend:
```bash
docker network create shared-network
```

### 2. Panduan Setup Berdasarkan OS

#### A. Windows dengan Docker Desktop & WSL2
1. Pastikan integrasi WSL2 pada Docker Desktop diaktifkan (Settings > Resources > WSL Integration).
2. Dari terminal Windows (PowerShell/CMD) atau dari dalam WSL, masuk ke folder `frontend/` dan jalankan:
   ```bash
   docker compose up -d --build
   ```
3. Docker Desktop akan memforward port `5173`. Buka `http://localhost:5173` di browser Windows Anda.

#### B. macOS (Docker Desktop)
1. Buka aplikasi Docker Desktop di Mac.
2. Jalankan perintah compose untuk membangun dan memulai kontainer:
   ```bash
   docker compose up -d --build
   ```
3. Akses antarmuka pengguna di `http://localhost:5173`.

#### C. Linux
1. Jalankan perintah berikut di terminal:
   ```bash
   docker compose up -d --build
   ```

---

## Perintah Pengelolaan Docker

*   **Menjalankan Frontend**: `docker compose up -d`
*   **Membangun Ulang Kontainer**: `docker compose up -d --build`
*   **Melihat Log Dev Server**: `docker compose logs -f frontend`
*   **Menghentikan Kontainer**: `docker compose down`

---

## Variabel Lingkungan (Environment Variables)

Secara default, frontend akan menghubungi backend API di `http://localhost:8000`. Jika backend Anda berjalan di port atau host lain, Anda dapat membuat file `.env` di direktori `frontend/` dan menetapkan variabel berikut:

```env
VITE_API_URL=http://ip-backend-anda:port
```
*Catatan:* Karena kode frontend dieksekusi di sisi browser pengguna, pastikan URL tersebut dapat diakses secara publik atau dari mesin lokal Anda.
