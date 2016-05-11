# Atualização ----------------------------
library(magrittr)
library(dplyr)
library(httr)

# A base da carga-demanda está na visão mensal. No entanto todos os dados ficam 
# disponíveis em uma página por ano.
# Para atualizar precisamos pegar baixar de novo os dados do último ano e 
# adicionar estes dados à tabela.

base_arquivos <- read.csv("data/base_arquivos.csv")

# descobrir qual é o último ano que temos.
periodo_atualizar <- base_arquivos %>%
  filter(leitura_ok, download_ok) %$%
  max(periodos)

# excluir arquivos deste periodo
for(regiao in regioes){
  file.remove(criar_nome_arq(regiao, periodo_atualizar))  
}

# função p/ baixar
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

# baixar os dados mais recentes de novo.
for(regiao in regioes){
  POST2(regiao, periodo_atualizar)
  Sys.sleep(1)
}

# processar os novos arquivos
# criar base marcando se o arquivo foi baixado ou não
base_arquivos <- expand.grid(regioes = regioes, periodos = periodos, stringsAsFactors = F)


lista_arquivos <- list.files("data-raw/", full.names = T) %>%
  stringr::str_replace_all(stringr::fixed("//"), "/")

# criando coluna que indica se o download foi ok.
base_arquivos$download_ok <- criar_nome_arq(base_arquivos$regioes, base_arquivos$periodos) %in% 
  lista_arquivos

consistencia <- plyr::laply(lista_arquivos, function(x){
  verificar_consistencia(x)
})

arqs_consistentes <- lista_arquivos[consistencia]
base <- plyr::ldply(arqs_consistentes, ler_e_transformar)

base_arquivos$leitura_ok <- consistencia

write.csv(base_arquivos, file = "data/base_arquivos.csv", row.names = F)
write.csv(base, file = "data/base.csv", row.names = F)




