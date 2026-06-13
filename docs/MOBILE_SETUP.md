# Mobile development setup (macOS)

## Current status

| Platform | Status |
|----------|--------|
| **Android** | Ready — SDK 36, emulator `Paedia_Pixel_7`, debug APK builds |
| **iOS** | Ready — Xcode 26.5, iOS 26.5 Simulator, CocoaPods |
| **Web** | Ready — `flutter run -d chrome --web-port=7358 --web-hostname=localhost` |

## Android (ready)

Installed via Homebrew:

- Android Studio (`/Applications/Android Studio.app`)
- Command-line SDK at `/opt/homebrew/share/android-commandlinetools`
- Flutter configured: `flutter config --android-sdk` → that path

### Shell environment

Add to `~/.zshrc` (or run each session):

```bash
source ~/Documents/Paedia/scripts/mobile-env.sh
```

### Commands

```bash
# List devices
flutter devices

# Start emulator
emulator -avd Paedia_Pixel_7

# Run on Android
cd ~/Documents/Paedia
flutter run -d Paedia_Pixel_7
```

Debug APK output: `build/app/outputs/flutter-apk/app-debug.apk`

## iOS

**Xcode.app** at `/Applications/Xcode.app`; `xcode-select` → `/Applications/Xcode.app/Contents/Developer`. License accepted via `xcodebuild -license accept`.

Setup script (already run once; safe to re-run):

```bash
cd ~/Documents/Paedia
./scripts/finish-ios-setup.sh
```

If `flutter doctor` reports *Unable to get list of installed Simulator runtimes*, install the iOS simulator:

```bash
xcodebuild -downloadPlatform iOS
# or: Xcode → Settings → Components → iOS Simulator
```

Then verify simulators:

```bash
xcrun simctl list devices available
flutter doctor -v
```

Run on simulator:

```bash
cd ~/Documents/Paedia
flutter pub get
flutter run -d ios
```

### Already installed

- **CocoaPods** 1.16.2 (`brew install cocoapods`)
- iOS minimum: 14.0 (`ios/Podfile`)
- Pods installed (`ios/Pods`)

## Verify

```bash
flutter doctor -v
```

Target: green checkmarks for **Android toolchain** and **Xcode** (simulator runtime included).

## Production safety

Local builds do not deploy to Firebase or the stores. Release signing uses `android/key.properties` (not in repo) when you eventually ship to Play/App Store.
