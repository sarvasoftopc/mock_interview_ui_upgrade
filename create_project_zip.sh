#!/usr/bin/.env bash
set -e
ROOT_DIR="$(pwd)"
if [ ! -f create_files.sh ]; then
  echo "create_files.sh not found. Exiting."
  exit 1
fi
./create_files.sh
zip -r interview_prep_prototype.zip . -x "build/*" "ios/Flutter/Flutter.framework/*"
echo "Created interview_prep_prototype.zip"
chmod +x create_project_zip.sh
