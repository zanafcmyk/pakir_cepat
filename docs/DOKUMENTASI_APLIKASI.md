# Dokumentasi Lengkap Aplikasi Parkir Cepat

## 1. Nama Aplikasi dan Tujuan Aplikasi

Nama aplikasi yang dikembangkan dalam proyek ini adalah **Parkir Cepat**. Parkir Cepat merupakan aplikasi mobile berbasis Flutter yang dirancang sebagai prototipe sistem smart parking untuk membantu pengguna mencari lokasi parkir, melihat ketersediaan slot, melakukan booking, membayar biaya parkir secara digital, dan menggunakan tiket QR sebagai bukti akses parkir. Selain menyediakan fitur untuk pengguna umum, aplikasi ini juga menyediakan mode penyedia parkir atau admin yang berfungsi untuk memantau lokasi parkir, kendaraan, transaksi, slot, laporan, dan status operasional tempat parkir.

Secara umum, tujuan utama aplikasi Parkir Cepat adalah mendigitalisasi proses parkir yang selama ini sering dilakukan secara manual. Dalam sistem parkir konvensional, pengguna biasanya harus datang langsung ke lokasi tanpa mengetahui apakah slot masih tersedia atau tidak. Hal ini dapat menyebabkan antrean, pemborosan waktu, ketidakpastian, dan pengalaman pengguna yang kurang efisien. Melalui aplikasi ini, pengguna dapat memperoleh informasi lokasi parkir secara lebih cepat dan dapat melakukan reservasi slot sebelum tiba di lokasi.

Dari sisi penyedia parkir, aplikasi ini bertujuan memberikan dashboard operasional yang sederhana namun informatif. Penyedia parkir dapat melihat jumlah kendaraan masuk, pendapatan harian, slot tersedia, slot aktif, daftar lokasi, monitoring kendaraan, notifikasi operasional, dan laporan statistik. Walaupun versi saat ini masih berupa prototipe lokal tanpa database, struktur fitur yang disediakan sudah menggambarkan alur kerja aplikasi smart parking yang dapat dikembangkan menjadi sistem production pada tahap berikutnya.

Tujuan akademis dari aplikasi ini adalah menyediakan contoh implementasi aplikasi mobile modern yang menggabungkan desain antarmuka, state management, routing, simulasi transaksi, QR Code, dan pemisahan peran pengguna. Aplikasi ini dapat digunakan sebagai bahan laporan proyek, tugas kampus, demonstrasi MVP, atau dasar pengembangan penelitian mengenai digitalisasi layanan parkir.

## 2. Permasalahan yang Diselesaikan Aplikasi

Aplikasi Parkir Cepat dibangun untuk menjawab beberapa permasalahan umum dalam layanan parkir. Permasalahan pertama adalah kurangnya informasi ketersediaan slot parkir secara real-time. Pada banyak lokasi parkir, pengguna baru mengetahui kondisi slot setelah tiba di lokasi. Jika lokasi penuh, pengguna harus mencari alternatif lain, sehingga waktu perjalanan menjadi lebih lama dan konsumsi bahan bakar meningkat.

Permasalahan kedua adalah antrean pada pintu masuk dan pintu keluar parkir. Sistem manual biasanya membutuhkan proses pengambilan karcis, pencatatan kendaraan, pembayaran tunai, dan validasi petugas. Proses ini dapat menjadi lambat terutama pada jam sibuk seperti jam masuk kantor, jam pulang kerja, atau akhir pekan di pusat perbelanjaan.

Permasalahan ketiga adalah kurangnya pencatatan digital bagi pengguna. Pengguna sering tidak memiliki riwayat transaksi parkir yang rapi. Bukti parkir masih berupa karcis fisik yang mudah hilang atau rusak. Dengan tiket digital berbasis QR, pengguna dapat menyimpan bukti parkir di dalam aplikasi dan menggunakannya untuk validasi.

Permasalahan keempat adalah terbatasnya dashboard monitoring bagi penyedia parkir. Pengelola parkir membutuhkan informasi mengenai jumlah slot, kendaraan aktif, pendapatan, transaksi, dan notifikasi operasional. Tanpa dashboard digital, pengambilan keputusan menjadi lebih lambat dan bergantung pada laporan manual.

Permasalahan kelima adalah kurangnya integrasi antara proses booking, pembayaran, dan validasi. Parkir Cepat menyimulasikan satu alur terpadu mulai dari pencarian lokasi, pemilihan slot, booking, pembayaran, pembuatan QR Code, sampai validasi kendaraan keluar. Dengan alur ini, aplikasi memberikan gambaran bagaimana proses parkir modern dapat dibuat lebih efisien.

## 3. Target Pengguna Aplikasi

Target pengguna aplikasi Parkir Cepat terdiri dari dua kelompok utama. Kelompok pertama adalah **customer** atau pengguna parkir. Customer dapat berupa mahasiswa, pekerja kantoran, pengunjung pusat perbelanjaan, pengemudi harian, pengendara ojek online, atau siapa pun yang membutuhkan tempat parkir dengan cepat. Kebutuhan utama kelompok ini adalah menemukan lokasi parkir, mengetahui slot tersedia, mendapatkan estimasi biaya, menyimpan kendaraan, membuat booking, melakukan pembayaran, dan memperoleh tiket digital.

