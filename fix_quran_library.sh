#!/bin/bash

# Fix for quran_library package compatibility and release mode issues
# Author: Senior Flutter Developer

PACKAGE_DIR="$HOME/.pub-cache/hosted/pub.dev/quran_library-2.3.1"
AUDIO_WIDGET_PATH="$PACKAGE_DIR/lib/src/audio/widgets/ayah_audio_widget.dart"
ASSETS_PATH="$PACKAGE_DIR/lib/src/core/utils/assets_path.dart"

echo "Applying fixes to quran_library version 2.3.1..."

# 1. Fix AlignmentGeometry.bottomCenter issue (Dart/Flutter version mismatch)
if [ -f "$AUDIO_WIDGET_PATH" ]; then
    sed -i '' 's/AlignmentGeometry\.bottomCenter/Alignment.bottomCenter/g' "$AUDIO_WIDGET_PATH"
    echo "✅ Fixed AlignmentGeometry compatibility"
else
    echo "⚠️  Audio widget file not found"
fi

# 2. Fix AssetsPath reflection issue (Release mode icons fix)
# In release mode, Symbol names are obfuscated, so invocation.memberName.toString() 
# does not return the actual name, breaking SVG paths.
if [ -f "$ASSETS_PATH" ]; then
    cat > "$ASSETS_PATH" <<EOF
part of '/quran.dart';

abstract class _AssetsPath {
  _AssetsPath._();
  String get surahSvgBanner;
  String get surahSvgBannerDark;
  String get ayahBookmarked;
  String get sajdaIcon;
  String get suraNum;
  String get playArrow;
  String get pauseArrow;
  String get checkMark;
  String get alert;
  String get backward;
  String get rewind;
  String get surahsAudio;
  String get buttomSheet;
  String get options;
  String get backArrow;
}

class AssetsPath implements _AssetsPath {
  AssetsPath._();
  static final AssetsPath assets = AssetsPath._();
  static const String _prefix = "packages/quran_library/assets/svg/";

  @override String get surahSvgBanner => '\${_prefix}surahSvgBanner.svg';
  @override String get surahSvgBannerDark => '\${_prefix}surahSvgBannerDark.svg';
  @override String get ayahBookmarked => '\${_prefix}ayahBookmarked.svg';
  @override String get sajdaIcon => '\${_prefix}sajdaIcon.svg';
  @override String get suraNum => '\${_prefix}suraNum.svg';
  @override String get playArrow => '\${_prefix}playArrow.svg';
  @override String get pauseArrow => '\${_prefix}pauseArrow.svg';
  @override String get checkMark => '\${_prefix}checkMark.svg';
  @override String get alert => '\${_prefix}alert.svg';
  @override String get backward => '\${_prefix}backward.svg';
  @override String get rewind => '\${_prefix}rewind.svg';
  @override String get surahsAudio => '\${_prefix}surahsAudio.svg';
  @override String get buttomSheet => '\${_prefix}buttomSheet.svg';
  @override String get options => '\${_prefix}options.svg';
  @override String get backArrow => '\${_prefix}backArrow.svg';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
EOF
    echo "✅ Fixed Release Mode Icon loading (Replaced reflection with static getters)"
else
    echo "⚠️  Assets path file not found"
fi

echo "All fixes applied successfully! 🚀"
