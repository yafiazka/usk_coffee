# USK Coffee Classifier

Aplikasi Flutter berbasis Deep Learning untuk klasifikasi dan sortir biji kopi secara online menggunakan integrasi **Gradio API (Hugging Face)**. Aplikasi ini dirancang untuk mendeteksi empat kategori utama biji kopi: **Peaberry, Longberry, Premium, dan Defect**.

Ini Link Hugging Face Space : [Coffee Classifier Space](https://yafiazka-coffee-classifier.hf.space/)

Ini Link Dataset : [Dataset Coffee USK](https://drive.google.com/drive/folders/1jMDKadmh39ihWtb6sTqYXOdmr1yIwS5T?usp=drive_link)

## Fitur Utama

- **Inference AI Online**: Menggunakan model Deep Learning yang dideploy di Hugging Face Spaces melalui Gradio API.
- **Connectivity Check**: Pengecekan otomatis saat aplikasi dibuka untuk memastikan server API siap digunakan.
- **Robust Processing**: Menggunakan alur *upload-then-predict* untuk memastikan pemrosesan gambar yang stabil dari berbagai sumber.
- **Deteksi Fleksibel**: Mendukung pengambilan foto langsung dari kamera maupun unggah gambar dari galeri.
- **Analisis Detail**: Menampilkan prediksi utama beserta skor probabilitas (persentase) untuk setiap kelas.
- **Desain Premium**: Antarmuka pengguna yang bersih, responsif, dan bertema kopi dengan palet warna cokelat elegan.

## Teknologi yang Digunakan

- **Framework**: [Flutter](https://flutter.dev/)
- **Networking**: [http](https://pub.dev/packages/http) (Integrasi Gradio 4 API)
- **Image Processing**: [image_picker](https://pub.dev/packages/image_picker)
- **Permission Management**: [permission_handler](https://pub.dev/packages/permission_handler)
- **API Engine**: Gradio Asynchronous Call (Step-by-step Upload & Predict)

## Daftar Kelas Klasifikasi

| Kelas         | Deskripsi                                             |
| ------------- | ----------------------------------------------------- |
| **Peaberry**  | Biji kopi tunggal berbentuk bulat (lantang).          |
| **Longberry** | Biji kopi dengan bentuk memanjang melebihi rata-rata. |
| **Premium**   | Biji kopi kualitas ekspor dengan bentuk sempurna.     |
| **Defect**    | Biji kopi yang cacat, pecah, atau rusak.              |

## Persyaratan Sistem

- **Android SDK**: minimal API 21 (Android 5.0).
- **Koneksi Internet**: Diperlukan untuk melakukan klasifikasi gambar karena model berjalan di server.

## Panduan Instalasi

1. **Clone repositori**:
   ```bash
   git clone [url-repositori-anda]
   ```
2. **Instal dependensi**:
   ```bash
   flutter pub get
   ```
3. **Jalankan Aplikasi**:
   ```bash
   flutter run
   ```

## Struktur Proyek Utama

- `lib/main.dart`: Antarmuka pengguna utama dan logika integrasi UI.
- `lib/api/model-api.dart`: Service layer untuk komunikasi ke Gradio API (Upload, Call, dan SSE Stream handling).

## Kontributor & Lisensi

Proyek ini dibuat untuk keperluan studi dan riset klasifikasi biji kopi.

