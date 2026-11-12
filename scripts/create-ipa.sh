#!/bin/bash
set -e

APP_NAME="KiberXavfliy"
BUNDLE_ID="com.kiberxavfliy.app"
DEVELOPMENT_TEAM="YOUR_TEAM_ID"
XCODE_PROJECT="../ios/KiberXavfliy.xcodeproj"
SCHEME="KiberXavfliy"
ARCHIVE_PATH="build/${APP_NAME}.xcarchive"
IPA_PATH="build/${APP_NAME}.ipa"
EXPORT_OPTIONS="exportOptions.plist"

if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "Xato: IPA yaratish faqat macOS da ishlaydi"
    exit 1
fi

echo "=== Archive yaratish ==="
xcodebuild archive \
    -project "${XCODE_PROJECT}" \
    -scheme "${SCHEME}" \
    -archivePath "${ARCHIVE_PATH}" \
    -destination "generic/platform=iOS" \
    DEVELOPMENT_TEAM="${DEVELOPMENT_TEAM}" \
    PRODUCT_BUNDLE_IDENTIFIER="${BUNDLE_ID}" \
    CODE_SIGN_IDENTITY="iPhone Developer" \
    -allowProvisioningUpdates

cat > "${EXPORT_OPTIONS}" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>development</string>
    <key>teamID</key>
    <string>${DEVELOPMENT_TEAM}</string>
    <key>uploadSymbols</key>
    <true/>
    <key>compileBitcode</key>
    <false/>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
EOF

echo "=== IPA eksport qilish ==="
xcodebuild -exportArchive \
    -archivePath "${ARCHIVE_PATH}" \
    -exportPath "build" \
    -exportOptionsPlist "${EXPORT_OPTIONS}" \
    -allowProvisioningUpdates

echo "=== IPA tayyor: ${IPA_PATH} ==="
ls -lh "${IPA_PATH}"
shasum -a 256 "${IPA_PATH}"
