# Deputies data preparation -----------------------------------------------

# import deputies.csv, skipping the first non-interesting variable
deputies <- vroom(here('data/deputies.csv'),
      col_select = c('name','partito',"s_office","e_office"))

deputies <- deputies %>% 
  separate(col= partito,
           into = c('party','trash'),
           sep= '\\(') %>% 
  select(!(trash))
deputies$party <- str_trim(deputies$party) 


# parsing party dates
deputies$e_office <- ifelse(test = is.na(deputies$e_office), yes = 20220228, no = deputies$e_office)

deputies <- deputies %>% 
  mutate(s_office = ymd(s_office),
         e_office = ymd(e_office))


# mutate to interval date format
deputies <- deputies %>% 
  mutate(date = interval(start = s_office, end = e_office)) %>% 
  select(!c(s_office, e_office))

# Conte I data preparation ------------------------------------------------

# import contributors.csv, skipping the first non-interesting variable
conteI <- vroom(here("data/conteI.csv"),
                      col_select = c('num':'joint_signatory'))

# Conte I date interval
conteI_date <- interval(ydm("2018-31-05"), ydm("2019-04-09"))

# Parsing date
conteI$date <- ymd(conteI$date)


# Conte I deputies and contributors

conteI_deputies <-  subset(deputies, int_start(deputies$date) < int_end(conteI_date))
conteI_deputies <- unique(conteI_deputies)
conteI_deputies <- conteI_deputies %>% 
  select(!(date))
 #since all deputies have one entry no further preparations are required




