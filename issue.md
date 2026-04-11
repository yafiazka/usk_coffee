# 🫘 Issue: Klasifikasi & Sortir Biji Kopi dengan Deep Learning

## 📋 Ringkasan

Menambahkan fitur **Klasifikasi Biji Kopi** ke dalam aplikasi Flutter `usk_coffee` menggunakan model Deep Learning PyTorch Lite (`.ptl`). Aplikasi akan mampu mengidentifikasi 4 kategori biji kopi melalui foto langsung atau unggah gambar, lalu menampilkan skor klasifikasi secara detail.

---

## 🎯 Tujuan

Mengintegrasikan model AI (`coffee_model_flutter.ptl`) ke dalam aplikasi Flutter untuk melakukan inferensi lokal (on-device) guna mengklasifikasikan biji kopi ke dalam 4 kelas:

| Kelas       | Deskripsi                                                        |
|-------------|------------------------------------------------------------------|
| `peaberry`  | Biji kopi berbentuk bulat (satu biji per buah, tanpa belahan)   |
| `longberry` | Biji kopi panjang & ramping, ukuran di atas rata-rata           |
| `premium`   | Biji kopi berkualitas tinggi, bentuk sempurna                   |
| `defect`    | Biji kopi cacat/rusak (pecah, berlubang, berjamur, dll.)        |

---

## 🖼️ Tampilan yang Diharapkan (1 Halaman)

```
┌─────────────────────────────────────┐
│   ☕ USK Coffee Classifier           │
├─────────────────────────────────────┤
│                                     │
│   ┌─────────────────────────────┐   │
│   │                             │   │
│   │     [Area Preview Foto]     │   │
│   │                             │   │
│   │   Tap untuk pilih gambar    │   │
│   └─────────────────────────────┘   │
│                                     │
│  [ 📷 Ambil Foto ]  [ 🖼️ Upload ]   │
│                                     │
│  ──── Hasil Klasifikasi ────        │
│  🏆 Peaberry (96.05%)               │
│                                     │
│  Detail Skor Klasifikasi:           │
│  • peaberry  : ████████████ 96.05%  │
│  • premium   : █ 3.30%              │
│  • defect    : ▏ 0.64%              │
│  • longberry : ▏ 0.01%              │
│                                     │
│       [ 🔄 Reset ]                  │
└─────────────────────────────────────┘
```

---

## ✅ Fitur yang Diminta

### 1. Input Gambar
- [ ] **Kamera langsung** — Ambil foto biji kopi langsung dari kamera perangkat
- [ ] **Upload gambar** — Pilih gambar dari galeri/penyimpanan perangkat
- [ ] Preview gambar yang dipilih/diambil ditampilkan di area tengah

### 2. Proses Klasifikasi AI
- [ ] Memuat model `assets/model/coffee_model_flutter.ptl` menggunakan `flutter_pytorch_lite`
- [ ] Melakukan preprocessing gambar sebelum inferensi (resize, normalize)
- [ ] Menjalankan inferensi on-device (tidak butuh internet)
- [ ] Menghasilkan skor probabilitas untuk 4 kelas

### 3. Tampilan Hasil
- [ ] Menampilkan **label kelas tertinggi** sebagai hasil utama
- [ ] Menampilkan **detail skor** semua kelas dengan format:
  ```
  Detail Skor Klasifikasi:
  - peaberry  : 96.05%
  - premium   : 3.30%
  - defect    : 0.64%
  - longberry : 0.01%
  ```
- [ ] Skor diurutkan dari tertinggi ke terendah
- [ ] Visualisasi bar progress untuk setiap skor

### 4. Tombol Reset
- [ ] Menghapus gambar yang dipilih
- [ ] Menghapus semua hasil klasifikasi
- [ ] Mereset state model/inferensi ke kondisi awal

---

## 📦 Package yang Digunakan

### Wajib

```yaml
dependencies:
  flutter:
    sdk: flutter

  # PyTorch Lite untuk inferensi model .ptl on-device
  flutter_pytorch_lite: ^0.1.0+3

  # Picker gambar dari kamera & galeri
  image_picker: ^1.1.2

  # Izin akses kamera & penyimpanan
  permission_handler: ^11.3.1

  # Ikon tambahan
  cupertino_icons: ^1.0.8
```

### Opsional (untuk UI yang lebih baik)

```yaml
  # Loading indicator yang lebih bagus
  flutter_spinkit: ^5.2.1

  # Animasi transisi & UI
  animate_do: ^3.3.4
```

---

## 🗂️ Struktur File

```
lib/
└── main.dart                   # (MODIFY) Entry point + satu halaman utama

assets/
└── model/
    └── coffee_model_flutter.ptl   # Model PyTorch Lite (sudah ada)
```

