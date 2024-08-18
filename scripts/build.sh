#!/bin/bash

# Android
BUILD_TYPE="release"
ANDROID_OUTPUT_DIR="build/app/outputs/apk/$BUILD_TYPE"
APK_NAME="Soda-$BUILD_TYPE.apk"  # Change MyApp to your app's name

# Build the Android APK
echo "Building Android APK..."
flutter build apk --$BUILD_TYPE

# Check if the build was successful
if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi

# Move the APK to the current directory
echo "Moving APK to current directory..."
mv "$ANDROID_OUTPUT_DIR/app-$BUILD_TYPE.apk" "./$APK_NAME"

# Check if the move was successful
if [ $? -ne 0 ]; then
    echo "Failed to move APK!"
    exit 1
fi

echo "APK created successfully: $APK_NAME"

##################################################################
# Mac
APP_NAME="Soda"
MAC_OUTPUT_DIR="build/macos/Build/Products/Release"
DMG_NAME="$APP_NAME.dmg"

# Build the macOS app
echo "Building macOS app..."
flutter build macos

# Check if the build was successful
if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi

# Create the DMG file
echo "Creating DMG file..."

create-dmg \
  --volname "Soda" \
  --window-size 500 300 \
  --background "scripts/bg.png" \
  --icon Soda.app 130 110 \
  --app-drop-link 360 110 \
  Soda.dmg \
  build/macos/Build/Products/Release/Soda.app


# Check if the DMG creation was successful
if [ $? -ne 0 ]; then
    echo "DMG creation failed!"
    exit 1
fi

echo "DMG created successfully: $DMG_NAME"
