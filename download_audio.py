import json
import os
import urllib.request
import time

BASE_URL = "https://raw.githubusercontent.com/rn0x/Adhkar-json/main"
JSON_PATH = "assets/adhkar.json"
AUDIO_DIR = "assets/audio"

def download_audio():
    if not os.path.exists(AUDIO_DIR):
        os.makedirs(AUDIO_DIR)

    with open(JSON_PATH, 'r') as f:
        data = json.load(f)

    audio_files = set()

    # Extract audio from categories
    for category in data:
        if 'audio' in category and category['audio']:
            audio_files.add(category['audio'])
        
        # Extract audio from items
        if 'array' in category:
            for item in category['array']:
                if 'audio' in item and item['audio']:
                    audio_files.add(item['audio'])

    print(f"Found {len(audio_files)} unique audio files.")

    for i, relative_path in enumerate(audio_files):
        # relative_path is like "/audio/filename.mp3"
        # We want to download from BASE_URL + relative_path
        # And save to AUDIO_DIR + filename
        
        filename = os.path.basename(relative_path)
        local_path = os.path.join(AUDIO_DIR, filename)
        
        if os.path.exists(local_path):
            print(f"[{i+1}/{len(audio_files)}] Skipping {filename} (already exists)")
            continue

        url = f"{BASE_URL}{relative_path}"
        print(f"[{i+1}/{len(audio_files)}] Downloading {filename}...")
        
        try:
            urllib.request.urlretrieve(url, local_path)
            time.sleep(0.1) # Be nice to the server
        except Exception as e:
            print(f"Error downloading {url}: {e}")

if __name__ == "__main__":
    download_audio()
