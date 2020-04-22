## setup ####
setwd("~/Dropbox/nycdsa/projects/proj1_covid19/Rshiny-Covid19")
library(shiny);library(shinydashboard)
library(tidyverse)

ui = dashboardPage(
  dashboardHeader("COVID19 Analysis"),
  dashboardSidebar(
  ),
  dashboardBody()
)

server = function(input, output){
  
}

shinyApp(ui, server)