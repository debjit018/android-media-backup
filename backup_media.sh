#!/bin/bash

LOGFILE="backup.log"
exec > >(tee -a "$LOGFILE") 2>&1

echo "=== Backup started at $(date) ==="
echo ""

DRY_RUN=0
if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=1
    echo "🚧 Running in DRY RUN mode (no files will be pulled)"
fi

echo "📲 Android Media Backup with Storage Selection"

mkdir -p ~/PhoneBackup/{Audio,Video,Images,PDFs}

echo ""
echo "📁 Available storage paths on your device:"
AVAILABLE_PATHS=$(adb shell "ls /storage" | tr -d '\r')

i=1
declare -a OPTIONS
for path in $AVAILABLE_PATHS; do
    OPTIONS+=("/storage/$path")
    echo "  $i) /storage/$path"
    ((i++))
done

echo ""
echo "Choose storage to scan:"
echo "  a) Internal storage only (/sdcard/)"
echo "  b) External (select from above)"
echo "  c) Both internal and external"

read -p "Enter your choice (a/b/c): " CHOICE

SCAN_PATHS=()

if [[ "$CHOICE" == "a" || "$CHOICE" == "A" ]]; then
    SCAN_PATHS=("/sdcard/")
elif [[ "$CHOICE" == "b" || "$CHOICE" == "B" ]]; then
    read -p "Enter number(s) of storage to scan (e.g. 2 or 2 3): " SELECTION
    MAX_INDEX=$(( ${#OPTIONS[@]} - 1 ))
    for num in $SELECTION; do
        if ! [[ "$num" =~ ^[0-9]+$ ]]; then
            echo "❌ Invalid input: '$num' is not a number."
            exit 1
        fi
        index=$((num - 1))
        if (( index < 0 || index > MAX_INDEX )); then
            echo "❌ Invalid selection: '$num' is out of valid range."
            exit 1
        fi
        SCAN_PATHS+=("${OPTIONS[$index]}")
    done
elif [[ "$CHOICE" == "c" || "$CHOICE" == "C" ]]; then
    SCAN_PATHS=("/sdcard/")
    for path in "${OPTIONS[@]}"; do
        SCAN_PATHS+=("$path")
    done
else
    echo "❌ Invalid choice. Exiting."
    exit 1
fi

echo ""
echo "📂 Selected paths to scan:"
for p in "${SCAN_PATHS[@]}"; do
    echo "  • $p"
done

IMG_TYPES='-iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.bmp" -o -iname "*.webp" -o -iname "*.tiff" -o -iname "*.heic"'
VID_TYPES='-iname "*.mp4" -o -iname "*.mkv" -o -iname "*.3gp" -o -iname "*.avi" -o -iname "*.mov" -o -iname "*.webm" -o -iname "*.flv" -o -iname "*.wmv"'
AUD_TYPES='-iname "*.mp3" -o -iname "*.wav" -o -iname "*.aac" -o -iname "*.ogg" -o -iname "*.flac" -o -iname "*.m4a"'
PDF_TYPE='-iname "*.pdf"'

> image_list.txt
> video_list.txt
> audio_list.txt
> pdf_list.txt

for path in "${SCAN_PATHS[@]}"; do
    echo "🔍 Scanning: $path"
    adb shell "find '$path' -type f \\( $IMG_TYPES \\)" >> image_list.txt
    adb shell "find '$path' -type f \\( $VID_TYPES \\)" >> video_list.txt
    adb shell "find '$path' -type f \\( $AUD_TYPES \\)" >> audio_list.txt
    adb shell "find '$path' -type f \\( $PDF_TYPE \\)" >> pdf_list.txt
done

pull_files() {
    local list_file="$1"
    local target_dir="$2"
    local label="$3"

    echo "⬇️ Processing $label files..."
    if [[ $DRY_RUN -eq 1 ]]; then
        echo " (Dry run) Files that would be pulled:"
        while read -r line; do
            if [[ -n "$line" ]]; then
                echo "   $line"
            fi
        done < "$list_file"
    else
        echo "⬇️ Pulling $label files..."
        while read -r line; do
            if [[ -n "$line" ]]; then
                adb pull "$line" "$target_dir" || echo "❌ Failed to pull: $line"
            fi
        done < "$list_file"
    fi
}

pull_files image_list.txt ~/PhoneBackup/Images "image"
pull_files video_list.txt ~/PhoneBackup/Video "video"
pull_files audio_list.txt ~/PhoneBackup/Audio "audio"
pull_files pdf_list.txt ~/PhoneBackup/PDFs "PDF"

echo ""
if [[ $DRY_RUN -eq 1 ]]; then
    echo "🚧 Dry run complete. No files were copied."
else
    echo "✅ Backup complete! Check: ~/PhoneBackup/"
fi

echo ""
echo "=== Backup ended at $(date) ==="

