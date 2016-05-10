# Coletar dados da ONS
setwd("geracao-energia/")

# Definir parâmetros -----------------------------

url <- "http://www.ons.org.br/historico/geracao_energia_out.aspx?area="

tipos_de_geracao <- c("HID", "TER", "NUC", "EME", "EOL")
regioes <- c("SE/CO", "S", "NE", "N", "Itaipu", "Sistemas")
unidades_de_medida <- c("Mwmed", "GWh")
periodos <- c(2002:2016)

# Criar lista com parâmertros ----------------------------

# essa é uma lista de exmplo p/ testes
par <- list(
  submit = "Consultar",
  passo1 = "HID",
  passo2 = "SE/CO",
  passo3 = "Mwmed",
  passo4 = "2016",
  passo5 = "-1"
)

# Função que cria nome p/ os arquivos.

criar_nome_arq <- function(tipo_de_geracao, regiao, unidade_de_medida, periodo){
  regiao <- stringr::str_replace_all(regiao, stringr::fixed("/"), "")
  sprintf("data-raw/%s-%s-%s-%s.html", tipo_de_geracao, regiao, unidade_de_medida, periodo)
}

# Baixar dados ----------------------------

# essa é a versão inicial que baixou todos os dados até o momento presente
# 10-05-2016
# Nas próximas vezes deve ser rodado o script de atualização.

library(httr)

POST2 <- dplyr::failwith(NULL, function(tipo_de_geracao, regiao, unidade_de_medida, periodo){
  par <- list(
    submit = "Consultar",
    passo1 = tipo_de_geracao,
    passo2 = regiao,
    passo3 = unidade_de_medida,
    passo4 = periodo,
    passo5 = "-1"
  )
  arq <- criar_nome_arq(tipo_de_geracao, regiao, unidade_de_medida, periodo)
  POST(url, body = par, encode = "form", write_disk(arq))
})

for(tipo_de_geracao in tipos_de_geracao){
  for(regiao in regioes){
    for(unidade_de_medida in unidades_de_medida){
      for(periodo in periodos){
        POST2(tipo_de_geracao, regiao, unidade_de_medida, periodo)
        Sys.sleep(1)
      }
    }
  }
}


