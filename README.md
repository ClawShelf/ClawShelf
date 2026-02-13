# 🦀 ClawShelf

[![OpenClaw Sync](https://img.shields.io/github/actions/workflow/status/ClawShelf/clawshelf.github.io/build-and-deploy.yml?label=OpenClaw%20Sync&logo=github)](https://github.com/ClawShelf/clawshelf.github.io/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**ClawShelf** is a lightning-fast, offline-first documentation reader and reference library built for the [OpenClaw](https://github.com/OpenClaw) ecosystem.

[![Get it on Google Play](https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png)](https://play.google.com/store/apps/details?id=com.fengjiongmax.clawshelf)
[![Download on the App Store](https://developer.apple.com/app-store/marketing/guidelines/images/badge-download-on-the-app-store.svg)](https://apps.apple.com/us/app/clawshelf-openclaw-docs/id6758986679)


Navigating hundreds of technical files shouldn't be a chore. ClawShelf takes the entire OpenClaw reference library and puts it in your pocket with instant search and native mobile rendering.

---

## 🚀 Key Features

* **Instant Search**: Millisecond results across 600+ files using the Isar NoSQL engine.
* **Smart Sync**: Fetches documentation updates via a binary ZIP bundle without requiring an app store update.
* **Native Experience**: Native Markdown rendering optimized for technical manuals and code snippets.
* **Offline-First**: Reliable access to the full English technical library anywhere, anytime.

---

## 🛠 Tech Stack

* **UI**: [Flutter](https://flutter.dev)
* **Database**: [Isar](https://isar.dev) (NoSQL with Full-Text Search)
* **Automation**: Dart-based CLI tools for data processing.

---

## 📦 Getting Started

### Prerequisites

* Flutter SDK (Stable)
* Local clone of [OpenClaw](https://github.com/OpenClaw) (if compiling data manually)

### Installation

```bash
git clone https://github.com/ClawShelf/ClawShelf.git
cd ClawShelf
flutter pub get
```

### Managing Assets

ClawShelf uses a custom pipeline to transform Markdown into a high-performance database.

**1. Fetching Remote Assets (Quick Start)**
To download the latest pre-compiled database and images into your `assets/` folder:

```bash
dart run tool/fetch_assets.dart
```

**2. Compiling Local Assets (Development)**
To build the database from a local copy of the OpenClaw docs:

```bash
# Basic build (updates assets/ for local testing)
dart run tool/package_documents.dart --openclaw_path ~/path/to/openclaw --output assets

# Full build (updates assets/ AND generates ZIP/Manifest in dist/)
dart run tool/package_documents.dart --openclaw_path ~/path/to/openclaw --output assets --archive

```

---

## 🏗 Content & Deployment Pipeline

1. **Content**: Raw docs live in the `OpenClaw` repo.
2. **Processing**: `package_documents.dart` parses Markdown, optimizes images, and builds the Isar DB.
3. **Packaging**: With the `--archive` flag, a `[timestamp].zip` and `build.json` are generated.
4. **Distribution**: GitHub Actions deploy these artifacts to the SvelteKit project's static directory on GitHub Pages.
5. **Update Loop**: The mobile app checks `https://clawshelf.github.io/dist-assets/build.json`, compares the version, and performs an atomic binary swap.

---

## 🤝 Contributing

We welcome contributions!

* **Content Changes**: Please submit PRs to the [OpenClaw](https://github.com/OpenClaw) repository.
* **App/Tooling**: PRs for the Flutter app or the Dart processing tools are welcome here.
* **Issues**: Report rendering bugs or search performance issues in the GitHub Issues tab.

## ⚖️ License

This project is licensed under the MIT License - see the [LICENSE](https://www.google.com/search?q=LICENSE) file for details.

---

*Built for the OpenClaw Community. Master your tools, one document at a time.*
