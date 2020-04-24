library(shiny)
library(shinydashboard)

dashboardPage(skin = "green",
  dashboardHeader(title = tags$h2("Covid-19")), 
                  
  dashboardSidebar(
    #sidebarUserPanel(tags$h3("Sections")),
    sidebarUserPanel(tags$img(src="https://cdn.pixabay.com/photo/2020/03/31/02/20/virus-4986015_960_720.png", width = "50%", height = "100%")),
    #sidebarSearchForm(textId = "searchText", buttonId = "searchButton",
    #                  label = "Search..."),
    sidebarMenu(
      # date ####
      dateInput("date", label = tags$h4("Select Date"), 
                value = "2020-04-19", min = "2020-03-08"),
      fluidRow(column(3, verbatimTextOutput("date"))),
      
      # menu tabs ####
      menuItem("Overview", tabName = "overview", icon = icon("map-signs")), 
      menuItem("Geology", tabName = "geology", icon = icon("globe-americas")),
      menuItem("Politics", tabName = "politics", icon = icon("landmark")),
      menuItem("Economy", tabName = "economy", icon = icon("dollar-sign")),
      menuItem("People", tabName = "people", icon = icon("users")),
      menuItem("Medical", tabName = "medical", icon = icon("hospital-symbol")),
      menuItem("About Me", tabName = "aboutme", icon = icon("smile-wink")),
      
      # polical stand ####
      checkboxGroupInput("party", label = tags$h4("State Political Stands"),
                         choices = list("Republican" = 1, "Democratic" = 2), 
                         selected = c(1,2)),
      fluidRow(column(3, verbatimTextOutput("party")))      
    )
  ),
  
  dashboardBody(
    tabItems(
      #img(src='Image.png',style="width: 50px")
      tabItem(tabName = "overview", 
              #tags$img(src="coronavirus.jpg", height="50%", width="50%"),
              fluidRow(column(6, plotOutput("case")),
                       column(6, plotOutput("ratio"))),
              fluidRow(column(6, ),
                       column(6, h4("fatality ratio = death/tested"),
                              h4("infected ratio = infected/tested"),
                              h4("tested ratio = tested/population")))),
      
      tabItem(tabName = "geology", plotOutput("temperature")), # add airport, urban
      tabItem(tabName = "politics", plotOutput("pps")), # add govner, senate, house
      tabItem(tabName = "economy", plotOutput("gdp")), # add gini, top industry, income, unemploye
      tabItem(tabName = "people", plotOutput("pop.density")), # add old people, sex
      tabItem(tabName = "medical", plotOutput("hospitals")), # add pysician, icu bed, pollution, flu, smoking, health spending
      tabItem(tabName = "aboutme", 
              tags$img(src="LY.jpg",height="100%", width="100%"), tags$h4("Lu Yu"),
              plotOutput("test"))
      )
  )
)

# problems encountered ####
# histogram can only do x = log10(xxx), + coord_trans(x = "log10") doesn't work


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