Kelompok kedua adalah **provider** atau penyedia parkir, yang dalam aplikasi juga disebut sebagai admin. Provider dapat berupa pemilik lahan parkir, operator gedung, pengelola mall, pengelola kampus, pengelola kantor, atau petugas yang bertanggung jawab terhadap operasional parkir. Kebutuhan utama provider adalah melihat dashboard, memantau slot, menambahkan lokasi parkir, memvalidasi QR, melihat transaksi, mencetak nota, dan melihat statistik laporan.

Selain dua target utama tersebut, aplikasi ini juga relevan bagi pihak akademik sebagai contoh implementasi aplikasi mobile berbasis Flutter. Mahasiswa dapat mempelajari bagaimana struktur proyek Flutter dibentuk, bagaimana state management digunakan, bagaimana routing diatur, dan bagaimana fitur prototipe dapat dibuat tanpa database terlebih dahulu.

## 4. Fitur Utama Aplikasi

Fitur utama aplikasi dibagi menjadi fitur umum, fitur customer, dan fitur admin. Fitur umum meliputi splash screen, onboarding, login, register, forgot password, delete account, pemilihan role, dan pengalihan halaman sesuai mode akun. Splash screen menampilkan identitas aplikasi, sedangkan onboarding memberikan penjelasan singkat mengenai manfaat aplikasi.

Fitur customer meliputi home dashboard, smart recommendation, daftar lokasi parkir, map lokasi parkir, detail lokasi, tambah kendaraan, booking parkir, tiket QR digital, pembayaran, riwayat parkir, notifikasi, profil pengguna, favorit lokasi parkir, dan perpanjangan durasi parkir. Fitur-fitur ini membentuk alur utama pengguna mulai dari mencari lokasi sampai menyelesaikan transaksi.

Fitur admin meliputi dashboard admin, statistik kendaraan dan pendapatan, map monitoring area, tambah lahan parkir, monitoring kendaraan, scan QR, detail transaksi, cetak nota, statistik laporan, export PDF/Excel secara prototipe, kelola slot parkir, notifikasi admin, profil admin, dan simulasi verifikasi provider. Fitur admin menunjukkan bagaimana aplikasi dapat digunakan oleh pengelola parkir untuk memantau operasional.

Fitur teknis yang menonjol meliputi penggunaan Riverpod sebagai state management, GoRouter sebagai sistem navigasi, fl_chart untuk grafik pendapatan, qr_flutter untuk QR Code, Google Fonts untuk tipografi, serta desain reusable widget untuk menjaga konsistensi UI.

## 5. Penjelasan Fungsi Setiap Halaman Secara Rinci

### 5.1 Splash Screen

Splash Screen adalah halaman pertama yang muncul ketika aplikasi dibuka. Halaman ini menampilkan logo, nama aplikasi, slogan, ilustrasi smart city, dan indikator loading. Secara teknis, halaman ini menggunakan timer selama kurang lebih 1,8 detik. Setelah timer selesai, aplikasi memeriksa state onboarding dan autentikasi. Jika onboarding belum selesai, pengguna diarahkan ke halaman onboarding. Jika onboarding selesai tetapi belum login, pengguna diarahkan ke login. Jika sudah login, pengguna diarahkan ke dashboard sesuai mode akun.

### 5.2 Onboarding Screen

Onboarding Screen berisi tiga halaman pengenalan. Halaman pertama menjelaskan pencarian parkir terdekat, halaman kedua menjelaskan booking parkir online, dan halaman ketiga menjelaskan pembayaran digital serta QR. Onboarding menggunakan PageView dan menyimpan indeks halaman aktif di state. Pengguna dapat menekan tombol lanjut atau melewati onboarding. Setelah selesai, state `onboardingDone` diubah menjadi true.

### 5.3 Login Screen

Login Screen menyediakan pilihan masuk sebagai pengguna parkir atau penyedia parkir. Form login berisi email, nomor HP, remember me, tombol lupa password, tombol masuk, tombol masuk dengan Google, dan tombol login nomor HP. Pada versi prototipe, semua tombol login mengarah ke proses login lokal di `AppController`, bukan ke backend. Setelah login, aplikasi menentukan route tujuan melalui fungsi `landingRouteFor`.

### 5.4 Register Screen

Register Screen digunakan untuk membuat akun baru. Pengguna dapat memilih role customer atau provider. Untuk customer, form berisi nama lengkap, email, nomor HP, password, dan konfirmasi password. Untuk provider, aplikasi menampilkan tambahan data verifikasi seperti nama tempat parkir, alamat lahan, foto lahan, titik lokasi, kapasitas kendaraan, dan dokumen identitas. Jika provider melakukan registrasi, status akun menjadi pending verification.

### 5.5 Forgot Password Screen

Forgot Password Screen menyimulasikan proses reset password. Pengguna memasukkan email atau nomor HP, lalu menekan tombol kirim OTP. Setelah itu, field OTP dan password baru muncul. Jika pengguna menyimpan password baru, state `passwordResetRequested` berubah menjadi true. Fitur ini masih bersifat prototipe karena belum terhubung ke layanan email, SMS, atau OTP production.

### 5.6 Delete Account Screen

Delete Account Screen digunakan untuk menghapus akun. Pengguna diminta memasukkan password verifikasi dan mencentang persetujuan bahwa data akan hilang. Jika disetujui, fungsi `deleteAccount` dijalankan dan state aplikasi dikembalikan ke data seed awal. Dalam versi prototipe, penghapusan akun hanya mereset state lokal.

### 5.7 Provider Verification Screen

