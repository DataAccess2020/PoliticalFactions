# Deputies data preparation -----------------------------------------------

# import deputies.csv
deputies <- vroom(here("data/deputies.csv"),
                  #skipping the non used data
                  col_select = c("name", "partito", "s_office", "e_office"))


deputies <- deputies %>%

  # removing office term included in the party name var party is provide as
  # "PartyX (1900-00-01-[...])" we need to remove what's after the first "("
  separate(col = partito,
           into = c("party", "trash"),
           sep = "\\(") %>%
  mutate(
    # arty column has space after the party name, then we must trim it!
    party = str_trim(party),

    # parsing offices data into a single interval format
    date = interval(start = ymd(s_office),
                    end = ymd(ifelse(test = is.na(deputies$e_office),
                                     #since the 18th leg is still in office
                                     #some MPs does not have ending date
                                     yes = 20220228,
                                     no = deputies$e_office)))) %>%

  # dropping working variables no more useful
  select(!c(trash, s_office, e_office)) %>%

  # drop deputies which have taken office *AFTER* Conte_ii cabinet
  filter(int_start(date) < ymd("2021-12-02"))
  


# Conte I data preparation ------------------------------------------------

# import contributors.csv and cabine dates:
conte_i <- vroom(here("data/conte_i.csv"),
                # skipping the first non-interesting variable
                col_select = c("num":"joint_signatory"))

# Conte_i cabinet dates
conte_i_date <- interval(ydm("2018-31-05"), ydm("2019-04-09"))



# Due to the construction of dati.camera.it database it is easier preparing data
# within R environment:

conte_i <- conte_i %>%

  # removing duplicate rows
  distinct(.) %>%

  # Parsing dates
  mutate(date = ymd(date))



# Extracting Conte I deputies and contributors
conte_i_deputies <- deputies %>%
  filter(int_start(date) < int_end(conte_i_date)) %>%
  filter(!(int_end(date) < int_start(conte_i_date)))

# Some MPs, who have changed party or decayed during Conte I cabinet
# are coded as SWITCHER/DECAYED
is_duplicate <- conte_i_deputies %>%

  # group by MPs names
  group_by(name) %>%

  # n as how many time a unique name appears
  summarise(n = n()) %>%

  # filter only the names who appear more than one time
  filter(n > 1) %>%

  # coding party as "SWITCHER/DECAYED"
  add_column(party = "SWITCHER/DECAYED") %>%

  #selecting only name an party to match the structure of conte_i_deputies
  select(name, party)



conte_i_deputies <- conte_i_deputies %>%

  # remove switcher from conte_i_deputies with an anti joint fun
  anti_join(is_duplicate, by = "name") %>%

  #drop the date column, no more useful
  select(!(date)) %>%

  #bind the Switcher to conte_i_deputies
  bind_rows(., is_duplicate)
  


#remove orphan nodes
conte_i_deputies <- conte_i_deputies[
  - (which(conte_i_deputies$name %!in% conte_i$signatory &
  conte_i_deputies$name %!in% conte_i$joint_signatory)), ]



# debug to check eventual non represented edges
table(unique(conte_i$signatory) %in% conte_i_deputies$name)
table(unique(conte_i$joint_signatory) %in% conte_i_deputies$name)



# since there is MPs no included in the nodes df we must debug it!
index <- which(!(conte_i$joint_signatory %in% conte_i_deputies$name))
index
debug <- conte_i[index, ]
debug <- unique(debug$joint_signatory)
conte_i_deputies <- rbind(conte_i_deputies,
                         deputies[deputies$name %in% debug, 1:2])

# Conte II data preparation ---------------------------------------------------

# Import contributions during Conte II cabinets
conte_ii <- vroom(here("data/conte_ii.csv"),
                #skipping the non-interesting variable
                 col_select = c("num":"joint_signatory"))

# conte_ii cabinet dates
conte_ii_date <- interval(ydm("2019-04-09"), ydm("2021-12-02"))

# Reproduce the same procedure adopted for conte_ii

conte_ii <- conte_ii %>%

  # removing duplicate rows
  distinct(.) %>%

  # Parsing dates
  mutate(date = ymd(date))

# Extracting Conte II MPs
conte_ii_deputies <-  deputies %>%
  filter(int_start(date) < int_end(conte_ii_date)) %>%
  filter(!(int_end(date) < int_start(conte_ii_date)))

# Dropping Conte II deputies and contributors e dealing with duplicate nodes

is_duplicate <- conte_ii_deputies %>%

  # group by MPs names
  group_by(name) %>%

  # n as how many time a unique name appears
  summarise(n = n()) %>%

  # filter only the names who appear more than one time
  filter(n > 1) %>%

  # coding party as "SWITCHER/DECAYED"
  add_column(party = "SWITCHER/DECAYED") %>%

  #selecting only name an party to match the structure of conte_i_deputies
  select(name, party)


conte_ii_deputies <- conte_ii_deputies %>%

  # remove switcher from conte_i_deputies with an anti joint fun
  anti_join(is_duplicate, by = "name") %>%

  #drop the date column, no more useful
  select(!(date)) %>%

  #bind the Switcher to conte_i_deputies
  bind_rows(., is_duplicate)

#remove orphan nodes, if presents
conte_ii_deputies <- conte_ii_deputies[-(which(conte_ii_deputies$name %!in% conte_ii$signatory & conte_ii_deputies$name %!in% conte_ii$joint_signatory)),]


# As with Conte I contributors we must control for errors and missing values
table(unique(conte_ii$signatory) %in% conte_ii_deputies$name)
table(unique(conte_ii$joint_signatory) %in% conte_ii_deputies$name)

# manual inspection:
index <- which(!(conte_ii$joint_signatory %in% conte_ii_deputies$name))
#index
debug <- conte_ii[index, ]
debug <- unique(debug$joint_signatory)
#' the inspection revealed that the missing MPs
#' are those who took the first term office AFTER the start of Conte II!
#' Since that, we will add them to the nodes df
conte_ii_deputies <- rbind(conte_ii_deputies, deputies[deputies$name %in% debug,1:2])


#'IV pol. group was founded only 10 days after Conte_ii starting date.
#' The script codes IV MPs as switcher.
#' Recognizing the weight of IV MPs we must recode them manually
iv <- deputies %>%
  filter(party == "ITALIA VIVA") %>%
  filter(int_start(date) == ymd("2019-09-19") &
        int_end(date) > int_end(conte_ii_date)) %>%
  select(!(date))

conte_ii_deputies$party <- ifelse(conte_ii_deputies$name %in% iv$name,
                                "ITALIA VIVA",
                                conte_ii_deputies$party)

# Removing tmp/working variables ----------------------------------------------
rm(conte_i_date, conte_ii_date, debug, index, deputies, is_duplicate, iv)
