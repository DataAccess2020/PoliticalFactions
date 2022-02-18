
endpoint <- "http://dati.camera.it/sparql"

bio <- "SELECT ?nome ?cognome ?partito 
WHERE { ?persona a ocd:deputato;
      	foaf:firstName ?nome;
      	foaf:surname ?cognome.
   		?persona ocd:rif_mandatoCamera ?mandato.
       
       	#adesione a partito
       	?mandato ocd:rif_deputato ?deputato.
       	?deputato ocd:aderisce ?l.
       	?l rdfs:label ?partito.
       
        #restict to 18esima legislatura
      	?mandato ocd:rif_leg <http://dati.camera.it/ocd/legislatura.rdf/repubblica_18> .}
GROUP BY ?partito
ORDER BY ?cognome"

qd <- SPARQL(endpoint, bio)
anagrafica <- qd$results
