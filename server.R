library(shiny)
library(shinydashboard)

#g = ggplot(data = us)

shinyServer(function(input, output) {

  ## dynamic data based on inpu ####
  # adjust data based on date selected by user
  usTodayAll = reactive({
    us.constant = us %>% select(-tested, -infected, -deaths)
    us.ts.today = us.ts %>% filter(date == input$date) # filter by date
    us.today.number = left_join(us.constant, us.ts.today, by = c("abbr")) # combine with contant part of table
    # calculate ration & filter by user selection
    us.today.all = us.today.number %>% 
      mutate(rate.tested = tested / population,
             rate.positive = infected / tested,
             rate.fatality = deaths / infected) 
    return(us.today.all)
  }) 
  usTodayFilter = reactive({
    # set politcal stands filter
    ps = switch (input$party, 
                 "A" = "Republican", 
                 "B" = "Democratic", 
                 "C" = c("Republican","Democratic"))
    sc = switch(input$sector, 
                "D" = "Primary & Secondary", 
                "E" = "Tertiary", 
                "F" = c("Primary & Secondary", "Tertiary"))
    # adjust data based on political stand & industry sector selected by user
    us.today.filter = usTodayAll() %>% 
      filter(pres.elec.2016 %in% ps) %>%  
      filter(primary.industry.sector %in% sc)
    return(us.today.filter)
  })
  usTodayGatherAll = reactive({
    us.today.gather.all = usTodayAll() %>% 
      gather(number.content, number, tested, infected, deaths) %>% 
      gather(ratio.content, ratio, rate.tested, rate.positive, rate.fatality)
    return(us.today.gather.all)
  }) 
  usTodayGatherFilter = reactive({
    us.today.gather.filter = usTodayFilter() %>% 
      gather(number.content, number, tested, infected, deaths) %>% 
      gather(ratio.content, ratio, rate.tested, rate.positive, rate.fatality)
    return(us.today.gather.filter)
  })

  # overview ####
  output$case = renderPlot({
    target = usTodayGatherFilter()
    ggplot(data = target, aes(x=log10(number))) +
      geom_histogram(aes(fill = number.content), position = "dodge", bins = 10) +
      #geom_density(aes(fill = number.content, color = number.content), alpha = 0.5) +
      labs(title = "Counts of Covid-19 Cases", x = "Log of Number of People", y = "Count") +
      theme(legend.position="bottom") +
      facet_grid(~number.content)
  })
  output$ratio = renderPlot({
    target = usTodayGatherFilter()
    ggplot(data = target, aes(x = ratio)) +
      geom_histogram(aes(fill = ratio.content), position = "dodge", bins = 5) +
      facet_grid(~ratio.content) +
      #geom_density(aes(fill = ratio.content, color = number.content), alpha = 0.5) +
      labs(title = "Ratios of Covid-19 Cases", x = "Ratio", y = "Count") +
      theme(legend.position="bottom") + 
      facet_grid(~ratio.content)
  })
  
  # geology ####
  output$temperature = renderPlot({
    target = usTodayAll()
    ggplot(data = target, aes( y = rate.fatality, x = temperature)) +
      geom_point()
  })
  
  # economy ####

  output$gdp.filter = renderPlotly({
    target = usTodayFilter()
    g = ggplot(data = target, aes(y = rate.fatality, x = gdp, label = abbr)) +
      geom_point(aes(shape = pres.elec.2016, 
                     color = primary.industry.sector),
                 size = 3) +
      geom_smooth() +
      labs(title = "GDP", x = "GDP", y = "Fatality Ratio", shape = "Political Stands", color = "Primary Industry Sector") +
      theme(plot.title = element_text(hjust = 0.5))
    h = ggplotly(g) %>% 
      layout(legend = list(size = 0.4, orientation="h", x = 0,y = -0.5, yanchor="bottom"))
  })
  output$gini.filter = renderPlotly({
    target = usTodayFilter()
    g = ggplot(data = target, aes(y = rate.fatality, x = gini, label = abbr)) +
      geom_point(aes(shape = pres.elec.2016, 
                     color = primary.industry.sector),
                 size = 3) +
      labs(title = "Gini Index", x = "Gini Index", y = "Fatality Ratio", shape = "Political Stands", color = "Primary Industry Sector") +
      theme(plot.title = element_text(hjust = 0.5))
    h = ggplotly(g) %>% 
      layout(legend = list(size = 0.4, orientation="h", x = 0,y = -0.5, yanchor="bottom"))
  })
  output$unemp.filter = renderPlotly({
    target = usTodayFilter()
    g = ggplot(data = target, aes(y = rate.fatality, x = unemployment)) +
      geom_point(aes(shape = pres.elec.2016,
                     color = primary.industry.sector),
                 size = 3) +
      labs(title = "Unemployment Ratio", x = "Unemployment Ratio", y = "Fatality Ratio", shape = "Political Stands", color = "Primary Industry Sector") +
      theme(plot.title = element_text(hjust = 0.5))
    h = ggplotly(g) %>% 
      layout(legend = list(size = 0.4, orientation="h", x = 0,y = -0.5, yanchor="bottom"))
  })
  output$income.filter = renderPlotly({
    target = usTodayFilter()
    g = ggplot(data = target, aes(y = rate.fatality, x = income)) +
      geom_point(aes(shape = pres.elec.2016,
                     color = primary.industry.sector),
                 size = 3) +
      labs(title = "Average Income", x = "Average Income", y = "Fatality Ratio", shape = "Political Stands", color = "Primary Industry Sector") +
      theme(plot.title = element_text(hjust = 0.5))
    h = ggplotly(g) %>% 
      layout(legend = list(size = 0.4, orientation="h", x = 0,y = -0.5, yanchor="bottom"))
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
#test.gather = gather(test.ts.today, content, number, 4:6)
#test.gather = gather(test.ts.today, content, number, tested, infected, deaths)

test.today.number = left_join(us.constant, test.ts.today, by = c("abbr"))
test.today = test.today.number %>%
  mutate(rate.tested = tested / population,
         rate.positive = infected / tested,
         rate.fatality = deaths / infected)
#new = test.today %>% filter(pres.elec.2016 == "Republican")
test.today.gather = test.today %>% 
  gather(number.content, number, tested, infected, deaths) %>% 
  gather(ratio.content, ratio, rate.tested, rate.positive, rate.fatality)
  
ggplot(data = test.today.gather, aes(x=number)) +
  geom_histogram(aes(fill = number.content), position = "dodge", bins = 10) +
  #geom_density(aes(fill = number.content, color = number.content), alpha = 0.5) +
  labs(title = "Counts of Covid-19 Cases", x = "Log Number of People", y = "Count") +
  facet_grid(~number.content) +
  theme(legend.position="bottom") #+
  #coord_trans(x = "log10")

# historical code ####
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
# if (input$republican) {
#   ps = "Republican"
# } else {ps = "Democratic"}

# print out table
# output$gdp.table = renderTable({
#   target = usTodayGatherFilter()
# })

# output$gdp = renderPlot({
#   target = usTodayAll()
#   ggplot(data = target, aes(y = rate.fatality, x = gdp)) +
#     geom_point(aes(shape = pres.elec.2016, 
#                    color = primary.industry.sector), 
#                size = 3) +
#     theme(legend.position= "bottom")
# })
# output$gini = renderPlot({
#   target = usTodayAll()
#   ggplot(data = target, aes(y = rate.fatality, x = gini)) +
#     geom_point(aes(shape = pres.elec.2016,
#                    color = primary.industry.sector),
#                size = 3) +
#     theme(legend.position="bottom")
# })