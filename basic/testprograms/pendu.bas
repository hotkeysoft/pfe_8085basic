50 CLS
100 A = RND(1) AND 15: REM 0..15
101 IF A>10 THEN GOTO 100
110 GOSUB A+1000
120 FOR I=1 TO LEN(A$)
130 GOTOXY I*4+10, 5
140 PRINT "_";
150 NEXT
190 ES = 1
200 GOTOXY 10,10:PRINT "Trouve:",TR;
201 GOTOXY 10,11:PRINT "Essai: ",ES;
210 GOTOXY 10,15:PRINT"Entrez une lettre:     ":GOTOXY 29,15:INPUT L$
211 IF(LEN(L$)<>1) OR(L$<"A") OR (L$>"Z") THEN GOTO 210
219 OK = 0
220 FOR I=1 TO LEN(A$): IF MID$(A$,I,1) = L$ THEN OK = 1:TR=TR+1:GOSUB2000
225 NEXT
226 IF OK=1 THEN GOTO 200
230 GOTOXY 10,20:PRINT"Desole... essayez encore"
240 BEEP
245 GOTOXY 10,20:PRINT"                          "
250 ES=ES+1
260 GOTO 200
999 END
1000 A$="INTERPRETEUR":RETURN
1001 A$="EXPRESSION":RETURN
1002 A$="EVALUATION":RETURN
1003 A$="COMMUNICATION":RETURN
1004 A$="MICROPROCESSEUR":RETURN
1005 A$="ANALOGIQUE":RETURN
1006 A$="ASYNCHRONE":RETURN
1007 A$="PROBLEMATIQUE":RETURN
1008 A$="METHODOLOGIE":RETURN
1009 A$="IMPLANTATION":RETURN
1010 A$="OPERATION":RETURN
2000 GOTOXY I*4+10,5
2001 COLOR 14:PRINT MID$(A$,I,1);:COLOR 7
2002 RETURN
