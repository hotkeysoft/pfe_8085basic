@ECHO OFF
..\..\bin\AS8085.EXE -log io
..\..\bin\AS8085.EXE -log test
..\..\bin\aslink.exe -f io
