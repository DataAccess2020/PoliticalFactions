endpoint <- "http://dati.camera.it/sparql"

# Deputati XVIII legi ---------------------------------------------------------------


#biographies of all Deputati
bio <- "
SELECT DISTINCT (CONCAT(?cognome,\" \",?nome) AS ?name) , ?partito, ?s_office, ?e_office
WHERE { ?persona a ocd:deputato;
      	foaf:firstName ?nome;
      	foaf:surname ?cognome .
   		  ?persona ocd:rif_mandatoCamera ?mandato .
       
       	#adesione a partito
       	?mandato ocd:rif_deputato ?deputato .
       	?deputato ocd:aderisce ?l .
       	?l rdfs:label ?partito .
	OPTIONAL{?l ocd:startDate ?s_office.}
	OPTIONAL{?l ocd:endDate ?e_office.}
       
        #restict to 18esima legislatura
      	?mandato ocd:rif_leg <http://dati.camera.it/ocd/legislatura.rdf/repubblica_18> .}
ORDER BY ?name

"

df_bio <- SPARQL(endpoint, bio)
df_bio <- df_bio$results
#Data Updated To 28 of February 2021 10:00 AM UTC+01:00
write.csv(df_bio, here::here("data/deputies.csv"))


# Conte I ------------------------------------------------------------------


#extraction of laws first and others contributors
df_law <- tibble() #empty df 

#the main query makes use of a subquery for offset purposes
query_main <- "
SELECT DISTINCT ?num ?date(CONCAT(?primo_cognome, \" \",?primo_nome) AS ?signatory) 
(CONCAT(?altro_cognome,\" \",?altro_nome) AS ?joint_signatory)
WHERE {
 {
  SELECT ?num ?date ?primo_nome ?primo_cognome ?altro_nome ?altro_cognome
  WHERE {
  ?atto a ocd:atto;
          dc:identifier ?num;
          dc:date ?date;
          ocd:rif_leg <http://dati.camera.it/ocd/legislatura.rdf/repubblica_18> ;
          ocd:rif_governo <http://dati.camera.it/ocd/governo.rdf/g142> .
  
  ?atto ocd:primo_firmatario ?primo .
  ?primo  a ocd:deputato;
            foaf:firstName ?primo_nome;
            foaf:surname ?primo_cognome .
  	
  ?atto ocd:altro_firmatario ?altro .
  ?altro  a ocd:deputato;
            foaf:firstName ?altro_nome;
            foaf:surname ?altro_cognome .
  
  #filter for testing purposes
  #FILTER( ?atto = <http://dati.camera.it/ocd/attocamera.rdf/ac18_71>).
    }
	GROUP BY ?atto
	ORDER BY ?num ?primo_cognome ?altro_cognome
}
  }

LIMIT 10000
OFFSET"

#since the Virtuoso Endpoint have a 10000 results limits it need an offset
# in order to scrapes all the triples
query_offset <- c("0","5000","10000","15000","20000","25000","30000","35000")


i <- 0
for (i in 1:length(query_offset)) {
  law <- str_c(query_main,
               query_offset[i],
               sep = " ")
  #print(query_offset[i])
  result_law <- SPARQL(endpoint, law)
  df_law <- rbind(df_law, result_law$results)
  Sys.sleep(2)
}
#Data Updated To 20 of February 2021 10:00 AM UTC+01:00
write.csv(df_law, here::here("data/conteI.csv"))


# Conte II ----------------------------------------------------------------

df_law <- tibble() #empty df 

#the main query makes use of a subquery for offset purposes
query_main <- "
SELECT DISTINCT ?num ?date(CONCAT(?primo_cognome, \" \",?primo_nome) AS ?signatory) 
(CONCAT(?altro_cognome,\" \",?altro_nome) AS ?joint_signatory)
WHERE {
 {
  SELECT ?num ?date ?primo_nome ?primo_cognome ?altro_nome ?altro_cognome
  WHERE {
  ?atto a ocd:atto;
          dc:identifier ?num;
          dc:date ?date;
          ocd:rif_leg <http://dati.camera.it/ocd/legislatura.rdf/repubblica_18> ;
          ocd:rif_governo <http://dati.camera.it/ocd/governo.rdf/g162> .
  
  ?atto ocd:primo_firmatario ?primo .
  ?primo  a ocd:deputato;
            foaf:firstName ?primo_nome;
            foaf:surname ?primo_cognome .
  	
  ?atto ocd:altro_firmatario ?altro .
  ?altro  a ocd:deputato;
            foaf:firstName ?altro_nome;
            foaf:surname ?altro_cognome .
  
  #filter for testing purposes
  #FILTER( ?atto = <http://dati.camera.it/ocd/attocamera.rdf/ac18_71>).
    }
	GROUP BY ?atto
	ORDER BY ?num ?primo_cognome ?altro_cognome
}
  }

LIMIT 10000
OFFSET"

#since the Virtuoso Endpoint have a 10000 results limits it need an offset
# in order to scrapes all the triples
query_offset <- c("0","5000","10000","15000","20000","25000","30000","35000")


i <- 0
for (i in 1:length(query_offset)) {
  law <- str_c(query_main,
               query_offset[i],
               sep = " ")
  #print(query_offset[i])
  result_law <- SPARQL(endpoint, law)
  df_law <- rbind(df_law, result_law$results)
  Sys.sleep(2)
}
#Data Updated To 20 of February 2021 10:00 AM UTC+01:00
write.csv(df_law, here::here("data/conteII.csv"))

