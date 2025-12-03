#!/bin/bash

# Download Poppins font
echo "Downloading Poppins..."
curl -L "https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-Regular.ttf" -o Poppins-Regular.ttf
curl -L "https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-Medium.ttf" -o Poppins-Medium.ttf
curl -L "https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-SemiBold.ttf" -o Poppins-SemiBold.ttf
curl -L "https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-Bold.ttf" -o Poppins-Bold.ttf

# Download Cairo font
echo "Downloading Cairo..."
curl -L "https://github.com/google/fonts/raw/main/ofl/cairo/Cairo-Regular.ttf" -o Cairo-Regular.ttf
curl -L "https://github.com/google/fonts/raw/main/ofl/cairo/Cairo-Medium.ttf" -o Cairo-Medium.ttf
curl -L "https://github.com/google/fonts/raw/main/ofl/cairo/Cairo-SemiBold.ttf" -o Cairo-SemiBold.ttf
curl -L "https://github.com/google/fonts/raw/main/ofl/cairo/Cairo-Bold.ttf" -o Cairo-Bold.ttf

# Download Amiri font
echo "Downloading Amiri..."
curl -L "https://github.com/google/fonts/raw/main/ofl/amiri/Amiri-Regular.ttf" -o Amiri-Regular.ttf
curl -L "https://github.com/google/fonts/raw/main/ofl/amiri/Amiri-Bold.ttf" -o Amiri-Bold.ttf

echo "✅ All fonts downloaded!"
