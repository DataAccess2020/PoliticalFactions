# Conte I Social Network Analysis------------------------------------------------

# Conte I in carica dal 1º giugno 2018 al 5 settembre 2019, 
# per un totale di 461 giorni, ovvero 1 anno, 3 mesi e 4 giorni. 
# Dimissioni 20 agosto 2019.

#Selecting edges variables

conteI <- conteI %>% 
  select(!c(num, date))

# network governo 
conteI_network <- graph_from_data_frame(conteI, directed = T, vertices = conteI_deputies)

#unique(V(conteI_network)$party)

# codifica colori partito
V(conteI_network)$color <- NA
V(conteI_network)$color <- ifelse(V(conteI_network)$party == "FRATELLI D'ITALIA", "#003366","orange")
V(conteI_network)$color <- ifelse(V(conteI_network)$party == "MOVIMENTO 5 STELLE", "yellow", V(conteI_network)$color)
V(conteI_network)$color <- ifelse(V(conteI_network)$party == "LEGA - SALVINI PREMIER", "forestgreen", V(conteI_network)$color)
V(conteI_network)$color <- ifelse(V(conteI_network)$party == "FORZA ITALIA - BERLUSCONI PRESIDENTE", "lightblue", V(conteI_network)$color)
V(conteI_network)$color <- ifelse(V(conteI_network)$party == "PARTITO DEMOCRATICO", "red", V(conteI_network)$color)
V(conteI_network)$color <- ifelse(V(conteI_network)$party == "LIBERI E UGUALI", "#EA3323", V(conteI_network)$color)
V(conteI_network)$color <- ifelse(V(conteI_network)$party == "MISTO", "#DDDDDD", V(conteI_network)$color)
V(conteI_network)$color <- ifelse(V(conteI_network)$party == "SWITCHER/DECAYED", NA, V(conteI_network)$color)

color <- unique(V(conteI_network)$party)
party_color <-  c("lightblue", "#003366", "red", "yellow", NA, "forestgreen", "peachpuff4", "magenta")

hub_sc <- hub_score(conteI_network, weights=NA)$vector
aut_sc <- authority_score(conteI_network, weights=NA)$vector
community <- cluster_edge_betweenness(conteI_network)

l <- layout_with_fr(conteI_network)
# plot network
png(filename = here("fig/conteI.png"), width = 1980, height = 1080)
plot(
     conteI_network, 
     main = "Conte I",
     vertex.size = 7, 
     vertex.label = NA,
     vertex.label.cex = .7,
     edge.arrow.size = .1,
     edge.width = .7,
     frame = F,
     layout = l)
dev.off()

#plot(0,type='n',axes=FALSE,ann=FALSE)
#legend("bottom", legend=color, bty = "n", cex = 0.75, 
#       pt.cex = 3, pch=20, col = party_color ,
#       horiz = FALSE,ncol = 1)


# Conte II Social Network Analysis ------------------------------------------------


#Selecting edges variables

conteII <- conteII %>% 
  select(!c(num, date))

# network governo 
conteII_network <- graph_from_data_frame(conteII, directed = T, vertices = conteII_deputies)

#unique(V(conteI_network)$party)

# codifica colori partito
V(conteII_network)$color <- NA
V(conteII_network)$color <- ifelse(V(conteII_network)$party == "FRATELLI D'ITALIA", "#003366", NA)
V(conteII_network)$color <- ifelse(V(conteII_network)$party == "MOVIMENTO 5 STELLE", "yellow", V(conteII_network)$color)
V(conteII_network)$color <- ifelse(V(conteII_network)$party == "LEGA - SALVINI PREMIER", "forestgreen", V(conteII_network)$color)
V(conteII_network)$color <- ifelse(V(conteII_network)$party == "FORZA ITALIA - BERLUSCONI PRESIDENTE", "lightblue", V(conteII_network)$color)
V(conteII_network)$color <- ifelse(V(conteII_network)$party == "PARTITO DEMOCRATICO", "red", V(conteII_network)$color)
V(conteII_network)$color <- ifelse(V(conteII_network)$party == "LIBERI E UGUALI", "#EA3323", V(conteII_network)$color)
V(conteII_network)$color <- ifelse(V(conteII_network)$party == "MISTO", "#DDDDDD", V(conteII_network)$color)
V(conteII_network)$color <- ifelse(V(conteII_network)$party == "SWITCHER/DECAYED", NA, V(conteII_network)$color)
V(conteII_network)$color <- ifelse(V(conteII_network)$party == "ITALIA VIVA", "#C83282", V(conteII_network)$color)

color <- unique(V(conteII_network)$party)
party_color <-  c("lightblue", "#003366", "red", "yellow", NA, "forestgreen", "peachpuff4", "magenta")

hub_sc <- hub_score(conteII_network, weights=NA)$vector
aut_sc <- authority_score(conteII_network, weights=NA)$vector
community <- cluster_edge_betweenness(conteII_network)

l <- layout_with_fr(conteII_network)
# plot network
png(filename = here("fig/ConteII.png"), width = 1980, height = 1080)
plot(
  conteII_network, 
  main = "Conte II",
  vertex.size = 7, 
  vertex.label = NA,
  vertex.label.cex = .7,
  edge.arrow.size = .1,
  edge.width = .7,
  frame = F,
  layout = l)
dev.off()

