@ECHO OFF
..\..\bin\AS8085.EXE -lo io
..\..\bin\AS8085.EXE -lo test
..\..\bin\aslink.exe -f io
