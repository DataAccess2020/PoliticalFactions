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


# Parsing date
conteI$date <- ymd(conteI$date)

  
# first left join into first signatory keys
# if the mp have changed party subset if date_law not included within the political mandate
contributors <- subset(deputies, !(deputies$date < "2019-09-05"))

# second left join into joint signatory
contributors <- subset(deputies, int_end(deputies$date) < "2019-09-05")
contributors <- left_join(
  contributors,
  deputies,
  by = c("joint_signatory" = "name"),
  suffix = c("_first", "_joint")
)

# if the mp have changed party subset if date_law not included within the political mandate of joint signatory
contributors <- subset(contributors, (contributors$date_law %within% contributors$date) == TRUE)

# filter unsued columns
contributors <- contributors %>% 
  select(!c(date_mp, date))
