@ECHO OFF
..\..\bin\AS8085.EXE -lo common
..\..\bin\AS8085.EXE -lo test
..\..\bin\aslink.exe -f common
