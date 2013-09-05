Berechnung der Beregnungsdauer für Sprenkelanlagen/Beäwasserungssysteme

####Benötigte Addons:
#####CCU1:
[Telnet](http://www.homematic-inside.de/software/addons/item/telnet-dienst) -> mit Telnet ein Passwort für den FTP Zugang auf der CCU einrichten

Telnet Session (Windows) öffnen:

*   Start
*   Eingabeaufforderung
*   `telnet`
*   `open 192.168.X.X`
*   `root`
*   `passwd`
*   dein Passwort
*   dein Passwort

[FTP](http://www.homematic-inside.de/software/addons/item/ftp) -> Installieren

[Filezilla](https://filezilla-project.org/) -> Ordner aus dem GIT als Zip herunterladen und nach */usr/local/addons/* kopieren

*   Server:192.168.X.XXX
*   User:root
*   Passwort:dein Passwort was beim Telnet gesetzt wurde

#####CCU2:
[Filezilla](https://filezilla-project.org/) -> Ordner aus dem GIT als Zip herunterladen und nach */usr/local/addons/* kopieren

*   Server: sftp://192.168.X.XX
*   User:root
*   Passwort: MuZhlo9n%8!G
*   Port: 22

#####CCU1/CCU2

[CUx-Daemon](http://www.homematic-inside.de/software/cuxdaemon) -> Performance schonender Aufruf

*   homematic -> Einstellungen -> Systemsteuerung -> Zusatzsoftware
*   Cux-Damon -> Einstellen
*   Geräte
*   CUxD Gerätetyp -> (28)System)

![CuxD](https://github.com/nleutner/homematicWeather/blob/develop/addons/homematicWeather/doc/images/Cux%20Exec.jpg?raw=true)

*   homematic -> Posteingang

![homematic](https://raw.github.com/nleutner/homematicWeather/develop/addons/homematicWeather/doc/images/Cux%20CCU.gif)



###addons/homematicWatering





####config.tcl
Diese Datei ist die einzige die angepasst werden muss.

 Variabel            |Wert     |Beschreibung                                                                |
:--------------------|:--------|:---------------------------------------------------------------------------|
ort                  |         |Name des Ortes für den das Wetter abgefragt werden soll                     |
key                  |         |Ist dein API key von [wunderground](http://api.wunderground.com/weather/api/)                                                                          |
Dauer                |10       |Die maximale Beregnungszeit in min
MaxTemp              |10.00    |Bei Unterschreitung der Temperatur wird der Tag mit mit eingerechnet
Faktor1              |3        |Der heutige Tag bekommt eine Wichtigkeit
Faktor2              |2        |Morgen
Faktor3              |1        |Übermorgen



####watering.tcl
Diese Programm berechnet aufgrund verschiedener Faktoren die Bewässerungsdauer.

Beispielbedingungen aus wunderground.com
*   Heute 10% Regenwahrscheinlichkeit
*   Morgen 10% Regenwahrscheinlichkeit
*   Übermorgen 60% Regenwahrscheinlichkeit

Priorität:
*   Heute Faktor = 3
*   Morgen Faktor = 2
*   Übermorgen Faktor = 1

Ich rechne wie folgt

(100-Regenwahrscheinlichkeit Heute* Faktor 1) + (100-Regenwahrscheinlichkeit Morgen* Faktor 2) + (100-Regenwahrscheinlichkeit Übermorgen* Faktor 3) / (10* (Faktor 1+ Faktor 2 + Faktor 3) = Dauer in min.

=(100-10)*3 + (100-10)*2 + (100-60)*1 / 60

=(270 +180 + 40) / 60

= 490 / 60

= 8,17min

Bedeutet, da es Heute und Morgen wahrscheinlich nicht regnet und erst am Übermorgen regnet, sollen die Pflanzen 8min bewässert werden.

Diese Formel ist meine Grundlage um erstmal überhaupt eine etwas logische Automatisierung hinzu bekommen.


Anschließend wird ein Script erstellt, welches den Werte Bereich der Systemvariabel "Giessen" abfragt und zu einem festen Zeitpunkt den Aktor einschaltet.

Wenn Giessen zwischen 1,00 -1,99 prüfen und Zeitpunkt = 20:00 dann 1min Aktor an und SMS Script (1%20Minute%20Bewaessern).
Sonst Wenn Giessen zwischen 2,00 -2,99 prüfen und Zeitpunkt = 20:00 dann 2min Aktor an und SMS Script (2%20Minute%20Bewaessern).
...

![homematic Programm](https://github.com/Blurline/homematicWatering/blob/develop/addons/homematicWatering/doc/images/AutoGiessen.jpg?raw=true)


Ich habe jetzt das Script um fogende Variabeln ergänzen
Maximale Gießtemperatur in °C
Maximale Gießdauer in min
Die Max Termperatur von Heute/Morgen/Übermorgen wird mit aufgenommen. Dadurch würde sich folgendes Verhalten ergeben.
![Temperaturabhängig](https://github.com/Blurline/homematicWatering/blob/develop/addons/homematicWatering/doc/images/Wetterberechnung.jpg?raw=true)

Die Formel ist etwas kompliziert -> leider
Als Variabel
Maximale Gießdauer : 10min
Maximale Gießtemperatur: 10C

Beispielwerte die von wunderground kommen:
Heute 25°C maximale Temperatur
Heute 0% Regenwahrscheinlichkeit
Morgen 25°C maximale Temperatur
Morgen 0% Regenwahrscheinlichkeit
Übermorgen 25°C maximale Temperatur
Übermorgen 50% Regenwahrscheinlichkeit

Priorität der Tage festgesetzt:
Heute Faktor = 3
Morgen Faktor = 2
Übermorgen Faktor = 1

Summe Faktoren:
Heute Faktor + Morgen Faktor + Übermorgen Faktor

= 3 + 2 + 1
= 6

Regenwahrscheinlichkeit mit Faktor berechnen:
(100-Regenwahrscheinlichkeit Heute* Faktor 1) + (100-Regenwahrscheinlichkeit Morgen* Faktor 2) + (100-Regenwahrscheinlichkeit Übermorgen* Faktor 3)

=(100-0)*3 + (100-0)*2 + (100-50)*1
=(300+ 200 + 50)
= 550

Temperatur Faktor berechnen
Faktor 1 * ((Temperatur Heute - Maximale Gießtemperatur) /10) + Faktor 2 * ((Temperatur Morgen - Maximale Gießtemperatur) /10) + Faktor 3 * ((Temperatur Übermorgen - Maximale Gießtemperatur) /10)

= 3*((25-10)/10) + 2*((25-10)/10) + 1*((25-10)/10)
= 3*1,5 + 2*1,5 + 1*1,5
= 4,5 + 3 + 1,5
= 9

MaxDauer Faktor -> Je länger die Dauer um so kleiner der Faktor
= 100 / Maximale Gießdauer

= 100/10
= 10


UND HIER DIE FORMEL:
= ( ((100-Regenwahrscheinlichkeit Heute* Faktor 1) + (100-Regenwahrscheinlichkeit Morgen* Faktor 2) + (100-Regenwahrscheinlichkeit Übermorgen* Faktor 3) ) / ( 20 / (Faktor 1 * ((Temperatur Heute - Maximale Gießtemperatur) /10) + Faktor 2 * ((Temperatur Morgen - Maximale Gießtemperatur) /10) + Faktor 3 * ((Temperatur Übermorgen - Maximale Gießtemperatur) /10) ) ) * (Heute Faktor + Morgen Faktor + Übermorgen Faktor) ) ) * (100 / Maximale Gießdauer)

vereinfacht:
( (Regenwahrscheinlichkeit mit Faktor berechnen) / (( 20 /Temperatur Faktor berechnen) * (Summe Faktoren) ) ) * MaxDauer Faktor

= (550 / ( ((20 / 9) * 6) *10)
= (550 / (2,2 * 6) *10
= (550 / (13,3) * 10
= (550 / 133,3
= 4,12 min

Heute 25°C kein Regen, Morgen 25°C kein Regen, Übermorgen 25°C und zu 50% Regen würde es heute 4min bewässern. Die Excel Grafik oben zeigt die verschiedenen Variationen mit der jeweiligen Dauer.

Beispiele aus der Grafik:
ca 5min Dauer da Heute 0% 25°C - Morgen 0% 25°C - Übermorgen 0% 30°C -> Es ist warm, kein Regen und es wird wärmer
ca 5min Dauer da Heute 0% 30°C - Morgen 0% 25°C - Übermorgen 50% 25°C -> Es ist heiß, wird aber kälter und regnerisch
ca 5min Dauer da Heute 0% 30°C - Morgen 50% 35°C - Übermorgen 50% 35°C -> Es ist heiß, wird heißer und regnerisch
ca 5min Dauer da Heute 0% 30°C - Morgen 0% 30°C - Übermorgen 100% 30°C -> Es bleibt heiß wird aber regnen


set Dauer 5;
set MaxTemp 10.00;
set Faktor1 3;
set Faktor2 2;
set Faktor3 1;

wird im Script konfiguriert, so oft ändern sich die Zahlen nicht ;) Einfach angeben wie lange die maximale Beregnungszeit ist, und bis welcher °C beregnet werden soll.
Giessen ist die normale Dauer ohne abhängigkeit der Temperatur. Nur aufgrund der Regenprognose!


#####Systemvariabeln
 Name                        | Variablentyp| Werte|Maßeinheit
:----------------------------|:------------|:-----|:-------
Giessen                      |Zahl         |      |min
Giessen-Temperatur-Abhaengig |Zahl         |      |min

#####Aufruf im homematic Programm:
```
dom.GetObject("CUxD.CUX2801001:1.CMD_EXEC").State("cd /usr/local/addons/homematicWatering && tclsh watering.tcl");
```
