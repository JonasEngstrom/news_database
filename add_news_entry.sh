#!/usr/bin/env bash
echo 'Skriv in nya NEWS-parametrar.'
echo 'Skriv NULL när ett värde saknas. Kom ihåg citattecken runt textsträngar.'
echo 'Datavalidering utförs av SQLite3, så kontrollera att inget felmeddelande dyker upp.'
echo 'Notera att skriptet inte skriver över tidigare observationer, om det finns i databasen.'

echo 'Tid [åååå-mm-dd tt:mm]:'
read observation_time

echo 'Andningsfrekvens (andetag/min) [0-200]:'
read respiratory_rate

echo 'Syremättnad (%) [0-100]:'
read oxygen_saturation

echo 'Tillförd syrgas [0 eller 1]:'
read supplemental_oxygen

echo 'Systoliskt blodtryck (mmHg) [0-300]:'
read systolic_pressure

echo 'Pulsfrekvens (slag/min) [0-300]:'
read heart_rate

echo "Medvetandegrad ['A', 'C', 'V', 'P' eller 'U']:"
read consciousness

echo 'Temperatur (°C) [0.0-50.0]:'
read temperature

echo "Kommentarer om mätningen ['textsträng']:"
read comment

sqlite3 news_database.db "INSERT INTO news_parameters (
    time,
    respiratory_rate,
    oxygen_saturation,
    supplemental_oxygen,
    systolic_pressure,
    heart_rate,
    consciousness,
    temperature,
    comment
)
VALUES (
    '$observation_time',
    $respiratory_rate,
    $oxygen_saturation,
    $supplemental_oxygen,
    $systolic_pressure,
    $heart_rate,
    $consciousness,
    $temperature,
    $comment
);"

echo 'Följande rad lades till i databasen. Vänligen kontrollera att den är korrekt.'

sqlite3 news_database.db -cmd ".headers on" ".mode columns" "SELECT * FROM news_parameters WHERE time IS '$observation_time'"
