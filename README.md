# Serenity Diary

Flutter ile geliştirilmiş, kişisel günlük ve alışkanlık takibi uygulaması. Veriler cihazda (SQLite) saklanır.

## Özellikler

- **Günlük:** Not ekleme ve listeleme
- **Defterler:** Konulara göre ayrı defterler ve defter notları
- **Alışkanlık takibi:** Alışkanlık ekleme/düzenleme, detay ve arşiv ekranları
- **Su takibi:** Günlük su tüketimi kaydı ve istatistikleri
- **Bahçem:** Alışkanlıklarla ilişkili görsel ilerleme ekranı
- **Ana sayfa:** Takvim, motivasyon kartı ve modül kısayolları
- **Ayarlar:** Kullanıcı tercihleri

## Teknolojiler

Flutter / Dart, Provider (durum yönetimi), sqflite (yerel veritabanı), shared_preferences, table_calendar, intl, google_fonts.

## Mimari

```
lib/
├── models/        Veri modelleri (Note, Habit, Notebook, WaterEntry ...)
├── repository/    Veritabanı erişim katmanı
├── providers/     Durum yönetimi (Provider)
├── screens/       Ekranlar ve widget'lar
└── theme/         Tema
```

## Çalıştırma

```bash
flutter pub get
flutter run
```
