# Baixar dados

setwd("carga-de-demanda/")

# Definição dos parâmetros -------------------

url <- "http://www.ons.org.br/historico/carga_propria_de_demanda_out.aspx"
regioes <- c("SE/CO", "S", "NE", "N", "SIN")
periodos <- c(2000:2016)

# Função que cria nome dos arquivos ------------------------
criar_nome_arq <- function(regiao, periodo){
  regiao <- stringr::str_replace_all(regiao, stringr::fixed("/"), "")
  sprintf("data-raw/%s-%s.html", regiao, periodo)
}

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