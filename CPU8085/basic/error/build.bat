@ECHO OFF
..\..\bin\AS8085.EXE -lo error
..\..\bin\AS8085.EXE -lo test
..\..\bin\aslink.exe -f error
..\..\bin\hexbin error.ihx
