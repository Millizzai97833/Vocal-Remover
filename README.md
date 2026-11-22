# Vocal Remover

Flutter Android starter project for an offline-first app focused only on removing human speech/dialogue from videos while retaining background ambience, music and sound effects.

## Current status

This repository builds a Flutter APK with:
- Video picker using Android's system document picker.
- Video preview.
- A 30-minute input-duration limit.
- A focused dialogue-removal screen.
- GitHub Actions debug APK build.

**Important:** The actual speech-separation AI model and audio/video processing pipeline are not integrated in this starter. The processing button deliberately reports this rather than pretending to remove speech. A real local model, its license, model files, Android ONNX integration, audio chunking, and FFmpeg muxing must be added before the app can remove dialogue.

## Build on GitHub

1. Create a GitHub repository named `Vocal-Remover`.
2. Upload all files and folders from this project to the repository root.
3. Open **Actions** and enable workflows if GitHub asks.
4. Select **Build Vocal Remover APK** and press **Run workflow**, or push a commit to `main`.
5. Open the completed workflow run.
6. Under **Artifacts**, download `vocal-remover-debug-apk`.
7. Extract the ZIP and install `app-debug.apk` on your Android phone.

## Local build

Install Flutter and Android SDK, then run:

```bash
flutter pub get
flutter analyze
flutter build apk --debug
```

## Planned AI integration

The next engineering milestone is selecting and licensing a pretrained model that separates speech/dialogue from non-speech background audio, then integrating ONNX Runtime on Android. Process long audio in short overlapping chunks, crossfade chunk boundaries, and mux the cleaned audio back into the original video without re-encoding video when possible.

A generic vocal/music separator is not sufficient: this app's target is spoken human dialogue, not all vocals.
