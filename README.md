Berechnung der Beregnungsdauer für Sprenkelanlagen/Beäwasserungssystme

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
Diese Programm berechnet aufgrund verschiedener Faktoren die Berägnungsdauer.

#####Systemvariabeln
 Name                        | Variablentyp| Werte|Maßeinheit
:----------------------------|:------------|:-----|:-------
Giessen                      |Zahl         |      |min
Giessen-Temperatur-Abhaengig |Zahl         |      |min

#####Aufruf im homematic Programm:
```
dom.GetObject("CUxD.CUX2801001:1.CMD_EXEC").State("cd /usr/local/addons/homematicWatering && tclsh watering.tcl");
```
