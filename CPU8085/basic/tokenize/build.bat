@ECHO OFF
..\..\bin\AS8085.EXE -lo tokenize
..\..\bin\AS8085.EXE -lo test
..\..\bin\aslink.exe -f tokenize
