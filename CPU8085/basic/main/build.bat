@ECHO OFF
..\..\bin\AS8085.EXE -lo main
..\..\bin\AS8085.EXE -lo ..\common\common
..\..\bin\AS8085.EXE -lo ..\error\error
..\..\bin\AS8085.EXE -lo ..\expreval\evaluate
..\..\bin\AS8085.EXE -lo ..\expreval\expreval
..\..\bin\AS8085.EXE -lo ..\integer\integer
..\..\bin\AS8085.EXE -lo ..\io\io
..\..\bin\AS8085.EXE -lo ..\program\program
..\..\bin\AS8085.EXE -lo ..\strings\strings
..\..\bin\AS8085.EXE -lo ..\tokenize\tokenize
..\..\bin\AS8085.EXE -lo ..\variables\variable
..\..\bin\aslink.exe -f main
..\..\bin\hexbin main.ihx
