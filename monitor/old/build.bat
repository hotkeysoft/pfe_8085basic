@ECHO OFF
..\..\bin\AS8085.EXE -lo monitor
..\..\bin\AS8085.EXE -lo io
..\..\bin\aslink.exe -f monitor
