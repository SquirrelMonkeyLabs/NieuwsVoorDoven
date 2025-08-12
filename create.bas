' * * * * * * * * * * * * * * * * * * * * * * * * * * * *
' Dit programma haalt Teletekstpagina's van de data-server
' via Powershell (standaard in Windows) en verwijdert semi-
' grafische tekens, tags en past de tekst aan om in het
' andere programma (Nieuws voor Doven en Slechthorenden,
' ingelezen te worden.
' * * * * * * * * * * * * * * * * * * * * * * * * * * * *

_Title "Create - Nieuws-downloader v1.0"
Option _Explicit

Const STARTPAGE% = 104
Const ENDPAGE% = 199
Const BASEURL$ = "https://teletekst-data.nos.nl/json/"
Const OUTTXT$ = "output.txt"

Dim p%: Dim file$, cmd$: Dim ffIn, ffOut: Dim line$, all$, content$, readable$: Dim progressCol%: Dim f: Dim tmpDate$
Dim dd%: Dim mm%: Dim yy%: Dim weekday%: Dim vandaag$: Dim sep1%: Dim sep2%: Dim i%: Dim ch$: Dim i2%: Dim a%: Dim b%

' Output leegmaken
ffOut = FreeFile
Open OUTTXT$ For Output As #ffOut
Close #ffOut

' --- Eerste regel: datum in Nederlandse notatie ---
Dim dagen$(7), maanden$(12)
dagen$(1) = "ZONDAG": dagen$(2) = "MAANDAG": dagen$(3) = "DINSDAG": dagen$(4) = "WOENSDAG"
dagen$(5) = "DONDERDAG": dagen$(6) = "VRIJDAG": dagen$(7) = "ZATERDAG"
maanden$(1) = "JANUARI": maanden$(2) = "FEBRUARI": maanden$(3) = "MAART": maanden$(4) = "APRIL"
maanden$(5) = "MEI": maanden$(6) = "JUNI": maanden$(7) = "JULI": maanden$(8) = "AUGUSTUS"
maanden$(9) = "SEPTEMBER": maanden$(10) = "OKTOBER": maanden$(11) = "NOVEMBER": maanden$(12) = "DECEMBER"
tmpDate$ = Date$
' Autodetecteer of Date$ dd-mm-jjjj of mm-dd-jjjj (ook / of . als scheiding toegestaan)
sep1% = 0: sep2% = 0
For i% = 1 To Len(tmpDate$)
    ch$ = Mid$(tmpDate$, i%, 1)
    If ch$ < "0" Or ch$ > "9" Then sep1% = i%: Exit For
Next
For i2% = sep1% + 1 To Len(tmpDate$)
    ch$ = Mid$(tmpDate$, i2%, 1)
    If ch$ < "0" Or ch$ > "9" Then sep2% = i2%: Exit For
Next
a% = Val(Left$(tmpDate$, sep1% - 1))
b% = Val(Mid$(tmpDate$, sep1% + 1, sep2% - sep1% - 1))
yy% = Val(Mid$(tmpDate$, sep2% + 1))
' Autodetectie met duidelijke regels:
' - Als   n deel > 12 dan is dat de DAG
' - Als allebei <= 12 (ambigu), kies standaard mm-dd-jjjj (VS-volgorde)
If a% > 12 And b% <= 12 Then
    dd% = a%: mm% = b%
ElseIf b% > 12 And a% <= 12 Then
    dd% = b%: mm% = a%
Else
    mm% = a%: dd% = b%
End If
weekday% = DayOfWeek%(dd%, mm%, yy%)
vandaag$ = dagen$(weekday%) + " " + LTrim$(Str$(dd%)) + " " + maanden$(mm%)
ffOut = FreeFile: Open OUTTXT$ For Append As #ffOut: Print #ffOut, vandaag$: Close #ffOut
' --- Einde datumregel ---


Color 11, 1: Cls

Locate 2, 1: Print Chr$(201) + String$(78, 205) + Chr$(187);
For f = 3 To 23
    Locate f, 1: Print Chr$(186);
    Locate f, 80: Print Chr$(186);
Next f
Locate 24, 1: Print Chr$(200) + String$(78, 205) + Chr$(188);


