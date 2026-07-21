#!/bin/sh

sleep 1

# 啟動 Chrome
chromium "https://testcloud.joy.com.tw" --incognito &
CHROME_PID=$!

# 等待 Chrome 結束
while kill -0 "$CHROME_PID" 2>/dev/null; do
  sleep 1
done

echo "Chrome 已關閉，執行 pkill..."
pkill -u 1000
