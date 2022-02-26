
# Deputies data preparation -----------------------------------------------


# import deputies.csv, skipping the firs column which contains unused data
deputies <- vroom(here('data/deputies.csv'),
      col_select = c('nome','cognome','partito'))

# Contributors data preparation ------------------------------------------------

# import contributors.csv, skipping the firs column which contains unused data
contributors <- vroom(here("data/contributors.csv"),
                      col_select = c('num':'altro_cognome'))

# parsing the date column
contributors$date <- ymd(contributors$date)

subset(contributors, contributors$date >= "2018-06-01" & contributors$date < "2019-09-05")



# Conte I in carica dal 1º giugno 2018 al 5 settembre 2019, 
# per un totale di 461 giorni, ovvero 1 anno, 3 mesi e 4 giorni. 
# Dimissioni 20 agosto 2019.
conteI <- subset(contributors, contributors$date >= "2018-06-01" & contributors$date < "2019-09-05")





