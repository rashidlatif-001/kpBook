# Pakhtunkhwa Ilm: KPK E-Textbooks Mobile App (Flutter & Dart)

An official, offline-first mobile and tablet application engineered for the **Khyber Pakhtunkhwa Textbook Board (KPTBB)** and **Elementary & Secondary Education Department, Govt. of Khyber Pakhtunkhwa**.

Built directly from the Google Stitch design specification (`pakhtunkhwa_ilm`) with Flutter 3.35+ and Dart 3.9+.

---

## 🌟 Key Highlights & Architectural Features

1. **Village Mode (100% Offline-First):**
   - Designed for low-connectivity environments across Khyber Pakhtunkhwa.
   - Textbooks can be downloaded once and accessed offline forever with zero latency and no mobile data requirement.

2. **Full Grade Range (Class 1 to 12):**
   - Primary: Classes 1 to 5
   - Middle: Classes 6 to 8
   - Secondary / Matric: Classes 9 & 10 (Science, Arts, General, Compulsory)
   - Higher Secondary: Classes 11 & 12 (FSc Pre-Med, Pre-Eng, ICS, FA)

3. **Interactive E-Textbook & PDF Reader:**
   - Realistic textbook reader engine with zoom/pinch gesture controls.
   - 3 reading modes: **Light Mode**, **Sepia Paper Mode**, and **Night Study Mode**.
   - Interactive Table of Contents drawer with direct unit jumping.
   - Bookmarking and persistent reading progress tracking (e.g. "Resume Pg 82").

4. **Curriculum 2024–25 Exam Guides & Model Papers:**
   - Dedicated exam preparation banners and subject unit notes.

5. **Integrated Download Manager:**
   - Storage visualizer (App usage, Free disk space).
   - "Wi-Fi Only" download switch to protect students' cellular data.
   - Pause, resume, and delete offline textbooks.

6. **Search & Zero-Results Recovery:**
   - Instant live search by book title, Urdu title, class number, or subject.
   - Empty-state suggestions with recovery pills (Physics, Mathematics, Biology, Chemistry).

7. **Multilingual Architecture:**
   - Ready for English, Urdu (اردو), and Pashto (پښتو) locale switching.

---

## 📂 Project Directory Structure

```
kpBook/
├── lib/
│   ├── main.dart                          # App entry point, MultiProvider setup
│   ├── theme/
│   │   ├── app_colors.dart                # Stitch Material 3 design tokens
│   │   └── app_theme.dart                 # Typography & component themes
│   ├── models/
│   │   ├── book_model.dart                # Book data structure & download states
│   │   └── chapter_model.dart             # Unit/Chapter schema with topics
│   ├── providers/
│   │   └── app_state.dart                 # Reactive state management
│   ├── screens/
│   │   ├── splash_screen.dart             # Animated KPK emblem splash
│   │   ├── main_shell.dart                # Core NavigationBar shell
│   │   ├── home_screen.dart               # Greeting, banners, Class 1-12 grid
│   │   ├── library_screen.dart            # Official library & subject filters
│   │   ├── content_selection_screen.dart  # Unit breakdown & topics
│   │   ├── offline_shelf_screen.dart      # Village mode offline shelf
│   │   ├── pdf_reader_screen.dart         # Full featured e-reader
│   │   ├── download_manager_screen.dart   # Storage & active downloads
│   │   ├── search_screen.dart             # Live discovery & zero results
│   │   ├── settings_screen.dart           # Preferences & multilingual toggle
│   │   └── connect_with_us_screen.dart    # KPTBB Hayatabad Peshawar info
│   └── widgets/
│       ├── book_card.dart                 # Responsive vertical & horizontal cards
│       ├── custom_app_bar.dart            # Standard top bar with notifications
│       └── offline_sync_banner.dart       # Village mode status indicator
├── test/
│   └── widget_test.dart                   # Smoke test suite
└── pubspec.yaml                           # Dependencies (google_fonts, provider)
```

---

## 🚀 Running the App

### 1. In Google Chrome (Web Preview)
```bash
flutter run -d chrome
```

### 2. On Windows Desktop
```bash
flutter run -d windows
```

### 3. On Android Device / Emulator (APK)
```bash
flutter run -d android
```

Or build the production Android APK:
```bash
flutter build apk --release
```
