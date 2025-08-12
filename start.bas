'
' Nieuws voor Doven, versie 1.0
' Tekstweergave kan verbeterd worden. Ook het font (mist trema's en zo)
'
_Title "Nieuws voor Doven en Slechthorenden"
_FullScreen , _Smooth
Screen _NewImage(1450, 410, 32)
ff& = FreeFile
Open "output.txt" For Input As #ff&
Line Input #ff&, vandaag$
Close #ff&

Const BLACK = _RGB32(0, 0, 0)
Const WHITE = _RGB32(255, 255, 255)
Const GREEN = _RGB32(0, 255, 0)
Const YELLOW = _RGB32(255, 255, 0)
Const RED = _RGB32(255, 0, 0)
Const CYAN = _RGB32(28, 227, 255)
Const BLUE = _RGB32(0, 0, 255)
Const BLUE_BG = _RGB32(0, 0, 255)
Const BLACK_BG = _RGB32(0, 0, 0)

a = 160
x = -30
omhoog = 30

fon& = _LoadFont("font.ttf", 25, "MONOSPACE")
If fon& = 0 Then Print "Fout bij laden font": Sleep: End
_Font fon&

' Font geschikt maken voor QB64
For i = 0 To 255
    _MapUnicode i To i
Next

Line (420, 45)-(1134, 385), CYAN, BF
Color BLUE
_PrintMode _KeepBackground
_PrintString (480, 100), "N I E U W S  voor  D O V E N"
_PrintString (480, 155), "en"
_PrintString (480, 205), "S L E C H T H O R E N D E N "
_PrintString (480, 290), vandaag$
_Delay 5
Line (420, 45)-(1134, 385), CYAN, BF

Declare Sub PrintLine (txt$, linesOnPage%)
Dim outLineCount As Integer
Dim outCount As Integer
outLineCount = 0

