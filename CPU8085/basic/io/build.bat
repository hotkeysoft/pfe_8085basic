@ECHO OFF
..\..\bin\AS8085.EXE -lo io
..\..\bin\AS8085.EXE -lo test
..\..\bin\AS8085.EXE -lo ..\common\common
..\..\bin\aslink.exe -f io
..\..\bin\hexbin io.ihx