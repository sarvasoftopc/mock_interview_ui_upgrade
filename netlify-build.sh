#!/usr/bin/env bash
set -euo pipefail

# --- CONFIG ---
FLUTTER_DIR="/tmp/flutter"
FLUTTER_GIT="https://github.com/flutter/flutter.git"
FLUTTER_BRANCH="stable"
# ----------------

echo ">>> Using Flutter branch: ${FLUTTER_BRANCH}"

# If directory doesn't exist, clone stable branch shallowly (faster & avoids missing refs)
if [ ! -d "${FLUTTER_DIR}" ]; then
  echo ">>> Cloning flutter (${FLUTTER_BRANCH})..."
  if git clone --depth 1 --branch "${FLUTTER_BRANCH}" "${FLUTTER_GIT}" "${FLUTTER_DIR}"; then
    echo ">>> Flutter cloned (shallow) to ${FLUTTER_DIR}"
  else
    echo ">>> Shallow clone failed, falling back to full clone (slower)"
    rm -rf "${FLUTTER_DIR}"
    git clone "${FLUTTER_GIT}" "${FLUTTER_DIR}"
    cd "${FLUTTER_DIR}"
    git fetch origin "${FLUTTER_BRANCH}" --tags
    git checkout "${FLUTTER_BRANCH}"
    cd -
  fi
else
  echo ">>> Flutter directory already exists at ${FLUTTER_DIR}"
fi

export PATH="${FLUTTER_DIR}/bin:${PATH}"
export FLUTTER_ROOT="${FLUTTER_DIR}"

# Check flutter installed
if ! command -v flutter >/dev/null 2>&1; then
  echo "ERROR: flutter not found on PATH"
  exit 1
fi

echo ">>> Flutter version info:"
flutter --version

# Just ensure we’re on stable channel
set +e
flutter channel "${FLUTTER_BRANCH}" >/dev/null 2>&1 || true
set -e

# Prep environment
flutter upgrade --force || true
flutter doctor -v || true

# Get dependencies
echo ">>> Running flutter pub get"
flutter pub get

# ✅ Build web as a standard website (no PWA)
echo ">>> Building Flutter web (release, no PWA)"
flutter build web --release \
  --dart-define=SUPABASE_URL="${SUPABASE_URL:-}" \
  --dart-define=SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY:-}" \
  --no-wasm-dry-run \
  --pwa-strategy=none

# ✅ Remove leftover PWA artifacts just in case
rm -f build/web/flutter_service_worker.js || true
rm -f build/web/manifest.json || true
sed -i.bak 's|<script src="flutter_service_worker.js" defer></script>||' build/web/index.html || true

echo ">>> Build complete — build/web is ready for Netlify deployment (no PWA mode)"
