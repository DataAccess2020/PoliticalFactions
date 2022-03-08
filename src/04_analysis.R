
# IOBD Conte I ------------------------------------------------------------------

# computing csp value with cosponsor function defined in 99_functions
csp_i <-  cosponsor(contributions = conte_i,
                  deputies = conte_i_deputies)

csp_2 <-  cosponsor(contributions = conte_ii,
                    deputies = conte_ii_deputies) 

csp <- csp_i %>% 
  full_join(csp_2, 
            by = c("party_main" = "party_main"),
            suffix = c("_i", "_ii")) %>%
  rename(conteI = csp_avg_i,
         conteII = csp_avg_ii,
         party = party_main) %>% 
  mutate(across(2:3, round, 3))
  
csp %>%
  kbl(caption = "csp value") %>%
  kable_classic_2("hover", full_width = F) %>% 
  save_kable(file = here("fig/csp.html"))
# IODB Conte II  ----------------------------------------------------------


