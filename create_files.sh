#!/usr/bin/.env bash
set -e

# This script creates a minimal project skeleton. It is intended as a helper
# and writes placeholder files. The repository produced by this project already
# contains complete implementations. Use this script to re-generate files if needed.

echo "Creating project skeleton..."

mkdir -p lib/providers lib/services lib/models lib/ui/screens lib/ui/widgets lib/utils assets ci test integration_test tools

cat > pubspec.yaml <<'EOF'
name: interview_prep_prototype
description: Prototype interview prep app
version: 0.1.0+1
environment:
  sdk: ">=2.17.0 <3.0.0"

dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.0
  shared_preferences: ^2.0.15
  path_provider: ^2.0.11
  http: ^0.13.5
  flutter_localizations:
    sdk: flutter

dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  mockito: ^5.3.0
  build_runner: ^2.2.0

flutter:
  uses-material-design: true
  assets:
    - assets/config.json
    - assets/env.example
EOF

cat > assets/config.json <<'EOF'
{
  "questionTemplates": [
    {
      "textTemplate": "Explain {topic} and how you approached it",
      "tags": ["system", "design"],
      "difficulty": "medium"
    }
  ],
  "topics": ["scalability", "oop", "testing"]
}
EOF

cat > assets/env.example <<'EOF'
API_BASE_URL=https://api.example.com
STT_API_KEY=YOUR_STT_KEY
TTS_API_KEY=YOUR_TTS_KEY
STORAGE_BUCKET=your-bucket
FIREBASE_PROJECT=project-id
EOF

echo "Created skeleton files."
chmod +x create_files.sh
