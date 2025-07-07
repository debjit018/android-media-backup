# Android Media Backup

> Backup your Android phone’s media and PDFs selectively and safely using ADB — supports internal & external storage with dry-run and detailed logging.

---

## Features

* **Selective Storage Scanning:**
  Choose to back up media from internal storage, external SD cards, or both.

* **File Type Filtering:**
  Supports images (`.jpg`, `.png`, `.heic`, etc.), videos (`.mp4`, `.mkv`, `.avi`, etc.), audio files (`.mp3`, `.wav`, `.flac`, etc.), and PDFs.

* **Dry Run Mode:**
  Preview all files to be backed up without copying them (`--dry-run`).

* **User Input Validation:**
  Validates storage selection inputs to prevent errors.

* **Comprehensive Logging:**
  All output and errors logged in `backup.log`. Scanned file lists saved separately for review.

* **Clear Progress Reporting:**
  User-friendly messages with progress and error indicators.

* **Automatic Directory Setup:**
  Creates organized backup folders (`Audio`, `Video`, `Images`, `PDFs`) automatically.

---

## Requirements

* **ADB (Android Debug Bridge)** installed and configured
* USB debugging enabled on your Android device
* Ubuntu/Linux system for running the script

---

## Usage

1. Connect your Android device via USB and ensure it’s recognized by ADB:

   ```bash
   adb devices
   ```

2. Run the script normally to back up:

   ```bash
   ./backup_media.sh
   ```

3. Or run in dry-run mode to preview files without copying:

   ```bash
   ./backup_media.sh --dry-run
   ```

4. After completion, check backup folders under `~/PhoneBackup/` and review logs in `backup.log`.

---

## Notes

* The script requires your device to support the `find` command via ADB shell.
* External storage options are dynamically detected each run.
* Make sure USB debugging is enabled on your device before running.

---

## License

MIT License © \[debjit018]

---