Open "output.txt" For Input As #1
Do While Not EOF(1)
    Line Input #1, line$
    If UCase$(Left$(line$, 9)) = "== PAGINA" Then
        ' Sla de regel "NOS Teletekst xxx" over
        If Not EOF(1) Then Line Input #1, dummy$
        ' Sla de blanco regel na "NOS Teletekst" over
        If Not EOF(1) Then Line Input #1, dummy$
        ' Lees de titelregel
        If Not EOF(1) Then
            Line Input #1, title$
        Else
            Exit Do
        End If
        title$ = UCase$(title$)

        ' Regel na de titel (kan blanco, begin van tekst, of direct marker)
        firstContent$ = ""
        If Not EOF(1) Then
            Line Input #1, line$
        Else
            line$ = ""
        End If

        If line$ = "" Then
            firstContent$ = ""
        ElseIf UCase$(Left$(line$, 6)) = "NIEUWS" And InStr(UCase$(line$), "SPORT") > 0 Then
            GoTo SkipArticleContent
        Else
            firstContent$ = line$
        End If

        ' Lees artikeltekst t/m marker
        article$ = ""
        If firstContent$ <> "" Then
            line$ = firstContent$
        Else
            If Not EOF(1) Then
                Line Input #1, line$
            Else
                line$ = ""
            End If
        End If

        Do While Not EOF(1)
            If UCase$(Left$(line$, 6)) = "NIEUWS" And InStr(UCase$(line$), "SPORT") > 0 Then
                Exit Do
            End If
            If line$ <> "" Then
                ' Harde afbreking met koppelteken: voeg volgende regel direct aan
                Do While Right$(line$, 1) = "-" And Not EOF(1)
                    Line Input #1, continuation$
                    If UCase$(Left$(continuation$, 6)) = "NIEUWS" And InStr(UCase$(continuation$), "SPORT") > 0 Then
                        Exit Do
                    End If
                    If continuation$ = "" Then Exit Do
                    line$ = Left$(line$, Len(line$) - 1) + continuation$
                Loop
                article$ = article$ + line$ + " "
            End If
            If Not EOF(1) Then
                Line Input #1, line$
            Else
                line$ = ""
            End If
        Loop

        SkipArticleContent:
        article$ = RTrim$(article$)

        ' Bouw gewrapte regels (max 30 tekens), met witregel na punt.
        outCount = 0
        ReDim out$(1 To 1)
        Dim posi As Long
        Dim startPos As Long
        cur$ = ""
        w$ = ""
        startPos = 1

        Do
            posi = InStr(startPos, article$, " ")
            If posi > 0 Then
                w$ = Mid$(article$, startPos, posi - startPos)
                If w$ <> "" Then
                    If cur$ = "" Then
                        cur$ = w$
                    ElseIf Len(cur$) + 1 + Len(w$) <= 30 Then
                        cur$ = cur$ + " " + w$
                    Else
                        outCount = outCount + 1
                        ReDim _Preserve out$(1 To outCount)
                        out$(outCount) = cur$
                        cur$ = w$
                    End If
                    ' Witregel na zin
                    If Right$(w$, 1) = "." Then
                        outCount = outCount + 1
                        ReDim _Preserve out$(1 To outCount)
                        out$(outCount) = cur$
                        outCount = outCount + 1
                        ReDim _Preserve out$(1 To outCount)
                        out$(outCount) = ""
                        cur$ = ""
                    End If
                End If
                startPos = posi + 1
                Do While startPos <= Len(article$) And Mid$(article$, startPos, 1) = " "
                    startPos = startPos + 1
                Loop
            Else
                If startPos <= Len(article$) Then
                    w$ = Mid$(article$, startPos)
                Else
                    w$ = ""
                End If
                If w$ <> "" Then
                    If cur$ = "" Then
                        cur$ = w$
                    ElseIf Len(cur$) + 1 + Len(w$) <= 30 Then
                        cur$ = cur$ + " " + w$
                    Else
                        outCount = outCount + 1
                        ReDim _Preserve out$(1 To outCount)
                        out$(outCount) = cur$
                        cur$ = w$
                    End If
                    If Right$(w$, 1) = "." Then
                        outCount = outCount + 1
                        ReDim _Preserve out$(1 To outCount)
                        out$(outCount) = cur$
                        outCount = outCount + 1
                        ReDim _Preserve out$(1 To outCount)
                        out$(outCount) = ""
                        cur$ = ""
                    End If
                End If
                Exit Do
            End If
        Loop

        If cur$ <> "" Then
            outCount = outCount + 1
            ReDim _Preserve out$(1 To outCount)
            out$(outCount) = cur$
        End If

        ' Verwijder eventuele laatste witregel
        If outCount > 0 Then
            If out$(outCount) = "" Then
                outCount = outCount - 1
                If outCount < 1 Then
                    ReDim out$(1 To 1)
                Else
                    ReDim _Preserve out$(1 To outCount)
                End If
            End If
        End If

        Dim i As Integer, j As Integer
        i = 1
        Do While i < outCount
            If out$(i) <> "" Then
                If InStr(out$(i), " ") = 0 Then
                    If out$(i + 1) <> "" Then
                        If Len(out$(i)) + 1 + Len(out$(i + 1)) <= 30 Then
                            out$(i) = out$(i) + " " + out$(i + 1)
                            For j = i + 1 To outCount - 1
                                out$(j) = out$(j + 1)
                            Next j
                            outCount = outCount - 1
                            ReDim _Preserve out$(1 To outCount)
                            i = i - 1
                        End If
                    End If
                End If
            End If
            i = i + 1
        Loop

        ' Bereken totaal benodigde regels voor dit artikel
        Dim totalLines As Integer
        totalLines = 0

        ' Tel titelregels
        Dim tCount As Integer
        Dim tStart As Long
        tCount = 0
        ReDim tWords$(1 To 1)
        tStart = 1

        Do
            posi = InStr(tStart, title$, " ")
            If posi > 0 Then
                w$ = Mid$(title$, tStart, posi - tStart)
                If w$ <> "" Then
                    tCount = tCount + 1
                    ReDim _Preserve tWords$(1 To tCount)
                    tWords$(tCount) = w$
                End If
                tStart = posi + 1
                Do While tStart <= Len(title$) And Mid$(title$, tStart, 1) = " "
                    tStart = tStart + 1
                Loop
            Else
                If tStart <= Len(title$) Then
                    w$ = Mid$(title$, tStart)
                Else
                    w$ = ""
                End If
                If w$ <> "" Then
                    tCount = tCount + 1
                    ReDim _Preserve tWords$(1 To tCount)
                    tWords$(tCount) = w$
                End If
                Exit Do
            End If
        Loop

        cur$ = ""
        For i = 1 To tCount
            w$ = tWords$(i)
            If cur$ = "" Then
                cur$ = w$
            ElseIf Len(cur$) + 1 + Len(w$) <= 30 Then
                cur$ = cur$ + " " + w$
            Else
                totalLines = totalLines + 1
                cur$ = w$
            End If
        Next i
        If cur$ <> "" Then totalLines = totalLines + 1

        If outLineCount > 0 Then totalLines = totalLines + 1

        totalLines = totalLines + outCount

        ' Controleer of artikel past op huidige pagina
        If outLineCount > 0 And (outLineCount + totalLines) > 12 Then
            ' Start nieuwe pagina
            Line (375, 40)-(400, 385), CYAN, BF
            For ii = 40 To 385
                Line (375, ii)-(400, ii + 1), BLACK, BF
                _Delay 0.045
            Next ii
            Line (420, 45)-(1134, 385), CYAN, BF
            outLineCount = 0
        End If

        ' Titel afdrukken
        cur$ = ""
        For i = 1 To tCount
            w$ = tWords$(i)
            If cur$ = "" Then
                cur$ = w$
            ElseIf Len(cur$) + 1 + Len(w$) <= 30 Then
                cur$ = cur$ + " " + w$
            Else
                _PrintMode _KeepBackground
                Color BLUE
                PrintLine cur$, outLineCount
                cur$ = w$
            End If
        Next i
        If cur$ <> "" Then
            _PrintMode _KeepBackground
            Color BLUE
            PrintLine cur$, outLineCount
        End If

        ' Witregel na titel (maar nooit bovenaan een nieuwe pagina)
        If outLineCount > 0 Then
            _PrintMode _KeepBackground
            Color BLUE
            PrintLine "", outLineCount
        End If

        ' Artikelregels afdrukken - ALLE regels, ook als het over pagina's loopt
        For i = 1 To outCount
            _PrintMode _KeepBackground
            Color BLUE
            PrintLine out$(i), outLineCount
        Next i

        ' Voeg een extra witregel toe na elk artikel (als er nog ruimte is)
        If outLineCount > 0 And outLineCount < 12 Then
            _PrintMode _KeepBackground
            Color BLUE
            PrintLine "", outLineCount
        End If
    End If
