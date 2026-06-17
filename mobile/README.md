# Arjuna Mobile 🌾📈

<p align="center">
  <img src="assets/images/arjuna-logo.png" width="160" alt="Arjuna Mobile Logo">
</p>

**Arjuna Mobile** adalah aplikasi *mobile* untuk memantau harga pangan pokok, membaca kondisi pasar, dan melihat prediksi harga berbasis AI dalam tampilan yang disesuaikan untuk pembeli maupun pedagang. Aplikasi ini memadukan ringkasan pasar nasional, daftar komoditas yang mudah dipindai, detail grafik harga, audit model AI, dan briefing pasar yang lebih personal.

---

## ✨ Fitur Unggulan

- **🏠 Beranda Ringkas dan Kontekstual**: Halaman utama menampilkan *market pulse* nasional, ringkasan komoditas penting, *top movers*, dan feed berita pangan dalam satu alur yang cepat dipindai.
- **🤖 Mascot-Driven Market UI**: Beberapa area utama memakai mascot Arjuna dengan pose berbeda untuk memberi nuansa briefing, insight, dan status pasar tanpa membuat layar terasa penuh.
- **📊 Prediksi Harga AI 7 Hari**: Halaman detail komoditas menampilkan riwayat harga, proyeksi AI, serta tren pasar dalam grafik yang lebih mudah dibaca.
- **🔄 Perspektif Pembeli dan Pedagang**: Warna tren, insight, dan penekanan informasi menyesuaikan kebutuhan pengguna. Kenaikan harga bisa dibaca sebagai risiko belanja atau peluang margin tergantung mode yang dipilih.
- **🧠 Floating AI Insight**: Pada halaman detail, insight AI muncul sebagai panel terapung yang mengikuti perspektif aktif dari pengaturan dan tidak mengganggu area grafik utama.
- **🔍 Audit Akurasi Prediksi**: Pengguna dapat membuka audit model untuk melihat akurasi, evaluasi historis, dan transparansi hasil prediksi AI.
- **📦 Daftar Komoditas yang Bisa Dicari dan Diurutkan**: Tab komoditas mendukung pencarian cepat serta pengurutan berdasarkan urutan default, nama, harga tertinggi, dan pergerakan terbesar.
- **📰 Berita Pangan Terintegrasi**: Feed berita memakai kartu horizontal dengan *loading state*, detail artikel, dan tautan sumber eksternal.
- **💾 Preferensi Persisten**: Tema dan mode perspektif disimpan secara lokal sehingga pengalaman tetap konsisten saat aplikasi dibuka kembali.
- **✨ Loading dan Motion yang Lebih Halus**: Aplikasi memakai shimmer, transisi masuk ringan, dan state loading yang lebih jelas di area penting seperti dashboard, insight, dan berita.

---

## 🛠️ Teknologi yang Digunakan

### Frontend (Mobile)
- **Framework**: [Flutter](https://flutter.dev/) (Dart)
- **State Management**: [Riverpod](https://riverpod.dev/) untuk state global dan dependency injection, serta [Flutter BLoC/Cubit](https://pub.dev/packages/flutter_bloc) untuk alur detail dan audit yang lebih interaktif
- **Persistence**: `hive_flutter` untuk penyimpanan cache komoditas offline berkinerja tinggi, `flutter_secure_storage` untuk enkripsi data sensitif (KeyStore/KeyChain), dan `shared_preferences` untuk pengaturan preferensi aplikasi
- **Networking**: `dio` (dengan penanganan error & interseptor kustom)
- **Charting**: `fl_chart`
- **Motion & Loading**: `shimmer` untuk placeholder loading dan animasi masuk ringan pada area kunci
- **Design System**: Font kustom *Outfit*, pola latar batik, skema warna harmonis, dan dukungan penuh dark/light mode

### Backend (AI Engine & API)
- **API Framework**: [FastAPI](https://fastapi.tiangolo.com/) (Python)
- **AI/ML**: Endpoint prediksi, insight, dan audit model untuk mendukung pembacaan pasar yang lebih transparan

---

## 🚀 Memulai Penggunaan

### 1. Prasyarat
- Flutter SDK (^3.10.7)
- Dart SDK
- Perangkat Android/iOS atau Emulator/Simulator.

### 2. Persiapan Proyek
```bash
# Clone repository
git clone https://github.com/username-anda/arjuna-mobile.git

# Masuk ke direktori mobile
cd arjuna_mobile

# Ambil dependensi
flutter pub get
```

### 3. Konfigurasi API
Ubah `baseUrl` di `lib/core/api_config.dart` sesuai dengan lokasi server backend Anda.
```dart
static const String baseUrl = 'http://127.0.0.1:8000'; // Sesuaikan IP jika menggunakan device fisik
```

Untuk feed berita, Anda dapat menyediakannya melalui berkas `secrets.json` di root folder proyek:
```json
{
  "GNEWS_API_KEY": "kunci_api_gnews_anda"
}
```
Lalu jalankan aplikasi dengan perintah:
```bash
flutter run --dart-define-from-file=secrets.json
```
Atau jika ingin menggunakan baris terminal langsung:
```bash
flutter run --dart-define=GNEWS_API_KEY=key_anda
```

### 4. Menjalankan Aplikasi
```bash
flutter run
```

---

## 📂 Struktur Proyek

Proyek ini menerapkan pendekatan **Clean Architecture** dengan struktur folder berbasis fitur (feature-first) untuk modularitas dan kemudahan pemeliharaan:

```text
lib/
├── core/
│   ├── api_client.dart       # API client dengan dio dan interceptors
│   ├── api_config.dart       # Konfigurasi basis endpoint
│   ├── providers.dart        # Riverpod providers untuk core dependencies
│   └── theme.dart            # Sistem desain (Colors, Typography, Dark & Light themes)
├── features/
│   ├── splash/               # Splash screen dengan animasi masuk
│   ├── onboarding/           # Pengenalan fitur aplikasi bagi pengguna baru
│   ├── dashboard/            # Beranda dengan market pulse, akses cepat, top movers, dan berita
│   ├── home/                 # Daftar komoditas dengan pencarian dan sorting
│   ├── detail/               # Grafik harga, prediksi AI, floating insight, audit, dan sub-komoditas
│   │   └── presentation/cubit/ # Cubit untuk state detail dan audit model
│   ├── insight/              # Briefing pasar global berbasis AI dengan mascot dan mood pasar
│   └── settings/             # Pengaturan tema, perspektif pengguna, dan informasi aplikasi
├── shared/
│   ├── data/                 # Repository data bersama (CommodityRepository)
│   ├── domain/               # Model data entitas (Commodity, Price, dll)
│   └── widgets/              # Widget umum (ErrorState, ArjunaBrand, ShimmerPlaceholder)
└── main.dart                 # Titik masuk utama aplikasi & inisialisasi state
```

---

## 🤝 Kontribusi
Aplikasi ini bersifat terbuka untuk pengembangan lebih lanjut. Jika Anda menemukan *bug* atau memiliki ide fitur baru, silakan ajukan melalui *Issue* atau *Pull Request*.

---
*Membangun ketahanan pangan melalui inovasi kecerdasan buatan.*
