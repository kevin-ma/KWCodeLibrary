set -euo pipefail

PLUGINS_DIR="${HOME}/Library/Application Support/Developer/Shared/Xcode/Plug-ins"
FILE=${PLUGINS_DIR}/KWCodeLibrary.xcplugin
rm -rf "$FILE"
echo "🍺 卸载KWCodeLibrary成功"