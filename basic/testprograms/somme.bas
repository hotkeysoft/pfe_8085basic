10 A$="---=== Somme ===---":GOSUB 1000
11 A$="Ce programme calcule la somme 1+2+3+...+N": GOSUB 1000
12 A$="Ou n est un nombre defini par l'usager": GOSUB 1000
13 PRINT
20 INPUT "Entrez un nombre, -1 pour quitter: "; N
25 IF N = -1 THEN GOTO 80
30 IF (N<1) OR (N>255) THEN PRINT"Entrez un nombre entre 1 et 255" : GOTO 20
35 SU = 0
40 FOR I=1 TO N: SU = SU+I: PRINT".";:NEXT
45 PRINT
50 PRINT"La somme des nombres de 1 a ";N;" est ";SU
60 INPUT"Voulez-vous recommencer (oui/non)", RE$
70 IF (LEFT$(RE$,1) = "o") OR (LEFT$(RE$,1) = "O") THEN GOTO 20
80 PRINT"Au revoir!"
100 END
1000 REM *CENTER*
1010 L = (80-LEN(A$))/2
1020 FOR I=1TOL:PRINT" ";:NEXT
1025 PRINT A$
1030 RETURN
