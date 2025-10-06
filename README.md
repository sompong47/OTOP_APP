# OTOP APP

แอปพลิเคชัน OTOP (One Tambon One Product) สำหรับการจัดการและแสดงผลิตภัณฑ์ชุมชนไทย

## 📱 เกี่ยวกับโปรเจค

โปรเจคนี้เป็นแอปพลิเคชัน Full Stack ที่พัฒนาด้วย Flutter เพื่อรองรับการจัดการและแสดงผลิตภัณฑ์ OTOP ซึ่งเป็นผลิตภัณฑ์ชุมชนของไทยที่มีเอกลักษณ์เฉพาะถิ่น

## ✨ ฟีเจอร์หลัก

- 🏪 แสดงรายการผลิตภัณฑ์ OTOP
- 🔍 ค้นหาและกรองผลิตภัณฑ์
- 📋 รายละเอียดผลิตภัณฑ์
- 🛒 ระบบตะกร้าสินค้า
- 👤 ระบบผู้ใช้และการจัดการบัญชี
- 📍 แสดงตำแหน่งที่ตั้งผลิตภัณฑ์

## 🛠️ เทคโนโลยีที่ใช้

### Frontend
- **Flutter** - Framework สำหรับพัฒนา Mobile Application
- **Dart** - ภาษาโปรแกรมมิ่ง

### Backend
- API [สำหรับเชื่อมต่อข้อมูล(https://otopbacknd-production.up.railway.app/)
- Database สำหรับจัดเก็บข้อมูล Postgres
- deploy Raiway

## 📋 ความต้องการของระบบ

- Flutter SDK (เวอร์ชัน 3.0 ขึ้นไป)
- Dart SDK
- Android Studio / Xcode (สำหรับ emulator)
- IDE: VS Code หรือ Android Studio

## 🚀 การติดตั้งและใช้งาน

### 1. Clone Repository

```bash
git clone https://github.com/sompong47/OTOP_APP.git
cd OTOP_APP
```

### 2. ติดตั้ง Dependencies

```bash
flutter pub get
```

### 3. ตรวจสอบการตั้งค่า Flutter

```bash
flutter doctor
```

### 4. รันแอปพลิเคชัน

```bash
# รันบน Android
flutter run

# รันบน iOS
flutter run -d ios

# รันบน Web
flutter run -d chrome
```

## 📂 โครงสร้างโปรเจค

```
OTOP_APP/
├── lib/
│   ├── main.dart           # Entry point ของแอป
│   ├── models/             # Data models
│   ├── screens/            # หน้าจอต่างๆ
│   ├── widgets/            # Custom widgets
│   ├── services/           # API services
│   └── utils/              # Helper functions
├── assets/                 # รูปภาพและ resources
├── android/                # Android configuration
├── ios/                    # iOS configuration
└── pubspec.yaml           # Dependencies
```

## 🔧 การตั้งค่า

### Environment Variables

สร้างไฟล์ `.env` และเพิ่มการตั้งค่าดังนี้:

```env
API_BASE_URL=your_api_url
API_KEY=your_api_key
```

### Firebase Configuration (ถ้ามี)

1. ดาวน์โหลด `google-services.json` สำหรับ Android
2. ดาวน์โหลด `GoogleService-Info.plist` สำหรับ iOS
3. วางไฟล์ในตำแหน่งที่เหมาะสม

## 📱 สร้าง Build

### Android

```bash
flutter build apk --release
# หรือ
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

## 🧪 การทดสอบ

```bash
# รัน unit tests
flutter test

# รัน integration tests
flutter test integration_test
```

## 📸 Screenshots
หน้าแรก
<img width="319" height="688" alt="image" src="https://github.com/user-attachments/assets/94dc93e2-d7dd-47ec-9f94-c0ee039fea45" />
หน้าคำสั่งซื้อ
<img width="320" height="678" alt="image" src="https://github.com/user-attachments/assets/206d2857-7976-4b43-86e5-2256f9a240a9" />
หน้าจัดการคำสั่งซื้อของผู้ขาย
<img width="320" height="678" alt="image" src="https://github.com/user-attachments/assets/b7f64891-346b-43cc-80f0-d79c8f23e6f5" />
หน้าตระกร้าสินค้า
<img width="326" height="687" alt="image" src="https://github.com/user-attachments/assets/c73fa202-f856-4d9f-96a0-09522c4a7e34" />


## 🤝 การมีส่วนร่วม

หากต้องการมีส่วนร่วมในการพัฒนา:

1. Fork โปรเจค
2. สร้าง Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit การเปลี่ยนแปลง (`git commit -m 'Add some AmazingFeature'`)
4. Push ไปยัง Branch (`git push origin feature/AmazingFeature`)
5. เปิด Pull Request

## 📝 License

โปรเจคนี้เป็นส่วนหนึ่งของการศึกษา

## 👨‍💻 ผู้พัฒนา

**Sompong**
- GitHub: [@sompong47](https://github.com/sompong47)

## 📧 ติดต่อ

หากมีคำถามหรือข้อเสนอแนะ สามารถติดต่อผ่าน GitHub Issues

---

⭐ ถ้าชอบโปรเจคนี้ อย่าลืมกด Star ให้ด้วยนะครับ!
