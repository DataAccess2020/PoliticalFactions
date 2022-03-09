# Conte I Social Network Analysis------------------------------------------------

# Edges preparations
conte_i_edges <- conte_i %>%
  select(!c(num, date)) %>%
  relocate(joint_signatory)
  
# Computating igraph network from edges df:
conte_i_network <- graph_from_data_frame(conte_i_edges, directed = T, vertices = conte_i_deputies)

# Coding the colors for each political party:
#unique(V(conte_i_network)$party)
V(conte_i_network)$color <- NA
V(conte_i_network)$color <- ifelse(V(conte_i_network)$party == "FRATELLI D'ITALIA","#003366",
                              ifelse(V(conte_i_network)$party == "MOVIMENTO 5 STELLE", "yellow",
                                ifelse(V(conte_i_network)$party == "LEGA - SALVINI PREMIER", "forestgreen",
                                  ifelse(V(conte_i_network)$party == "FORZA ITALIA - BERLUSCONI PRESIDENTE","lightblue",
                                    ifelse(V(conte_i_network)$party == "PARTITO DEMOCRATICO","red",
                                      ifelse(V(conte_i_network)$party == "LIBERI E UGUALI","orange",
                                        ifelse(V(conte_i_network)$party == "MISTO","#DDDDDD",
                                          ifelse(V(conte_i_network)$party == "SWITCHER/DECAYED", NA, "pink"))))))))


# Fruchterman-Reingold layout computation:
l <- layout_with_fr(conte_i_network, niter = 2000)

# Plot network and .png export:
png(filename = here("fig/conte_i.png"), width = 1980, height = 1080)

plot(
  
  ## Network main arguments
  conte_i_network, 
 # main = "Conte I",
  frame = F,
  layout = l,
  
  ## Vertexes aes:
  vertex.size = 7, 
  vertex.label = NA,
  vertex.label.cex = .7,
  vertex.color = adjustcolor(V(conte_i_network)$color, alpha.f = 0.9),
  
  ## Edges aes: 
  edge.arrow.size = .05,
  edge.width = .3,
  edge.curved=0.3)
dev.off()

#removing edges df
rm(conte_i_edges)

# Conte II Social Network Analysis ------------------------------------------------


# Edges preparations
conte_ii_edges <- conte_ii %>% 
  select(!c(num, date)) %>% 
  relocate(joint_signatory)

# Computating igraph network from edges df:
conte_ii_network <- graph_from_data_frame(conte_ii_edges, directed = T, vertices = conte_ii_deputies)

# Coding the colors for each political party:
#unique(V(conte_i_network)$party)
V(conte_ii_network)$color <- NA
V(conte_ii_network)$color <- ifelse(V(conte_ii_network)$party == "FRATELLI D'ITALIA","#003366",
                                ifelse(V(conte_ii_network)$party == "MOVIMENTO 5 STELLE","yellow",
                                  ifelse(V(conte_ii_network)$party == "LEGA - SALVINI PREMIER","forestgreen",
                                    ifelse(V(conte_ii_network)$party == "FORZA ITALIA - BERLUSCONI PRESIDENTE","lightblue",
                                      ifelse(V(conte_ii_network)$party == "PARTITO DEMOCRATICO","red",
                                        ifelse(V(conte_ii_network)$party == "LIBERI E UGUALI","orange",
                                          ifelse(V(conte_ii_network)$party == "MISTO","#DDDDDD",
                                            ifelse(V(conte_ii_network)$party == "ITALIA VIVA","#C83282",
                                              ifelse(V(conte_ii_network)$party == "SWITCHER/DECAYED",NA, "pink"))))))))) 


# Fruchterman-Reingold layout computation:
l <- layout_with_fr(conte_ii_network, niter = 2000)

# plot network and .png export:
png(filename = here("fig/Conte_ii.png"), width = 1980, height = 1080)

plot(
  
  ## Network main arguments
  conte_ii_network, 
  frame = F,
  layout = l,
  
  ## Vertexes aes:
  vertex.size = 7, 
  vertex.label = NA,
  vertex.label.cex = .7,
  vertex.color = adjustcolor(V(conte_ii_network)$color, alpha.f = 0.9),
  
  ## Edges aes: 
  edge.arrow.size = .05,
  edge.width = .3,
  edge.curved=0.3)
dev.off()

#removing edges df
rm(conte_ii_edges)

