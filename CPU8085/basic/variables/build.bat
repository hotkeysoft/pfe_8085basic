@ECHO OFF
..\..\bin\AS8085.EXE -lo variable
..\..\bin\AS8085.EXE -lo test
..\..\bin\AS8085.EXE -lo ..\common\common
..\..\bin\aslink.exe -f variable
..\..\bin\hexbin variable.ihx
