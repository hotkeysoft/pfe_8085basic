@ECHO OFF
..\bin\AS8085.EXE -log ..\basic\io\io
..\bin\AS8085.EXE -log monitor
..\bin\aslink.exe -f monitor
