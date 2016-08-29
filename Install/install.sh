#!/bin/bash

set -euo pipefail

echo "=== KWCodeLibrary 管理程序 ==="
echo "1. 安装"
echo "2. 卸载"
echo "3. 退出"
echo

while :  # loop  
do  
if read -t 30 -n 1 -p "请选择要进行的操作[1/2/3]:"  #limited time 5s    
    then  
        case $REPLY in  
            1|a|A) #Y  
                choose=1;  
                echo "\n 正在安装，请稍后~\n"  
                  break  
                ;;  
            2|b|B) #N  
                choose=2;  
                echo "\n 正在卸载，请稍后~\n"  
                  break  
                ;;
            3|c|C) #N  
                choose=3;  
                echo "\n 程序正在终止~\n"  
                sleep 1
                echo "\n 程序已终止，感谢您的使用~"
                exit 0
                  break  
                ;;  
            *) #input error repeat  
                echo "\n 选择有误，请重新选择 !! \n"  
                continue  
        esac   
else #timeover  
    echo "\n 未检出到操作，程序已退出\n"  
    break  
fi   
done  

PLUGINS_DIR="${HOME}/Library/Application Support/Developer/Shared/Xcode/Plug-ins"

if [[ $choose = 1 ]]; then

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
	            echo '是否继续？'
	            echo '您可以手动退出Xcode后继续，或者选择继续，程序会强制退出Xcode'
	            while :  # loop  
				do 
	            if read -t 30 -n 1 -p "是否继续[Y/N]:"
	            	then
	            		case $REPLY in
	            			 Y|y)
							goOn=1
								break
	            				;;
	            			N|n)
							exit 0
								break
	            				;; 
	            				*) #input error repeat  
                			echo "\n 选择有误，请重新选择 !! \n"  
                			continue  
	            		esac
	            fi
	            done
	        }
	        defaults write com.apple.dt.Xcode "$PLIST_PLUGINS_KEY" "$(cat "$TMP_FILE")"
	        echo '已经将KWCodeLibrary从Xcode插件白名单中移除'\
	             '下次启动请选择“Load Bundle”'
	    }
	else
	    # Could not read the prefs. Filter known warnings, and exit for any other.
	    KNOWN_WARNING="The domain/default pair of \(.+, $PLIST_PLUGINS_KEY\) does not exist"

	    # tr: For some mysterious reason, some `defaults` errors are outputed on two lines.
	    # grep: -v returns 1 when output is empty (ie. we filtered the known warning)
	    # so we exit on 0, which means an unknown error occured.
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
		echo "\n🍺 安装成功~重启Xcode加载\n"
	else
		echo "\n安装失败，请重试\n"
	fi
fi
if [[ $choose = 2 ]]; then
	FILE=${PLUGINS_DIR}/KWCodeLibrary.xcplugin
	echo "$FILE"
	rm -rf "$FILE"
	echo "🍺 卸载完成~重启Xcode生效"
fi

