library(shiny)
library(shinydashboard)


shinyServer(function(input, output) {
  output$temperature = renderPlot({
    ggplot(data = us, aes( y = rate.fatality, x = temperature)) +
      geom_point()
  })
  
  output$gdp = renderPlot({
    ggplot(data = us, aes(y = rate.fatality, x = gdp)) +
      geom_point()
  })
  
  output$pps = renderPlot({
    ggplot(data = us, aes(x = pres.elec.2016, y = rate.fatality)) +
      geom_boxplot()
  })
  
  output$pop.density = renderPlot({
    ggplot(data = us, aes(x = pop.density, y = rate.fatality)) +
      geom_point()
  })
    
  output$hospitals = renderPlot({
      ggplot(data = us, aes(y = rate.fatality, x = hospitals)) +
        geom_point()
    })
})
