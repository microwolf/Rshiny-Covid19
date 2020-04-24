library(shiny)
library(shinydashboard)

#g = ggplot(data = us)

shinyServer(function(input, output) {
  
  us.constant = us %>% select(-tested, -infected, -deaths)
  
  ## dynamic data based on inpu ####
  # adjust data based on date selected by user
  usToday = reactive({
    us.ts.today = us.ts %>% filter(date == input$date)
    us.today.number = left_join(us.constant, us.ts.today, by = c("abbr")) #%>% 
      #filter(pres.elec.2016 == input$party)
    us.today = us.today.number %>% 
      mutate(rate.tested = tested / population,
             rate.positive = infected / tested,
             rate.fatality = deaths / infected) #%>% 
      #filter(pres.elec.2016 == input$party)
    return(us.today)
  })
  
  usTodayNR = reactive({
    us.today.nr = usToday() %>% 
      gather(number.content, number, tested, infected, deaths) %>% 
      gather(ratio.content, ratio, rate.tested, rate.positive, rate.fatality)
  })

  # overview ####
  output$case = renderPlot({
    target = usTodayNR()
    ggplot(data = target, aes(x=log10(number))) +
      geom_histogram(aes(fill = number.content), position = "dodge", bins = 10) +
      labs(title = "Counts of Covid-19 Cases", x = "Log Number of People", y = "Count") #+
      #coord_trans(x = "log10")
  })
  output$ratio = renderPlot({
    target = usTodayNR()
    ggplot(data = target, aes(x = ratio)) +
      geom_histogram(aes(fill = ratio.content), position = "dodge") +
      labs(title = "Ratios of Covid-19 Cases", x = "Ratio", y = "Count")
  })
  
  # geology ####
  output$temperature = renderPlot({
    target = usToday()
    ggplot(data = target, aes( y = rate.fatality, x = temperature)) +
      geom_point()
  })
  
  
  # economy ####
  output$gdp = renderPlot({
    target = usToday()
    ggplot(data = target, aes(y = rate.fatality, x = gdp)) +
      geom_point()
  })
  
  # politics ####
  output$pps = renderPlot({
    ggplot(data = us, aes(x = pres.elec.2016, y = rate.fatality)) +
      geom_boxplot()
  })
  
  
  # people ####
  output$pop.density = renderPlot({
    ggplot(data = us, aes(x = pop.density, y = rate.fatality)) +
      geom_point()
  })
  
  
  # healthcare ####
  output$hospitals = renderPlot({
      ggplot(data = us, aes(y = rate.fatality, x = hospitals)) +
        geom_point()
    })
  
    # test ####
  # output$test = renderPlot({
  #   target = usTodayAll()
  #   ggplot(data = target, aes(x = abbr, y = deaths)) +
  #     geom_bar(stat = "identity") +
  #     coord_flip()
  # })
})

# pilot test ####
test.day = as.Date("2020-03-16")
test.ts.today = us.ts %>% filter(date == test.day)
test.gather = gather(test.ts.today, content, number, 4:6)
test.gather = gather(test.ts.today, content, number, tested, infected, deaths)


# unused code ####
#output$theDay = renderPrint({input$date})

  # usTodayAll = reactive({
  #   us.ts.today = us.ts %>% filter(date == input$date)
  #   us.today = left_join(us.constant, us.ts.today, by = c("abbr")) %>% 
  #     filter(pres.elec.2016 == input$party)
  #   return(us.today)
  # })
 # usTodayCase = reactive({
 #    us.ts.today = us.ts %>% filter(date == input$date) #%>% 
 #      #filter(pres.elec.2016 == input$party)
 #    us.case.today = gather(us.ts.today, number.content, number, 4:6) 
 #    return(us.case.today)
 #  })
