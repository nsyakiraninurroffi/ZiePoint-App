<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=gradient&customColorList=12&height=220&section=header&text=ZiePoint&fontSize=90&fontColor=ffffff&fontAlignY=38&desc=School%20Management%20%E2%80%94%20Reimagined&descAlignY=58&descSize=18&descColor=d4d0ff&animation=fadeIn" width="100%"/>

<br/>

<p>
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white"/>
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white"/>
  <img src="https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white"/>
  <img src="https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white"/>
  <img src="https://img.shields.io/badge/Express-000000?style=for-the-badge&logo=express&logoColor=white"/>
</p>

<p>
  <img src="https://img.shields.io/badge/Architecture-MVVM-7C6FF7?style=flat-square"/>
  <img src="https://img.shields.io/badge/State-Provider-9B95F9?style=flat-square"/>
  <img src="https://img.shields.io/badge/UI-Glassmorphism-B8B3FC?style=flat-square"/>
  <img src="https://img.shields.io/badge/Platform-Web%20%7C%20Android%20%7C%20iOS-5B52E8?style=flat-square"/>
  <img src="https://img.shields.io/badge/License-MIT-34C782?style=flat-square"/>
</p>

<br/>

```
  ╔══════════════════════════════════════════════════════════╗
  ║   Bukan sekadar aplikasi sekolah.                        ║
  ║   Ini adalah cara baru guru dan siswa berinteraksi       ║
  ║   dengan data — elegan, cepat, dan real-time.            ║
  ╚══════════════════════════════════════════════════════════╝
```

<br/>