Provider Verification Screen menampilkan status verifikasi provider, yaitu pending, verified, atau rejected. Halaman ini juga menampilkan data pengajuan provider seperti nama tempat parkir, alamat, titik lokasi, kapasitas, foto lahan, dan identitas. Tersedia tombol simulasi verified dan rejected untuk kebutuhan demo. Jika status verified, provider dapat masuk ke dashboard admin.

### 5.8 Customer Home Screen

Customer Home Screen adalah dashboard utama customer. Halaman ini menampilkan sapaan pengguna, search field, hero banner, smart recommendation, daftar tempat parkir terdekat, live slot realtime, rekomendasi smart parking, dan ringkasan profil parkir. Rekomendasi dihitung dari data lokal, misalnya lokasi terdekat berdasarkan distance, termurah berdasarkan price per hour, dan tidak ramai berdasarkan rasio slot tersedia.

### 5.9 Customer Map Screen

Customer Map Screen menampilkan placeholder peta lokasi parkir. Peta ini belum menggunakan SDK map asli, namun sudah menampilkan marker dan daftar lokasi. Pengguna dapat memilih lot pada peta dan membuka detail lokasi. Halaman ini menggambarkan rancangan fitur map monitoring yang nantinya dapat diganti dengan Google Maps, Mapbox, atau layanan peta lain.

### 5.10 Parking Detail Screen

Parking Detail Screen menampilkan informasi lengkap lokasi parkir yang dipilih. Informasi yang ditampilkan meliputi nama lokasi, alamat, harga per jam, slot tersedia, jam buka, rating, gambar ilustratif, tombol favorite, dan tombol booking. Halaman ini menjadi penghubung antara proses pencarian lokasi dan proses reservasi.

### 5.11 Add Vehicle Screen

Add Vehicle Screen memungkinkan customer menyimpan data kendaraan. Field yang tersedia meliputi plat nomor, jenis kendaraan, jumlah kendaraan, dan durasi parkir. Jenis kendaraan dipilih melalui segmented choice yang mencakup motor, mobil, dan truk. Setelah disimpan, data kendaraan masuk ke list kendaraan di AppState dan menjadi selectedVehicle.

### 5.12 Booking Screen

Booking Screen digunakan untuk membuat reservasi parkir. Halaman ini menampilkan lokasi terpilih, kendaraan terpilih, pilihan slot parkir, waktu masuk, estimasi biaya, durasi, dan ringkasan kendaraan. Pengguna memilih slot yang masih available. Setelah konfirmasi, aplikasi membuat booking, mengunci slot, membuat countdown reservasi, menambah notifikasi customer, dan menambah notifikasi admin.

### 5.13 Customer Ticket Screen

Customer Ticket Screen menampilkan tiket digital. Jika belum ada booking aktif, halaman menampilkan empty state dan tombol booking. Jika ada booking aktif, halaman menampilkan QR Code menggunakan paket `qr_flutter`, nomor tiket, plat kendaraan, jenis kendaraan, lokasi parkir, waktu masuk, countdown reservasi, status pembayaran, tombol extend durasi, tombol QR keluar, dan tombol scan pembayaran.

### 5.14 Payment Screen

Payment Screen menyimulasikan proses pembayaran. Pengguna dapat memilih metode pembayaran seperti QRIS, e-wallet, tunai, atau kartu debit/kredit. Aplikasi menampilkan ringkasan biaya, nomor tiket, dan total pembayaran. Setelah tombol bayar ditekan, fungsi `payBooking` memperbarui booking menjadi lunas, memasukkan transaksi ke history, menghapus countdown reservasi, dan menambahkan notifikasi pembayaran.

### 5.15 Parking History Screen

Parking History Screen menampilkan daftar riwayat transaksi parkir. Setiap riwayat menampilkan ID transaksi, status, lokasi, plat kendaraan, waktu parkir, dan total biaya. Data history berasal dari seed awal dan juga bertambah setelah pembayaran berhasil.

### 5.16 Customer Notifications Screen

Customer Notifications Screen menampilkan daftar notifikasi pengguna. Notifikasi dapat berisi booking berhasil, durasi hampir habis, pembayaran berhasil, atau perpanjangan durasi. Notifikasi ditampilkan menggunakan widget `NotificationsList`.

### 5.17 Customer Profile Screen

Customer Profile Screen menampilkan data profil pengguna, email, jumlah kendaraan, jumlah transaksi, pengaturan akun, akses ke hapus akun, dan tombol logout. Halaman ini menjadi pusat pengelolaan identitas customer pada prototipe.

### 5.18 Admin Dashboard Screen

Admin Dashboard Screen adalah halaman utama admin. Halaman ini menampilkan statistik kendaraan masuk, pendapatan hari ini, slot tersedia, slot aktif, jumlah cabang, grafik revenue, aksi cepat, preview CCTV, dan prediksi kepadatan berbasis AI secara prototipe. Data yang ditampilkan sebagian berasal dari state dan sebagian merupakan data dummy untuk simulasi.

### 5.19 Admin Map Screen

Admin Map Screen menampilkan monitoring lokasi parkir dari sisi admin. Admin dapat melihat map placeholder dan daftar lokasi parkir. Setiap lokasi menampilkan slot tersedia dan alamat. Halaman ini berguna untuk pengelolaan multi-cabang.

### 5.20 Add Parking Lot Screen

Add Parking Lot Screen digunakan admin untuk menambahkan lokasi parkir baru. Form berisi nama lokasi, alamat, placeholder map, kapasitas kendaraan, harga per jam, dan placeholder upload foto. Setelah disimpan, lot baru masuk ke list `lots` di state dan menjadi selectedLot.

### 5.21 Vehicle Monitoring Screen

