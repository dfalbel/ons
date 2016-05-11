# Parametros

url <- "http://www.ons.org.br/historico/carga_propria_de_demanda_out.aspx"
regioes <- c("SE/CO", "S", "NE", "N", "SIN")
periodos <- c(2000:2016)

# Função que cria nome dos arquivos ------------------------
criar_nome_arq <- function(regiao, periodo){
  regiao <- stringr::str_replace_all(regiao, stringr::fixed("/"), "")
  sprintf("data-raw/%s-%s.html", regiao, periodo)
}