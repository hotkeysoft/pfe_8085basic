@ECHO OFF
..\..\bin\AS8085.EXE -lo integer
..\..\bin\AS8085.EXE -lo test
..\..\bin\AS8085.EXE -lo ..\common\common
..\..\bin\aslink.exe -f integer
..\..\bin\hexbin integer.ihx