> **Catatan:** Semua logika (UI + AI inference) dijadikan satu di `main.dart` karena hanya 1 halaman.

---

## ⚙️ Konfigurasi yang Perlu Diubah

### `pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_pytorch_lite: ^0.1.0+3
  image_picker: ^1.1.2
  permission_handler: ^11.3.1
  cupertino_icons: ^1.0.8

flutter:
  uses-material-design: true
  assets:
    - assets/model/coffee_model_flutter.ptl
```

### Android — `android/app/src/main/AndroidManifest.xml`

Tambahkan permission berikut di dalam tag `<manifest>`:

```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>

<!-- Untuk Android 13+ -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
```

Tambahkan di dalam tag `<application>`:

```xml
<provider
  android:name="androidx.core.content.FileProvider"
  android:authorities="${applicationId}.fileprovider"
  android:exported="false"
  android:grantUriPermissions="true">
  <meta-data
    android:name="android.support.FILE_PROVIDER_PATHS"
    android:resource="@xml/file_paths" />
</provider>
```

### Android — `android/app/build.gradle`

Pastikan `minSdkVersion` minimal **21**:

```gradle
android {
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

---

## 🧠 Alur Kerja Aplikasi

```
[User buka app]
       │
       ▼
[Halaman Utama] ──► [Area preview kosong]
       │
       ├──► [Tap "Ambil Foto"] ──► [Buka kamera] ──► [Foto diambil]
       │                                                    │
       └──► [Tap "Upload"]     ──► [Buka galeri] ──► [Gambar dipilih]
                                                           │
                                                           ▼
                                                  [Preview gambar tampil]
                                                           │
                                                           ▼
                                               [Otomatis jalankan inferensi]
                                                           │
                                                           ▼
                                               [Tampilkan hasil klasifikasi]
                                                           │
                                                           ▼
                                               [User tap "Reset"] ──► [State bersih]
```

---

## 🔧 Detail Implementasi Teknis

### Preprocessing Gambar (sebelum inferensi)

Model PyTorch umumnya membutuhkan:
- Resize gambar ke `224 × 224` pixel (atau sesuai input model)
- Normalisasi: `mean = [0.485, 0.456, 0.406]`, `std = [0.229, 0.224, 0.225]` (ImageNet standard)
- Format tensor: `[1, 3, H, W]` (batch, channel, height, width)

### Label Kelas (urutan output model)

```dart
const List<String> labels = ['peaberry', 'longberry', 'premium', 'defect'];
```

> ⚠️ **Penting:** Urutan label harus sesuai dengan urutan output node pada model saat training. Verifikasi urutan ini dengan tim yang melatih model.

### Contoh Output yang Diharapkan

```
Detail Skor Klasifikasi:
- peaberry  : 96.05%
- premium   : 3.30%
- defect    : 0.64%
- longberry : 0.01%
```

---

## 🚨 Potensi Masalah & Solusi

| Masalah | Kemungkinan Penyebab | Solusi |
|--------|----------------------|--------|
| Model gagal dimuat | File `.ptl` tidak terdaftar di `pubspec.yaml` | Pastikan path asset benar dan jalankan `flutter pub get` |
| Crash saat inferensi | Ukuran input tidak sesuai ekspektasi model | Sesuaikan nilai resize dengan input shape model |
| Kamera tidak terbuka (Android) | Permission belum diberikan | Tambahkan `permission_handler` dan minta izin di `initState` |
| Hasil klasifikasi tidak akurat | Urutan label salah | Verifikasi urutan output kelas dengan metadata training |
| `flutter_pytorch_lite` tidak kompatibel | SDK < 21 atau arsitektur arm32 | Set `minSdkVersion 21`, gunakan device arm64 |

---

## 📋 Acceptance Criteria

- [x] Aplikasi berhasil dijalankan tanpa crash
- [ ] Model `.ptl` berhasil dimuat dari bundle aset
- [ ] Foto dari kamera berhasil diproses dan menghasilkan output klasifikasi
- [ ] Gambar dari galeri berhasil diproses dan menghasilkan output klasifikasi
- [ ] Output menampilkan 4 label beserta persentase skor masing-masing
- [ ] Total skor mendekati 100% (karena softmax)
- [ ] Tombol Reset berhasil menghapus gambar dan hasil
- [ ] UI responsif dan tidak freeze saat proses inferensi (gunakan `async/await` + loading indicator)

---

## 📌 Referensi

- [flutter_pytorch_lite — pub.dev](https://pub.dev/packages/flutter_pytorch_lite)
- [image_picker — pub.dev](https://pub.dev/packages/image_picker)
- [permission_handler — pub.dev](https://pub.dev/packages/permission_handler)
- Model: `assets/model/coffee_model_flutter.ptl`

---

*Issue dibuat: 2026-04-11 | Proyek: USK Coffee — Flutter*