Loop
Close #1

' Eindscherm met semigraphics. :)
Cls
Line (420, 45)-(1134, 385), CYAN, BF
Color BLUE
_PrintMode _KeepBackground
Locate 5, 32: Print Chr$(222); Chr$(178); Chr$(32); Chr$(222); Chr$(32); Chr$(222); Chr$(128); Chr$(199); Chr$(32); Chr$(222); Chr$(128); Chr$(199); Chr$(32); Chr$(222); Chr$(178)
Locate 6, 32: Print Chr$(222); Chr$(175); Chr$(32); Chr$(222); Chr$(32); Chr$(222); Chr$(32); Chr$(222); Chr$(32); Chr$(222); Chr$(175); Chr$(156); Chr$(32); Chr$(222); Chr$(175)
Locate 9, 29: Print "VOLGENDE  UITZENDING"
Locate 11, 35: Print "23.45 uur"
Locate 13, 34: Print "NEDERLAND 1"
Sleep
System

If outLineCount <> 0 Then
End If
End

Sub PrintLine (txt$, linesOnPage%)
    If txt$ = "" And linesOnPage% = 0 Then Exit Sub

    If linesOnPage% >= 12 Then
        Line (375, 40)-(400, 385), CYAN, BF
        ' Balkanimatie.
        For ii = 40 To 385
            Line (375, ii)-(400, ii + 1), BLACK, BF
            If InKey$ <> "" Then System: End
            _Delay 0.045
        Next ii

        ' Cyaanblauwe achtergrond
        Line (420, 45)-(1134, 385), CYAN, BF
        linesOnPage% = 0
    End If

    ' Print de regel
    Locate linesOnPage% + 1 + 2, 24
    Print txt$
    linesOnPage% = linesOnPage% + 1
End Sub

Function DayOfWeek% (d As Long, m As Long, y As Long)
    Dim h As Long, K As Long, J As Long
    If m <= 2 Then m = m + 12: y = y - 1
    K = y Mod 100
    J = y \ 100
    h = (d + (13 * (m + 1)) \ 5 + K + (K \ 4) + (J \ 4) + (5 * J)) Mod 7
    DayOfWeek% = ((h + 6) Mod 7) + 1
End Function

