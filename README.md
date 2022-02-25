![Logo](fig/dapscologo.jpg)

# Political Factions into the Italian Parliament

## Capstone project for Data Access class

## Content


### Domanda di ricerca e due/tre pubblicazioni sul tema

I partiti di governo, presso la Camera dei Deputati, erano coesi nell'attività legislativa durante il governo Conte I ed il governo Conte II? All'interno dei partiti erano risultano evidenti fazioni politiche?
Pubblicazioni sul:

- De Giorgi, E., & Dias, A. (2018). Standing apart together? Common traits of (new) challenger parties in the Italian parliament. Italian Political Science, 13(2).
- *In Aggiunta ulteriori pubblicazioni*

### Ipotesi e meccanismo

- *H1* I partiti di governo erano coesi nella proposta dei testi legislativi.
- *H2* All'interno dei parititi di governo non erano presenti non erano presenti evidenti fazioni politiche.

Il meccanismo di supporto risulta ancora da definire.

### Dateset e operazionalizzazione di massima

I dati sono estratti dal progeto [Linked Open Data della Camera dei Deputati](https://dati.camera.it/it/), che rende fruibile il patrimonio informativo della Camera.
Le variabili utilizzate sono estratte tramite l'utilizzo di due query SPARQL dal LOD della Camera. La query si compone di una serie di collegamenti tra le unità informative minime tramite l'utilizzo di [triple semantiche](https://en.wikipedia.org/wiki/Semantic_triple), composte da soggetto, predicato e oggetto.
L'[Ontologia della Camera dei Deputati](http://dati.camera.it/ocd/reference_document/), OCD, rende possibile la composizione di queste triple.
Il LOD viene interrogato tramite il pacchetto r `SPARQL`.

I datasets ricavati sono salvati su supporto `.csv` per ottimizzarne la portabilità e sono così costituiti:

- `deputies.csv`:
  - `name` - Nome e Cognome del deputato
  - `party` - Partito di afferenza del deputato

La variabile `name` è ricavata dal merge tra la proprietà `firstName` e `surname` metadata [FOAF](http://xmlns.com/foaf/spec/) della classe `ocd:deputato` . I deputati verrano codificati secondo un'id univoco.
La variabile `party` è ricavata dalla label della proprietà . I partiti verrano poi codificati secondo id univoci; i deputati che hanno cambiato il partito durante il corso della legislatura verrano ricodificati in una categoria a parte *da definire*.

- `contributors.csv`:
  - `num` - numero atto
  - `date` - data atto
  - `signatory` - primo firmatario
  - `joint_signatory` - altri firmatari

Le variabili `num` e `date` sono ricavate dalle porprietà `identifier` e `date`, metatdata [Dublin Core](https://www.dublincore.org/specifications/dublin-core/dcmi-terms/) della classe `ocd:atto`.
I firmatari sono ricavati da indentificatori FOAF di proprietà della classe `ocd:atto`.

Sia i deputati che gli atti verrano estratti filtrando solo quelli afferenti alla Diciottesima legislatura. Questo verrà fatto tramite la proprietà  `ocd:rif_leg <http://dati.camera.it/ocd/legislatura.rdf/repubblica_18>` 

Gli atti, una volta importati, verrano divisi in atti proposti durante il governo Conte I e durante il governo Conte II.
L'endpoint SPARQL impone un limite massimo di $10 000$ risultati per singola query. Per superare questo limite dovrà essere impletato un sistema di offset e una subquery SPARQL.

I dataset così ricavati verrano preparati per costituire i nodi, nodes, e le connessioni, edges, del network. I vari edges saranno elaborati come direzionati, directed, da `joint_signatory` verso `signatory`, divisi per parito del primo firmatario.

### Idea dell'analisi

L'analisi si baserà sui principi della Social Network Analysis, SNA. In particolare, tramite la generazione di un network i cui rami, egdes, saranno costituiti dalla relazione tra i co-firmatari e il primo firmatario delle proposte legislative. Inoltre, verrà calcolato l'indice *intra-opposition party bill differentiation*, come definito da De Giorgi & Dias.
*Da definire* eventuali modelli statistici aggiuntivi.

### Risultati attesi

Da questa analisi mi attendo un risposta alle due ipotesi formulate per comprendere meglio le dinamiche di coesione tra i partiti di governo, e in generale tutti i partiti rappresentati in parlamento, durante i primi due governi di Giuseppe Conte.


## Team

- [Nicola Casarin](https://github.com/n-oise)

## Working directory structure

| Dir | Usage |
| ----- | -----|
| src | Scripts |
| fig | Figures and images |
| output | Textual outputs |
| doc | Documentation |
| old | Old files |
| data | Data [^1] |

[^1]: Please, do not publish data unless you are sure about what are you doing!


## Attribution

Data source: [dati.camera.it](https://dati.camera.it)

