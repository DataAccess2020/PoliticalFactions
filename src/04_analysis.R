
# IOBD Conte I ------------------------------------------------------------------

# computing csp value with cosponsor function defined in 99_functions
#conte_i_csp <-  cosponsor(contributions = conte_i,
#                  deputies = conte_i_deputies)

# computing ips value with cosponsor function defined in 99_functions
#conte_i_isp<-  intraparty(contributions = conte_i,
#                          deputies = conte_i_deputies)

# Using the function to compute the IOBD index for the selected period"

conte_i_iobd <- iobd_index(contributions = conte_i,
                           deputies = conte_i_deputies)                   


# IODB Conte II  ----------------------------------------------------------

# computing csp value with cosponsor function defined in 99_functions
#csp_conte_ii <-  cosponsor(contributions = conte_ii,
#                    deputies = conte_ii_deputies) 

# computing ips value with cosponsor function defined in 99_functions
#ips_conte_ii <-  intraparty(contributions = conte_ii,
#     

# Using the function to compute the IOBD index for the selected period"

conte_ii_iobd <- iobd_index(contributions = conte_ii,
                           deputies = conte_ii_deputies)                   
