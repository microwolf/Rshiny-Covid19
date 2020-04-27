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
      menuItem("Economy", tabName = "economy", icon = icon("dollar-sign")),
      menuItem("Population", tabName = "population", icon = icon("users")),
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
              fluidRow(column(6, 
                              fluidRow(column(4, plotlyOutput("case.tested")),
                                       column(4, plotlyOutput("case.infected")),
                                       column(4, plotlyOutput("case.deaths")))),
                       column(6, fluidRow(column(4, plotlyOutput("ratio.tested")),
                                          column(4,plotlyOutput("ratio.infected")),
                                          column(4,plotlyOutput("ratio.fatality"))))),
              fluidRow(column(6, h5(align = "left", "Deaths = number of people died of covid-19 infection"),
                              h5(align = "left", "Infected = number of people tested positive of covid-19"),
                              h5(align = "left", "Tested = number of people performed covid-19 test")),
                       column(6, h5(align = "right", "Fatality Ratio = death/tested"),
                              h5(align = "right", "Infected Ratio = infected/tested"),
                              h5(align = "right", "Tested Ratio = tested/population"))),
              h2(align = "center", 'What "Type" of State are you interested in?'),
              h4(align = "center", "Each state has its unique politcal stands and economic structure"), 
              h4(align = "center", "Choose to view a certain type of states by selecting in the left side menu.")
              ),
  
      # tab: geology --------------------
      tabItem(tabName = "geology", 
              fluidRow(column(6, plotlyOutput("urban")),
                       column(6, plotlyOutput("airport"))) 
              ),
      # tab: economy --------------------
      tabItem(tabName = "economy", 
              fluidRow(column(6, plotlyOutput("gdp")),
                       column(6, plotlyOutput("gini"))),
              fluidRow(column(6, plotlyOutput("unemp")),
                       column(6, plotlyOutput("income")))
              #fluidRow(tableOutput("gdp.table"))
              ), # add gini, top industry, income, unemploye
      # tab: population --------------------
      tabItem(tabName = "population", 
              fluidRow(column(6, plotlyOutput("pop.density")),
                       column(6, plotlyOutput("age55")))
              ), # add old people, sex
      # tab: medical --------------------
      tabItem(tabName = "medical", 
              fluidRow(column(6, plotlyOutput("hospital")),
                       column(6, plotlyOutput("icu"))),
              fluidRow(column(6, plotlyOutput("res.dis")),
                       column(6, plotlyOutput("smoke")))
              ), # add pysician, icu bed, pollution, flu, smoking, health spending
      # tab: aboutme --------------------
      tabItem(tabName = "aboutme", 
              HTML('<center><img src="LY.jpg" width="50%"></center>'),
              #tags$img(src="LY.jpg", height="50%", width="50%", align = "center"), 
              tags$h4(tags$b("Lu Yu"), align = "center"),
              tags$h5(tags$a(href = "https://www.linkedin.com/in/lu-yu-6ab86238/", "Linkedin"), align = "center"),
              tags$h5(tags$em("soslucysos@gmail.com"), align = "center")
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

# tab: politics --------------------
#tabItem(tabName = "politics", plotOutput("pps")), # add govner, senate, house


#sidebarSearchForm(textId = "searchText", buttonId = "searchButton",
#                  label = "Search..."),

#menuItem("Politics", tabName = "politics", icon = icon("landmark")),
#   )
# ))