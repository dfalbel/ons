setwd("carga-de-energia/")

# definir os parametros ------------------------------
url <- "http://www.ons.org.br/historico/carga_propria_de_energia_out.aspx"
regioes <- c("SE/CO", "SUL", "NORDESTE", "NORTE", "SIN")
unidades_de_medida <- c("Mwmed", "GWh")
bases <- c("anual", "mensal")
periodos <- 2000:2016

# funcao p/ criar nome de arquivo --------------------
criar_nome_arq <- function(regiao, unidade_de_medida, base, periodo){
  regiao <- stringr::str_replace_all(regiao, stringr::fixed("/"), "")
  sprintf("data-raw/%s-%s-%s-%s.html", regiao, unidade_de_medida, base, periodo)
}

# baixar arquivos ------------------------------------
# essa é a versão inicial que baixou todos os dados até o momento presente
# 10-05-2016
# Nas próximas vezes deve ser rodado o script de atualização.

library(httr)

POST2 <- dplyr::failwith(NULL, function(regiao, unidade_de_medida, base, periodo){
  par <- list(
    submit = "Consultar",
    passo1 = regiao,
    passo2 = unidade_de_medida,
    passo3 = base,
    passo4 = periodo,
    passo5 = "-1"
  )
  arq <- criar_nome_arq(regiao, unidade_de_medida, base, periodo)
  POST(url, body = par, encode = "form", write_disk(arq))
})


for(regiao in regioes){
  for(unidade_de_medida in unidades_de_medida){
    for(base in bases){
      for(periodo in periodos){
        POST2(regiao, unidade_de_medida, base, periodo)
        Sys.sleep(1)
      } 
    }
  }
}


