@ECHO OFF
..\bin\AS8085.EXE -lo ..\basic\io\io
..\bin\AS8085.EXE -lo monitor
..\bin\aslink.exe -f monitor
