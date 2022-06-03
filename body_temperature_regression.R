library(dplyr, warn.conflicts = FALSE)
library(DBI)
library(RSQLite)

db <- dbConnect(SQLite(), commandArgs(trailingOnly=TRUE)[1])

db %>%
    dbReadTable('news_parameters') %>%
    tibble() %>%
    select(heart_rate, temperature) ->
    heart_temp_table

heart_temp_table %>%
    pull(temperature) ->
    x

heart_temp_table %>%
    pull(heart_rate) ->
    y

lm_model <- lm(y~x)

a <- lm_model$coefficients[1]
b <- lm_model$coefficients[2]

print('Hjärtfrekvens i slag per minut (y) som en funktion av kroppstemperatur i °C (x):')
print(paste('y(x) = ', round(b, 2) ,'x ', if(sign(a) == -1) '- ' else '+ ', abs(round(a, 2)), sep=''))
