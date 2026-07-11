#!/bin/sh

# 正常登入流程
chromium https://testcloud.joyedugroup.com --incognito &
CHROME_PID=$!

while kill -0 "$CHROME_PID" 2>/dev/null; do
  sleep 1
done

pkill -u 1000
