# Dart Development Service (DDS) Hata Çözüm Rehberi

## Sorun
```
Error connecting to the service protocol: failed to connect to http://127.0.0.1:52985/e2xmlcfL5pg=/ 
DartDevelopmentServiceException: Failed to start Dart Development Service
```

## Çözüm Adımları (Sırayla Deneyin)

### 1. ADB ve Emülatörü Yeniden Başlatma
```bash
# ADB'yi durdur
adb kill-server

# ADB'yi başlat
adb start-server

# Bağlı cihazları kontrol et
adb devices

# Emülatörü yeniden başlat
```

### 2. Flutter Clean ve Rebuild
```bash
cd /Users/alaettintopal/Desktop/Projects/edusocial

# Flutter cache'i temizle
flutter clean

# Pub paketlerini yeniden yükle
flutter pub get

# Uygulamayı yeniden çalıştır
flutter run
```

### 3. Port Çakışmasını Kontrol Etme
```bash
# Kullanılan portları kontrol et (macOS)
lsof -i :52985

# Eğer port kullanılıyorsa, o process'i sonlandır
kill -9 <PID>
```

### 4. Flutter Run ile Özel Port Belirtme
```bash
# Farklı bir port ile çalıştır
flutter run --dds-port=0

# Veya belirli bir port
flutter run --dds-port=9100
```

### 5. Emülatör Ağ Ayarlarını Kontrol Etme
- Android Studio'da emülatör ayarlarından:
  - Cold Boot Now seçeneğini deneyin
  - Emülatörü tamamen kapatıp yeniden açın
  - Wipe Data seçeneğini deneyin (son çare)

### 6. Flutter SDK İzinlerini Düzeltme
```bash
# Flutter SDK izinlerini düzelt
sudo chown -R $(whoami) /opt/homebrew/Caskroom/flutter/3.29.3/flutter/bin/cache/

# Alternatif olarak Flutter'ı yeniden yükleyin
```

### 7. DDS'i Devre Dışı Bırakma (Geçici Çözüm)
```bash
# DDS olmadan çalıştır (hot reload çalışmaz ama uygulama çalışır)
flutter run --disable-dds
```

### 8. Android Studio/VS Code Yeniden Başlatma
- IDE'yi tamamen kapatıp yeniden açın
- Flutter ve Dart eklentilerini güncelleyin

### 9. Flutter Channel ve Versiyon Kontrolü
```bash
# Flutter versiyonunu kontrol et
flutter --version

# Flutter'ı güncelle
flutter upgrade

# Stable channel'da olduğunuzdan emin olun
flutter channel stable
flutter upgrade
```

### 10. En Etkili Çözüm (Çoğu Durumda İşe Yarar)
```bash
# 1. Tüm Flutter process'lerini sonlandır
pkill -f flutter

# 2. ADB'yi yeniden başlat
adb kill-server && adb start-server

# 3. Emülatörü yeniden başlat

# 4. Projeyi temizle
cd /Users/alaettintopal/Desktop/Projects/edusocial
flutter clean
flutter pub get

# 5. Yeniden çalıştır
flutter run
```

## Hala Çalışmıyorsa

1. **Firewall Kontrolü**: macOS Firewall'un Flutter/Dart'a izin verdiğinden emin olun
2. **VPN Kapatma**: VPN aktifse kapatıp tekrar deneyin
3. **Antivirus Kontrolü**: Antivirus yazılımı portları engelliyor olabilir
4. **Flutter SDK Yeniden Kurulumu**: Flutter SDK'yı tamamen silip yeniden kurun

## Notlar
- Bu hata genellikle geçicidir ve yukarıdaki adımlarla çözülür
- Uygulama çalışıyor ama hot reload çalışmıyorsa, `--disable-dds` ile çalıştırabilirsiniz
- Production build'de bu sorun olmaz, sadece debug modunda görülür

