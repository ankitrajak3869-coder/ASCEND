# Ascend

<div align="center">
  <img src="assets/images/logo.png" alt="Ascend Logo" width="200"/>
  <h3>A modern Flutter application built with Clean Architecture</h3>
  <p>
    <a href="#features">Features</a> •
    <a href="#tech-stack">Tech Stack</a> •
    <a href="#getting-started">Getting Started</a> •
    <a href="#architecture">Architecture</a> •
    <a href="#contributing">Contributing</a>
  </p>
</div>

---

## 📖 Project Overview

Ascend is a **Flutter application** designed with **Clean Architecture** principles, leveraging **Firebase** for backend services and **Riverpod** for state management. The project follows industry best practices for scalability, testability, and maintainability.

### Vision

To provide a robust, maintainable, and scalable Flutter application template that demonstrates professional software engineering practices including Clean Architecture, feature-driven development, automated testing, and CI/CD pipelines.

---

## ✨ Features

- 🔐 **Authentication** - Firebase Auth with email/password, Google, Apple sign-in
- ☁️ **Cloud Sync** - Real-time data synchronization with Cloud Firestore
- 🔔 **Push Notifications** - Firebase Cloud Messaging integration
- 📱 **Cross-platform** - iOS, Android, and Web support
- 🎨 **Modern UI** - Material Design 3 with custom theming
- 🧪 **Testing** - Unit, widget, and integration tests
- 🚀 **CI/CD** - GitHub Actions for automated builds and testing
- 📦 **Dependency Injection** - Service locator pattern with GetIt
- 🔄 **State Management** - Riverpod for reactive state management
- 🏗️ **Clean Architecture** - Separation of concerns with domain, data, and presentation layers

---

## 🛠 Tech Stack

| Category | Technology |
|----------|------------|
| **Framework** | Flutter 3.x |
| **Language** | Dart 3.x |
| **Architecture** | Clean Architecture |
| **State Management** | Riverpod 2.x |
| **Dependency Injection** | GetIt |
| **Backend** | Firebase (Auth, Firestore, FCM, Storage, Functions) |
| **Local Storage** | Hive / SharedPreferences |
| **Networking** | Dio |
| **Routing** | GoRouter |
| **Testing** | flutter_test, mockito, integration_test |
| **Code Generation** | freezed, json_serializable, build_runner |
| **Linting** | flutter_lints, dart_code_metrics |
| **CI/CD** | GitHub Actions |

---

## 📁 Folder Structure

```
lib/
├── core/
│   ├── constants/          # App-wide constants
│   ├── errors/             # Failure classes, exceptions
│   ├── network/            # Network info, API client
│   ├── utils/              # Utility functions, extensions
│   └── themes/             # App themes, colors, typography
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── pages/
│   │       └── widgets/
│   ├── home/
│   ├── profile/
│   └── settings/
├── shared/
│   ├── widgets/            # Reusable UI components
│   ├── providers/          # Shared Riverpod providers
│   └── models/             # Shared data models
├── injection_container.dart # GetIt setup
└── main.dart               # App entry point
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.16+
- Dart SDK 3.2+
- Firebase CLI (`npm install -g firebase-tools`)
- Android Studio / Xcode / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-org/ascend.git
   cd ascend
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Configure Firebase**
   ```bash
   # Login to Firebase
   firebase login
   
   # Initialize Firebase in project
   flutterfire configure
   ```

5. **Run the app**
   ```bash
   # Development
   flutter run --flavor development --target lib/main_development.dart
   
   # Staging
   flutter run --flavor staging --target lib/main_staging.dart
   
   # Production
   flutter run --flavor production --target lib/main_production.dart
   ```

---

## 🏗 Build Instructions

### Android

```bash
# Debug APK
flutter build apk --flavor development --target lib/main_development.dart

# Release App Bundle (Play Store)
flutter build appbundle --flavor production --target lib/main_production.dart

# Release APK
flutter build apk --flavor production --target lib/main_production.dart --release
```

### iOS

```bash
# Debug
flutter build ios --flavor development --target lib/main_development.dart --debug

# Release (App Store)
flutter build ios --flavor production --target lib/main_production.dart --release
```

### Web

```bash
# Development
flutter build web --flavor development --target lib/main_development.dart

# Production
flutter build web --flavor production --target lib/main_production.dart --release
```

### Flavor Configuration

| Flavor | Target File | Firebase Project |
|--------|-------------|------------------|
| Development | `lib/main_development.dart` | `ascend-dev` |
| Staging | `lib/main_staging.dart` | `ascend-staging` |
| Production | `lib/main_production.dart` | `ascend-prod` |

---

## 🧪 Testing Instructions

### Unit Tests

```bash
# Run all unit tests
flutter test

# Run with coverage
flutter test --coverage

# Generate HTML coverage report
genhtml coverage/lcov.info -o coverage/html
```

### Widget Tests

```bash
flutter test test/widget_test.dart
```

### Integration Tests

```bash
# Android
flutter test integration_test/ --flavor development

# iOS
flutter test integration_test/ --flavor development -d ios

# Web
flutter test integration_test/ -d chrome
```

### Static Analysis

```bash
# Analyze code
flutter analyze

# Check formatting
dart format --set-exit-if-changed .

# Run Dart Code Metrics
dart run dart_code_metrics:metrics analyze lib
```

---

## 🏛 Architecture

Ascend follows **Clean Architecture** with a **feature-first** module structure. See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed documentation.

### Key Principles

1. **Separation of Concerns** - Domain, Data, Presentation layers
2. **Dependency Rule** - Inner layers don't depend on outer layers
3. **Single Responsibility** - Each class has one reason to change
4. **Interface Segregation** - Depend on abstractions, not concretions
5. **Testability** - Business logic isolated from frameworks

### Architecture Decision Records

See [docs/adr/](docs/adr/) for architectural decisions:
- [ADR-001: Clean Architecture](docs/adr/ADR-001-Clean-Architecture.md)
- [ADR-002: Event Bus](docs/adr/ADR-002-Event-Bus.md)
- [ADR-003: Riverpod for State Management](docs/adr/ADR-003-Riverpod.md)

---

## 🤝 Contributing

We welcome contributions! Please read our [Contributing Guide](CONTRIBUTING.md) for details on:

- Branch naming conventions
- Commit message format
- Pull request process
- Code review guidelines

### Quick Start

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/your-org/ascend/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-org/ascend/discussions)
- **Email**: support@ascend.app

---

## 🙏 Acknowledgments

- [Flutter](https://flutter.dev)
- [Firebase](https://firebase.google.com)
- [Riverpod](https://riverpod.dev)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

---

<div align="center">
  <sub>Built with ❤️ by the Ascend Team</sub>
</div>