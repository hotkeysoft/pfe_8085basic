@ECHO OFF
..\..\bin\AS8085.EXE -lo strings
..\..\bin\AS8085.EXE -lo test
..\..\bin\AS8085.EXE -lo ..\common\common
..\..\bin\aslink.exe -f strings
..\..\bin\hexbin strings.ihx
