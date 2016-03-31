@ECHO OFF
:: use ._exe or .lol to avoid exeute directly
taskkill /f /t /im rebol-view-278-3-1.lol
:: timeout /t 0.5
start .\core\windows\rebol-view-278-3-1.lol -i -v -s .\core\webide.reb
EXIT

:: WebIDE-Windows.lnk
:: %comspec% /C Core\windows\rebol-view-278-3-1.exe -i -v -s Core\webide.r
