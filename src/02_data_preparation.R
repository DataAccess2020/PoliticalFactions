# Deputies data preparation -----------------------------------------------

# import deputies.csv
deputies <- vroom(here("data/deputies.csv"),
                  #skipping the non used data
                  col_select = c("name", "partito", "s_office", "e_office"))



deputies <- deputies %>%
  
  # removing office term included in the party name var
  # party is provide as "PartyX (1900-00-01-[...])" 
  # we need to remove what's after the first "("
  separate(col= partito,
           into = c("party","trash"),
           sep= "\\(") %>%
  mutate(
    # arty column has space after the party name, then we must trim it!
    party = str_trim(party),
    
    # parsing offices data into a single interval format
    date = interval(start = ymd(s_office),
                    end = ymd(ifelse(test = is.na(deputies$e_office),
                                     #since the 18th leg is still in office some MPs does not have ending date
                                     yes = 20220228,
                                     no = deputies$e_office)))) %>%
  
  # dropping working variables no more useful
  select(!c(trash, s_office, e_office)) %>% 

  # drop deputies which have taken office *AFTER* ConteII cabinet
  filter(int_start(date) < ymd("2021-12-02"))
  


# Conte I data preparation ------------------------------------------------


# import contributors.csv:
conteI <- vroom(here("data/conteI.csv"),
                # skipping the first non-interesting variable
                col_select = c("num":"joint_signatory"))

# ConteI cabinet dates
conteI_date <- interval(ydm("2018-31-05"), ydm("2019-04-09"))

# Due to the construction of dati.camera.it database it is easier preparing data
# within R environment:

conteI <- conteI %>% 
  
  # removing duplicate rows
  distinct(.) %>% 
  
  # Parsing dates
  mutate(date = ymd(date))



# Extracting Conte I deputies and contributors
conteI_deputies <- deputies %>%
  filter(int_start(date) < int_end(conteI_date)) %>%
  filter(!(int_end(date) < int_start(conteI_date)))

# Some MPs, who have changed party or decayed during Conte I cabinet
# are coded as SWITCHER/DECAYED
duplicate <- conteI_deputies %>%
  
  # group by MPs names
  group_by(name) %>%
  
  # n as how many time a unique name appears
  summarise(n = n()) %>%
  
  # filter only the names who appear more than one time
  filter(n >1) %>%
  
  # coding party as "SWITCHER/DECAYED"
  add_column(party = "SWITCHER/DECAYED") %>%
  
  #selecting only name an party to match the structure of conteI_deputies
  select(name, party)



conteI_deputies <- conteI_deputies %>%
  
  # remove switcher from conteI_deputies with an anti joint fun
  anti_join(duplicate, by = "name") %>%
  
  #drop the date column, no more useful
  select(!(date)) %>% 
  
  #bind the Switcher to conteI_deputies
  bind_rows(., duplicate)
  


#remove orphan nodes
conteI_deputies <- conteI_deputies[
  - (which(conteI_deputies$name %!in% conteI$signatory &
  conteI_deputies$name %!in% conteI$joint_signatory)), ]



# debug to check eventual non represented edges
table(unique(conteI$signatory) %in% conteI_deputies$name)
table(unique(conteI$joint_signatory) %in% conteI_deputies$name)



# since there is MPs no included in the nodes df we must debug it!
index <- which(!(conteI$joint_signatory %in% conteI_deputies$name))
index
debug <- conteI[index, ]
debug <- unique(debug$joint_signatory)
conteI_deputies <- rbind(conteI_deputies, 
                         deputies[deputies$name %in% debug,1:2])

# Conte II data preparation ---------------------------------------------------

# Import contributions during Conte II cabinets
conteII <- vroom(here("data/conteII.csv"),
                #skipping the non-interesting variable
                 col_select = c("num":"joint_signatory"))

# removing ducplicate edges
conteII <- unique(conteII)

# Conte II cabinet interval
conteII_date <- interval(ydm("2019-04-09"), ydm("2021-12-02"))

# Parsing interval dates
conteII$date <- ymd(conteII$date)

# Extracting Conte II MPs
conteII_deputies <-  deputies %>%
  filter(int_start(date) < int_end(conteII_date)) %>%
  filter(!(int_end(date) < int_start(conteII_date)))

# Dropping Conte II deputies and contributors e dealing with duplicate nodes
duplicate <- conteII_deputies %>%
  group_by(name) %>%
  summarise(n = n()) %>%
  filter(n >1) %>%
  add_column(party = "SWITCHER/DECAYED") %>%
  select(name, party)
  #again: after selecting non unique MPs we remove them with
  # an anti joint from the deputies df
conteII_deputies <- conteII_deputies %>%
  anti_join(duplicate, by = "name") %>%
  select(!(date))
conteII_deputies <- rbind(conteII_deputies, duplicate)

#remove orphan nodes, if presents
conteII_deputies <- conteII_deputies[-(which(conteII_deputies$name %!in% conteII$signatory & conteII_deputies$name %!in% conteII$joint_signatory)),]


# As with Conte I contributors we must control for errors and missing values
table(unique(conteII$signatory) %in% conteII_deputies$name)
table(unique(conteII$joint_signatory) %in% conteII_deputies$name)

# manual inspection:
index <- which(!(conteII$joint_signatory %in% conteII_deputies$name))
#index
debug <- conteII[index, ]
debug <- unique(debug$joint_signatory)
# the inspection revealed that the missing MPs
# are those who took the first term office AFTER the start of Conte II!
# Since that, we will add them to the nodes df
conteII_deputies <- rbind(conteII_deputies, deputies[deputies$name %in% debug,1:2])

# IV pol. group was founded only 10 days after ConteII starting date. The script
# codes IV MPs as switcher. Recognizing the weight of IV MPs we must recode them manually
iv <- deputies %>%
  filter(party == "ITALIA VIVA") %>%
  filter(int_start(date) == ymd("2019-09-19") &
        int_end(date) > int_end(conteII_date)) %>%
  select(!(date))

conteII_deputies$party <- ifelse(conteII_deputies$name %in% iv$name,
                                "ITALIA VIVA", 
                                conteII_deputies$party)

# Removing tmp/working variables --------------------------------------------------
rm(conteI_date, conteII_date, debug, index, deputies, duplicate, iv)