#00 - Parâmetros ---------------

# Definir parâmetros -----------------------------

url <- "http://www.ons.org.br/historico/geracao_energia_out.aspx?area="

tipos_de_geracao <- c("HID", "TER", "NUC", "EME", "EOL")
regioes <- c("SE/CO", "S", "NE", "N", "Itaipu", "Sistemas")
unidades_de_medida <- c("Mwmed", "GWh")
periodos <- c(2002:2016)


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

# Funções auxiliares --------------------------
# função p/ verificar consistencia
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

ler_e_transformar <- function(arq){
  d <- read_html(arq) %>%
    html_node(".tabelaHistorico") %>%
    html_table()
  
  d <- d[-1,]
  
  arq_meta <- stringr::str_replace_all(arq, stringr::fixed("data-raw/"), "") %>%
    stringr::str_replace_all(stringr::fixed(".html"), "") %>%
    stringr::str_split("-") %>%
    unlist()
  
  tipo_de_geracao <- arq_meta[1]
  regiao = arq_meta[2]
  unidade_de_medida <- arq_meta[3]
  ano <- arq_meta[4]
  mes <- 1:12
  
  if (regiao == "SECO")
    regiao <- "SE/CO"
  
  
  data.frame(
    tipo_de_geracao = tipo_de_geracao,
    regiao = regiao,
    unidade_de_medida = unidade_de_medida,
    ano = ano,
    mes = mes,
    geracao_de_energia = d[["X2"]] %>% str_replace_all(fixed(","), ".") %>% as.numeric()
  )
}


