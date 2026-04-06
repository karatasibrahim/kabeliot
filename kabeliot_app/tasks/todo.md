# Kabel IoT App — Görev Listesi

## Faz 1: Proje Kurulumu + Tema (TAMAMLANDI ✅)

- [x] Flutter projesi oluştur (`kabeliot_app`)
- [x] `pubspec.yaml` güncelle — tüm paketler eklendi
- [x] Asset klasörleri oluştur (`animations/`, `images/`, `icons/`)
- [x] Tema sistemi: `app_colors.dart`, `app_text_styles.dart`, `app_decorations.dart`, `app_theme.dart`
- [x] Paylaşılan widget'lar: `iot_grid_painter`, `gradient_scaffold`, `kabel_logo`, `kabel_button`, `kabel_text_field`, `loading_overlay`
- [x] Navigasyon: `app_routes.dart`, `app_router.dart` (GoRouter + Riverpod)
- [x] Auth state provider: `auth_state_provider.dart`
- [x] Ekranlar: `splash_screen`, `login_screen`, `register_screen`, `dashboard_screen`
- [x] `main.dart` ve `app.dart` giriş noktaları
- [x] `flutter pub get` — 107 paket indirildi
- [x] `build_runner build` — `.g.dart` dosyaları üretildi
- [x] `flutter analyze` — **0 hata, 0 uyarı**

## Faz 2: Tema Onayı Bekleniyor ⏳

Kullanıcı temayı inceleyip onay verince:

- [ ] Gerçek auth API entegrasyonu (login/register notifier'ları)
- [ ] SecureStorage ile JWT token saklama
- [ ] Dio client + auth interceptor
- [ ] Dashboard'a gerçek cihaz verisi bağlama
- [ ] Splash ekranına Lottie animasyonu ekleme
- [ ] Hata yönetimi (snackbar, error state)
- [ ] Form validasyonlarını güçlendirme

## Faz 3: Gelecek Ekranlar

- [ ] Cihaz detay ekranı
- [ ] Bildirimler ekranı
- [ ] Profil & ayarlar ekranı
- [ ] Cihaz ekleme ekranı

---

_Güncelleme: 2026-04-06_
