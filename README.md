# StudyNote AI Flutter PWA

Initial Flutter web client for the StudyNote AI API.

## Setup

Install Flutter, then run:

```bash
flutter pub get
flutter create --platforms web .
flutter run -d chrome --dart-define=STUDYNOTE_API_URL=http://localhost:8000
```

`flutter create --platforms web .` generates standard Flutter web assets. Preserve the custom `web/index.html` and `web/manifest.json` if prompted to overwrite them. Add branded PWA icons before production deployment.

This is an initial functional scaffold, not yet a production-ready app. It currently supports one image at a time, editable OCR, and viewing generated questions. Authentication, persistent study packs, flashcards, downloads, audio and push notifications remain to be implemented. Set a reachable HTTPS API URL for iPhone deployment.
