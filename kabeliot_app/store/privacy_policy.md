# Gizlilik Politikası / Privacy Policy
**Kabel Core — KABEL Teknoloji**
Son güncelleme / Last updated: 06 Mayıs 2025

---

## TÜRKÇE

### 1. Giriş
KABEL Teknoloji olarak gizliliğinize saygı duyuyor ve kişisel verilerinizi korumayı öncelik olarak benimsiyoruz. Bu Gizlilik Politikası, Kabel Core mobil uygulamasını ("Uygulama") kullandığınızda hangi verilerin toplandığını, nasıl kullanıldığını ve nasıl korunduğunu açıklamaktadır.

### 2. Toplanan Veriler

#### 2.1 Hesap Bilgileri
Uygulamaya giriş yaparken Firebase Authentication aracılığıyla e-posta adresiniz ve şifreniz işlenir. Şifreler hiçbir zaman açık metin olarak saklanmaz; Google Firebase altyapısı tarafından şifreli biçimde yönetilir.

#### 2.2 Cihaz ve Sensör Verileri
Bağlı KABEL IoT cihazlarından gelen sensör ölçümleri (sıcaklık, nem, basınç vb.) ve röle durumları ThingsBoard IoT platformu üzerinden aktarılır. Bu veriler cihazlarınıza aittir ve yalnızca size sunulmak amacıyla işlenir.

#### 2.3 Konum İzni
Uygulama, ESP32 tabanlı KABEL cihazlarını WiFi üzerinden keşfetmek için konum iznine ihtiyaç duyar. Bu izin yalnızca yakındaki WiFi ağlarını taramak amacıyla kullanılır; konum veriniz hiçbir sunucuya iletilmez veya saklanmaz.

#### 2.4 Yerel Ağ Erişimi
Cihaz kurulumu (provisioning) sırasında ESP32 erişim noktasına bağlanmak için yerel ağ erişimi kullanılır. Bu süreçte yalnızca cihaz yapılandırma verisi (WiFi kimlik bilgileri) cihaza iletilir; üçüncü taraflarla paylaşılmaz.

#### 2.5 Uygulama İçi Tercihler
Röle isimleri, sensör konfigürasyonları ve otomasyon kuralları gibi kullanıcı tercihleri cihazınızın yerel depolama alanında (SharedPreferences) saklanır. Bu veriler cihazınızı terk etmez.

### 3. Verilerin Kullanım Amacı
Toplanan veriler yalnızca şu amaçlarla kullanılır:
- Kullanıcı kimlik doğrulaması ve hesap güvenliği
- IoT cihazlarınızın gerçek zamanlı izlenmesi ve kontrolü
- Otomasyon kurallarının yerel olarak çalıştırılması
- Uygulama deneyimini kişiselleştirme (isimler, konfigürasyonlar)

Verileriniz reklam, pazarlama veya üçüncü taraflara satış amacıyla **kullanılmaz**.

### 4. Üçüncü Taraf Hizmetler
Uygulama aşağıdaki üçüncü taraf hizmetleri kullanmaktadır:

| Hizmet | Amaç | Gizlilik Politikası |
|---|---|---|
| Google Firebase | Kimlik doğrulama, veritabanı | https://firebase.google.com/support/privacy |
| ThingsBoard | IoT veri aktarımı ve cihaz yönetimi | https://thingsboard.io/docs/reference/privacy-policy/ |

Bu hizmetlerin kendi gizlilik politikaları geçerlidir.

### 5. Veri Güvenliği
- Sunucu ile iletişim TLS/SSL ile şifrelenir.
- Firebase Authentication, endüstri standardı güvenlik protokolleri kullanır.
- Hassas kimlik bilgileri (token, şifre) cihazda şifreli olarak saklanır (Flutter Secure Storage).

### 6. Çocukların Gizliliği
Uygulama 13 yaşın altındaki çocuklara yönelik değildir ve bu yaş grubundan bilerek veri toplanmaz.

### 7. Haklarınız
KVKK kapsamında aşağıdaki haklara sahipsiniz:
- Kişisel verilerinize erişme ve kopyasını talep etme
- Yanlış verilerin düzeltilmesini isteme
- Verilerinizin silinmesini talep etme
- Veri işlemeye itiraz etme

Bu haklarınızı kullanmak için **support@kabelteknoloji.com** adresine yazabilirsiniz.

### 8. İletişim
**KABEL Teknoloji**
E-posta: support@kabelteknoloji.com
Web: https://www.kabelteknoloji.com

### 9. Politika Değişiklikleri
Bu politika güncellendiğinde yeni sürüm uygulama içinde ve web sitemizde yayınlanır. Önemli değişiklikler için kullanıcılar bildirim alır.

---

## ENGLISH

### 1. Introduction
At KABEL Teknoloji, we respect your privacy and are committed to protecting your personal data. This Privacy Policy explains what data is collected when you use the Kabel Core mobile application ("App"), how it is used, and how it is protected.

### 2. Data We Collect

#### 2.1 Account Information
When you sign in, your email address and password are processed via Firebase Authentication. Passwords are never stored in plain text; they are managed in encrypted form by Google Firebase infrastructure.

#### 2.2 Device and Sensor Data
Sensor measurements (temperature, humidity, pressure, etc.) and relay states from connected KABEL IoT devices are transmitted via the ThingsBoard IoT platform. This data belongs to your devices and is processed solely for display to you.

#### 2.3 Location Permission
The app requires location permission to discover ESP32-based KABEL devices over Wi-Fi. This permission is used only to scan for nearby Wi-Fi networks. Your location data is never transmitted to or stored on any server.

#### 2.4 Local Network Access
Local network access is used during device setup (provisioning) to connect to the ESP32 access point. Only device configuration data (Wi-Fi credentials) is sent to the device during this process; it is not shared with any third party.

#### 2.5 In-App Preferences
User preferences such as relay names, sensor configurations, and automation rules are stored locally on your device (SharedPreferences). This data never leaves your device.

### 3. How We Use Your Data
Collected data is used exclusively for:
- User authentication and account security
- Real-time monitoring and control of your IoT devices
- Local execution of automation rules
- Personalizing the app experience (names, configurations)

Your data is **not** used for advertising, marketing, or sold to third parties.

### 4. Third-Party Services
The App uses the following third-party services:

| Service | Purpose | Privacy Policy |
|---|---|---|
| Google Firebase | Authentication, database | https://firebase.google.com/support/privacy |
| ThingsBoard | IoT data transfer and device management | https://thingsboard.io/docs/reference/privacy-policy/ |

Their respective privacy policies apply to data processed by these services.

### 5. Data Security
- All server communications are encrypted with TLS/SSL.
- Firebase Authentication uses industry-standard security protocols.
- Sensitive credentials (tokens, passwords) are stored encrypted on device (Flutter Secure Storage).

### 6. Children's Privacy
The App is not directed at children under 13, and we do not knowingly collect data from this age group.

### 7. Your Rights
You have the following rights regarding your personal data:
- Access your personal data and request a copy
- Request correction of inaccurate data
- Request deletion of your data
- Object to data processing

To exercise these rights, contact us at **support@kabelteknoloji.com**.

### 8. Contact
**KABEL Teknoloji**
Email: support@kabelteknoloji.com
Website: https://www.kabelteknoloji.com

### 9. Policy Changes
When this policy is updated, the new version will be published within the app and on our website. Users will be notified of significant changes.
