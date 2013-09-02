#!/bin/tclsh

# load libaries
load tclrega.so

# include config
source config.tcl

# Systemvariablen:
# Zahl Wetter-Regen-Heute
# Zahl Wetter-Regen-Morgen
# Zahl Wetter-Regen-Uebermorgen
# Zahl Wetter-MaxTemperatur-Heute
# Zahl Wetter-MaxTemperatur-Morgen
# Zahl Wetter-MaxTemperatur-Uebermorgen
# Zahl Giessen
# Zahl Giessen-Temperatur-Abhaengig

set Dauer 10;
set MaxTemp 10.00;
set Faktor1 3;
set Faktor2 2;
set Faktor3 1;

# Aufruf und Erstellung der xml

set url http://api.wunderground.com/api/$key/forecast/lang:DL/q/Germany/$ort.xml
exec /usr/bin/wget -q -O watering.xml $url

set f [open "watering.xml"]
set input [read $f]
close $f

# Regenrisiko
set tag0regen 0;
regexp "<period>0</period>(.*?)</fcttext_metric>" $input dummy current  ; #get current forecastday0
regexp "Regenrisiko (.*?)%.]]>" $current dummy tag0regen ;

set tag1regen 0;
regexp "<period>2</period>(.*?)</fcttext_metric>" $input dummy current  ; #get current forecastday1
regexp "Regenrisiko (.*?)%.]]>" $current dummy tag1regen ;

set tag2regen 0;
regexp "<period>4</period>(.*?)</fcttext_metric>" $input dummy current  ; #get current forecastday2
regexp "Regenrisiko (.*?)%.]]>" $current dummy tag2regen ;


# Max Temperatur
regexp "<period>0</period>(.*?)<pop>" $input dummy part0tmp  ; #get part0tmp values
regexp "chsttemperatur: (.*?)</fcttext_metric>" $part0tmp dummy part0  ; #get part0 values
regexp "chsttemperatur: (.*?)C." $part0 dummy maxtemp0 ; 

regexp "<period>2</period>(.*?)<pop>" $input dummy part1tmp  ; #get part1tmp values
regexp "chsttemperatur: (.*?)</fcttext_metric>" $part1tmp dummy part1  ; #get part1 values
regexp "chsttemperatur: (.*?)C." $part1 dummy maxtemp1 ; 

regexp "<period>4</period>(.*?)<pop>" $input dummy part2tmp  ; #get part2tmp values
regexp "chsttemperatur: (.*?)</fcttext_metric>" $part2tmp dummy part2  ; #get part2 values
regexp "chsttemperatur: (.*?)C." $part2 dummy maxtemp2 ; 


# Summe Faktoren: Heute Faktor + Morgen Faktor + �bermorgen Faktor
set sumFaktor [expr {$Faktor1 + $Faktor2 + $Faktor3}];

# MaxDauer Faktor -> Je l�nger die Dauer um so kleiner der Faktor
set DauerFaktor [expr {100 / $Dauer}];


#Regenwahrscheinlichkeit mit Faktor berechnen: (100-Regenwahrscheinlichkeit Heute* Faktor 1) + (100-Regenwahrscheinlichkeit Morgen* Faktor 2) + (100-Regenwahrscheinlichkeit �bermorgen* Faktor 3) 
set bewaessern0tmp [expr {100 - $tag0regen}];
set bewaessern1tmp [expr {100 - $tag1regen}];
set bewaessern2tmp [expr {100 - $tag2regen}];

set bewaessern0 [expr {$bewaessern0tmp * $Faktor1}];
set bewaessern1 [expr {$bewaessern1tmp * $Faktor2}];
set bewaessern2 [expr {$bewaessern2tmp * $Faktor3}];
 
set bewaessernsum [expr {$bewaessern0 + $bewaessern1 + $bewaessern2}];
set bewaesserntmp [expr {$DauerFaktor * $sumFaktor}];

set bewaessern [expr {$bewaessernsum / $bewaesserntmp}];

# Temperatur Faktor berechnen Faktor 1 * ((Temperatur Heute - Maximale Gie�temperatur) /10) + Faktor 2 * ((Temperatur Morgen - Maximale Gie�temperatur) /10) + Faktor 3 * ((Temperatur �bermorgen - Maximale Gie�temperatur) /10) 
set tempfaktor [expr {(($Faktor1 * (($maxtemp0 - $MaxTemp) / 10)) + ($Faktor2 * (($maxtemp1 - $MaxTemp) / 10)) + ($Faktor3 * (($maxtemp2 - $MaxTemp) / 10)))}];

# Formel: ( (Regenwahrscheinlichkeit mit Faktor berechnen) / ( 20 /Temperatur Faktor berechnen) * (Summe Faktoren) ) ) * MaxDauer Faktor 
set ErgDauer [expr {($bewaessernsum / (((20 / $tempfaktor) * $sumFaktor)* $DauerFaktor))}];


#
# set ReGaHss variables
#
set rega_cmd ""
append rega_cmd "dom.GetObject('Wetter-Regen-Heute').State('$tag0regen');"
append rega_cmd "dom.GetObject('Wetter-Regen-Morgen').State('$tag1regen');"
append rega_cmd "dom.GetObject('Wetter-Regen-Uebermorgen').State('$tag2regen');"
append rega_cmd "vdom.GetObject('Wetter-MaxTemperatur-Heute').State('$maxtemp0');"
append rega_cmd "dom.GetObject('Wetter-MaxTemperatur-Morgen').State('$maxtemp1');"
append rega_cmd "dom.GetObject('Wetter-MaxTemperatur-Uebermorgen').State('$maxtemp2');"
append rega_cmd "dom.GetObject('Giessen').State('$bewaessern');"
append rega_cmd "dom.GetObject('Giessen-Temperatur-Abhaengig').State('$ErgDauer');"
rega_script $rega_cmd