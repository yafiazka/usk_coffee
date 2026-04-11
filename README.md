# USK Coffee Classifier

Aplikasi Flutter berbasis Deep Learning untuk klasifikasi dan sortir biji kopi secara on-device menggunakan PyTorch Lite. Aplikasi ini dirancang untuk mendeteksi empat kategori utama biji kopi: **Peaberry, Longberry, Premium, dan Defect**.

## Fitur Utama

- **Inference AI Lokal**: Menjalankan model Deep Learning (`.ptl`) langsung di perangkat tanpa memerlukan koneksi internet.
- **Deteksi Real-time**: Mendukung pengambilan foto langsung dari kamera maupun unggah gambar dari galeri.
- **Analisis Detail**: Menampilkan prediksi utama beserta skor probabilitas (persentase) untuk tiap kelas.
- **Desain Premium**: Antarmuka pengguna yang bersih, responsif, dan bertema kopi.

## Teknologi yang Digunakan

- **Framework**: [Flutter](https://flutter.dev/)
- **AI Engine**: [flutter_pytorch_lite](https://pub.dev/packages/flutter_pytorch_lite) (v0.1.0+3)
- **Image Processing**: [image_picker](https://pub.dev/packages/image_picker)
- **Model Deep Learning**: PyTorch Mobile Optimized (`.ptl`)

## Daftar Kelas Klasifikasi

| Kelas         | Deskripsi                                             |
| ------------- | ----------------------------------------------------- |
| **Peaberry**  | Biji kopi tunggal berbentuk bulat (lantang).          |
| **Longberry** | Biji kopi dengan bentuk memanjang melebihi rata-rata. |
| **Premium**   | Biji kopi kualitas ekspor dengan bentuk sempurna.     |
| **Defect**    | Biji kopi yang cacat, pecah, atau rusak.              |

## Persyaratan Sistem

- **Android SDK**: minimal API 21 (Android 5.0).
- **Hardware**: Disarankan menggunakan perangkat fisik (bukan emulator) untuk performa inferensi AI yang optimal.

## Panduan Instalasi

1. **Clone repositori**:

   ```bash
   git clone [url-repositori-anda]
   ```

2. **Instal dependensi**:

   ```bash
   flutter pub get
   ```

3. **Pastikan model tersedia**:
   Letakkan file model Anda di: `assets/model/coffee_model_flutter.ptl`.

4. **Jalankan Aplikasi**:
   ```bash
   flutter run
   ```

## Struktur Proyek

- `lib/main.dart`: Logika utama UI, pengambilan gambar, dan inferensi model.
- `assets/model/`: Tempat menyimpan model PyTorch Lite.
- `android/`: Konfigurasi platform Android (Permission, FileProvider, dll).

## Lisensi

Proyek ini dibuat untuk keperluan studi dan riset klasifikasi biji kopi.
