

# Deputies data preparation -----------------------------------------------

# import deputies.csv, skipping the firs column which contains unused data
deputies <- vroom(here('data/deputies.csv'),
      col_select = c('nome','cognome','partito'))

# merge name and surname
deputies <- deputies %>% 
  unite(name, nome, cognome, sep = " ") %>% 
  separate(col = partito,
           into = c('party','date'),
           sep = '\\(')

deputies <- deputies %>% 
  mutate(date= gsub(")", "", date))

deputies <- deputies %>% 
  separate(col= date,
           into = c('s_date','e_date'),
           sep= '-') %>% 
  mutate(e_date = ifelse(is.na(e_date), "26.02.2022", e_date))
   

# parsing party dates
deputies <- deputies %>% 
  mutate(s_date = dmy(deputies$s_date),
         e_date = dmy(deputies$e_date))

# mutate to interval date format
deputies <- deputies %>% 
  mutate(date = s_date %--% e_date)

# creating unique keys for party
deputies <- deputies %>% 
  group_by(party) %>% 
  mutate(party_id = cur_group_id())

# creating unique keys for deputies
deputies <- deputies %>% 
  group_by(name) %>% 
  mutate(mp_id = cur_group_id())

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





