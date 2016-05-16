setwd("carga-de-energia/")

# baixar arquivos ------------------------------------
# essa é a versão inicial que baixou todos os dados até o momento presente
# 10-05-2016
# Nas próximas vezes deve ser rodado o script de atualização.

source("R/00 - Parametros.R")

library(httr)

for (regiao in regioes) {
  for (unidade_de_medida in unidades_de_medida) {
    for (base in bases) {
      for (periodo in periodos) {
        POST2(regiao, unidade_de_medida, base, periodo)
        Sys.sleep(1)
      } 
    }
  }
}