[① Tentang](#-tentang-ziepoint) · [② Fitur](#-fitur-unggulan) · [③ Tech Stack](#-tech-stack) · [④ Mulai](#-getting-started) · [⑤ Struktur](#-struktur-project) · [⑥ Kontribusi](#-kontribusi)

</div>

---

<br/>

## ✦ Tentang ZiePoint

**ZiePoint** lahir dari satu pertanyaan sederhana:

> *"Kenapa aplikasi manajemen sekolah selalu terasa berat, jelek, dan membosankan?"*

Jawabannya adalah aplikasi ini.

ZiePoint adalah platform manajemen catatan siswa berbasis Flutter yang dibangun dengan **arsitektur MVVM yang bersih**, **glassmorphism UI yang immersive**, dan **real-time data flow** — dirancang untuk guru yang ingin mencatat pelanggaran atau prestasi siswa dalam hitungan detik, dan untuk siswa yang ingin melihat perkembangan diri mereka sendiri dengan jelas.

Tidak ada clutter. Tidak ada loading lama. Hanya pengalaman yang **smooth, professional, dan worth it.**

<br/>

---

## ✦ Fitur Unggulan

<br/>

```
  ┌─────────────────────────────────────────────────────────────────┐
  │                                                                  │
  │   🔐  Smart Auth          Role-based login — Guru & Siswa       │
  │   📋  Input Pelanggaran   Catat & kategorikan dengan cepat      │
  │   🏆  Input Prestasi      Rayakan pencapaian siswa              │
  │   📊  Student Dashboard   Riwayat poin personal yang elegan     │
  │   ⚡  Real-time           Live clock · koneksi · auto-refresh   │
  │   🌙  Glassmorphism UI    Deep navy + soft indigo aesthetic      │
  │   📱  Cross-platform      Web · Android · iOS — satu codebase   │
  │   🗃️  Offline First       Hive cache, tetap jalan tanpa net     │
  │   🔒  Secure by Default   JWT · secure storage · route guard    │
  │   🧪  Production Ready    Unit test · widget test · CI/CD       │
  │                                                                  │
  └─────────────────────────────────────────────────────────────────┘
```

<br/>

---

## ✦ Tech Stack

<br/>

<div align="center">

| Lapisan | Teknologi | Peran |
|:--------|:----------|:------|
| 📱 **UI Framework** | Flutter 3 + Dart | Cross-platform interface |
| 🧠 **Arsitektur** | MVVM + Provider | Clean, testable state management |
| 🌐 **HTTP Client** | Dio | API calls + smart interceptors |
| 🗃️ **Local Cache** | Hive | Offline-first data persistence |
| 🧭 **Navigasi** | GoRouter | Auth-guarded, deep-link ready |
| ✨ **Animasi** | flutter_animate | Micro-interactions yang refined |
| 🔒 **Keamanan** | flutter_secure_storage | Encrypted token management |
| 🖥️ **Backend** | Node.js + Express | Lightweight REST API |
| 🗄️ **Database** | MySQL 8 | Relational data storage |
| 🚀 **CI/CD** | GitHub Actions | Auto analyze · test · build |

</div>

<br/>

---

## ✦ Getting Started

<br/>

### Apa yang kamu butuhkan

```
  ✔  Flutter SDK  ≥ 3.0.0
  ✔  Node.js      ≥ 18.0.0
  ✔  MySQL        ≥ 8.0
  ✔  Git
```

<br/>

### 01 — Clone project

```bash
git clone https://github.com/YOUR_USERNAME/ziepoint.git
cd ziepoint
```

<br/>

### 02 — Setup backend

```bash
cd backend
npm install
cp .env.example .env
```

Isi file `.env` dengan konfigurasi database kamu:

```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=ziepoint
JWT_SECRET=your_secret_key
PORT=3000
```

Lalu jalankan:

```bash
npm run dev
# ✔ Server running at http://localhost:3000
```

<br/>

### 03 — Setup Flutter

```bash
flutter pub get
```

Buat file environment di root project:

**`.env.dev`**
```env
API_BASE_URL=http://localhost:3000
ENV=development
APP_NAME=ZiePoint Dev
```

**`.env.prod`**
```env
API_BASE_URL=https://api.ziepoint.com
ENV=production
APP_NAME=ZiePoint
```

<br/>

### 04 — Jalankan aplikasi

```bash
# 🌐 Web
flutter run -d chrome --dart-define-from-file=.env.dev

# 📱 Android
flutter run -d android --dart-define-from-file=.env.dev

# 📦 Build APK
flutter build apk --release --dart-define-from-file=.env.prod
```

<br/>

---

## ✦ Akun Default (Development)

<br/>

<div align="center">

| Role | Login | Password |
|:-----|:------|:---------|
| 👨‍🏫 Guru | budi@sekolah.id | `guru123` |
| 👨‍🏫 Guru | siti@sekolah.id | `guru123` |
| 👨‍🎓 Siswa | *(sesuai data di DB)* | *(sesuai data di DB)* |

</div>

> ⚠️ Akun ini hanya untuk development. Ganti sebelum deploy ke production.

<br/>

---

## ✦ Struktur Project

<br/>

```
ziepoint/
│
├── 📁 lib/
│   │
│   ├── 📁 core/
│   │   ├── dio_client.dart           ← Singleton Dio + auth interceptors
│   │   ├── router.dart               ← GoRouter + redirect guard by role
│   │   ├── theme.dart                ← Dark glassmorphism design system
│   │   ├── validators.dart           ← Form validators (Indonesian messages)
│   │   ├── app_logger.dart           ← Structured logger, silent on release
│   │   ├── local_db.dart             ← Hive init + box registry
│   │   └── env.dart                  ← dart-define environment reader
│   │
│   ├── 📁 models/
│   │   ├── user_model.dart           ← Auth user (HiveType: 2)
│   │   ├── student_profile.dart      ← Student data (HiveType: 0)
│   │   ├── student_summary.dart      ← Lightweight dropdown model
│   │   └── violation_record.dart     ← Catatan siswa (HiveType: 1)
│   │
│   ├── 📁 repositories/
│   │   ├── auth_repository.dart              ← Abstract contract
│   │   ├── auth_repository_impl.dart         ← Token + API delegate
│   │   ├── student_repository.dart           ← Abstract contract
│   │   └── student_repository_impl.dart      ← Cache-first strategy
│   │
│   ├── 📁 services/
│   │   ├── auth_service.dart             ← Login/logout endpoints
│   │   ├── token_manager.dart            ← Memory + secure_storage
│   │   ├── notification_service.dart     ← Glass SnackBar system
│   │   └── connectivity_service.dart     ← Real-time connection stream
│   │
│   ├── 📁 viewmodels/
│   │   ├── login_viewmodel.dart                  ← Auth + error handling
│   │   ├── student_dashboard_viewmodel.dart      ← Profile + history + pagination
│   │   └── teacher_input_viewmodel.dart          ← Form + save + feedback
│   │
│   ├── 📁 screens/
│   │   ├── login_page.dart               ← Immersive glassmorphism login
│   │   ├── student_dashboard.dart        ← Personal point history UI
│   │   └── teacher_input_page.dart       ← Violation & achievement form
│   │
│   ├── 📁 widgets/
│   │   ├── glass_card.dart               ← Reusable BackdropFilter card
│   │   ├── glass_dropdown.dart           ← Custom animated dropdown
│   │   ├── glass_snackbar.dart           ← Themed success/error toast
│   │   ├── skeleton_card.dart            ← Shimmer loading states
│   │   ├── empty_state.dart              ← No-data illustration widget
│   │   ├── error_state.dart              ← Error + retry button
│   │   └── connection_indicator.dart     ← Live connection status dot
│   │
│   └── main.dart                         ← App entry · MultiProvider · Hive · Router
│
├── 📁 backend/
│   ├── 📁 routes/
│   │   ├── login.js                  ← POST /api/login/guru & /siswa
│   │   ├── students.js               ← GET student list & profile
│   │   └── records.js                ← POST/GET violations & achievements
│   ├── 📁 middleware/
│   │   └── auth.js                   ← JWT verification middleware
│   ├── db.js                         ← MySQL connection pool
│   └── server.js                     ← Express entry point
│
├── 📁 test/
│   ├── 📁 viewmodels/
│   │   ├── login_viewmodel_test.dart
│   │   ├── student_dashboard_viewmodel_test.dart
│   │   └── teacher_input_viewmodel_test.dart
│   └── 📁 screens/
│       ├── login_page_test.dart
│       └── student_dashboard_test.dart
│
├── 📁 .github/
│   └── 📁 workflows/
│       └── ci.yml                    ← Analyze → Test → Build → Upload APK
│
├── .env.dev                          ← Dev config (git ignored)
├── .env.prod                         ← Prod config (git ignored)
├── .gitignore
├── pubspec.yaml
└── README.md
```

<br/>

---

## ✦ Alur Arsitektur

<br/>

```
  ┌─────────────────────────────────────────────────────┐
  │                                                      │
  │   Screens  ──watch/call──►  ViewModels               │
  │                                  │                   │
  │                           depends on                 │
  │                                  ▼                   │
  │                           Repositories               │
  │                          (abstract layer)            │
  │                                  │                   │
  │                      ┌───────────┴───────────┐       │
  │                      ▼                       ▼       │
  │               Local Cache               API Layer    │
  │                (Hive DB)            (Dio → Express)  │
  │                      │                       │       │
  │                      └───────────┬───────────┘       │
  │                                  ▼                   │
  │                            MySQL Database            │
  │                                                      │
  └─────────────────────────────────────────────────────┘
```

<br/>

---

## ✦ Kontribusi

<br/>

ZiePoint adalah project yang terus berkembang. Kalau kamu punya ide, fix, atau improvement — **pull request selalu terbuka.**

```bash
# Fork repo ini
# Buat branch baru
git checkout -b feat/nama-fiturmu

# Commit dengan conventional commits
git commit -m "feat: tambahkan fitur keren"

# Push dan buka Pull Request
git push origin feat/nama-fiturmu
```

**Conventional commit guide:**

```
feat:     ← fitur baru
fix:      ← perbaikan bug
refactor: ← restrukturisasi kode
style:    ← perubahan UI/styling
docs:     ← update dokumentasi
test:     ← tambah/update test
chore:    ← hal-hal lain
```

<br/>

---

## ✦ License

Dirilis di bawah lisensi **MIT** — bebas digunakan, dimodifikasi, dan didistribusikan dengan atribusi.

Lihat file [LICENSE](LICENSE) untuk detail lengkap.

<br/>

---

<div align="center">


<img src="https://capsule-render.vercel.app/api?type=waving&color=gradient&customColorList=12&height=120&section=footer" width="100%"/>

<sub>© 2025 ZiePoint · Built different, built better.</sub>

</div>
