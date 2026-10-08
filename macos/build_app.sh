#!/usr/bin/env bash
# Build ArXivApp.app (a Dock launcher) into ~/Applications.
#   macos/build_app.sh [destination-dir]
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/.." && pwd)"
DEST="${1:-$HOME/Applications}"
APP="$DEST/ArXivApp.app"
UV="$(command -v uv || true)"
[ -n "$UV" ] || { echo "uv not found on PATH"; exit 1; }

WORK="$(mktemp -d -t arxivapp-build)"
trap 'rm -rf "$WORK"' EXIT

sed -e "s#__REPO_DIR__#$REPO#" -e "s#__UV_PATH__#$UV#" "$HERE/ArXivApp.applescript" > "$WORK/launcher.applescript"
rm -rf "$APP"
mkdir -p "$DEST"
osacompile -s -o "$APP" "$WORK/launcher.applescript"   # -s = stay open (so Quit stops the server)

# Icon
"$REPO/.venv/bin/python" "$HERE/make_icon.py" "$WORK/icon.png" 2>/dev/null || python3 "$HERE/make_icon.py" "$WORK/icon.png"
mkdir "$WORK/icon.iconset"
for s in 16 32 128 256 512; do
    sips -z $s $s "$WORK/icon.png" --out "$WORK/icon.iconset/icon_${s}x${s}.png" >/dev/null
    sips -z $((s*2)) $((s*2)) "$WORK/icon.png" --out "$WORK/icon.iconset/icon_${s}x${s}@2x.png" >/dev/null
done
iconutil -c icns "$WORK/icon.iconset" -o "$APP/Contents/Resources/applet.icns"

/usr/libexec/PlistBuddy -c "Set :CFBundleName ArXivApp" "$APP/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string org.arxivapp.launcher" "$APP/Contents/Info.plist" 2>/dev/null \
    || /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier org.arxivapp.launcher" "$APP/Contents/Info.plist"

# Editing the bundle invalidates osacompile's ad-hoc signature; re-sign.
codesign --force --deep -s - "$APP"
touch "$APP"
echo "built $APP"
