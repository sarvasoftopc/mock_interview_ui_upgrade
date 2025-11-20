# Interview Prep Prototype

A multi-platform Flutter prototype app to practice interview questions. Uses mock services out-of-the-box and is designed to be extended with real API integrations.

Supported platforms:
- Android
- iOS
- Web
- Windows
- macOS
- Linux

## Prerequisites

- Flutter stable SDK (>= 3.0 recommended)
- Dart SDK included with Flutter
- Platform toolchains for target platforms (Android SDK, Xcode for iOS/macOS, etc.)

## Setup

1. Clone the repository:
   git clone <repo-url> interview_prep_prototype
   cd interview_prep_prototype

2. Copy and edit environment example:
   cp env.example env.local
   Edit env.local as needed. For Web, copy to web/env.json if you want runtime fetch.

3. Get packages:
   flutter pub get

4. Run on a device:
   flutter run -d <device>

## Building

- Android (APK):
  flutter build apk --release

- iOS:
  flutter build ios --release
  Open the Xcode workspace and manage signing if necessary.

- Web:
  flutter build web --release
  Serve the build/web folder (e.g., nginx, python -m http.server)

- Windows/macOS/Linux:
  flutter build <platform>

## Docker (Web hosting)

Build and run the Docker image to serve the web artifact via nginx:

docker build -t interview_prep_prototype:web .
docker run -p 8080:80 interview_prep_prototype:web

## Testing

Unit & widget tests:
  flutter test

Integration tests:
  flutter drive --driver=test_driver/integration_test_driver.dart --target=integration_test/app_test.dart

CI:
A sample CI pipeline is provided in ci/flutter_ci.yaml. Adjust as needed for your provider.

## Replacing Mocks

Mock services live in lib/services/*. Replace implementations (MockApiService, AudioService, TtsService, SttService, FileService) with real implementations and register them in lib/providers/providers.dart.

- API: lib/services/mock_api_service.dart -> implement real networked ApiService
- Audio: lib/services/audio_service.dart -> integrate flutter_sound or platform channels
- Storage/File: use cloud storage or local file solutions as required
- TTS/STT: integrate native packages or cloud services

## Assets

- assets/config.json contains templates used by MockApiService.
- env.example provides environment variable examples. For web, copy into web/env.json to be served.

## License

MIT License - see LICENSE file.

## Developer Notes

- run `dart tools/generate_assets.dart` to ensure basic assets exist.
- Use `./create_files.sh` to generate project skeleton in a new location (provided).
