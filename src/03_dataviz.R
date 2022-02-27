# Conte I data preparation ------------------------------------------------

# Conte I in carica dal 1º giugno 2018 al 5 settembre 2019, 
# per un totale di 461 giorni, ovvero 1 anno, 3 mesi e 4 giorni. 
# Dimissioni 20 agosto 2019.

# edges governo Conte I
conteI_edges <- contributors %>% 
  filter(contributors$date_law >= "2018-06-01" & contributors$date_law < "2019-09-05") %>% 
  select(joint_signatory, signatory)

# estrazione nodi(deputati) governo Conte I
deputies_conteI <- deputies %>% 
  filter(interval(start = "2018-06-01", end = "2019-09-05")  %within% date)

deputies_conteI

conteI_nodes <- unique(conteI_edges$signatory)
conteI_nodes <- append(conteI_nodes, unique(conteI_edges$joint_signatory))
conteI_nodes <- tibble(name = unique(conteI_nodes))

conteI_nodes <- left_join(conteI_nodes,
          subset(deputies, interval(start = "2018-06-01", end = "2019-09-05") %within% deputies$date),
          by = c("name" = "name"),
          suffix = c(".conte",".dep")) %>% 
  select(name, party)


# network governo 
conteI_network <- graph_from_data_frame(conteI_edges, directed = T, vertices = conteI_nodes)

unique(V(conteI_network)$party)

# codifica colori partito
V(conteI_network)$color <- NA
V(conteI_network)$color <- ifelse(V(conteI_network)$party == "FRATELLI D'ITALIA ", "#003366","orange")
V(conteI_network)$color <- ifelse(V(conteI_network)$party == "MOVIMENTO 5 STELLE ", "yellow", V(conteI_network)$color)
V(conteI_network)$color <- ifelse(V(conteI_network)$party == "LEGA - SALVINI PREMIER ", "forestgreen", V(conteI_network)$color)
V(conteI_network)$color <- ifelse(V(conteI_network)$party == "FORZA ITALIA - BERLUSCONI PRESIDENTE ", "lightblue", V(conteI_network)$color)
V(conteI_network)$color <- ifelse(V(conteI_network)$party == "PARTITO DEMOCRATICO ", "red", V(conteI_network)$color)
V(conteI_network)$color <- ifelse(V(conteI_network)$party == "LIBERI E UGUALI ", "magenta", V(conteI_network)$color)
V(conteI_network)$color <- ifelse(V(conteI_network)$party == "MISTO ", "peachpuff4", V(conteI_network)$color)

color <- unique(V(conteI_network)$party)
party_color <-  c("lightblue", "#003366", "red", "yellow", NA, "forestgreen", "peachpuff4", "magenta")

hub_sc <- hub_score(conteI_network, weights=NA)$vector
aut_sc <- authority_score(conteI_network, weights=NA)$vector
community <- cluster_edge_betweenness(conteI_network)

l <- layout_with_fr(conteI_network)
# plot network
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

#plot(0,type='n',axes=FALSE,ann=FALSE)
#legend("bottom", legend=color, bty = "n", cex = 0.75, 
#       pt.cex = 3, pch=20, col = party_color ,
#       horiz = FALSE,ncol = 1)