Locate 25, 1: Print String$(80, 176);
Locate 1, 1: Color 1, 7: Print String$(80, 32);
Locate 1, 14: Color 1, 7: Print "Nieuws voor Doven en Slechthorenden - Paginadownloader"
Locate 7, 16: Color 3, 1: Print "Het binnenhalen kan even duren. De nieuwspagina's"
Locate 8, 16: Color 3, 1: Print "worden van de NOS Teletekst-dataserver gehaald en"
Locate 9, 16: Color 3, 1: Print "omdat er geen vaste paginanummers gebruikt worden"
Locate 10, 16: Color 3, 1: Print "voor nieuws, moeten we de pagina's van 104 t/m 199"
Locate 11, 16: Color 3, 1: Print "doorlopen, op zoek naar nieuwsartikelen."


For p% = STARTPAGE% To ENDPAGE%
    file$ = "page_" + LTrim$(Str$(p%)) + ".json"

    ' Download via PowerShell (omdat QB64 die niet kan)
    cmd$ = "powershell -NoProfile -Command " + CHR$(34) + _
           "$u='" + BASEURL$ + LTRIM$(STR$(p%)) + "'; " + _
           "$o='" + file$ + "'; " + _
           "$r=Invoke-WebRequest -Uri $u -UseBasicParsing; " + _
           "if ($r.StatusCode -eq 200) { $r.Content | Out-File -Encoding UTF8 $o }" + CHR$(34)
    Shell _Hide cmd$

    If _FileExists(file$) Then
        On Error GoTo SkipPage

        ' Haalt json-bestand binnen
        ffIn = FreeFile
        Open file$ For Input As #ffIn
        all$ = ""
        Do Until EOF(ffIn)
            Line Input #ffIn, line$
            If Len(all$) Then all$ = all$ + Chr$(10)
            all$ = all$ + line$
        Loop
        Close #ffIn

        ' Conentfiltering
        content$ = GetJsonString$(all$, "content")
        If content$ <> "" Then
            ' Unescape (\n, \", \\, \t, \r, \/)
            content$ = JsonUnescape$(content$)

            ' HTML-tags strippen
            content$ = StripTags$(content$)

            ' Semigrafische/hex entiteiten opruimen
            content$ = CleanWeirdEntities$(content$)

            ' HTML-entiteiten (&euml; etc.) decoderen
            content$ = HtmlDecode$(content$)

            ' Spaties opschonen + trims per regel
            content$ = SqueezeSpaces$(content$)

            ' Lege regel na . ! ?
            readable$ = AddBlankLineAfterTerminators$(content$)

            ' Wegschrijven
            ffOut = FreeFile
            Open OUTTXT$ For Append As #ffOut
            Print #ffOut, "== Pagina " + LTrim$(Str$(p%)) + " =="
            Print #ffOut, readable$
            Print #ffOut, ""
            Close #ffOut
        End If
    End If

    ContinueLoop:
    Color 11, 1: Locate 15, 16: Print "[ Indien beschikbaar, binnenhalen van pagina"; p%; "]"

    ' Veilige voortgangskolom (altijd = 1 en = 79)
    progressCol% = 1 + Int(((p% - STARTPAGE%) * 78) / (ENDPAGE% - STARTPAGE% + 1))
    If progressCol% < 1 Then progressCol% = 1
    If progressCol% > 79 Then progressCol% = 79
    Locate 25, progressCol%: Print " ";
Next p%

Locate 25, 1: Print String$(80, 178);
Sound 800, 1
Locate 17, 16: Color 14: Print "Klaar! Druk op een toets."
Sleep: System: End

SkipPage:
Resume ContinueLoop


' ----------

Function GetJsonString$ (src$, key$)
    Dim k$, i&, j&, c$, out$
    Dim esc As _Byte
    k$ = Chr$(34) + key$ + Chr$(34) + ":"
    i& = InStr(src$, k$)
    If i& = 0 Then GetJsonString$ = "": Exit Function

    i& = i& + Len(k$)
    Do While i& <= Len(src$) And Mid$(src$, i&, 1) = " "
        i& = i& + 1
    Loop
    If i& > Len(src$) Or Mid$(src$, i&, 1) <> Chr$(34) Then GetJsonString$ = "": Exit Function

    i& = i& + 1
    out$ = ""
    esc = 0
    For j& = i& To Len(src$)
        c$ = Mid$(src$, j&, 1)
        If esc Then
            out$ = out$ + Chr$(92) + c$
            esc = 0
        ElseIf c$ = Chr$(92) Then ' "\" = CHR$(92)
            esc = -1
        ElseIf c$ = Chr$(34) Then ' afsluitende quote
            Exit For
        Else
            out$ = out$ + c$
        End If
    Next
    GetJsonString$ = out$
End Function

