@ECHO OFF
..\..\bin\AS8085.EXE -lop main
..\..\bin\AS8085.EXE -lop ..\common\common
..\..\bin\AS8085.EXE -lop ..\error\error
..\..\bin\AS8085.EXE -lop ..\expreval\evaluate
..\..\bin\AS8085.EXE -lop ..\expreval\expreval
..\..\bin\AS8085.EXE -lop ..\integer\integer
..\..\bin\AS8085.EXE -lop ..\io\io
..\..\bin\AS8085.EXE -lop ..\program\program
..\..\bin\AS8085.EXE -lop ..\strings\strings
..\..\bin\AS8085.EXE -lop ..\tokenize\tokenize
..\..\bin\AS8085.EXE -lop ..\variables\variable
..\..\bin\aslink.exe -f main

