#!/usr/bin/env bash
# Run AFTER full Xcode is installed from the App Store (~15 GB).
# Requires your Mac password for xcode-select.

set -euo pipefail

if [[ ! -d "/Applications/Xcode.app" ]]; then
  echo "Xcode.app not found. Install from App Store first:"
  echo "  open macappstore://apps.apple.com/app/id497799835"
  exit 1
fi

echo "Switching xcode-select to Xcode.app..."
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch

echo "Accepting Xcode license..."
sudo xcodebuild -license accept

echo "Installing iOS CocoaPods dependencies..."
cd "$(dirname "$0")/.."
flutter pub get
cd ios
pod install --repo-update
cd ..

echo "Installing iOS Simulator runtime if needed..."
xcodebuild -downloadPlatform iOS || true

flutter doctor -v

echo ""
echo "Done. Run: flutter run -d ios"
