#!/bin/bash

# Fix for quran_library package compatibility issue
# This script fixes the AlignmentGeometry.bottomCenter error

PACKAGE_PATH="$HOME/.pub-cache/hosted/pub.dev/quran_library-2.3.1/lib/src/audio/widgets/ayah_audio_widget.dart"

if [ -f "$PACKAGE_PATH" ]; then
    # Fix the AlignmentGeometry.bottomCenter issue
    sed -i '' 's/AlignmentGeometry\.bottomCenter/Alignment.bottomCenter/g' "$PACKAGE_PATH"
    echo "✅ Fixed quran_library compatibility issue"
else
    echo "⚠️  Package file not found. Run 'flutter pub get' first."
fi

