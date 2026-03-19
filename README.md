# 📿 Smart Zikr - Hands-Free Voice Counter

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)

**Smart Zikr** is an intelligent, completely hands-free Zikr counter built with Flutter. Whether you are coding, driving, cooking, or typing, you no longer need to hold your phone or a physical Tasbeeh to keep track. Just speak, and the app's AI voice engine will automatically recognize your Zikr and update your count in real-time.

## ✨ Key Features

* **🎙️ Hands-Free Voice Recognition:** Uses native iOS/Android speech-to-text engines to listen continuously in the background.
* **🧠 Smart "Fuzzy" NLP Matching:** Handles accents and mispronunciations beautifully. If you say "Astagfirullah" but the phone hears "Aas tak", the algorithm detects the similarity and counts it anyway.
* **⏱️ Anti-Spam Cooldown:** A custom temporal lock prevents rapid double-counting (the "+3 bug") caused by fast speech engines.
* **📳 Haptic Feedback:** Feel a gentle vibration for every successful count, and a heavy vibration upon completing a mission. No need to look at the screen!
* **🔥 Streaks & Activity Calendar:** Gamifies your habits with a GitHub-style contribution heat-map and daily streak counter.
* **🌙 Dynamic UI:** Beautiful, minimalist Islamic design with seamless Light/Dark mode transitions and authentic Arabic typography.

## 📱 Screenshots

| Active Zikr (Dark)| Active Zikr (Light) |Dashboard & Calendar(Light) |
| :---: | :---: | :---: |
| ![Screenshot 1](https://github.com/user-attachments/assets/61f9ab1c-6a54-45d7-bf4e-8e32a40e78f2) | ![Screenshot 2](https://github.com/user-attachments/assets/3b52626a-4705-4707-9359-72d450277f36) | ![Screenshot 3](https://github.com/user-attachments/assets/bd31a51c-fec0-4c16-852e-c73daa416860) |

## 🛠️ Tech Stack
* **Framework:** Flutter (Dart)
* **State Management:** Provider
* **Packages:** `speech_to_text`, `string_similarity` (Levenshtein distance), `permission_handler`, `shared_preferences`.

## 🚀 Getting Started

### Prerequisites
* Flutter SDK (v3.0+)
* Mac with Xcode (for iOS) or Android Studio.

### Installation
1. Clone the repo:
   ```bash
   git clone [https://github.com/neelislam/smart-zikr.git](https://github.com/neelislam/smart-zikr.git)
