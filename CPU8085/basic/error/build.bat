@ECHO OFF
..\..\bin\AS8085.EXE -lo error
..\..\bin\AS8085.EXE -lo test
..\..\bin\AS8085.EXE -lo ..\common\common
..\..\bin\AS8085.EXE -lo ..\io\io
..\..\bin\AS8085.EXE -lo ..\integer\integer
..\..\bin\aslink.exe -f error
..\..\bin\hexbin error.ihx