Function JsonUnescape$ (s$)
    ' Zet \n, \r, \t, \", \\ en \/ om; \uXXXX -> '?'
    Dim i&, ch$, out$, nextChar$, n$
    out$ = ""
    i& = 1
    Do While i& <= Len(s$)
        ch$ = Mid$(s$, i&, 1)
        If ch$ = Chr$(92) And i& < Len(s$) Then 'backslash
            nextChar$ = Mid$(s$, i& + 1, 1)
            Select Case nextChar$
                Case "n"
                    out$ = out$ + Chr$(13) + Chr$(10)
                    i& = i& + 2
                Case "r"
                    i& = i& + 2
                Case "t"
                    out$ = out$ + Chr$(9)
                    i& = i& + 2
                Case Chr$(34) ' aanhalingsteken
                    out$ = out$ + Chr$(34)
                    i& = i& + 2
                Case Chr$(92) ' backslash
                    out$ = out$ + Chr$(92)
                    i& = i& + 2
                Case Chr$(47) ' slash
                    out$ = out$ + Chr$(47)
                    i& = i& + 2
                Case "u"
                    If i& + 5 <= Len(s$) Then
                        n$ = Mid$(s$, i& + 2, 4)
                        out$ = out$ + "?"
                        i& = i& + 6
                    Else
                        i& = i& + 2
                    End If
                Case Else
                    out$ = out$ + nextChar$
                    i& = i& + 2
            End Select
        Else
            out$ = out$ + ch$
            i& = i& + 1
        End If
    Loop
    JsonUnescape$ = out$
End Function

Function ReplaceAll$ (src$, find$, repl$)
    Dim posi&, out$
    out$ = src$
    posi& = InStr(out$, find$)
    Do While posi& > 0
        out$ = Left$(out$, posi& - 1) + repl$ + Mid$(out$, posi& + Len(find$))
        posi& = InStr(posi& + Len(repl$), out$, find$)
    Loop
    ReplaceAll$ = out$
End Function

Function StripTags$ (src$)
    ' Verwijdert alles tussen < en >
    Dim i&, c$, out$
    Dim inTag As _Byte
    out$ = ""
    For i& = 1 To Len(src$)
        c$ = Mid$(src$, i&, 1)
        If c$ = "<" Then
            inTag = -1
        ElseIf c$ = ">" Then
            inTag = 0
        ElseIf inTag = 0 Then
            out$ = out$ + c$
        End If
    Next
    StripTags$ = out$
End Function

Function CleanWeirdEntities$ (src$)
    Dim s$
    s$ = src$
    ' Verwijder semigraphics
    s$ = RemoveHexEntitiesWithPrefix$(s$, "&#xF0")
    ' Verwijder overige &#xetc.
    s$ = RemoveAllHexEntities$(s$)
    CleanWeirdEntities$ = s$
End Function

Function RemoveHexEntitiesWithPrefix$ (src$, prefix$)
    ' Vervang door spatie
    Dim i&, j&, out$, p$
    out$ = src$
    i& = InStr(out$, prefix$)
    Do While i& > 0
        j& = InStr(i&, out$, ";")
        If j& > 0 Then
            p$ = Mid$(out$, i&, j& - i& + 1)
            out$ = Left$(out$, i& - 1) + " " + Mid$(out$, j& + 1)
        Else
            Exit Do
        End If
        i& = InStr(out$, prefix$)
    Loop
    RemoveHexEntitiesWithPrefix$ = out$
End Function

Function RemoveAllHexEntities$ (src$)

    Dim i&, j&, out$, p$
    out$ = src$
    i& = InStr(out$, "&#x")
    Do While i& > 0
        j& = InStr(i&, out$, ";")
        If j& > 0 Then
            p$ = Mid$(out$, i&, j& - i& + 1)
            out$ = Left$(out$, i& - 1) + Mid$(out$, j& + 1)
        Else
            Exit Do
        End If
        i& = InStr(out$, "&#x")
    Loop
    RemoveAllHexEntities$ = out$
End Function

