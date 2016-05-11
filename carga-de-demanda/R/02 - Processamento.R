# Processamento
library(rvest)
library(tidyr)

source("R/00 - Parametros.R")

# criar base marcando se o arquivo foi baixado ou não
base_arquivos <- expand.grid(regioes = regioes, periodos = periodos, stringsAsFactors = F)


lista_arquivos <- list.files("data-raw/", full.names = T) %>%
  stringr::str_replace_all(stringr::fixed("//"), "/")

# criando coluna que indica se o download foi ok.
base_arquivos$download_ok <- criar_nome_arq(base_arquivos$regioes, base_arquivos$periodos) %in% 
  lista_arquivos

# Funções auxiliares --------------------------

verificar_consistencia <- function(arq){
  
  f_aux <- dplyr::failwith(F, function(x){
    d <- x %>%
      read_html() %>%
      html_node(".tabelaHistorico") %>%
      html_table()
    ok <- is.data.frame(d) & (nrow(d) == 13)
    
    if(ok){
      return(T)
    } else {
      return(F)
    }
  })
  
  f_aux(arq)
}
# melhorar essa fun.
ler_e_transformar <- function(arq){
  
  regiao <- stringr::str_replace_all(arq, stringr::fixed("data-raw/"), "") %>%
    stringr::str_split("-") %>%
    unlist()
  regiao <- regiao[1]
  
  if(regiao == "SECO")
    regiao <- "SE/CO"
  
  d <- arq %>%
    read_html() %>%
    html_node(".tabelaHistorico") %>%
    html_table()
  
  ano <- d[1,2]
  
  d <- d %>%
    dplyr::slice(-1) %>%
    dplyr::select(-X1) %>%
    dplyr::transmute(
      carga_de_demanda  = X2 %>% stringr::str_replace_all(stringr::fixed(","), ".") %>% as.numeric
    )
  
  d$regiao = regiao
  d$ano <- ano
  d$mes <- 1:12
  
  d %>%
    dplyr::select(regiao, ano, mes, carga_de_demanda)
}

# Leitura e verificação
consistencia <- plyr::laply(lista_arquivos, function(x){
  verificar_consistencia(x)
})

arqs_consistentes <- lista_arquivos[consistencia]
base <- plyr::ldply(arqs_consistentes, ler_e_transformar)


base_arquivos$leitura_ok <- consistencia

write.csv(base_arquivos, file = "data/base_arquivos.csv", row.names = F)
write.csv(base, file = "data/base.csv", row.names = F)














