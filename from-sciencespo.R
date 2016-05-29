# recherche sciences po

# avec RSelenium
library(RSelenium)
library(foreach)

startServer()
mybrowser <- remoteDriver()
mybrowser$open()

url <- "http://www.sciences-po.asso.fr/gene/main.php?base=1244"
listing <- data.frame(id = c(1, 2, 3, 4, 5, 6 , 7), nom = c("Hollande","Chirac", "Attali", "Mitterrand"), stringsAsFactors = F)

setwd("~/Code_R/data")
listing <- read.csv("test1_elite_29mai.csv", sep = ",", header = TRUE)

foreach (id = listing$id) %do% {
  #prenom          <- listing$prenom[id]
  nom             <- listing$nom[id]
  
  retry(mybrowser$navigate(url))                                                                            # ouvre la page
  form <- mybrowser$findElement(using = 'css selector', "#select2-chosen-3")                                # sélectionne le champ "nom"
  retry(form$clickElement())                                                                                # clique dessus
  field <- mybrowser$findElement(using = 'css selector', "input#s2id_autogen3_search.select2-input")        # sélectionne la case d'input du champ "nom"
  retry(field$sendKeysToElement(list(nom)))                                                                 # met dedans le nom de la personne
  Sys.sleep(1)                                                                                              # attend que la liste soit générée
  list_reponse <- mybrowser$findElement(using = 'css selector', "ul#select2-results-3.select2-results")     # sélectionne le contenu de cette liste
  while (grepl("Chargement de résultats supplémentaires", tail(unlist(strsplit(as.character(list_reponse$getElementText()), "\n")),n=1)))  # si elle est pas entièrement générée, cette boucle la génère en entier
  {
    list_reponse$sendKeysToElement(list(key = "end"))
    # IMPROVEMENT :  si le nom apparait dans la liste, break loop
  }
  
  #mybrowser$findElement(using = 'css selector', paste0("div#select2-result-label-",58,".select2-result-label"))$clickElement()
  Sys.sleep(1) 
  
  if(grepl("Aucun résultat trouvé", unlist(strsplit(as.character(list_reponse$getElementText()), "\n"))[1])) {
    listing$resultat_courant[id] <- NA
  }else {
    line_pos <- which(unlist(strsplit(as.character(list_reponse$getElementText()), "\n")) == nom) + 13L #+33L si il a eu le temps de charger les noms commencant par A, +13L sinon     
    aclick<-mybrowser$findElement(using = 'css selector', paste0("div#select2-result-label-",line_pos,".select2-result-label"))
    retry(aclick$clickElement())
    button <- mybrowser$findElement(using = 'css selector', "a.jqueryButton.ui-button.ui-widget.ui-state-default.ui-corner-all.ui-button-text-icon-primary")
    retry(button$clickElement())
    Sys.sleep(2)
    reponses <- mybrowser$findElements(using = 'css selector', "h3>a")
    listing$resultat_courant[id]<- paste(unlist(sapply(reponses, function(x){x$getElementAttribute("href")})),collapse=' ')
    # IMPROVEMENT si ya une fleche pour aller à la page suivante, cliquer dessus en boucle et récupérer à chaque fois la liste
    print(listing[id,])
  }
}

listing
View(listing)

# IMPROVEMENT utiliser cSplit() de library(splitstackshape)
