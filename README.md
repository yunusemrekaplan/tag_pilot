# TAG Pilot

Mobil TAG şoförleri için geliştirilen, gelir-gider ve kazanç takibi sağlayan basit ama işlevsel bir Flutter uygulaması.

## 🎯 Amaç

TAG şoförlüğü yaparken fark ettiğim temel bir ihtiyaca çözüm üretmek:
- Her seferin net kazancı anlık olarak bilinmiyor.
- Yakıt gideri, km başına maliyet gibi veriler şoför tarafından manuel hesaplanıyor.
- Gün sonunda "ne kazandım, ne harcadım?" sorusuna net cevap alınamıyor.

Bu sorunları çözmek için TAG Pilot'u geliştirdim.

## 🚀 Özellikler

- Yolculuk bazlı kazanç takibi
- Otomatik net gelir hesaplama
- Yakıt maliyeti ve başabaş nokta analizi
- Geçmiş sefer kayıtları
- Grafikle desteklenen haftalık/aylık özetler

## 🧮 Hesaplama Mantığı

- Kullanıcı sadece toplam KM ve aldığı ücreti girer.
- Uygulama, tanımlanan `ortalama yakıt tüketimi` ve `benzin litresi fiyatı` üzerinden gideri hesaplar.
- `Net Kazanç = Ücret - Tahmini Yakıt Gideri`

## 📱 Uygulama Görselleri

| Araç Ekleme | Dashboard | Paket Seçimi | Yakıt Seçimi | Dashboard | Yolculuk Ekle | Gider Ekle | Rapor & Analiz | Rapor & Analiz |
|-------------|-----------|--------------|--------------|-----------|---------------|------------|----------------|----------------|
| ![Ekran1](https://github.com/yunusemrekaplan/tag_pilot/blob/master/screenshots/aracekle.png) | ![Ekran2](https://raw.githubusercontent.com/yunusemrekaplan/tag_pilot/main/screenshots/dash1.png) | ![Ekran3](https://raw.githubusercontent.com/yunusemrekaplan/tag_pilot/main/screenshots/paketsec.png) | ![Ekran4](https://raw.githubusercontent.com/yunusemrekaplan/tag_pilot/main/screenshots/yakitsec.png) | ![Ekran5](https://raw.githubusercontent.com/yunusemrekaplan/tag_pilot/main/screenshots/dash2.png) | ![Ekran6](https://raw.githubusercontent.com/yunusemrekaplan/tag_pilot/main/screenshots/yolculukekle.png) | ![Ekran7](https://raw.githubusercontent.com/yunusemrekaplan/tag_pilot/main/screenshots/giderekle.png) | ![Ekran8](https://raw.githubusercontent.com/yunusemrekaplan/tag_pilot/main/screenshots/raporanaliz1.png) | ![Ekran9](https://raw.githubusercontent.com/yunusemrekaplan/tag_pilot/main/screenshots/raporanaliz2.png) |

## 🛠️ Teknolojiler

- Flutter
- Firebase (Firestore + Auth)
- State Management: GetX

## 👤 Geliştirici

**Yunus Emre Kaplan**  
📧 yunusemrekaplan1@hotmail.com  
🔗 [LinkedIn](https://www.linkedin.com/in/yunus-emre-kaplan-203b05234)  
🐙 [GitHub](https://github.com/yunusemrekaplan)
