@ECHO OFF

cd ..\basic\io
..\..\bin\AS8085.EXE -lo io
cd ..\..\monitor

cd ..\basic\fbuffer
..\..\bin\AS8085.EXE -lo fbuffer
cd ..\..\monitor

cd ..\basic\integer
..\..\bin\AS8085.EXE -lo integer
cd ..\..\monitor

..\bin\AS8085.EXE -lo monitor
..\bin\aslink.exe -f monitor