Function HtmlDecode$ (src$)
    Dim s$
    s$ = src$
    s$ = ReplaceAll$(s$, "&nbsp;", " ")
    s$ = ReplaceAll$(s$, "&amp;", "&")
    s$ = ReplaceAll$(s$, "&quot;", Chr$(34))
    s$ = ReplaceAll$(s$, "&lt;", "<")
    s$ = ReplaceAll$(s$, "&gt;", ">")
    s$ = ReplaceAll$(s$, "&euml;", " ")
    s$ = ReplaceAll$(s$, "&iuml;", " ")
    s$ = ReplaceAll$(s$, "&ouml;", " ")
    s$ = ReplaceAll$(s$, "&uuml;", " ")
    s$ = ReplaceAll$(s$, "&aacute;", " ")
    s$ = ReplaceAll$(s$, "&eacute;", " ")
    s$ = ReplaceAll$(s$, "&iacute;", " ")
    s$ = ReplaceAll$(s$, "&oacute;", " ")
    s$ = ReplaceAll$(s$, "&uacute;", " ")
    s$ = ReplaceAll$(s$, "&ntilde;", " ")
    s$ = ReplaceAll$(s$, "&ccedil;", " ")
    s$ = ReplaceAll$(s$, "&egrave;", " ")
    s$ = ReplaceAll$(s$, "&agrave;", " ")
    s$ = ReplaceAll$(s$, "&ocirc;", " ")
    HtmlDecode$ = s$
End Function

Function SqueezeSpaces$ (src$)
    Dim s$, before$
    s$ = src$
    Do
        before$ = s$
        s$ = ReplaceAll$(s$, "  ", " ")
    Loop While s$ <> before$
    s$ = TrimLines$(s$)
    SqueezeSpaces$ = s$
End Function

Function TrimLines$ (src$)
    Dim out$, i&, c$, line$
    out$ = ""
    line$ = ""
    For i& = 1 To Len(src$)
        c$ = Mid$(src$, i&, 1)
        If c$ = Chr$(13) Then
        ElseIf c$ = Chr$(10) Then
            line$ = LTrim$(RTrim$(line$))
            If Len(out$) Then out$ = out$ + Chr$(13) + Chr$(10)
            out$ = out$ + line$
            line$ = ""
        Else
            line$ = line$ + c$
        End If
    Next
    If Len(line$) Then
        If Len(out$) Then out$ = out$ + Chr$(13) + Chr$(10)
        out$ = out$ + LTrim$(RTrim$(line$))
    End If
    TrimLines$ = out$
End Function

Function AddBlankLineAfterTerminators$ (src$)
    ' Lege regel na . ! ?.
    Dim out$, i&, ch$, nxt$, c2$
    Dim j&

    out$ = ""
    i& = 1
    Do While i& <= Len(src$)
        ch$ = Mid$(src$, i&, 1)
        out$ = out$ + ch$

        If ch$ = "." Or ch$ = "!" Or ch$ = "?" Then
            If i& < Len(src$) Then
                nxt$ = Mid$(src$, i& + 1, 1)
            Else
                nxt$ = ""
            End If

            If ch$ = "." Then
                If nxt$ = "." Then GoTo SkipInsert
                If nxt$ >= "0" And nxt$ <= "9" Then GoTo SkipInsert
            End If

            j& = i& + 1
            Do While j& <= Len(src$)
                c2$ = Mid$(src$, j&, 1)
                If c2$ = " " Or c2$ = Chr$(13) Or c2$ = Chr$(10) Then
                    j& = j& + 1
                Else
                    Exit Do
                End If
            Loop

            If j& <= Len(src$) And Mid$(src$, j&, 1) = Chr$(34) Then
                out$ = out$ + Chr$(34)
                j& = j& + 1
                Do While j& <= Len(src$)
                    c2$ = Mid$(src$, j&, 1)
                    If c2$ = " " Or c2$ = Chr$(13) Or c2$ = Chr$(10) Then
                        j& = j& + 1
                    Else
                        Exit Do
                    End If
                Loop
            End If

            ' Voeg witregel toe
            out$ = out$ + Chr$(13) + Chr$(10) + Chr$(13) + Chr$(10)
            i& = j& - 1
        End If

        SkipInsert:
        i& = i& + 1
    Loop

    AddBlankLineAfterTerminators$ = out$
End Function


' --- Weekdag berekenen (1=ZONDAG..7=ZATERDAG) ---
Function DayOfWeek% (d As Long, m As Long, y As Long)
    Dim t(12) As Integer
    t(1) = 0: t(2) = 3: t(3) = 2: t(4) = 5: t(5) = 0: t(6) = 3
    t(7) = 5: t(8) = 1: t(9) = 4: t(10) = 6: t(11) = 2: t(12) = 4
    If m < 3 Then y = y - 1
    DayOfWeek% = ((y + y \ 4 - y \ 100 + y \ 400 + t(m) + d) Mod 7) + 1
End Function

