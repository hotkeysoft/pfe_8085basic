@ECHO OFF
..\..\bin\AS8085.EXE -lo variable
..\..\bin\AS8085.EXE -lo test
..\..\bin\aslink.exe -f variable
..\..\bin\hexbin variable.ihx
