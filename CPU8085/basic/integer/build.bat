@ECHO OFF
..\..\bin\AS8085.EXE -lo integer
..\..\bin\AS8085.EXE -lo test
..\..\bin\aslink.exe -f integer
