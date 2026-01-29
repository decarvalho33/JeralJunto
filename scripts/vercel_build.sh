#!/usr/bin/env bash
set -euo pipefail

FLUTTER_RELEASES_URL="https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json"
FLUTTER_BASE_URL="https://storage.googleapis.com/flutter_infra_release/releases"

ARCHIVE_PATH=$(python - <<'PY'
import json, urllib.request
url = "https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json"
with urllib.request.urlopen(url) as resp:
    data = json.load(resp)
stable_hash = data["current_release"]["stable"]
for release in data["releases"]:
    if release.get("hash") == stable_hash:
        print(release["archive"])
        break
else:
    raise SystemExit("Stable release not found")
PY
)

curl -fsSL "${FLUTTER_BASE_URL}/${ARCHIVE_PATH}" -o /tmp/flutter.tar.xz
rm -rf /tmp/flutter
mkdir -p /tmp/flutter

tar -xf /tmp/flutter.tar.xz -C /tmp/flutter
export PATH="/tmp/flutter/flutter/bin:$PATH"

flutter --version
flutter pub get
flutter build web --web-renderer html --release \
  --dart-define=SUPABASE_URL=\"${SUPABASE_URL:-}\" \
  --dart-define=SUPABASE_ANON_KEY=\"${SUPABASE_ANON_KEY:-}\"
