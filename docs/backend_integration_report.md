# NOAA Uzay Havası & Kullanıcı Korelasyonu: Backend Gereksinim Raporu

Bu rapor; Schumann Rezonansı uyarılma skorlarının hesaplanması, kullanıcıların günlük fiziksel/ruhsal durumlarını kaydetmesi (Günlük/Notlar), bu verilerin uzay havasıyla ilişkilendirilmesi ve hem kişiye özel (AI destekli) hem de toplu (Admin paneli istatistikleri) analizler sunulması için gereken mimariyi ve backend gereksinimlerini tanımlar.

---

## 🌟 YENİ VİZYON: KULLANICI GÜNLÜĞÜ VE KOLEKTİF KORELASYON ANALİZİ
Kullanıcıların her gün uygulamayı ziyaret ederek nasıl hissettiklerini kaydetmesi sağlanacak, bu veriler o günkü uzay havası verileriyle (Schumann Skoru, Kp, Güneş Rüzgarı vb.) eşleştirilecek ve hem kullanıcıya hem de yönetime istatistiksel/yapay zeka destekli analizler sunulacaktır.

### Hibrit Arayüz Tasarımı
Veri kalitesini korumak ve analizi kolaylaştırmak için arayüzde **hibrit** bir yapı kurulacaktır:
1.  **Hazır Semptom Etiketleri (Chips/Tags - Zorunlu/Seçmeli):** Kullanıcı "Baş Ağrısı", "Uykusuzluk", "Canlı Rüyalar", "Eklem Ağrısı", "Yüksek Enerji", "Odaklanma Güçlüğü/Brain Fog", "Kaygı/Huzursuzluk" gibi önceden tanımlanmış etiketleri tek bir dokunuşla seçer. Bu sayede veriler standartlaştırılır (doğrudan veri tabanı sorgularında kullanılabilir hale gelir).
2.  **Kişisel Not Alanı (Metin Kutusu - İsteğe Bağlı):** Kullanıcı dilerse o güne ait detaylı kişisel günlük notlarını yazar. Bu serbest metin, yapay zeka analizlerinde (AI summary) derinlik katmak için kullanılacaktır.

---

## 🧮 ANALİZ VE GRAFİK EŞLEME YÖNTEMİ

### 1. 📊 Grafiklerin Veri Kaynağı Ayrımı
Ekranda bulunan iki grafiğin veri beslemesi şu şekilde olacaktır:
*   **Üst Grafik (Schumann Spektrogramı - 0.0 - 10.0):** Bu grafik tamamen yeni formülle hesaplanan **Schumann Uyarılma Skoru'nu (0.0 - 10.0)** gösterecektir. Frekans bantlarının parlaklığı ve renk geçişleri bu yeni birleşik skorla belirlenir.
*   **Alt Grafik (Jeomanyetik Kp Eğilimi - 0 - 9):** Bu grafik mevcut haliyle kalacak ve sadece ham **Kp Endeksi** değerlerini (0-9 arası bar çubukları) göstermeye devam edecektir.

### 2. Canlı İstatistik Hesaplama Mantığı (Aktif Kullanıcı Bazlı)
Toplu harita veya admin istatistiklerindeki semptom oranları hesaplanırken payda olarak "toplam kayıtlı kullanıcı sayısı" değil, **o gün/saat dilimi içerisinde aktif olarak durum bildirimi yapmış kullanıcı sayısı** esas alınacaktır.
*   **Formül:** `(Semptomu Bildiren Aktif Kişi Sayısı) / (O Gün Aktif Bildirim Yapan Toplam Kişi Sayısı)`

---

## 🗄️ VERİ TABANI TABLO TASARIMI ÖNERİSİ

### 1. `daily_space_weather` (Uzay Havası Arşivi)
*   `id` (Primary Key)
*   `timestamp` (DateTime, UTC)
*   `kp_index` (Float) -> Alt Grafik (Kp Eğilimi) burayı okur.
*   `schumann_score` (Float, 0.0 - 10.0) -> Üst Grafik (Schumann Spektrogramı) burayı okur.
*   `solar_wind_speed` (Float)
*   `solar_wind_density` (Float)
*   `magnetic_field_bt` (Float)
*   `magnetic_field_bz` (Float)

### 2. `user_journals` (Kullanıcı Günlükleri)
*   `id` (Primary Key, UUID)
*   `user_id` (Foreign Key -> Users)
*   `date` (Date, YYYY-MM-DD)
*   `mood_score` (Int, 1-5 veya 1-10 arası genel iyi hissetme skoru)
*   `symptoms` (Array/JSON list, örn: `["headache", "insomnia", "vivid_dreams", "joint_pain", "high_energy"]`)
*   `notes` (Text, kullanıcının kişisel günlüğü/notu - isteğe bağlı)
*   `created_at` (DateTime)

---

## 🛠️ BACKEND API ENDPOINT GEREKSİNİMLERİ

### 1. Kullanıcı Günlük Servisleri
*   `POST /api/journal`: Kullanıcının o güne ait durumunu, semptomlarını ve notlarını kaydeder.

### 2. Yapay Zeka Destekli Kişisel Analiz Servisi
*   `GET /api/journal/ai-analysis`: Backend, kullanıcının semptom etiketlerini ve notlarını **Schumann Skorları (0.0-10.0)** ile eşleştirerek yapay zeka üzerinden kişiselleştirilmiş analiz üretir.

### 3. Yönetici Korelasyon Analiz Servisi (Admin Dashboard)
*   `GET /api/admin/correlations`: **Schumann Skoru** seviyelerine (0-10.0) göre, aktif bildirim yapan kullanıcılar üzerinden semptom oranlarını hesaplar.
