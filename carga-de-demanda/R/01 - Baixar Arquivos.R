# Baixar dados

setwd("carga-de-demanda/")

# Definição dos parâmetros -------------------

source("R/00 - Parametros.R")


# Baixar Arquivos ------------------

library(httr)

POST2 <- dplyr::failwith(NULL, function(regiao, periodo){
  par <- list(
    submit = "Consultar",
    passo1 = regiao,
    passo2 = periodo,
    passo3 = "-1"
  )
  arq <- criar_nome_arq(regiao, periodo)
  POST(url, body = par, encode = "form", write_disk(arq))
})


for(regiao in regioes){
  for(periodo in periodos){
    POST2(regiao, periodo)
    Sys.sleep(1)
  } 
}