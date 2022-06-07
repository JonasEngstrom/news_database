library(rmarkdown)

render('news_report.Rmd',
       params = list(database_file = commandArgs(trailingOnly = TRUE)[1]),
       quiet = TRUE)
