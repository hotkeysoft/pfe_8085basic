@ECHO OFF
..\..\bin\AS8085.EXE -lo expreval
..\..\bin\AS8085.EXE -lo test
..\..\bin\AS8085.EXE -lo ..\common\common
..\..\bin\AS8085.EXE -lo ..\integer\integer
..\..\bin\aslink.exe -f expreval
..\..\bin\hexbin expreval.ihx
