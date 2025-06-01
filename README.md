# Chat Queen

A real-time Flutter chat app with private messaging, pagination, and Firebase backend.

---

## Features

- Real-time messaging with Firebase Firestore
- Private one-to-one chats
- Pagination (scroll up to load older messages)
- Light/Dark theme toggle
- Simple username sign-in

---

## Setup Instructions

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (latest stable recommended)
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/)
- A [Firebase project](https://console.firebase.google.com/) with Firestore enabled

### 1. Clone the Repository

git clone https://github.com/your-username/chat_queen.git
cd chat_queen


### 2. Firebase Setup

#### Android
- In the [Firebase Console](https://console.firebase.google.com/), add an Android app to your project.
- Download the `google-services.json` file.
- Place it in `android/app/`.

#### iOS (optional)
- In the Firebase Console, add an iOS app.
- Download the `GoogleService-Info.plist` file.
- Place it in `ios/Runner/`.

#### Web (optional)
- Follow [FlutterFire Web setup](https://firebase.flutter.dev/docs/overview/).

### 3. Install Dependencies

flutter pub get


---

## Running the Application

1. Connect your Android device or start an emulator.
2. Run:

flutter run


- For iOS, open the project in Xcode and ensure all signing/capabilities are set.

---

## Usage

- On first launch, enter a username to join the chat.
- Start a private chat with any listed user.
- Scroll up to load older messages.
- Use the theme toggle in the app bar to switch between light and dark modes.

---

## Video Presentation

[Watch the demo video here](https://your-video-link)

*The video demonstrates:*
- App launch and sign-in
- Sending and receiving messages
- Pagination (scrolling up)
- Theme switching

---

## Project Structure

chat_queen/
├── android/
├── ios/
├── lib/
│ └── main.dart
├── pubspec.yaml
├── pubspec.lock
├── README.md
└── ...


---

## Troubleshooting

- If you see "No pubspec.yaml file found", ensure you are in the project root.
- If you get dependency errors, run `flutter pub get` again.
- Make sure you have added the correct Firebase config files for Android/iOS.

---


## Credits

Developed by Shreyansh.
