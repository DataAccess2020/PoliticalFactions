
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

intraparty <- function(variables) {
  
}

