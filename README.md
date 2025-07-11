# 📝 Online Clipboard

Flutter tabanlı bu uygulama, kullanıcının panoya kopyaladığı metinleri web arayüzünde görüntülemesini sağlar. Aynı zamanda geçmiş metinleri Firebase veritabanında saklar ve Firebase Authentication ile güvenli oturum yönetimi sunar.

## 🚀 Özellikler

- 📋 Panoya kopyalanan metinleri otomatik olarak algılama
- 🕓 Metin geçmişini Firebase'e kaydetme
- 🔐 Firebase Authentication ile oturum açma ve hesap oluşturma
- ☁️ Firebase Firestore ile bulut veri depolama
- 🌐 Web platformu desteği
- 📱 Mobil destek (isteğe bağlı genişletilebilir)

## 🛠️ Kullanılan Teknolojiler

- Flutter
- Firebase Authentication
- Firebase Firestore
- Clipboard Listener (Flutter tarafında)

## 📦 Kurulum

### 1. Bu repoyu klonlayın:

```bash
git clone https://github.com/Emirhan1Arslan/online_clipboard.git
cd online_clipboard
```

### 2. Gerekli paketleri yükleyin:

```bash
flutter pub get
```

### 3. Firebase bağlantısını yapılandırın:

- Firebase projesi oluşturun: https://console.firebase.google.com
- `web/index.html` dosyasına Firebase konfigürasyon bilgilerini ekleyin
- `lib/firebase_options.dart` dosyasını oluşturmak için aşağıdaki komutu kullanın:

```bash
flutterfire configure
```

### 4. Uygulamayı çalıştırın:

```bash
flutter run -d chrome
```

## 🖼️ Ekran Görüntüsü

Eklenecek

## 📂 Klasör Yapısı

```plaintext
/lib
├── main.dart               # Uygulamanın başlangıç noktası
├── screens/               # Giriş, kayıt ve ana ekranlar
├── services/              # Firebase servisleri
├── models/                # (Varsa) veri modelleri
└── utils/                 # Yardımcı sınıflar
```

## 👤 Geliştirici

**Emirhan Arslan**

- GitHub: [@Emirhan1Arslan](https://github.com/Emirhan1Arslan)

## 📝 Lisans

Bu proje BBCLUB.space için tasarlanmıştır. Daha fazlası için www.bbclub.space adresini ziyaret ediniz.
