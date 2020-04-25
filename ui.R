library(shiny)
library(shinydashboard)

dashboardPage(skin = "green",
  dashboardHeader(title = tags$h2("Covid-19")), 
  # side bar ==============================          
  dashboardSidebar(
   
    sidebarUserPanel(tags$img(src="https://cdn.pixabay.com/photo/2020/03/31/02/20/virus-4986015_960_720.png", 
                              width = "50%", height = "100%")),
    
    sidebarMenu(
      # input: date --------------------
      dateInput("date", label = tags$h4("Select Date"), 
                value = "2020-04-19", min = "2020-03-08"),
      fluidRow(column(3, verbatimTextOutput("date"))),
      
      # menu tabs --------------------
      menuItem("Overview", tabName = "overview", icon = icon("map-signs")), 
      menuItem("Geology", tabName = "geology", icon = icon("globe-americas")),
      menuItem("Politics", tabName = "politics", icon = icon("landmark")),
      menuItem("Economy", tabName = "economy", icon = icon("dollar-sign")),
      menuItem("People", tabName = "people", icon = icon("users")),
      menuItem("Medical", tabName = "medical", icon = icon("hospital-symbol")),
      menuItem("About Me", tabName = "aboutme", icon = icon("smile-wink")),
      
      # input: polical stands --------------------
      radioButtons("party", label = "State Political Stands", 
                   choices = list("Republican" = "A", "Democratic" = "B", "Both" = "C"),
                   selected = "C"),
      fluidRow(column(3, verbatimTextOutput("party"))),
      # input: primary industry sector --------------------
      radioButtons("sector", label = "State Primary Industry Sector",
                   choices = list("Primary & Secondary" = "D", "Tertiary" = "E", "All" = "F"),
                   selected = "F")
    )
  ),
  # Body ==============================
  dashboardBody(
    tabItems(
      # tab: overview -------------------- 
      tabItem(tabName = "overview", 
              #tags$img(src="coronavirus.jpg", height="50%", width="50%"),
              fluidRow(column(6, plotOutput("case")),
                       column(6, plotOutput("ratio"))),
              fluidRow(column(6, h5("Deaths = number of people died of covid-19 infection"),
                              h5("Infected = number of people tested positive of covid-19"),
                              h5("Tested = number of people performed covid-19 test")),
                       column(6, h5("Fatality Ratio = death/tested"),
                              h5("Infected Ratio = infected/tested"),
                              h5("Tested Ratio = tested/population"))),
              h2(align = "center", 'What "Type" of State are you interested in?'),
              h4(align = "center", "Each state has its unique politcal stands and economic structure, choose to view certain category of states by selecting in the left side menu.")
              ),
  
      # tab: geology --------------------
      tabItem(tabName = "geology", plotOutput("temperature")), # add airport, urban
      # tab: politics --------------------
      tabItem(tabName = "politics", plotOutput("pps")), # add govner, senate, house
      # tab: economy --------------------
      tabItem(tabName = "economy", 
              fluidRow(column(6, plotOutput("gdp")),
                       column(6, plotOutput("gini"))),
              #fluidRow(column(6, plotOutput("unemployment")),
              #         column(6, plotOutput("income"))),
              fluidRow(column(6, plotOutput("gdp.filter")),
                       column(6, plotOutput("gini.filter")))

              #fluidRow(tableOutput("gdp.table"))
              ), # add gini, top industry, income, unemploye
      # tab: people --------------------
      tabItem(tabName = "people", plotOutput("pop.density")), # add old people, sex
      # tab: medical --------------------
      tabItem(tabName = "medical", plotOutput("hospitals")), # add pysician, icu bed, pollution, flu, smoking, health spending
      # tab: aboutme --------------------
      tabItem(tabName = "aboutme", 
              HTML('<center><img src="LY.jpg" width="50%"></center>'),
              #tags$img(src="LY.jpg", height="50%", width="50%", align = "center"), 
              tags$h4(tags$b("Lu Yu"), align = "center"),
              tags$h5(tags$em("soslucysos@gmail.com"), align = "center")
              #plotOutput("test"))
      )
  )
)
)

# problems encountered ####
# histogram can only do x = log10(xxx), + coord_trans(x = "log10") doesn't work

# historical versions ####
# checkboxGroupInput("party", label = tags$h4("State Political Stands"),
#                    choices = list("Republican" = 1, "Democratic" = 2), 
#                    selected = c(1)),
#checkboxInput("republican", label = tags$h4("Republican"), value = TRUE),
#checkboxInput("democratic", label = tags$h4("Democratic"), value = TRUE),
#fluidRow(column(3, verbatimTextOutput("republican"))),

#img(src='Image.png',style="width: 50px")

#sidebarSearchForm(textId = "searchText", buttonId = "searchButton",
#                  label = "Search..."),

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