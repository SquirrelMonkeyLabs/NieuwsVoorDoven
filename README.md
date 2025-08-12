# NieuwsVoorDoven
Download the news of today from NOS Teletekst and animate it as an early 1980s Dutch Nieuws voor Doven en Slechthorenden-broadcast.

Dit programma is geschreven in de programmeertaal QB64.
Het simuleert een Nieuws voor Doven en Slechthorenden-uitzending uit 1984/1985.

Dit heeft u nodig:
- Powershell (zit standaard in nieuwe Windows-versies).
- QB64 (ik heb een EXE bijgevoegd voor de het afspeelprogramma, maar niet voor start omdat de virusscanners gaan loeien bij bestanden die bestanden van servers afhalen).
- Een monitor met een 16:9-aspectratio.
Zorg ervoor dat alle bestanden in dezelfde directory staan of pas het pad aan in de broncode.

De bestanden:
CREATE.BAS - haalt nieuws van de NOS Teletekst-server (JSON-formaat) en zet ze om naar een textbestand.
FONT.TTF   - Een truetype-font met het lettertype van Nieuws voor Doven.
START.BAS  - Het programma dat de uitzending simuleert.
START.EXE  - 64 bit-gecompilede versie van Start.BAS
OUTPUT.EXE - Een voorbeeldbestand met verzonnen nieuwsartikelen.

Veel kijkplezier!
