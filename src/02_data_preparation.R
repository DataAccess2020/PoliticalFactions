# Deputies data preparation -----------------------------------------------

# import deputies.csv, skipping the firs column which contains unused data
deputies <- vroom(here('data/deputies.csv'),
      col_select = c('nome','cognome','partito'))

# merge name and surname
deputies <- deputies %>% 
  unite(name, nome, cognome, sep = " ") %>% 
  separate(col = partito,
           into = c('party','date'),
           sep = '\\(')

deputies <- deputies %>% 
  mutate(date= gsub(")", "", date))

deputies <- deputies %>% 
  separate(col= date,
           into = c('s_date','e_date'),
           sep= '-') %>% 
  mutate(e_date = ifelse(is.na(e_date), "26.02.2022", e_date))
   

# parsing party dates
deputies <- deputies %>% 
  mutate(s_date = dmy(deputies$s_date),
         e_date = dmy(deputies$e_date))

# mutate to interval date format
deputies <- deputies %>% 
  mutate(date = interval(start = s_date, end = e_date))

# creating unique keys for party
deputies <- deputies %>% 
  group_by(party) %>% 
  mutate(party_id = cur_group_id())

# creating unique keys for deputies
deputies <- deputies %>% 
  group_by(name) %>%
  mutate(mp_id = cur_group_id())

# drop s_date & e_date
deputies <- deputies %>% 
  select(!(c(s_date,e_date)))

# Contributors data preparation ------------------------------------------------

# import contributors.csv, skipping the firs column which contains 
# parsing the date columnunused data
contributors <- vroom(here("data/contributors.csv"),
                      col_select = c('num':'altro_cognome'))

contributors$date <- ymd(contributors$date)

# names first signatory
contributors <-  contributors %>% 
  unite(signatory, primo_nome, primo_cognome, sep = " ")
  
# names joint signatory
contributors <-  contributors %>% 
  unite(joint_signatory, altro_nome, altro_cognome, sep = " ") 

  
# first left join into first signatory keys
contributors <-  left_join(
    contributors,
    deputies,
    by = c("signatory" = "name"),
    suffix = c("_law", "_mp")
  )
# if the mp have changed party subset if date_law not included within the political mandate
contributors <- subset(contributors, (contributors$date_law %within% contributors$date_mp) == TRUE)

# second left join into joint signatory

contributors <- left_join(
  contributors,
  deputies,
  by = c("joint_signatory" = "name"),
  suffix = c("_first", "_joint")
)

# if the mp have changed party subset if date_law not included within the political mandate of joint signatory
contributors <- subset(contributors, (contributors$date_law %within% contributors$date) == TRUE)

# filter unsued columns
contributors <- contributors %>% 
  select(!c(date_mp, date))

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

# plot network
plot(conteI_network, vertex.size = 10, vertex.label = NA,vertex.label.cex = .7,edge.arrow.size = .3,edge.width = .7)