Vehicle Monitoring Screen menampilkan monitoring kendaraan dan transaksi. Halaman ini menggunakan data history untuk menampilkan kendaraan, lokasi, waktu, total, dan status. Tersedia search field untuk simulasi filter plat nomor atau lokasi.

### 5.22 Scan QR Screen

Scan QR Screen menyimulasikan proses scan QR kendaraan. Jika ada booking aktif, halaman menampilkan nomor tiket aktif dan tombol verifikasi kendaraan. Tombol konfirmasi kendaraan keluar memanggil fungsi `markVehicleExit`, membuka kembali slot, menghapus booking aktif, dan mengembalikan admin ke dashboard.

### 5.23 Transaction Detail Screen

Transaction Detail Screen menampilkan detail transaksi pertama dari history. Data yang ditampilkan meliputi ID transaksi, lokasi, kendaraan, waktu parkir, total biaya, dan status. Halaman ini menggambarkan fitur audit transaksi.

### 5.24 Receipt Screen

Receipt Screen menampilkan nota digital. Halaman ini berisi judul nota, QR Code berdasarkan ID transaksi, informasi transaksi, status pembayaran, total, dan tombol cetak nota. Tombol cetak masih berupa simulasi dengan snackbar.

### 5.25 Statistics Screen

Statistics Screen menampilkan laporan statistik admin. Halaman ini berisi pendapatan harian, pendapatan bulanan, line chart revenue, tombol export PDF, tombol export Excel, dan ringkasan slot tersedia serta slot penuh. Export laporan masih berupa simulasi.

### 5.26 Manage Slots Screen

Manage Slots Screen digunakan untuk mengelola status slot. Setiap slot ditampilkan dengan label dan status tersedia atau penuh. Admin dapat mengubah status slot melalui Switch. Perubahan ini memanggil fungsi `toggleSlot` pada AppController.

### 5.27 Admin Notifications Screen

Admin Notifications Screen menampilkan daftar notifikasi admin seperti kendaraan masuk, slot hampir penuh, pembayaran lunas, dan kendaraan keluar. Data notifikasi berasal dari state lokal.

### 5.28 Admin Profile Screen

Admin Profile Screen menampilkan profil admin, status verifikasi, jumlah lahan parkir, menu edit profil, data lahan, pengaturan akun, hapus akun, dan logout.

## 6. Alur Penggunaan Aplikasi dari Awal Sampai Akhir

Alur penggunaan aplikasi dimulai dari Splash Screen. Setelah splash selesai, aplikasi mengecek apakah onboarding sudah selesai. Jika belum, pengguna masuk ke Onboarding Screen. Setelah onboarding selesai, pengguna masuk ke Login Screen. Pengguna dapat memilih masuk sebagai customer atau provider.

Jika pengguna memilih customer, aplikasi mengubah `currentMode` menjadi customer dan mengarahkan pengguna ke Customer Home Screen. Dari dashboard, pengguna dapat melihat rekomendasi lokasi, memilih lokasi parkir, membuka detail, menambahkan lokasi ke favorite, atau langsung melakukan booking. Sebelum booking, pengguna dapat menambahkan kendaraan melalui Add Vehicle Screen. Setelah kendaraan tersedia, pengguna memilih slot dan waktu masuk pada Booking Screen. Ketika booking dikonfirmasi, aplikasi membuat objek Booking, mengubah slot menjadi tidak tersedia, mengaktifkan countdown reservasi, dan menampilkan tiket pada Customer Ticket Screen.

Setelah tiket muncul, pengguna dapat menuju Payment Screen. Pengguna memilih metode pembayaran dan menekan tombol bayar. Sistem memperbarui status booking menjadi lunas, mencatat transaksi ke history, serta menambahkan notifikasi. Pengguna dapat melihat QR Code sebagai tiket masuk dan keluar. Jika durasi ingin ditambah, pengguna dapat menekan tombol extend 1 jam. Jika transaksi sudah selesai, admin dapat melakukan proses kendaraan keluar melalui Scan QR Screen.

Jika pengguna masuk sebagai provider, aplikasi mengarahkan ke Admin Dashboard jika akun verified. Jika akun provider baru mendaftar, status awal adalah pending dan diarahkan ke Provider Verification Screen. Pada halaman tersebut, status dapat disimulasikan menjadi verified. Setelah verified, provider dapat membuka dashboard admin, memantau statistik, menambahkan lokasi parkir, mengelola slot, melihat map monitoring, memantau kendaraan, scan QR, melihat transaksi, mencetak nota, dan membuka statistik laporan.

## 7. Struktur Folder Project dan Fungsi Setiap Folder

Struktur proyek Flutter ini terdiri dari beberapa folder utama. Folder `lib` adalah pusat kode Dart aplikasi. Di dalamnya terdapat `main.dart`, `app.dart`, dan subfolder `src`. File `main.dart` menjadi entry point aplikasi dan menjalankan `ProviderScope` agar Riverpod dapat digunakan di seluruh aplikasi. File `app.dart` menjadi pusat komposisi aplikasi, berisi import package utama, deklarasi `part`, provider global, router, dan widget `ParkirCepatApp`.

Folder `lib/src/core` berisi bagian inti aplikasi. File `app_state.dart` berisi model data, enum, state utama, seed data, dan `AppController`. File `app_theme.dart` berisi warna, tema, format currency, format tanggal, dan format durasi.

