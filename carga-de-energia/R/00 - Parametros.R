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


# funções de processamento

verificar_consistencia <- dplyr::failwith(FALSE, function(arq){
  d <- read_html(arq) %>%
    html_node(".tabelaHistorico") %>%
    html_table()
  ok <- is.data.frame(d) & (nrow(d) >= 13)
  return(ok)
})

ler_e_transformar <- function(arq){
  d <- read_html(arq) %>%
    html_node(".tabelaHistorico") %>%
    html_table()
  
  d <- d[-1,]
  
  arq_meta <- stringr::str_replace_all(arq, stringr::fixed("data-raw/"), "") %>%
    stringr::str_replace_all(stringr::fixed(".html"), "") %>%
    stringr::str_split("-") %>%
    unlist()
  
  regiao <- arq_meta[1]
  unidade_de_medida <- arq_meta[2]
  periodo <- arq_meta[3]
  ano <- arq_meta[4]
  
  if(periodo == "anual"){
    mes <- NA
    ano <- d[["X1"]]
  } else {
    mes <- 1:12
  }
  
  data.frame(
    regiao = regiao,
    unidade_de_medida = unidade_de_medida,
    periodo = periodo,
    ano = ano,
    mes = mes,
    carga_de_energia = d[["X2"]] %>% stringr::str_replace_all(fixed(","), ".") %>% as.numeric()
  )
}