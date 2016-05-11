# Parametros

url <- "http://www.ons.org.br/historico/carga_propria_de_demanda_out.aspx"
regioes <- c("SE/CO", "S", "NE", "N", "SIN")
periodos <- c(2000:2016)

# Função que cria nome dos arquivos ------------------------
criar_nome_arq <- function(regiao, periodo){
  regiao <- stringr::str_replace_all(regiao, stringr::fixed("/"), "")
  sprintf("data-raw/%s-%s.html", regiao, periodo)
}

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