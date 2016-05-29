rm(list=ls())
library(XML)
library(httr)
library(foreach)
library(splitstackshape)

# recherche polytechnique

# + pour espace, %27 pour apostrophe, - pour tiret
# très tolérant, trouve n'importe quels noms tant qu'il n'y a pas trop de réponses
# les tirets, apostrophes sont traités comme des espaces 
# ordre des mots pas important

#listing : id, prenom, nom, ecole_confirmée, resultat_courant
# listing <- data.frame(id = c(1,2), prenom = c('valery','jacques'), nom_lower = c("giscard d estaing","attali"), resultat_courant = c(NA, NA), stringsAsFactors = F)

url <- "http://www.polytechnique.org/search?quick="
setwd("~/Code_R/data")
listing <- read.csv("test1_elite_29mai.csv", sep = ",", header = TRUE, stringsAsFactors = FALSE)

foreach (id = listing$id) %do% {
  prenom          <- listing$prenom_lower[id]
  nom             <- listing$nom_lower[id]
  response   <- GET(paste(url,prenom,nom, sep = "+"))
  doc      <- content(response, type="text/html", encoding = "UTF-8")
  parseddoc <- htmlParse(doc)
  listing$resultat_courant[id] <- paste(paste0("http://www.polytechnique.org/",unlist(xpathApply(parseddoc, "//div[@class='nom']/a/@href"))), collapse = " ")
  listing$resultat_courant[id] <- ifelse(listing$resultat_courant[id] == "http://www.polytechnique.org/", "",listing$resultat_courant[id])
  listing$edu[id] <- paste(gsub("\n", "", xpathApply(parseddoc, "//*[@id='multipage_content']/div/div/div/div[2]",xmlValue)), collapse = ";")
  listing$profession[id] <- paste(gsub("\n", "", xpathApply(parseddoc, "//*[@id='multipage_content']/div/div/div/table",xmlValue)), collapse = ";")
  print(listing[id,])
}

listing <- cSplit(listing, "resultat_courant", sep = " ")
listing <- cSplit(listing, "edu", sep = ";")
listing <- cSplit(listing, "profession", sep = ";")


listing
write.table(listing, "listing-out-polytechnique.csv", sep = ";", row.names = FALSE, col.names = TRUE)

