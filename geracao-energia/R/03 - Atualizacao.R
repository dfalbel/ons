# Atualização ----------------------------
library(magrittr)
library(dplyr)
library(httr)
setwd("geracao-energia/")
source("R/00 - Parametros.R")
# A base da geração de energia está na visão mensal. No entanto todos os dados ficam 
# disponíveis em uma página por ano.
# Para atualizar precisamos pegar baixar de novo os dados do último ano e 
# adicionar estes dados à tabela.

base_arquivos <- read.csv("data/base_arquivos.csv")

# descobrir qual é o último ano que temos.
periodo_atualizar <- base_arquivos %>%
  filter(leitura_ok, download_ok) %$%
  max(periodos)
periodo_atualizar <- max(c(periodo_atualizar, max(periodos)))

# excluir arquivos deste periodo
for(tipo_de_geracao in tipos_de_geracao){
  for(regiao in regioes){
    for(unidade_de_medida in unidades_de_medida){
      file.remove(criar_nome_arq(tipo_de_geracao, regiao, unidade_de_medida, periodo_atualizar))
    }
  }
}

# baixar os dados mais recentes de novo.
for(tipo_de_geracao in tipos_de_geracao){
  for(regiao in regioes){
    for(unidade_de_medida in unidades_de_medida){
        POST2(tipo_de_geracao, regiao, unidade_de_medida, periodo_atualizar)
        Sys.sleep(1)
    }
  }
}


# processar os novos arquivos
# criar base marcando se o arquivo foi baixado ou não
base_arquivos <- expand.grid(tipos_de_geracao = tipos_de_geracao, 
                             regioes = regioes, 
                             unidades_de_medida = unidades_de_medida,
                             periodos = periodos,
                             stringsAsFactors = F)

# criar lista de arquivos
lista_arquivos <- list.files("data-raw/", full.names = T) %>%
  stringr::str_replace_all(stringr::fixed("//"), "/")

# criando coluna que indica se o download foi ok.
base_arquivos$download_ok <- criar_nome_arq(
  tipo_de_geracao = base_arquivos$tipos_de_geracao,
  regiao = base_arquivos$regioes,
  unidade_de_medida = base_arquivos$unidades_de_medida,
  periodo = base_arquivos$periodos
) %in% 
  lista_arquivos


# Leitura e verificação
consistencia <- plyr::laply(lista_arquivos, function(x){
  verificar_consistencia(x)
})

arqs_consistentes <- lista_arquivos[consistencia]


base <- plyr::ldply(arqs_consistentes, ler_e_transformar)
base <- unique(base)

base_arquivos$leitura_ok <- consistencia

write.csv(base_arquivos, file = "data/base_arquivos.csv", row.names = F)
write.csv(base, file = "data/base.csv", row.names = F)
