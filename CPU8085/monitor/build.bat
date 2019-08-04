@ECHO OFF

..\bin\AS8085.EXE -lo io
..\bin\AS8085.EXE -lo monitor
..\bin\aslink.exe -f monitor
