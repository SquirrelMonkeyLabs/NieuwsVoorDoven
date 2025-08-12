# NieuwsVoorDoven
Download the news of today from NOS Teletekst and animate it as an early 1980s Dutch Nieuws voor Doven en Slechthorenden-broadcast.

D U T C H

[Wat?]
- Dit programma is geschreven in de programmeertaal QB64.
- Het simuleert een Nieuws voor Doven en Slechthorenden-uitzending uit 1984/1985.

[Dit heeft u nodig]
- Powershell (zit standaard in nieuwe Windows-versies).
- QB64 (ik heb een EXE bijgevoegd voor de het afspeelprogramma, maar niet voor start omdat de virusscanners gaan loeien bij bestanden die bestanden van servers afhalen).
- Een monitor met een 16:9-aspectratio.
- Zorg ervoor dat alle bestanden in dezelfde directory staan of pas het pad aan in de broncode.

[De bestanden]
- CREATE.BAS - haalt nieuws van de NOS Teletekst-server (JSON-formaat) en zet ze om naar een textbestand.
- FONT.TTF   - Een truetype-font met het lettertype van Nieuws voor Doven.
- START.BAS  - Het programma dat de uitzending simuleert.
- START.EXE  - 64 bit-gecompilede versie van Start.BAS
- OUTPUT.EXE - Een voorbeeldbestand met verzonnen nieuwsartikelen.

[Toekomstige versies]
- Het font ondersteunt geen trema's en accenten. Dat wil ik in een toekomstige versie aanpassen.
- Soms gaat het typografisch mis, daar moet ik de oorzaak van nog zien te vinden.

[Apple- en Linux-ports?]
- Ik zou het erg op prijs stellen als mensen het willen porten. Dan voeg ik de versies toe.
- Het zou al in QB64 onder Linux en Apple moeten draaien, op de powershell-import na.

Veel kijkplezier!

E N G L I S H

[What?]
- This program is written in the QB64 programming language.
- It simulates a *News for the Deaf and Hard of Hearing* broadcast from 1984/1985.

[What you need]

- PowerShell (included by default in recent Windows versions).
- QB64 (I’ve included an EXE for the playback program, but not for Start, because antivirus software tends to go off when files download other files from servers).
- A monitor with a 16:9 aspect ratio.
- Make sure all files are in the same directory, or adjust the path in the source code.

[The files]
- CREATE.BAS – Retrieves news from the NOS Teletext server (JSON format) and converts it into a text file.
- FONT.TTF – A TrueType font with the *News for the Deaf* typeface.
- START.BAS – The program that simulates the broadcast.
- START.EXE – 64-bit compiled version of START.BAS
- OUTPUT.EXE – A sample file with made-up news articles.

[Future versions]

- The font does not support umlauts and accents; I plan to fix this in a future version.
- Occasionally, there are typographic errors; I still need to find the cause.

[Apple and Linux ports?]
- I would very much appreciate it if people wanted to port this. I will then add those versions.
- It should already run in QB64 on Linux and Apple, except for the PowerShell import.

Enjoy watching!