Folder `lib/src/auth` berisi halaman autentikasi seperti splash, onboarding, login, register, forgot password, delete account, dan provider verification. Folder `lib/src/customer` berisi halaman untuk customer, termasuk home, map, detail lokasi, tambah kendaraan, booking, tiket, pembayaran, riwayat, notifikasi, dan profil. Folder `lib/src/admin` berisi halaman admin seperti dashboard, map, tambah lahan, monitoring, scan QR, detail transaksi, receipt, statistik, kelola slot, notifikasi, dan profil.

Folder `lib/src/shared` berisi widget reusable yang digunakan di berbagai halaman. Contohnya adalah shell layout, premium card, button, status badge, summary row, notification list, chart, map placeholder, slider, dan komponen visual lain.

Folder `android` berisi konfigurasi native Android seperti Gradle, AndroidManifest, MainActivity, dan resource launcher. Folder `ios` berisi konfigurasi native iOS. Folder `web` berisi konfigurasi web seperti `index.html`, manifest, favicon, dan icon. Folder `windows` berisi konfigurasi desktop Windows yang dihasilkan Flutter. Folder `test` berisi file pengujian widget. Folder `docs` berisi dokumen proyek seperti PRD dan dokumentasi ini.

## 8. Arsitektur Aplikasi yang Digunakan

Arsitektur aplikasi saat ini adalah arsitektur prototipe berbasis single source of truth lokal. Semua state utama disimpan dalam `AppState`, sedangkan perubahan state dilakukan melalui `AppController`. UI membaca state melalui Riverpod dan memanggil method controller ketika terjadi interaksi.

Secara konseptual, arsitektur ini dapat dijelaskan sebagai berikut: user interface berada pada layer screen dan widget, state berada pada `AppState`, logic manipulasi data berada pada `AppController`, dan routing berada pada `GoRouter`. Karena aplikasi belum menggunakan backend, belum ada layer service API atau repository database yang terpisah. Namun, pola yang digunakan sudah memungkinkan migrasi ke arsitektur yang lebih formal pada fase berikutnya.

Jika dikembangkan lebih lanjut, aplikasi dapat dipisahkan menjadi presentation layer, domain layer, data layer, repository, dan service. Untuk versi saat ini, pemusatan logic di `AppController` dipilih agar prototipe mudah dipahami, cepat dikembangkan, dan tidak membutuhkan konfigurasi backend.

## 9. State Management yang Digunakan dan Alasannya

State management yang digunakan adalah **Riverpod** melalui `flutter_riverpod`. Provider utama dideklarasikan sebagai `StateNotifierProvider<AppController, AppState>`. Dengan pola ini, UI dapat melakukan `ref.watch(appControllerProvider)` untuk membaca state dan `ref.read(appControllerProvider.notifier)` untuk memanggil fungsi perubahan state.

Alasan penggunaan Riverpod adalah karena Riverpod menyediakan manajemen state yang aman, terstruktur, dan mudah diuji. Riverpod tidak bergantung langsung pada BuildContext untuk membaca state sehingga lebih fleksibel dibanding beberapa pendekatan lain. Riverpod juga cocok untuk aplikasi Flutter modern karena mendukung pemisahan logic dari widget.

Dalam aplikasi ini, Riverpod membantu menyederhanakan pembaruan UI. Ketika controller mengubah state, widget yang melakukan watch akan rebuild secara otomatis. Contohnya, ketika booking dibuat, slot berubah menjadi penuh, tiket aktif muncul, notifikasi bertambah, dan tampilan yang membaca data tersebut akan ikut memperbarui diri.

## 10. Routing dan Navigation yang Digunakan

Routing aplikasi menggunakan **GoRouter**. GoRouter dipilih karena mendukung deklarasi route yang jelas, navigasi berbasis path, dan cocok untuk aplikasi dengan banyak halaman. Semua route utama dideklarasikan di `app.dart` dalam provider `appRouterProvider`.

Route awal aplikasi adalah `/`, yaitu SplashScreen. Route autentikasi mencakup `/onboarding`, `/login`, `/register`, `/forgot-password`, `/delete-account`, dan `/provider-verification`. Route customer mencakup `/customer/home`, `/customer/map`, `/customer/tickets`, `/customer/notifications`, `/customer/profile`, `/customer/parking-detail`, `/customer/add-vehicle`, `/customer/booking`, `/customer/payment`, dan `/customer/history`. Route admin mencakup `/admin/dashboard`, `/admin/map`, `/admin/monitoring`, `/admin/notifications`, `/admin/profile`, `/admin/add-lot`, `/admin/scan-qr`, `/admin/transaction-detail`, `/admin/receipt`, `/admin/statistics`, dan `/admin/manage-slots`.

Navigasi menggunakan kombinasi `context.go`, `context.push`, dan `context.pop`. `go` digunakan untuk mengganti halaman utama, sedangkan `push` digunakan untuk membuka halaman detail atau form di atas stack navigasi.

## 11. Model Data yang Digunakan

Model data utama didefinisikan di `app_state.dart`. Enum `AccountMode` membedakan customer dan provider. Enum `AccountStatus` membedakan status pending, verified, dan rejected. Enum `VehicleKind` membedakan motor, mobil, dan truk. Enum `PaymentMethod` membedakan QRIS, e-wallet, cash, dan card.

Model `ParkingLot` menyimpan data lokasi parkir seperti id, nama, alamat, harga per jam, slot tersedia, total slot, jarak, estimasi waktu, jam buka, rating, dan warna aksen. Model ini juga memiliki getter `isFull` untuk menentukan apakah lokasi penuh.

