#!/bin/bash

set -euo pipefail

PLUGINS_DIR="${HOME}/Library/Application Support/Developer/Shared/Xcode/Plug-ins"

DOWNLOAD_URI=https://github.com/kevin-ma/KWCodeLibrary/releases/download/v1.0/KWCodeLibrary.tar.gz
XCODE_VERSION="$(xcrun xcodebuild -version | head -n1 | awk '{ print $2 }')"
PLIST_PLUGINS_KEY="DVTPlugInManagerNonApplePlugIns-Xcode-${XCODE_VERSION}"
BUNDLE_ID="com.mogujie.KWCodeLibrary"
TMP_FILE="$(mktemp -t ${BUNDLE_ID})"

if defaults read com.apple.dt.Xcode "$PLIST_PLUGINS_KEY" &> "$TMP_FILE"; then
    /usr/libexec/PlistBuddy -c "delete skipped:$BUNDLE_ID" "$TMP_FILE" > /dev/null 2>&1 && {
        pgrep Xcode > /dev/null && {
            echo '检测到Xcode正在运行' 
            echo '安装程序需要退出才能继续'
            exit 1
        }
        defaults write com.apple.dt.Xcode "$PLIST_PLUGINS_KEY" "$(cat "$TMP_FILE")"
        echo '已经将KWCodeLibrary从Xcode插件白名单中移除'\
             '下次启动请选择“Load Bundle”'
    }
else
    KNOWN_WARNING="The domain/default pair of \(.+, $PLIST_PLUGINS_KEY\) does not exist"

    tr -d '\n' < "$TMP_FILE" | egrep -v "$KNOWN_WARNING" && exit 1
fi

if [[ ! -d ${PLUGINS_DIR} ]]; then
	echo "创建插件目录。。。";
   	mkdir ${PLUGINS_DIR}
else
	FILE=${PLUGINS_DIR}/KWCodeLibrary.xcplugin
	rm -rf "$FILE"
fi

echo "开始加载插件"
curl -L $DOWNLOAD_URI | tar xvz -C "${PLUGINS_DIR}"
if [[ $? = 0 ]]; then
	echo "\n🍺 安装KWCodeLibrary成功~重启Xcode加载\n"
else
	echo "\n安装KWCodeLibrary失败，请重试\n"
fi