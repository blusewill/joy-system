#!/bin/sh

# Update Check
DAYS=30
HISTORY="/var/log/apt/history.log"

need_update=0

# 沒有更新紀錄就視為需要更新
if [ ! -f "$HISTORY" ]; then
  need_update=1
else
  last=$(stat -c %Y "$HISTORY")
  now=$(date +%s)
  diff=$(((now - last) / 86400))

  if [ "$diff" -ge "$DAYS" ]; then
    need_update=1
  fi
fi

# 超過 30 天未更新
if [ "$need_update" -eq 1 ]; then
  xterm -T "Debian Update" -e sh -c '
        echo "========================================"
        echo " Debian System Update"
        echo "========================================"
        echo

        export DEBIAN_FRONTEND=noninteractive

        apt update
        apt -y full-upgrade
        apt -y autoremove
        apt -y autoclean

        echo
        echo "Update complete."
        echo "Rebooting in 5 seconds..."
        sleep 5
        reboot
    '

  exit 0
fi

# 正常登入流程
chromium https://testcloud.joyedugroup.com --incognito &
CHROME_PID=$!

while kill -0 "$CHROME_PID" 2>/dev/null; do
  sleep 1
done

pkill -u 1000
