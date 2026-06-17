# Arjuna Pijak API - Backend

Sistem Backend untuk prediksi harga pangan pokok menggunakan model SARIMAX yang dioptimasi. Aplikasi ini dibangun dengan FastAPI, SQLAlchemy (PostgreSQL), dan dilengkapi dengan job penjadwalan menggunakan APScheduler.

---

## Persyaratan Sistem
- Docker & Docker Compose (Docker Desktop / Docker WSL2)
- Python 3.12+ (jika ingin menjalankan secara lokal tanpa Docker)
- PostgreSQL 17 (berjalan pada jaringan Docker `shared-network` atau lokal)

---

## Konfigurasi Lingkungan (.env)

Salin file `.env.example` menjadi `.env` sebelum memulai:
```bash
cp .env.example .env
```
Sesuaikan variabel berikut di dalam `.env`:
*   `DATABASE_HOST`: Set ke `postgres` jika menggunakan PostgreSQL di dalam container docker pada network yang sama. Set ke `localhost` atau `host.docker.internal` jika menggunakan database lokal di mesin host.
*   `NVIDIA_API_KEY`: Masukkan API Key dari NVIDIA API Catalog (build.nvidia.com) untuk menyalakan fitur AI Insight.

---

## Development Lokal Menggunakan Docker

Sistem ini mendukung hot-reloading melalui volume mounting sehingga perubahan kode di mesin lokal langsung diterapkan di dalam container.

### 1. Prasyarat Jaringan Docker
Buat jaringan Docker bersama agar container backend, frontend, dan database dapat saling berkomunikasi:
```bash
docker network create shared-network
```

### 2. Panduan Setup Berdasarkan OS

#### A. Windows dengan Docker Desktop & WSL2 (Direkomendasikan)
1. Pastikan fitur **WSL2 Integration** diaktifkan di setelan Docker Desktop (Settings > Resources > WSL Integration).
2. Jalankan perintah di bawah ini dari terminal Windows (PowerShell/CMD) atau dari dalam distro WSL Anda:
   ```bash
   docker compose up -d --build
   ```
3. WSL2 akan otomatis memforward port `8000` ke localhost Windows. Anda dapat mengakses dokumentasi API di `http://localhost:8000/docs`.

#### B. macOS (Docker Desktop)
1. Nyalakan Docker Desktop untuk Mac.
2. Jika database PostgreSQL Anda berjalan secara native di Mac (bukan di docker), ubah `DATABASE_HOST` di `.env` menjadi `host.docker.internal`.
3. Bangun dan jalankan container:
   ```bash
   docker compose up -d --build
   ```
4. API dapat diakses langsung pada `http://localhost:8000`.

#### C. Linux (Docker Engine Native)
1. Pastikan daemon docker sedang berjalan: `sudo systemctl start docker`
2. Jalankan Docker Compose:
   ```bash
   docker compose up -d --build
   ```

---

## Perintah Penting Pengelolaan Docker

*   **Menjalankan Container**: `docker compose up -d`
*   **Membangun Ulang (Rebuild)**: `docker compose up -d --build`
*   **Melihat Log Aplikasi**: `docker compose logs -f api`
*   **Menghentikan Container**: `docker compose down`
*   **Merestart Service (untuk reload perubahan `.env`)**:
    ```bash
    docker compose restart api
    ```

---

## Persiapan & Seeding Database di Docker

Setelah container database PostgreSQL dan API berjalan di jaringan `shared-network`, lakukan migrasi dan seeding data awal dari `commodity_history.json` ke database dengan perintah berikut:

```bash
docker compose exec api python seeder.py
```
*Catatan:* Perintah di atas akan mengeksekusi skrip `seeder.py` langsung di dalam container API yang sedang berjalan.

---

## Fitur Utama & Dokumentasi API

1. **Endpoint `/predict`**: Menghasilkan prediksi harga hingga 30 hari ke depan dengan model `SARIMAX` berdasar parameter optimal hasil fine-tuning.
2. **Endpoint `/audit`**: Mengembalikan nilai pencocokan historis model (*in-sample fitted values*) dengan performa super cepat berbasis memori cache.
3. **Endpoint `/insight`**: Menghasilkan insight taktis bisnis untuk pelaku UMKM menggunakan Google Gemma 4 31B dengan fallback otomatis ke Gemini 2.5 Flash jika batas limit API key gratis terlampaui.
4. **Dokumentasi API**: Setelah aplikasi berjalan, dokumentasi interaktif Swagger UI tersedia di: `http://localhost:8000/docs`
