library(shiny)
library(shinydashboard)

#g = ggplot(data = us)

shinyServer(function(input, output) {
  #output$theDay = renderPrint({input$date})
  us.constant = us %>% select(-tested, -infected, -deaths)
  
  usToday = reactive({
    us.ts.today = us.ts %>% filter(date == input$date)
    us.today = left_join(us.constant, us.ts.today, by = c("abbr"))
    us.today
  })
  
  output$test = renderPlot({
    ggplot(data = usToday(), aes(x = abbr, y = deaths)) +
      geom_bar(stat = "identity") +
      coord_flip()
  })
  
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