Model `Vehicle` menyimpan data kendaraan berupa id, plat nomor, jenis kendaraan, jumlah, dan durasi parkir. Model `Booking` menyimpan nomor tiket, kode slot, nama lokasi, plat kendaraan, label kendaraan, waktu masuk, estimasi biaya, metode pembayaran, dan status lunas. Model `TransactionRecord` menyimpan data riwayat transaksi. Model `NoticeItem` menyimpan data notifikasi. Model `ParkingSlot` menyimpan data slot parkir. Model `ProviderApplication` menyimpan data pengajuan provider.

`AppState` menyatukan seluruh data tersebut ke dalam satu state besar. Data awal dibuat melalui `AppState.seeded()`, sehingga aplikasi dapat langsung digunakan tanpa database.

## 12. Penjelasan Setiap Screen dan Widget Utama

Screen utama sudah dijelaskan pada bagian halaman. Widget utama berada di `shared_widgets.dart`. `CustomerShell` dan `AdminShell` menyediakan layout utama dengan bottom navigation. `AppShell` adalah komponen dasar yang menerima daftar destinasi dan menampilkan child page. `AuthScaffold` menyediakan layout form autentikasi yang konsisten.

`PremiumCard` digunakan sebagai container visual utama dengan radius besar dan shadow lembut. `HeaderSection` digunakan untuk judul dan subtitle halaman. `HeroBanner` digunakan pada dashboard customer untuk menampilkan informasi promosi atau ajakan. `SearchField` menyediakan input pencarian. `SectionTitle` menyediakan judul section dengan optional action.

`RoleSelectionCards` dan `RoleSelectionCard` digunakan pada login/register untuk memilih role. `InlineNotice` digunakan untuk menampilkan pesan informasi. `AiRecommendationCard` digunakan untuk menampilkan rekomendasi lokasi. `ParkingLotCard` digunakan untuk menampilkan kartu lokasi parkir. `PrimaryButton` dan `SecondaryButton` digunakan sebagai tombol standar. `SegmentedChoice` digunakan untuk pilihan jenis kendaraan dan metode pembayaran. `StatusBadge`, `SummaryRow`, `EmptyStateCard`, dan `NotificationsList` digunakan untuk menyajikan informasi secara konsisten.

Widget `RevenueChart` menggunakan fl_chart untuk menampilkan grafik pendapatan. `ParkingMapPlaceholder` menampilkan area peta prototipe. `LabeledSlider` digunakan untuk memilih nilai numerik seperti kapasitas, harga, jumlah kendaraan, dan durasi.

## 13. Penjelasan Service dan Repository

Pada versi proyek saat ini, aplikasi belum memiliki folder service dan repository yang aktif. Tidak ada pemanggilan API, database, Supabase, Firebase, atau local persistent storage. Semua logic data berada di `AppController`. Dengan demikian, `AppController` berperan sebagai controller, state manager, sekaligus repository sementara untuk data prototipe.

Keputusan ini sesuai untuk MVP lokal karena aplikasi dapat berjalan tanpa konfigurasi eksternal. Namun, untuk versi production, sangat disarankan menambahkan repository dan service. Repository akan menjadi penghubung antara UI/controller dan data source, sedangkan service akan menangani komunikasi dengan backend, storage, map SDK, payment gateway, dan notification service.

Contoh repository yang dapat dibuat pada fase berikutnya adalah `AuthRepository`, `ParkingRepository`, `BookingRepository`, `PaymentRepository`, dan `NotificationRepository`. Contoh service adalah `AuthService`, `MapService`, `PaymentService`, `QrScannerService`, dan `NotificationService`.

## 14. Penjelasan Proses Autentikasi

Proses autentikasi pada aplikasi masih bersifat lokal. Login tidak memvalidasi password ke server. Ketika pengguna menekan tombol masuk, fungsi `login` pada `AppController` dipanggil dengan parameter mode, email, nomor HP, dan remember me. Controller mengubah state menjadi authenticated dan menentukan mode akun.

Pada registrasi customer, fungsi `register` menyimpan nama, email, nomor HP, mode customer, status verified, dan menandai onboarding selesai. Pada registrasi provider, fungsi yang sama menyimpan data provider application dan menetapkan status pending. Setelah itu pengguna diarahkan ke Provider Verification Screen.

Fungsi logout mengubah `isAuthenticated` menjadi false. Fungsi delete account mengembalikan state ke seed awal. Forgot password hanya mengubah flag `passwordResetRequested` tanpa proses OTP nyata.

## 15. Penjelasan Proses Booking dan Transaksi

Proses booking dimulai ketika pengguna memilih lokasi parkir dan kendaraan. Pada Booking Screen, pengguna memilih slot yang tersedia. Setelah tombol konfirmasi booking ditekan, fungsi `createBooking` dijalankan. Controller mengambil lot terpilih, kendaraan terpilih, menghitung total biaya, membuat objek Booking, mengubah slot terpilih menjadi tidak tersedia, mengatur `reservationLockedUntil`, dan menambahkan notifikasi.

Transaksi belum langsung dianggap lunas ketika booking dibuat. Booking memiliki properti `isPaid` bernilai false. Setelah pengguna melakukan pembayaran pada Payment Screen, fungsi `payBooking` memperbarui booking menjadi lunas, membuat `TransactionRecord`, memasukkan transaksi ke history, menghapus countdown reservasi, dan menambahkan notifikasi customer serta admin.

Jika kendaraan keluar, admin dapat membuka Scan QR Screen dan menekan konfirmasi kendaraan keluar. Fungsi `markVehicleExit` membuka kembali slot yang digunakan, menghapus active booking, dan menambahkan notifikasi kendaraan keluar.

