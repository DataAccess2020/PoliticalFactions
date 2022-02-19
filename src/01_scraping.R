
endpoint <- "http://dati.camera.it/sparql"

#biographies of all Deputati
bio <- "SELECT ?nome ?cognome ?partito 
WHERE { ?persona a ocd:deputato;
      	foaf:firstName ?nome;
      	foaf:surname ?cognome .
   		  ?persona ocd:rif_mandatoCamera ?mandato .
       
       	#adesione a partito
       	?mandato ocd:rif_deputato ?deputato .
       	?deputato ocd:aderisce ?l .
       	?l rdfs:label ?partito .
       
        #restict to 18esima legislatura
      	?mandato ocd:rif_leg <http://dati.camera.it/ocd/legislatura.rdf/repubblica_18> .}
GROUP BY ?partito
ORDER BY ?cognome"

df_bio <- SPARQL(endpoint, bio)
df_bio <- df_bio$results

#extraction of parliamentary purposed law
law <- "SELECT ?atto ?num ?primo_nome ?primo_cognome ?altro_nome ?altro_cognome
WHERE {
 {
  SELECT ?atto ?num ?primo_nome ?primo_cognome ?altro_nome ?altro_cognome
  WHERE {
  ?atto a ocd:atto;
          dc:identifier ?num;
          ocd:rif_leg <http://dati.camera.it/ocd/legislatura.rdf/repubblica_18> .
  
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
	ORDER BY ?num
}
  }

LIMIT 10
OFFSET 30000"

df_law <- SPARQL(endpoint, law)
df_law <- df_law$results



