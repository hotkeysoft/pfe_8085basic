@ECHO OFF
..\..\bin\AS8085.EXE -lo tokenize
..\..\bin\AS8085.EXE -lo test
..\..\bin\AS8085.EXE -lo ..\common\common
..\..\bin\aslink.exe -f tokenize
..\..\bin\hexbin tokenize.ihx
