# Son Yapılanlar — Kabel IoT App

## 2026-04-06 — Proje Kurulumu + Tema + Ekran İskeleti

### Flutter Projesi Oluşturuldu

- `kabeliot_app/` dizininde Flutter projesi oluşturuldu
- Org: `com.kabelteknoloji`, proje adı: `kabeliot_app`
- Platform: iOS + Android

### Paketler Eklendi (`pubspec.yaml`)

| Paket | Versiyon | Amaç |
|---|---|---|
| go_router | ^15.0.0 | Navigasyon |
| flutter_riverpod | ^2.6.1 | State management |
| riverpod_annotation | ^2.6.1 | Kod üretimi |
| freezed_annotation | ^2.4.4 | Immutable modeller |
| json_annotation | ^4.9.0 | JSON serileştirme |
| dio | ^5.9.0 | HTTP istemci |
| flutter_secure_storage | ^9.2.4 | JWT token saklama |
| shared_preferences | ^2.3.5 | Genel depolama |
| google_fonts | ^6.2.1 | Inter + JetBrains Mono |
| flutter_svg | ^2.0.14 | SVG desteği |
| lottie | ^3.3.1 | Animasyonlar |
| flutter_animate | ^4.5.2 | Micro-animasyonlar |
| flutter_screenutil | ^5.9.3 | Responsive boyutlama |
| shimmer | ^3.0.0 | Yükleme efekti |

### Tema Sistemi — "Industrial Cyber"

Dosyalar: `lib/core/theme/`

- **`app_colors.dart`** — Renk paleti:
  - Arka plan: `#0A0E1A` (koyu lacivert)
  - Ana renk (primary): `#0EA5E9` (elektrik mavi)
  - Vurgu: `#06B6D4` (cyan)
  - Başarı/Online: `#10B981`, Uyarı: `#F59E0B`, Hata/Offline: `#EF4444`

- **`app_text_styles.dart`** — Tipografi:
  - Inter (tüm UI metinleri)
  - JetBrains Mono (cihaz ID'leri, sensör değerleri)

- **`app_decorations.dart`** — Tekrar kullanılabilir BoxDecoration/InputDecoration factory'leri

- **`app_theme.dart`** — `ThemeData.dark()` tabanlı tam tema (AppBar, ElevatedButton, TextField, Card, SnackBar...)

### Paylaşılan Widget'lar (`lib/shared/widgets/`)

- **`iot_grid_painter.dart`** — Devre kartı görünümlü CustomPainter arka plan
- **`gradient_scaffold.dart`** — Tüm ekranlar için standart koyu gradient zemin
- **`kabel_logo.dart`** — Animasyonlu marka logo widget'ı (3 boyut seçeneği)
- **`kabel_button.dart`** — Gradient + glow CTA butonu (loading state dahil)
- **`kabel_text_field.dart`** — Focus glow, obscure toggle destekli text field
- **`loading_overlay.dart`** — Tam ekran yükleme katmanı

### Navigasyon (`lib/core/router/`)

- **`app_routes.dart`** — Rota sabitleri (`/`, `/login`, `/register`, `/dashboard`)
- **`app_router.dart`** — GoRouter + Riverpod entegrasyonu, otomatik auth redirect

### State Management (`lib/shared/providers/`)

- **`auth_state_provider.dart`** — Global oturum durumu Riverpod provider'ı

### Ekranlar

| Ekran | Dosya |
|---|---|
| Splash | `lib/features/splash/presentation/splash_screen.dart` |
| Login | `lib/features/auth/presentation/login/login_screen.dart` |
| Register | `lib/features/auth/presentation/register/register_screen.dart` |
| Dashboard | `lib/features/dashboard/presentation/dashboard_screen.dart` |

### Doğrulama

```
flutter pub get    → 107 paket indirildi ✅
build_runner build → .g.dart dosyaları üretildi ✅
flutter analyze    → 0 hata, 0 uyarı ✅
```

---

### Bekleyen: Tema Onayı

Kullanıcı temayı (`Industrial Cyber` — koyu lacivert + elektrik mavi + cyan) inceleyip onay verdikten sonra:
- Auth API entegrasyonu
- Gerçek cihaz verisi bağlama
- Lottie splash animasyonu
- Hata yönetimi
