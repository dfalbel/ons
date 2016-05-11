# Baixar dados

setwd("carga-de-demanda/")

# Definição dos parâmetros -------------------

source("R/00 - Parametros.R")


# Baixar Arquivos ------------------

library(httr)

for(regiao in regioes){
  for(periodo in periodos){
    POST2(regiao, periodo)
    Sys.sleep(1)
  } 
}