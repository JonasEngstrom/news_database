# NEWS Databsase

After working in the ICU through almost two and a half years of COVID, I finally caught it myself. Thankfully my symptoms are mild, but having COVID means that I am stuck at home for a few days.

As a way to pass the time and to catch any deterioration early I made this SQL database schema and a few scripts to monitor and graph parameters according to the *[National Early Warning Score 2](https://en.wikipedia.org/wiki/Early_warning_score)*, which is used to prompt assessment by rapid response teams in Swedish hospitals. The project is based on [Swedish national guidelines](https://www.vardhandboken.se/vard-och-behandling/akut-bedomning-och-skattning/bedomning-enligt-news/) and NEWS is taken to mean NEWS2 in the entire project.

## Imagined Use Case

### 1. Create NEWS Database

To setup a new SQLite database the `setup.sh` script is used. It takes the desired database name as an argument.

```bash
(base) user@computer directory % ./setup.sh database_name.db
```

### 2. Add NEWS Parameter Observations

One or several NEWS observations are added to the database. This could be done using SQLite directly, but to facilitate the process the `add_news_observation.sh` script can be used. The script takes the database file’s name as a parameter.

```bash
(base) user@computer directory % ./add_news_entry.sh database_name.db
```

The script goes through the parameters one by one. The values accepted by the SQL constraints are provided in square brackets. Be sure to follow the instructions carefully, if parameters in an incorrect format are provided they will not be added to the database. The same is true if parameters for a time that already exists in the database are provided, as the time variable has a unique constraint to act as the primary key in a table in the database. `NULL` is input to represent missing data (e.g. a missing blood pressure measurment).

After the parameters have been input the script prints the result of an SQL query selecting all variables with the time input earlier in the script. Verify that the input parameters are correct.

The script finishes by calling the `render_news_report.R` script.

```bash
Skriv in nya NEWS-parametrar.
Skriv NULL när ett värde saknas. Kom ihåg citattecken runt textsträngar.
Datavalidering utförs av SQLite3, så kontrollera att inget felmeddelande dyker upp.
Notera att skriptet inte skriver över tidigare observationer, om det finns i databasen.
Tid [åååå-mm-dd tt:mm]:
2022-06-06 17:20
Andningsfrekvens (andetag/min) [0-200]:
12
Syremättnad (%) [0-100]:
100
Tillförd syrgas [0 eller 1]:
0
Systoliskt blodtryck (mmHg) [0-300]:
NULL
Pulsfrekvens (slag/min) [0-300]:
61
Medvetandegrad ['A', 'C', 'V', 'P' eller 'U']:
'A'
Temperatur (°C) [0.0-50.0]:
36.7
Kommentarer om mätningen ['textsträng']:
NULL
Följande rad lades till i databasen. Vänligen kontrollera att den är korrekt.
time              respiratory_rate  oxygen_saturation  supplemental_oxygen  systolic_pressure  heart_rate  consciousness  temperature  comment   
----------------  ----------------  -----------------  -------------------  -----------------  ----------  -------------  -----------  ----------
2022-06-06 17:20  12                100                0                                       61          A              36.7                   
Rekommendation angående ny NEWS-kontroll:
Senast inom 12 timmar
Se filen news_report.html för en grafisk presentation av mätvärdena i databasen.
```

### 3. Data Analysis

Data can be shown either using SQLite and standard SQL queries or using the included script `render_news_report.R` which in turn renders the R Markdown file `news_report.Rmd` to generate an HTML file called `news_report.html` that provides a summary of the latest observation and plots the parameters over time. The R Markdown file also performs linear regression to look at the relationship between body temperature and heart rate.

#### SQLite

The SQLite database includes a table of parameters observed and a view, that calculates NEWS points when queried.

```bash
(base) user@computer directory % sqlite3 database_name.db 
SQLite version 3.32.3 2020-06-18 14:16:19
Enter ".help" for usage hints.
sqlite> .headers on
sqlite> .mode columns
sqlite> 
```

```bash
sqlite> SELECT * FROM news_parameters;
time              respiratory_rate  oxygen_saturation  supplemental_oxygen  systolic_pressure  heart_rate  consciousness  temperature  comment                                     
----------------  ----------------  -----------------  -------------------  -----------------  ----------  -------------  -----------  --------------------------------------------
2022-06-02 11:00  17                96                 0                                       78          A              38.3                                                     
2022-06-02 12:00  17                97                 0                                       84          A              38.2                                                     
2022-06-02 13:00  14                98                 0                                       96          A              38.3                                                     
2022-06-02 14:00  17                98                 0                                       73          A              37.5                                                     
2022-06-02 15:00  15                99                 0                                       71          A              37.3                                                     
2022-06-03 08:38  16                98                 0                                       72          A              36.9                                                     
2022-06-03 23:05  14                97                 0                                       58          A              36.6         T. Ibuprofen 400 mg 1 st P.O. taget 15.25.
2022-06-06 10:09  14                98                 0                                       67          A              36.9                                                     
2022-06-06 16:58  14                99                 0                                       62          A              36.6                                                                                                     
sqlite> 
```

```bash
sqlite> SELECT * FROM news_points;
time              points_respiratory_rate  points_oxygen_saturation  points_supplemental_oxygen  points_systolic_pressure  points_heart_rate  points_consciousness  points_temperature  total_points  clinical_risk  next_measurement      
----------------  -----------------------  ------------------------  --------------------------  ------------------------  -----------------  --------------------  ------------------  ------------  -------------  ----------------------
2022-06-02 11:00  0                        0                         0                                                     0                  0                     1                   1             Låg            Senast inom 4-6 timmar
2022-06-02 12:00  0                        0                         0                                                     0                  0                     1                   1             Låg            Senast inom 4-6 timmar
2022-06-02 13:00  0                        0                         0                                                     1                  0                     1                   2             Låg            Senast inom 4-6 timmar
2022-06-02 14:00  0                        0                         0                                                     0                  0                     0                   0             Låg            Senast inom 12 timmar 
2022-06-02 15:00  0                        0                         0                                                     0                  0                     0                   0             Låg            Senast inom 12 timmar 
2022-06-03 08:38  0                        0                         0                                                     0                  0                     0                   0             Låg            Senast inom 12 timmar 
2022-06-03 23:05  0                        0                         0                                                     0                  0                     0                   0             Låg            Senast inom 12 timmar 
2022-06-06 10:09  0                        0                         0                                                     0                  0                     0                   0             Låg            Senast inom 12 timmar 
2022-06-06 16:58  0                        0                         0                                                     0                  0                     0                   0             Låg            Senast inom 12 timmar 
sqlite> 
```

#### `render_news_report.R`

The `render_news_report.R` script takes the database file’s name as a parameter. Once the script has run, open the `news_report.html` file. (If the `add_news_entry.sh` script has been used to enter data a `news_report.html` file should already exist in the same directory.)

```bash
(base) user@computer directory % Rscript render_news_report.R database_name.db
```

The file `news_report_example.html` is included to show what a `news_report.html` file might look like after a few data points have been added. Note that no blood pressure readings have been included in the example file.

## Dependencies

- [GNU bash](https://www.gnu.org/software/bash/) version 3.2.57.
- [SQLite](https://www.sqlite.org/index.html) version 3.32.3.
- [R](https://www.r-project.org) version 4.1.3 (One Push-Up).
  - [DBI](https://dbi.r-dbi.org) version 1.1.2.
  - [dplyr](https://dplyr.tidyverse.org) version 1.0.8.
  - [ggplot2](https://ggplot2.tidyverse.org) version 3.3.5.
  - [tidyr](https://tidyr.tidyverse.org) version 1.2.0.
  - [rmarkdown](https://rmarkdown.rstudio.com) version 2.13.
  - [RSQLite](https://rsqlite.r-dbi.org) version 2.2.14.
