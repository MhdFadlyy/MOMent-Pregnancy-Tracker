# MOMent: Pregnancy Tracking Application 🤰📱

**MOMent** is a comprehensive mobile application designed to assist expectant mothers in monitoring their pregnancy journey. Built with **Flutter** and **Firebase**, it serves as a centralized hub for tracking health metrics, milestones, and appointments, ensuring a safer and more organized pregnancy experience.

🔗 **[Live demo](https://moment-5aa79.web.app)** (Web build, runs against the real Firebase backend — sign up with any email to try it)

## 🚀 Features

### 1. 🏠 Smart Dashboard
* **Dynamic Progress Tracking:** Calculates current pregnancy week and days remaining until due date.
* **Baby Size Visualization:** Fun comparisons of baby size to fruits (e.g., "Size of a Lime") that update weekly.

### 2. 💬 Automated Chat Assistant
* **Instant Advice:** A built-in rule-based chatbot that provides immediate answers to common concerns (e.g., "headache", "diet", "sleep") without needing an internet connection.
* **Offline Capable:** Ensures mothers can get reassurance anytime, anywhere.

### 3. 🍎 Health & Wellness Logger
* **Unified Tracking:** Dedicated tabs to log **Weight**, **Diet**, and **Exercise**.
* **Historical Data:** View a timeline of all health entries.
* **📄 PDF Report:** Generate and share a professional PDF health report directly with doctors.

### 4. 🦶 Prenatal Tools
* **Kick Counter:** Track fetal movements with a simple tap. Includes "Swipe-to-Delete" for accidental entries.
* **Contraction Timer:** Monitor labor signs with precision.
* **Appointment Manager:** Add, edit, and track upcoming prenatal checkups.

### 5. 🔒 Privacy & Security
* **Secure Auth:** Powered by Firebase Authentication.
* **Data Control:** Full "Delete Account" functionality that permanently wipes user data from the cloud, ensuring GDPR/Privacy compliance.

---

## 🛠️ Tech Stack

* **Frontend:** Flutter (Dart) — targets Android and Web
* **Backend:** Firebase (Authentication, Cloud Firestore)
* **Logic:** Custom local rule-engine for Chatbot (`lib/logic/`), pure and unit-tested
* **Architecture:** Screens call thin `lib/services/` classes instead of touching Firebase directly, so each collection's access lives in one place
* **Testing:** `flutter test` covers the pregnancy-week calculator, the chatbot rule engine, and a login-screen widget test
* **Packages:**
    * `cloud_firestore` & `firebase_auth` (Backend)
    * `pdf` & `printing` (Reporting)
    * `intl` (Date formatting)

---

## 📸 Screenshots

|                        Dashboard                         |                     Health Logger                     |                      Chat Bot                       |
|:--------------------------------------------------------:|:-----------------------------------------------------:|:---------------------------------------------------:|
| <img src="assets/screenshots/dashboard.png" width="200"> | <img src="assets/screenshots/health.png" width="200"> | <img src="assets/screenshots/chat.png" width="200"> |

|                     Kick Counter                     |                        Appointments                         |                     PDF Report                     |
|:----------------------------------------------------:|:-----------------------------------------------------------:|:--------------------------------------------------:|
| <img src="assets/screenshots/kicks.png" width="200"> | <img src="assets/screenshots/appointments.png" width="200"> | <img src="assets/screenshots/pdf.png" width="200"> |

---

## 🏁 Getting Started

To run this project locally:

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/MhdFadlyy/MOMent-Pregnancy-Tracker
    ```
2.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Firebase Setup:**
    * This project needs its own `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) — they aren't committed to the repo.
    * Create a Firebase project, enable Authentication (Email/Password) and Cloud Firestore, then register an Android/iOS app with package name `com.example.moment`.
    * Download the resulting config files into `android/app/google-services.json` and `ios/Runner/GoogleService-Info.plist` (see `android/app/google-services.json.example` for the expected shape).
    * Web already has its own registered Firebase app (`lib/firebase_options.dart`), so `flutter run -d chrome` works out of the box against the same project.

4.  **Run the App:**
    ```bash
    flutter run           # Android/iOS device or emulator
    flutter run -d chrome # Web
    ```
5.  **(Optional) Redeploy the web build:**
    ```bash
    flutter build web
    firebase deploy --only hosting
    ```

---

## 👤 Author

Built by **Fadly Muhammad** as a Final Year Project for the Bachelor of Information Technology program.

---