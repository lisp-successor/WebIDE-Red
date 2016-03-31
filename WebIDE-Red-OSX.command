#!/bin/sh
killall rebol-core-278-2-5
#sleep 0.5
osascript <<EOF
tell application "Terminal"
  #delay 0.5
  set mainID to id of front window
  close (every window whose id is not mainID and name contains "WebIDE-MacOSX.command")
end tell
EOF
cd $(dirname "$0")
./core/darwin/rebol-core-278-2-5 -i -v -s ./core/webide.reb
#osascript -e 'tell application "Terminal" to close first window' & exit
