# Deputies data preparation -----------------------------------------------

# import deputies.csv
deputies <- vroom(here("data/deputies.csv"),
                  #skipping the non used data
                  col_select = c("name", "partito", "s_office", "e_office"))


deputies <- deputies_prep(deputies)


# Conte I data preparation ------------------------------------------------

# import contributors.csv and cabine dates:
conte_i <- vroom(here("data/conte_i.csv"),
                # skipping the first non-interesting variable
                col_select = c("num":"joint_signatory"))

# Conte_i cabinet dates
conte_i_date <- interval(ydm("2018-31-05"), ydm("2019-04-09"))

cabinet_prep(cabinet = conte_i, cabinet_int = conte_i_date, deputies = deputies)



# Conte II data preparation ---------------------------------------------------

# Import contributions during Conte II cabinets
conte_ii <- vroom(here("data/conte_ii.csv"),
                #skipping the non-interesting variable
                 col_select = c("num":"joint_signatory"))

# conte_ii cabinet dates
conte_ii_date <- interval(ydm("2019-04-09"), ydm("2021-12-02"))

cabinet_prep(cabinet = conte_ii, cabinet_int = conte_ii_date, deputies = deputies)


#' Since IV pol. group was founded only 10 days after Conte_ii starting date.
#' The function codes IV MPs as switcher.
#' Recognizing the weight of IV MPs we must recode them manually
iv <- deputies %>%
  filter(party == "ITALIA VIVA") %>%
  filter(int_start(date) == ymd("2019-09-19") &
        int_end(date) > int_end(conte_ii_date)) %>%
  select(!(date))

conte_ii_deputies$party <- ifelse(conte_ii_deputies$name %in% iv$name,
                                "ITALIA VIVA",
                                conte_ii_deputies$party)


