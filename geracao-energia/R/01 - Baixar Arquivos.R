# Coletar dados da ONS
setwd("geracao-energia/")

source("R/00 - Parametros.R")

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


