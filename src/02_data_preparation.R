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

# drop deputies which have taken the office AFTER the Conte II end

deputies <- deputies %>% 
  filter(int_start(date) < ymd("2021-12-02"))

# Conte I data preparation ------------------------------------------------

# import contributors.csv, skipping the first non-interesting variable

conteI <- vroom(here("data/conteI.csv"),
                      col_select = c('num':'joint_signatory'))

# Due to the construction of the semantic dataframe it is more easy removing non unique obs with R

conteI <- unique(conteI)

# Conte I date interval

conteI_date <- interval(ydm("2018-31-05"), ydm("2019-04-09"))

# Parsing date

conteI$date <- ymd(conteI$date)

# Extracting Conte I deputies and contributors e dealing with duplicate nodes

conteI_deputies <- deputies %>% 
  filter(int_start(date) < int_end(conteI_date)) %>% 
  filter(!(int_end(date) < int_start(conteI_date)))

duplicate <- conteI_deputies %>% 
  group_by(name) %>% 
  summarise(n = n()) %>% 
  filter(n >1) %>% 
  add_column(party = "SWITCHER/DECAYED") %>% 
  select(name, party)
conteI_deputies <- conteI_deputies %>% 
  anti_join(duplicate, by = "name") %>% 
  select(!(date))
conteI_deputies <- rbind(conteI_deputies, duplicate)

#remove orphan nodes 
conteI_deputies <- conteI_deputies[-(which(conteI_deputies$name %!in% conteI$signatory & conteI_deputies$name %!in% conteI$joint_signatory)),]

# debug deputies list

table(unique(conteI$signatory) %in% conteI_deputies$name)
table(unique(conteI$joint_signatory) %in% conteI_deputies$name)

# since there one of the deputies is no included on the nodes df we must debug manually!

index <- which(!(conteI$joint_signatory %in% conteI_deputies$name))
index
debug <- conteI[index,]
debug <- unique(debug$joint_signatory)
conteI_deputies <- rbind(conteI_deputies, deputies[deputies$name %in% debug,1:2])

# Conte II data preparation --------------------------------------------------

# import contributors.csv, skipping the first non-interesting variable
conteII <- vroom(here("data/conteII.csv"),
                 col_select = c('num':'joint_signatory'))

conteII <- unique(conteII)

# Conte II date interval
conteII_date <- interval(ydm("2019-04-09"), ydm("2021-12-02"))

# Parsing date
conteII$date <- ymd(conteII$date)

# Extracting Conte II deputies and contributors
conteII_deputies <-  deputies %>% 
  filter(int_start(date) < int_end(conteII_date)) %>% 
  filter(!(int_end(date) < int_start(conteII_date)))

# Extracting Conte II deputies and contributors e dealing with duplicate nodes
duplicate <- conteII_deputies %>% 
  group_by(name) %>% 
  summarise(n = n()) %>% 
  filter(n >1) %>% 
  add_column(party = "SWITCHER/DECAYED") %>% 
  select(name, party)
conteII_deputies <- conteII_deputies %>% 
  anti_join(duplicate, by = "name") %>% 
  select(!(date))
conteII_deputies <- rbind(conteII_deputies, duplicate)

#remove orphan nodes 
conteII_deputies <- conteII_deputies[-(which(conteII_deputies$name %!in% conteII$signatory & conteII_deputies$name %!in% conteII$joint_signatory)),]


# As with Conte I contributors we must control for errors and missing values
table(unique(conteII$signatory) %in% conteII_deputies$name)
table(unique(conteII$joint_signatory) %in% conteII_deputies$name)

# manual inspection:
index <- which(!(conteII$joint_signatory %in% conteII_deputies$name))
index
debug <- conteII[index,]
debug <- unique(debug$joint_signatory)
# the inspection revealed that the missing MPs are those who took the first term 
# office AFTER the start of Conte II! Since that, we will add them to the nodes df
conteII_deputies <- rbind(conteII_deputies, deputies[deputies$name %in% debug,1:2])


# Removing tmp variables --------------------------------------------------

rm(conteI_date, conteII_date, debug, index, deputies, duplicate)

