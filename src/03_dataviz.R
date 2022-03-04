# Conte I Social Network Analysis------------------------------------------------

# Edges preparations
conteI_edges <- conteI %>% 
  select(!c(num, date)) %>%
  relocate(joint_signatory)
  
# Computating igraph network from edges df:
conteI_network <- graph_from_data_frame(conteI_edges, directed = T, vertices = conteI_deputies)

# Coding the colors for each political party:
#unique(V(conteI_network)$party)
V(conteI_network)$color <- NA
V(conteI_network)$color <- ifelse(V(conteI_network)$party == "FRATELLI D'ITALIA", "#003366","orange")
V(conteI_network)$color <- ifelse(V(conteI_network)$party == "MOVIMENTO 5 STELLE", "yellow", V(conteI_network)$color)
V(conteI_network)$color <- ifelse(V(conteI_network)$party == "LEGA - SALVINI PREMIER", "forestgreen", V(conteI_network)$color)
V(conteI_network)$color <- ifelse(V(conteI_network)$party == "FORZA ITALIA - BERLUSCONI PRESIDENTE", "lightblue", V(conteI_network)$color)
V(conteI_network)$color <- ifelse(V(conteI_network)$party == "PARTITO DEMOCRATICO", "red", V(conteI_network)$color)
V(conteI_network)$color <- ifelse(V(conteI_network)$party == "LIBERI E UGUALI", "orange", V(conteI_network)$color)
V(conteI_network)$color <- ifelse(V(conteI_network)$party == "MISTO", "#DDDDDD", V(conteI_network)$color)
V(conteI_network)$color <- ifelse(V(conteI_network)$party == "SWITCHER/DECAYED", NA, V(conteI_network)$color)


# Fruchterman-Reingold layout computation:
l <- layout_with_fr(conteI_network, niter = 2000)

# Plot network and .png export:
png(filename = here("fig/conteI.png"), width = 1980, height = 1080)

plot(
  
  ## Network main arguments
  conteI_network, 
  main = "Conte I",
  frame = F,
  layout = l,
  
  ## Vertexes aes:
  vertex.size = 7, 
  vertex.label = NA,
  vertex.label.cex = .7,
  vertex.color = adjustcolor(V(conteI_network)$color, alpha.f = 0.9),
  
  ## Edges aes: 
  edge.arrow.size = .05,
  edge.width = .3,
  edge.curved=0.3)
dev.off()

#removing edges df
rm(conteI_edges)

# Conte II Social Network Analysis ------------------------------------------------


# Edges preparations
conteII_edges <- conteII %>% 
  select(!c(num, date)) %>% 
  relocate(joint_signatory)

# Computating igraph network from edges df:
conteII_network <- graph_from_data_frame(conteII_edges, directed = T, vertices = conteII_deputies)

# Coding the colors for each political party:
#unique(V(conteI_network)$party)
V(conteII_network)$color <- NA
V(conteII_network)$color <- ifelse(V(conteII_network)$party == "FRATELLI D'ITALIA", "#003366", NA)
V(conteII_network)$color <- ifelse(V(conteII_network)$party == "MOVIMENTO 5 STELLE", "yellow", V(conteII_network)$color)
V(conteII_network)$color <- ifelse(V(conteII_network)$party == "LEGA - SALVINI PREMIER", "forestgreen", V(conteII_network)$color)
V(conteII_network)$color <- ifelse(V(conteII_network)$party == "FORZA ITALIA - BERLUSCONI PRESIDENTE", "lightblue", V(conteII_network)$color)
V(conteII_network)$color <- ifelse(V(conteII_network)$party == "PARTITO DEMOCRATICO", "red", V(conteII_network)$color)
V(conteII_network)$color <- ifelse(V(conteII_network)$party == "LIBERI E UGUALI", "orange", V(conteII_network)$color)
V(conteII_network)$color <- ifelse(V(conteII_network)$party == "MISTO", "#DDDDDD", V(conteII_network)$color)
V(conteII_network)$color <- ifelse(V(conteII_network)$party == "SWITCHER/DECAYED", NA, V(conteII_network)$color)
V(conteII_network)$color <- ifelse(V(conteII_network)$party == "ITALIA VIVA", "#C83282", V(conteII_network)$color)

# Fruchterman-Reingold layout computation:
l <- layout_with_fr(conteII_network, niter = 2000)

# plot network and .png export:
png(filename = here("fig/ConteII.png"), width = 1980, height = 1080)

plot(
  
  ## Network main arguments
  conteII_network, 
  main = "Conte II",
  frame = F,
  layout = l,
  
  ## Vertexes aes:
  vertex.size = 7, 
  vertex.label = NA,
  vertex.label.cex = .7,
  vertex.color = adjustcolor(V(conteII_network)$color, alpha.f = 0.9),
  
  ## Edges aes: 
  edge.arrow.size = .05,
  edge.width = .3,
  edge.curved=0.3)
dev.off()

#removing edges df
rm(conteII_edges)

