
# Co-sponsors of Same Party MEAN ------------------------------------------


cosponsor <- function(contributions, 
                      deputies, signatory = "signatory", 
                      joint_signatory = "joint_signatory",
                      mp_name = "name" ) {
 csp <- contributions %>% 
    left_join(deputies,
            by = c(signatory = mp_name )) %>% 
    left_join(deputies,
              by = c(joint_signatory = mp_name),
              suffix = c("_main","_joint")) %>% 
    group_by(num, party_main) %>% 
    summarise(n= n(),
              n_joint = sum(party_joint == party_main)) %>% 
    mutate(csp = (n_joint/n)) %>% 
    group_by(party_main) %>% 
    summarise(csp_avg = mean(csp))
 
 return(csp)
}


# Contributions preparation -----------------------------------------------


prep_cabinet <- function(cabinet, cabinet_int, deputies) {
  `%!in%` <- Negate(`%in%`) # "not in" function declaration
  
  #define cabinet name
  name <- as.character(substitute(cabinet))  
 

   # Due to the construction of dati.camera.it database it is easier preparing data
   # within R environment:
   cabinet <- cabinet %>%
     
     # removing duplicate rows
     distinct(.) %>%
     
     # Parsing dates
     mutate(date = ymd(date))
   
   # Extracting deputies and contributors
   cabinet_deputies <- deputies %>%
     filter(int_start(date) < int_end(cabinet_int)) %>%
     filter(!(int_end(date) < int_start(cabinet_int)))
   
   # Since some MPs, may have changed party or decayed in between
   # they must be coded as SWITCHER/DECAYED
   is_duplicate <- cabinet_deputies %>%
     
     # group by MPs names
     group_by(name) %>%
     
     # n as how many time a unique name appears
     summarise(n = n()) %>%
     
     # filter only the names who appear more than one time
     filter(n > 1) %>%
     
     # coding party as "SWITCHER/DECAYED"
     add_column(party = "SWITCHER/DECAYED") %>%
     
     #selecting only name an party to match the structure of cabinet_deputies
     select(name, party)
   
   
   cabinet_deputies <- cabinet_deputies %>%
     
     # remove switcher from cabinet_deputies with an anti joint fun
     anti_join(is_duplicate, by = "name") %>%
     
     #drop the date column, no more useful
     select(!(date)) %>%
     
     #bind the Switcher to cabinet_deputies
     bind_rows(., is_duplicate)
     
   #remove eventual orphan nodes
   cabinet_deputies <-  cabinet_deputies %>% 
      filter(!(name %!in% c(cabinet$signatory,cabinet$joint_signatory)))
   
   # since there is MPs no included in the nodes df we must debug it!
   debug <- cabinet[which(!(cabinet$joint_signatory %in% cabinet_deputies$name)), ]
   debug <- unique(debug$joint_signatory)
   cabinet_deputies <- rbind(cabinet_deputies,
                             deputies[deputies$name %in% debug, 1:2])
   
   #assign the contributions DFs
   assign(name, 
          cabinet,
          envir = parent.frame())
   
   #assign the deputies DFs
   assign(stringr::str_c(name, "_deputies"),
          cabinet_deputies,
          envir = parent.frame())
   }


# Deputies preparation --------------------------------------------------

prep_deputies <- function(deputies, end_date = "2021-12-02") {
  
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
    filter(int_start(date) < lubridate::ymd(end_date))

  #reuturn value
  return(deputies)
}