## 16. Penjelasan Proses Pembayaran

Pembayaran pada aplikasi bersifat simulasi. Pengguna dapat memilih metode pembayaran QRIS, e-wallet, tunai, atau kartu. Nilai biaya dihitung dari harga parkir per jam dikalikan durasi parkir kendaraan. Saat tombol bayar ditekan, tidak ada integrasi payment gateway. Aplikasi langsung menganggap pembayaran berhasil.

Walaupun masih simulasi, alur pembayaran sudah menggambarkan proses bisnis dasar. Data pembayaran memengaruhi status booking, notifikasi, history transaksi, dan tiket. Pada versi berikutnya, bagian ini dapat dihubungkan ke Midtrans, Xendit, Stripe, atau payment gateway lokal lain.

## 17. Penjelasan Proses Notifikasi

Notifikasi disimpan sebagai list `NoticeItem` di dalam AppState. Terdapat dua daftar notifikasi, yaitu `customerNotifications` dan `adminNotifications`. Customer menerima notifikasi seperti booking berhasil, pembayaran berhasil, dan durasi diperpanjang. Admin menerima notifikasi seperti slot baru terpakai, pembayaran berhasil, dan kendaraan keluar.

Notifikasi belum menggunakan push notification production. Semua notifikasi hanya muncul di halaman notifikasi dalam aplikasi. Dengan demikian, notifikasi bersifat lokal dan hanya hidup selama state aplikasi berjalan. Pada versi berikutnya, notifikasi dapat dikembangkan menggunakan Firebase Cloud Messaging atau layanan push notification lain.

## 18. Penjelasan Proses QR Code

QR Code dibuat menggunakan paket `qr_flutter`. Pada Customer Ticket Screen, data QR berasal dari `booking.ticketNumber`. Pada Receipt Screen, data QR berasal dari ID transaksi. QR digunakan sebagai representasi digital dari tiket dan nota.

Scan QR pada admin masih berupa simulasi. Halaman Scan QR menampilkan placeholder kamera dan tombol verifikasi. Jika ada active booking, admin dapat menekan verifikasi dan aplikasi menampilkan snackbar bahwa tiket valid. Untuk production, proses ini perlu dihubungkan dengan kamera perangkat dan decoder QR Code.

## 19. Penjelasan Fitur Admin

Fitur admin dirancang untuk menggambarkan kebutuhan penyedia parkir. Admin dapat melihat dashboard operasional, statistik, grafik pendapatan, aksi cepat, CCTV placeholder, dan prediksi kepadatan. Admin juga dapat melihat map monitoring, menambah lokasi, memantau kendaraan, scan QR, melihat detail transaksi, mencetak nota, melihat laporan, export PDF/Excel secara prototipe, mengelola slot, menerima notifikasi, dan mengelola profil.

Fitur admin sangat penting karena aplikasi smart parking tidak hanya melayani customer, tetapi juga harus membantu operator menjalankan bisnis parkir. Pada versi production, fitur admin dapat diperluas dengan manajemen petugas, multi-cabang, laporan real-time, audit log, manajemen harga, dan integrasi perangkat gate.

## 20. Diagram Alur Sistem Dalam Bentuk Teks

```text
Pengguna membuka aplikasi
        |
        v
Splash Screen
        |
        v
Cek onboarding dan login
        |
        +-- onboarding belum selesai --> Onboarding --> Login
        |
        +-- belum login ---------------> Login / Register
        |
        +-- sudah login customer ------> Customer Home
        |
        +-- sudah login provider ------> Provider Verification / Admin Dashboard

Customer Flow:
Customer Home
        |
        v
Pilih lokasi parkir
        |
        v
Detail lokasi / Booking
        |
        v
Pilih kendaraan dan slot
        |
        v
Buat booking
        |
        v
Tiket QR aktif
        |
        v
Pembayaran
        |
        v
History dan notifikasi diperbarui

Admin Flow:
Admin Dashboard
        |
        +--> Tambah lahan parkir
        +--> Monitoring kendaraan
        +--> Kelola slot
        +--> Scan QR
        +--> Detail transaksi
        +--> Cetak nota
        +--> Statistik laporan
```

## 21. Kelebihan Aplikasi

Kelebihan utama aplikasi adalah alur fitur yang cukup lengkap untuk ukuran prototipe. Aplikasi sudah memiliki dua role, onboarding, auth lokal, customer dashboard, booking, pembayaran, QR, history, notifikasi, dashboard admin, monitoring, statistik, dan kelola slot. UI juga dibuat modern dengan warna biru, emerald, putih, shadow halus, kartu premium, dan tipografi Poppins.

Kelebihan lain adalah aplikasi dapat berjalan tanpa database. Hal ini membuat demo lebih mudah dilakukan karena tidak membutuhkan konfigurasi server, akun cloud, API key, atau koneksi internet. Struktur state lokal juga memudahkan pengujian alur dari awal sampai akhir.

Secara teknis, penggunaan Riverpod dan GoRouter membuat aplikasi memiliki fondasi yang baik. Widget reusable juga membantu menjaga konsistensi tampilan. Penggunaan fl_chart dan qr_flutter menunjukkan integrasi package eksternal yang relevan dengan kebutuhan aplikasi.

## 22. Kekurangan Aplikasi Saat Ini

