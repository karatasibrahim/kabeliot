# Son Yapılanlar — Kabel IoT App

## 2026-04-06 — Oturum 2: Dashboard + Navigasyon + Menüler

### Login → Dashboard Yönlendirmesi Düzeltildi
- `LoginScreen` → `ConsumerStatefulWidget`'a çevrildi
- `_onLogin()` içinde `ref.read(authStateProvider.notifier).setAuthenticated(true)` çağrısı eklendi
- GoRouter redirect mekanizması otomatik olarak `/home`'a yönlendiriyor

### Navigasyon Mimarisi — StatefulShellRoute
- **`app_routes.dart`** güncellendi — `/dashboard` → `/home`, yeni rotalar eklendi:
  - `/home`, `/devices`, `/notifications`, `/profile`
  - `/devices/add`, `/profile/settings`
- **`app_router.dart`** yeniden yazıldı — `StatefulShellRoute.indexedStack` ile bottom nav shell
- **`main_shell.dart`** oluşturuldu — Material 3 `NavigationBar` ile 4 sekme

### Dashboard (Home Ekranı) — Yeniden Tasarlandı
**Dosya**: `lib/features/home/presentation/home_screen.dart`
- **Başlık**: Dinamik selamlama (günaydın/iyi günler/iyi akşamlar) + MQTT durum göstergesi
- **2×2 Özet Grid**:
  - Toplam Cihaz: 12
  - Sensörler: 8 (cyan)
  - Röle Çıkışı: 6 (amber)
  - Çevrimiçi: 9 (yeşil)
- **Hızlı İşlemler**: Cihaz Ekle, Yenile, MQTT Bağlan, Grafik Görünüm (yatay scroll)
- **Son Aktivite**: Timeline kartı (cihaz bağlanma/kopma, sensör uyarısı, röle tetikleme)
- **Cihaz Önizlemesi**: İlk 3 cihaz + "Tümünü Gör →" linki

### Cihazlar Ekranı
**Dosya**: `lib/features/devices/presentation/devices_screen.dart`
- Arama çubuğu (ad veya ID)
- Filtre chipler: Tümü / Çevrimiçi / Çevrimdışı / Sensör / Röle
- 6 mock cihaz (sensör sayısı, röle sayısı, MQTT konusu gösteriliyor)
- Sol şerit rengi online/offline durumunu yansıtıyor
- FAB: "Cihaz Ekle" → AddDeviceScreen

### Cihaz Ekleme Ekranı — WiFi Provisioning Wizard
**Dosya**: `lib/features/devices/presentation/add_device_screen.dart`
- 3 adım animasyonlu wizard:
  1. **Hazırlık**: ESP32'yi AP moduna alma talimatları
  2. **Ağ Bilgisi**: Cihaz adı + WiFi SSID + şifre girişi
  3. **Bağlanıyor**: Loading → Başarı animasyonu (mock)
- MQTT konu önizlemesi başarı ekranında gösteriliyor

### Bildirimler Ekranı
**Dosya**: `lib/features/notifications/presentation/notifications_screen.dart`
- Tarih gruplaması: Bugün / Dün / Bu Hafta
- Okunmuş/okunmamış durumu (sol şerit + nokta göstergesi)
- Tek tıkla okundu işareti + "Tümünü Oku" butonu
- Tür: bağlantı, sıcaklık uyarısı, röle tetikleme, firmware güncelleme

### Profil Ekranı
**Dosya**: `lib/features/profile/presentation/profile_screen.dart`
- Kullanıcı kartı: Avatar (baş harfler) + ad + email + rol badge
- Bölüm menüleri: Hesap / Cihaz Yönetimi / Tercihler
- Çıkış Yapma: Onay dialog'u → `authStateProvider.logout()`
- Doğrudan linkler: MQTT Ayarları, Cihaz Ekle, Tüm Cihazlar

### Ayarlar Ekranı
**Dosya**: `lib/features/profile/presentation/settings_screen.dart`
- MQTT: Sunucu adresi + Port + TLS toggle
- Bildirimler: Cihaz online/offline, sensör uyarısı, röle değişimi toggle'ları
- Uygulama bilgisi: versiyon, yapı tarihi, SDK
- Kaydet butonu + SnackBar geri bildirimi

---

## 2026-04-06 — Oturum 1: Proje Kurulumu + Tema

### Flutter Projesi Oluşturuldu
- `kabeliot_app/` dizininde Flutter projesi
- Org: `com.kabelteknoloji`, paket: 14 bağımlılık

### Tema Sistemi — "Industrial Cyber"
| Token | Hex | Kullanım |
|---|---|---|
| background | `#0A0E1A` | Koyu lacivert |
| primary | `#0EA5E9` | Elektrik mavi |
| accent | `#06B6D4` | Cyan |
| success | `#10B981` | Online |
| error | `#EF4444` | Offline/Hata |

### Temel Dosyalar
- `core/theme/` — app_colors, app_text_styles (Inter + JetBrains Mono), app_decorations, app_theme
- `shared/widgets/` — gradient_scaffold, kabel_button, kabel_text_field, kabel_logo, iot_grid_painter
- `assets/fonts/` — Inter.ttf, JetBrainsMono.ttf (bundle edildi, internet gerekmez)

---

## Doğrulama
```
flutter pub get    ✅
build_runner build ✅  (.g.dart dosyaları üretildi)
flutter analyze    ✅  0 hata, 0 uyarı
```

## Bekleyen: Sonraki Fazlar
- [ ] Gerçek auth API entegrasyonu
- [ ] MQTT bağlantısı (mqtt_client paketi)
- [ ] ESP32 WiFi provisioning (gerçek HTTP)
- [ ] Sensör verileri canlı grafikler
- [ ] Cihaz detay ekranı
