library(shiny)
library(shinydashboard)

dashboardPage(
  dashboardHeader(title = "COVID19 Analysis"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Geology", tabName = "geology", icon = icon("globe-americas")),
      menuItem("Politics", tabName = "politics", icon = icon("landmark")),
      menuItem("Economy", tabName = "economy", icon = icon("dollar-sign")),
      menuItem("People", tabName = "people", icon = icon("users")),
      menuItem("Medical", tabName = "medical", icon = icon("capsules"))
    )
  ),
  dashboardBody()
)



# shinyUI(dashboardPage(
#   dashboardHeader(title = "My Dashboard"),
#   dashboardSidebar(
#     
#     sidebarUserPanel("NYC DSA",
#                      image = "https://yt3.ggpht.com/-04uuTMHfDz4/AAAAAAAAAAI/AAAAAAAAAAA/Kjeupp-eNNg/s100-c-k-no-rj-c0xffffff/photo.jpg"),
#     sidebarMenu(
#       menuItem("Map", tabName = "map", icon = icon("map")),
#       menuItem("Data", tabName = "data", icon = icon("database"))
#     )
#   ),
#   dashboardBody(
# 
#   )
# ))