Kekurangan utama aplikasi adalah data belum persistent. Semua data akan kembali ke seed awal ketika aplikasi restart. Aplikasi juga belum memiliki autentikasi nyata, validasi form lengkap, database, backend, payment gateway, map SDK asli, QR scanner kamera, dan push notification.

Beberapa data admin masih bersifat dummy, seperti pendapatan harian, kendaraan masuk, dan prediksi AI. Fitur Google login, OTP, export PDF/Excel, CCTV, dan upload foto juga masih berupa tampilan prototipe. Selain itu, logic aplikasi masih terpusat di AppController sehingga jika aplikasi semakin besar, kode dapat menjadi sulit dipelihara tanpa pemisahan repository dan service.

## 23. Fitur yang Sudah Selesai

Fitur yang sudah selesai untuk kebutuhan MVP lokal meliputi splash screen, onboarding, login lokal, register customer, register provider, provider verification simulation, customer home, customer map placeholder, detail lokasi, tambah kendaraan, booking slot, tiket QR, pembayaran simulasi, riwayat, notifikasi customer, profil customer, dashboard admin, admin map placeholder, tambah lahan, monitoring kendaraan, scan QR simulasi, detail transaksi, receipt, statistik, kelola slot, notifikasi admin, profil admin, logout, dan delete account reset lokal.

Fitur tersebut sudah cukup untuk mendemonstrasikan alur utama aplikasi dari sisi pengguna dan penyedia parkir.

## 24. Fitur yang Masih Prototype

Fitur yang masih prototype meliputi autentikasi backend, login Google, login nomor HP, OTP, reset password nyata, upload foto lahan, upload identitas provider, peta GPS asli, rekomendasi AI nyata, CCTV monitoring, payment gateway, scan QR kamera, export PDF, export Excel, push notification, penyimpanan data permanen, dan sinkronisasi real-time.

Fitur-fitur tersebut sudah memiliki representasi UI, namun belum terhubung dengan layanan eksternal atau backend production. Dengan kata lain, fitur tersebut dapat dipresentasikan sebagai rancangan pengalaman pengguna, tetapi belum dapat digunakan sebagai sistem operasional nyata.

## 25. Rekomendasi Pengembangan Versi Berikutnya

Rekomendasi pertama adalah menambahkan persistence lokal terlebih dahulu, misalnya menggunakan SharedPreferences, Hive, Isar, atau SQLite. Dengan persistence lokal, data kendaraan, booking, dan login tidak hilang ketika aplikasi ditutup.

Rekomendasi kedua adalah memisahkan arsitektur menjadi layer yang lebih jelas. AppController dapat dipecah menjadi AuthController, ParkingController, BookingController, PaymentController, dan NotificationController. Repository dapat dibuat untuk mengakses data, sedangkan service dapat dibuat untuk komunikasi API.

Rekomendasi ketiga adalah menambahkan backend. Backend dapat menggunakan Laravel, Node.js, Firebase, Supabase, atau platform lain. Backend perlu menangani autentikasi, role, user, provider verification, parking lot, slot, booking, payment, ticket, notification, dan report.

Rekomendasi keempat adalah mengintegrasikan map SDK. Fitur map akan lebih berguna jika menggunakan lokasi GPS, marker nyata, jarak aktual, estimasi waktu tempuh, dan navigasi.

Rekomendasi kelima adalah menghubungkan payment gateway. Dengan payment gateway, transaksi dapat divalidasi secara nyata dan status pembayaran tidak hanya simulasi.

Rekomendasi keenam adalah mengembangkan QR scanner menggunakan kamera. Admin perlu dapat memindai QR secara langsung untuk memvalidasi tiket.

Rekomendasi ketujuh adalah menambahkan push notification agar pengguna menerima pengingat durasi parkir, status pembayaran, dan status booking walaupun tidak membuka aplikasi.

Rekomendasi kedelapan adalah menambahkan fitur laporan formal seperti export PDF/Excel, filter tanggal, filter cabang, dan analisis okupansi. Fitur ini akan sangat berguna bagi penyedia parkir.

Rekomendasi kesembilan adalah meningkatkan validasi dan keamanan. Form login, register, booking, dan pembayaran perlu memiliki validasi kuat. Data sensitif seperti password dan identitas provider tidak boleh disimpan sembarangan.

Rekomendasi terakhir adalah melakukan pengujian lebih lengkap, termasuk unit test untuk controller, widget test untuk setiap halaman penting, dan integration test untuk alur booking dari awal sampai selesai.

## 26. Kesimpulan

Parkir Cepat merupakan prototipe aplikasi smart parking yang sudah menggambarkan alur digitalisasi parkir secara cukup lengkap. Aplikasi ini memiliki dua peran pengguna, yaitu customer dan provider/admin. Customer dapat mencari lokasi, memilih slot, booking, membayar, dan melihat tiket QR. Provider dapat memantau dashboard, menambah lahan, mengelola slot, memonitor kendaraan, scan QR, melihat transaksi, dan membuka laporan.

Dari sisi teknis, aplikasi menggunakan Flutter, Riverpod, GoRouter, fl_chart, qr_flutter, dan Google Fonts. State dikelola secara lokal melalui AppState dan AppController. Walaupun belum menggunakan database, aplikasi sudah dapat digunakan sebagai MVP untuk demonstrasi, laporan kampus, atau dasar pengembangan skripsi.

Dengan pengembangan lanjutan berupa persistence, backend, payment gateway, map SDK, QR scanner, dan push notification, Parkir Cepat dapat berkembang dari prototipe menjadi aplikasi smart parking production yang lebih lengkap dan siap digunakan pada lingkungan nyata.
