#!/bin/bash

# Download Poppins font
echo "Downloading Poppins..."
curl -L "https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-Regular.ttf" -o Poppins-Regular.ttf
curl -L "https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-Medium.ttf" -o Poppins-Medium.ttf
curl -L "https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-SemiBold.ttf" -o Poppins-SemiBold.ttf
curl -L "https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-Bold.ttf" -o Poppins-Bold.ttf

# Download Noto Sans Arabic font
echo "Downloading Noto Sans Arabic..."
curl -L "https://github.com/google/fonts/raw/main/ofl/notosansarabic/NotoSansArabic-Regular.ttf" -o NotoSansArabic-Regular.ttf
curl -L "https://github.com/google/fonts/raw/main/ofl/notosansarabic/NotoSansArabic-Medium.ttf" -o NotoSansArabic-Medium.ttf
curl -L "https://github.com/google/fonts/raw/main/ofl/notosansarabic/NotoSansArabic-SemiBold.ttf" -o NotoSansArabic-SemiBold.ttf
curl -L "https://github.com/google/fonts/raw/main/ofl/notosansarabic/NotoSansArabic-Bold.ttf" -o NotoSansArabic-Bold.ttf

# Download Amiri font (for Quran/Dhikr text)
echo "Downloading Amiri..."
curl -L "https://github.com/google/fonts/raw/main/ofl/amiri/Amiri-Regular.ttf" -o Amiri-Regular.ttf
curl -L "https://github.com/google/fonts/raw/main/ofl/amiri/Amiri-Bold.ttf" -o Amiri-Bold.ttf

echo "✅ All fonts downloaded!"
