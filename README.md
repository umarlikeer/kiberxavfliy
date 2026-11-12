# KiberXavfliy

![Platform](https://img.shields.io/badge/platform-iOS%2015+-blue.svg)
![Language](https://img.shields.io/badge/language-Swift%20%7C%20Rust-orange.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

**KiberXavfliy** — iOS qurilmalar uchun professional kiberxavfsizlik ilovasi. SwiftUI interfeys va Rust yadro (FFI orqali) kombinatsiyasidan foydalanadi.

## Xususiyatlari

### Tarmoq Xavfsizligi
- **Lokal tarmoq skaneri** — Tarmoqdagi qurilmalarni va ularning ochiq portlarini aniqlash
- **Port skaneri** — Belgilangan host'da portlarni tekshirish
- **IP ma'lumotlari** — IP manzil haqida batafsil ma'lumot

### SSL/TLS Tekshiruvi
- Sertifikat amal qilish muddati
- Issuer va subject ma'lumotlari
- TLS versiyasi va cipher suite
- Ogohlantirishlar va xatolar

### Parol Xavfsizligi
- **Parol kuchini baholash** (0-100 ball)
- **Parol generatori** — kuchli tasodifiy parollar
- Batafsil tahlil (harflar, raqamlar, maxsus belgilar)
- Kriptanaliz vaqti taxmini

### Xavfsizlik Maslahatlari
- 8 ta kategoriya bo'yicha maslahatlar
- Muhimlik darajasi (yuqori/o'rtacha/past)
- Qidiruv va filtrlash

## Arxitektura

```
KiberXavfliy/
├── ios/                          # iOS ilova (SwiftUI)
│   ├── KiberXavfliy/
│   │   ├── Views/               # UI komponentlari
│   │   ├── Models/              # Ma'lumot modellari
│   │   ├── FFI/                 # Rust bilan bog'lanish
│   │   └── KiberXavfliyApp.swift
│   └── Package.swift
├── rust-core/                    # Rust yadro kutubxonasi
│   ├── src/
│   │   ├── lib.rs               # Asosiy modul
│   │   ├── ffi.rs               # FFI eksportlari
│   │   ├── network.rs           # Tarmoq skaneri
│   │   ├── crypto.rs            # Kriptografiya
│   │   ├── password.rs          # Parol tahlili
│   │   └── ssl.rs               # SSL tekshiruvi
│   └── Cargo.toml
└── scripts/
    ├── build-rust.sh            # Rust build skripti
    ├── create-ipa.sh            # IPA export skripti
    └── setup-project.sh         # Xcode sozlash
```

## O'rnatish

### Talablar
- macOS 12+ (Monterey)
- Xcode 14+
- Rust 1.70+
- iOS 15+ (maqsad qurilma)

### 1. Loyihani klonlash

```bash
git clone https://github.com/yourusername/kiberxavfliy.git
cd kiberxavfliy
```

### 2. Rust core'ni build qilish

```bash
make setup   # Birinchi marta
make rust    # Har safar
```

### 3. Xcode'da ochish

```bash
cd ios
open KiberXavfliy.xcodeproj
```

### 4. Build Settings

- `Objective-C Bridging Header`: `KiberXavfliy/FFI/kiberxavfliy_core.h`
- `Library Search Paths`: `$(PROJECT_DIR)/KiberXavfliy/Libraries`
- `Other Linker Flags`: `-lkiberxavfliy_core`

## Rust FFI Funksiyalari

| Funksiya | Tavsif |
|----------|--------|
| `kx_version()` | Kutubxona versiyasi |
| `kx_scan_network()` | Tarmoq skaneri |
| `kx_scan_ports()` | Port skaneri |
| `kx_check_ssl()` | SSL sertifikat tekshiruvi |
| `kx_analyze_password()` | Parol kuchini baholash |
| `kx_password_details()` | Parol tafsilotlari |
| `kx_sha256()` | SHA-256 hash |
| `kx_md5()` | MD5 hash |
| `kx_base64_encode()` | Base64 encode |
| `kx_base64_decode()` | Base64 decode |
| `kx_generate_password()` | Parol generatsiyasi |
| `kx_security_tips()` | Xavfsizlik maslahatlari |
| `kx_ip_info()` | IP ma'lumotlari |

## IPA Build

```bash
./scripts/create-ipa.sh
```

## Litsenziya

MIT License

## Eslatma

Bu ilova **xavfsizlik tadqiqoti va ta'lim** maqsadlarida yaratilgan.
