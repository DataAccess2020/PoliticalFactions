# Deputies data preparation -----------------------------------------------

# import deputies.csv, skipping the firs column which contains unused data
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

# import contributors.csv, skipping the firs column which contains 
conteI <- vroom(here("data/conteI.csv"),
                      col_select = c('num':'joint_signatory'))

# Conte I date interval
conteI_date <- interval(ydm("2018-31-05"), ydm("2019-04-09"))

# Parsing date
conteI$date <- ymd(conteI$date)


# deputies decayed or switcher
decayed <- subset(deputies, int_end(deputies$date) < int_end(conteI_date))

decayed <- left_join(
  decayed,
  deputies,
  by = c("name" = "name"),
  suffix = c("_fist", "_second")
)
decayed <- decayed %>% 
  group_by(name) %>% 
  summarize(n = n()) %>% 
  mutate(party = ifelse(n > 1, "SWITCHER", "DECAYED")) %>% 
  select(!(n))

# Conte I deputies contributors


#deputies_conteI

conteI_dep <- unique(conteI$signatory)
conteI_dep <- append(conteI_dep, unique(conteI$joint_signatory))
conteI_dep <- tibble(name = unique(conteI_dep))
