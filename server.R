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
  output$case.tested = renderPlotly({
    target = usTodayFilter()
    g = ggplot(data = target, aes(x=log10(tested))) +
      geom_histogram(position = "dodge", bins = 10, fill = "darkblue") +
      labs(title = "Tested #", x = "Log10 Population", y = "# of States") +
      theme(plot.title = element_text(hjust = 0.5), legend.position="bottom") +
      ylim(0, 15)
    h = ggplotly(g)
  })
  output$case.infected = renderPlotly({
    target = usTodayFilter()
    g = ggplot(data = target, aes(x=log10(infected))) +
      geom_histogram(position = "dodge", bins = 10, fill = "darkgoldenrod") +
      labs(title = "Infected #", x = "Log10 Population", y = "# of States") +
      theme(plot.title = element_text(hjust = 0.5), legend.position="bottom") +
      ylim(0, 15)
    h = ggplotly(g)
  })
  output$case.deaths = renderPlotly({
    target = usTodayFilter()
    g = ggplot(data = target, aes(x=log10(deaths))) +
      geom_histogram(position = "dodge", bins = 10, fill = "darkred") +
      labs(title = "Deaths #", x = "Log10 Population", y = "# of States") +
      theme(plot.title = element_text(hjust = 0.5), legend.position="bottom") +
      ylim(0, 15)
    h = ggplotly(g)
  })
  output$ratio.tested = renderPlotly({
    target = usTodayFilter()
    g = ggplot(data = target, aes(x=tested)) +
      geom_histogram(position = "dodge", bins = 10, fill = "darkblue") +
      labs(title = "Tested %", x = "Ratio", y = "# of States") +
      theme(plot.title = element_text(hjust = 0.5), legend.position="bottom") +
      ylim(0, 20)
    h = ggplotly(g)
  })
  output$ratio.infected = renderPlotly({
    target = usTodayFilter()
    g = ggplot(data = target, aes(x=rate.positive)) +
      geom_histogram(position = "dodge", bins = 10, fill = "darkgoldenrod") +
      labs(title = "Infected %", x = "Ratio", y = "# of States") +
      theme(plot.title = element_text(hjust = 0.5), legend.position="bottom") +
      ylim(0, 20)
    h = ggplotly(g)
  })
  output$ratio.fatality = renderPlotly({
    target = usTodayFilter()
    g = ggplot(data = target, aes(x=rate.fatality)) +
      geom_histogram(position = "dodge", bins = 10, fill = "darkred") +
      labs(title = "Mortality %", x = "Ratio", y = "# of States") +
      theme(plot.title = element_text(hjust = 0.5), legend.position="bottom") +
      ylim(0, 20)
    h = ggplotly(g)
  })
  
  # geology ####
  output$urban = renderPlotly({
    target = usTodayFilter()
    #r = cor(target$urban, target$rate.fatality, method = "pearson")
    g = ggplot(data = target, aes( y = rate.fatality, x = urban, label = state)) +
      geom_point(aes(shape = pres.elec.2016, 
                     color = primary.industry.sector),
                 size = 2) +
      geom_smooth(size=0.5, color = "grey", fill = "wheat", method = "lm") +
      labs(title = "Urbanization ", x = "Urban Percentage of Population", y = "Mortality Rate", shape = "Political Stands", color = "Primary Industry Sector") +
      theme(plot.title = element_text(hjust = 0.5))
    h = ggplotly(g) %>% 
      layout(legend = list(size = 0.4, orientation="h", x = 0,y = -0.5, yanchor="bottom"))
  })
  output$airport = renderPlotly({
    target = usTodayFilter()
    g = ggplot(data = target, aes( y = rate.fatality, x = med_large.airports, label = state)) +
      geom_boxplot(aes(fill = pres.elec.2016), alpha = 0.5) +
      labs(title = "Med-Large Airport Number", x = "Airport Mumber", y = "Mortality Rate", shape = "Political Stands", color = "Primary Industry Sector") +
      theme(plot.title = element_text(hjust = 0.5)) +
      xlim(-1, 10)
    h = ggplotly(g) %>%
      layout(legend = list(size = 0.4, orientation="h", x = 0,y = -0.5, yanchor="bottom"))
  })
  
  # economy ####
  output$gdp = renderPlotly({
    target = usTodayFilter()
    g = ggplot(data = target, aes(y = rate.fatality, x = gdp, label = state)) +
      geom_point(aes(shape = pres.elec.2016, 
                     color = primary.industry.sector),
                 size = 2) +
      geom_smooth(size=0.5, color = "grey", fill = "wheat", method = "lm") +
      labs(title = "GDP Per Capita", x = "GDP ($)", y = "Mortality Rate", shape = "Political Stands", color = "Primary Industry Sector") +
      theme(plot.title = element_text(hjust = 0.5))
    h = ggplotly(g) %>% 
      layout(legend = list(size = 0.4, orientation="h", x = 0,y = -0.5, yanchor="bottom"))
  })
  output$gini = renderPlotly({
    target = usTodayFilter()
    g = ggplot(data = target, aes(y = rate.fatality, x = gini, label = state)) +
      geom_point(aes(shape = pres.elec.2016, 
                     color = primary.industry.sector),
                 size = 2) +
      geom_smooth(size=0.5, color = "grey", fill = "wheat", method = "lm") +
      labs(title = "Gini Index", x = "Gini Index", y = "Mortality Rate", shape = "Political Stands", color = "Primary Industry Sector") +
      theme(plot.title = element_text(hjust = 0.5))
    h = ggplotly(g) %>% 
      layout(legend = list(size = 0.4, orientation="h", x = 0,y = -0.5, yanchor="bottom"))
  })
  output$unemp = renderPlotly({
    target = usTodayFilter()
    g = ggplot(data = target, aes(y = rate.fatality, x = unemployment, label = state)) +
      geom_point(aes(shape = pres.elec.2016,
                     color = primary.industry.sector),
                 size = 2) +
      geom_smooth(size=0.5, color = "grey", fill = "wheat", method = "lm") +
      labs(title = "Unemployment Percentage to Workforce", x = "Unemployment Ratio", y = "Mortality Rate", shape = "Political Stands", color = "Primary Industry Sector") +
      theme(plot.title = element_text(hjust = 0.5))
    h = ggplotly(g) %>% 
      layout(legend = list(size = 0.4, orientation="h", x = 0,y = -0.5, yanchor="bottom"))
  })
  output$income = renderPlotly({
    target = usTodayFilter()
    g = ggplot(data = target, aes(y = rate.fatality, x = income, label = state)) +
      geom_point(aes(shape = pres.elec.2016,
                     color = primary.industry.sector),
                 size = 2) +
      geom_smooth(size=0.5, color = "grey", fill = "wheat", method = "lm") +
      labs(title = "Income Per Capita", x = "Income ($)", y = "Mortality Rate", shape = "Political Stands", color = "Primary Industry Sector") +
      theme(plot.title = element_text(hjust = 0.5))
    h = ggplotly(g) %>% 
      layout(legend = list(size = 0.4, orientation="h", x = 0,y = -0.5, yanchor="bottom"))
  })
  
  # population ####
  output$pop.density = renderPlotly({
    target = usTodayFilter()
    g = ggplot(data = target, aes(y = rate.fatality, x = pop.density, label = state)) +
      geom_point(aes(shape = pres.elec.2016,
                     color = primary.industry.sector),
                 size = 2) +
      geom_smooth(size=0.5, color = "grey", fill = "wheat", method = "lm") +
      labs(title = "Population Density", x = "Population Density (#/m2)", y = "Mortality Rate", shape = "Political Stands", color = "Primary Industry Sector") +
      theme(plot.title = element_text(hjust = 0.5))
    h = ggplotly(g) %>% 
      layout(legend = list(size = 0.4, orientation="h", x = 0,y = -0.5, yanchor="bottom"))
  })
  output$age55 = renderPlotly({
    target = usTodayFilter()
    g = ggplot(data = target, aes(y = rate.fatality, x = age.55more, label = state)) +
      geom_point(aes(shape = pres.elec.2016,
                     color = primary.industry.sector),
                 size = 2) +
      geom_smooth(size=0.5, color = "grey", fill = "wheat", method = "lm") +
      labs(title = "Percentage of People 55+ years old", x = "> 55 yr People Ratio", y = "Mortality Rate", shape = "Political Stands", color = "Primary Industry Sector") +
      theme(plot.title = element_text(hjust = 0.5))
    h = ggplotly(g) %>% 
      layout(legend = list(size = 0.4, orientation="h", x = 0,y = -0.5, yanchor="bottom"))
  })
  
  # healthcare ####
  output$hospital = renderPlotly({
    target = usTodayFilter()  
    g = ggplot(data = target, aes(y = rate.fatality, x = pop.hospitals, label = state)) +
      geom_point(aes(shape = pres.elec.2016,
                     color = primary.industry.sector),
                 size = 2) +
      geom_smooth(size=0.5, color = "grey", fill = "wheat", method = "lm") +
      labs(title = "Number of Hospitals Per Person", x = "Hospital Per Person", y = "Mortality Rate", shape = "Political Stands", color = "Primary Industry Sector") +
      theme(plot.title = element_text(hjust = 0.5))
    h = ggplotly(g) %>% 
      layout(legend = list(size = 0.4, orientation="h", x = 0,y = -0.5, yanchor="bottom"))
    })
  output$icu = renderPlotly({
    target = usTodayFilter()  
    g = ggplot(data = target, aes(y = rate.fatality, x = pop.icu, label = state)) +
      geom_point(aes(shape = pres.elec.2016,
                     color = primary.industry.sector),
                 size = 2) +
      geom_smooth(size=0.5, color = "grey", fill = "wheat", method = "lm") +
      labs(title = "Number of ICU Beds Per Person", x = "ICU Beds Per Person", y = "Mortality Rate", shape = "Political Stands", color = "Primary Industry Sector") +
      theme(plot.title = element_text(hjust = 0.5))
    h = ggplotly(g) %>% 
      layout(legend = list(size = 0.4, orientation="h", x = 0,y = -0.5, yanchor="bottom"))
  })
  output$res.dis = renderPlotly({
    target = usTodayFilter()  
    g = ggplot(data = target, aes(y = rate.fatality, x = respiratory.deaths, label = state)) +
      geom_point(aes(shape = pres.elec.2016,
                     color = primary.industry.sector),
                 size = 2) +
      geom_smooth(size=0.5, color = "grey", fill = "wheat", method = "lm") +
      labs(title = "Chronic Lower Respiratory Disease Death Rate", x = "Respiratory Disease Deaths per 100,000 people", y = "Mortality Rate", shape = "Political Stands", color = "Primary Industry Sector") +
      theme(plot.title = element_text(hjust = 0.5))
    h = ggplotly(g) %>% 
      layout(legend = list(size = 0.4, orientation="h", x = 0,y = -0.5, yanchor="bottom"))
  })
  output$smoke = renderPlotly({
    target = usTodayFilter()  
    g = ggplot(data = target, aes(y = rate.fatality, x = smoking.rate, label = state)) +
      geom_point(aes(shape = pres.elec.2016,
                     color = primary.industry.sector),
                 size = 2) +
      geom_smooth(size=0.5, color = "grey", fill = "wheat", method = "lm") +
      labs(title = "Percentage of Smokers", x = "smoking rate", y = "Mortality Rate", shape = "Political Stands", color = "Primary Industry Sector") +
      theme(plot.title = element_text(hjust = 0.5))
    h = ggplotly(g) %>% 
      layout(legend = list(size = 0.4, orientation="h", x = 0,y = -0.5, yanchor="bottom"))
  })

})
  
  


# pilot test ####
#test.day = as.Date("2020-03-16")
#test.ts.today = us.ts %>% filter(date == test.day)
#test.gather = gather(test.ts.today, content, number, 4:6)
#test.gather = gather(test.ts.today, content, number, tested, infected, deaths)

#test.today.number = left_join(us.constant, test.ts.today, by = c("abbr"))
# test.today = test.today.number %>%
#   mutate(rate.tested = tested / population,
#          rate.positive = infected / tested,
#          rate.fatality = deaths / infected)
# #new = test.today %>% filter(pres.elec.2016 == "Republican")
# test.today.gather = test.today %>% 
#   gather(number.content, number, tested, infected, deaths) %>% 
#   gather(ratio.content, ratio, rate.tested, rate.positive, rate.fatality)
#   
# ggplot(data = test.today.gather, aes(x=number)) +
#   geom_histogram(aes(fill = number.content), position = "dodge", bins = 10) +
#   #geom_density(aes(fill = number.content, color = number.content), alpha = 0.5) +
#   labs(title = "Counts of Covid-19 Cases", x = "Log Number of People", y = "Count") +
#   facet_grid(~number.content) +
#   theme(legend.position="bottom") #+
#   #coord_trans(x = "log10")
# historical code ####
# output$case = renderPlot({
#   target = usTodayGatherFilter()
#   g = ggplot(data = target, aes(x=log10(number))) +
#     geom_histogram(aes(fill = number.content), position = "dodge", bins = 10) +
#     #geom_density(aes(fill = number.content, color = number.content), alpha = 0.5) +
#     labs(title = "Counts of Covid-19 Cases", x = "Log of Number of People", y = "Count") +
#     theme(plot.title = element_text(hjust = 0.5), legend.position="bottom") +
#     ylim(0, 65) +
#     facet_grid(~number.content)
#   g
# })
# output$ratio = renderPlot({
#   target = usTodayGatherFilter() %>% group_by(abbr, ratio) 
#   g = ggplot(data = target, aes(x = ratio)) +
#     geom_histogram(aes(fill = ratio.content), position = "dodge", bins = 5) +
#     #geom_density(aes(fill = ratio.content, color = number.content), alpha = 0.5) +
#     labs(title = "Ratios of Covid-19 Cases", x = "Ratio", y = "Count") +
#     theme(plot.title = element_text(hjust = 0.5), legend.position="bottom") + 
#     ylim(0, 150) +
#     facet_grid(~ratio.content)
#   g
# })
# output$airport = renderPlotly({
#   target = usTodayFilter()
#   g = ggplot(data = target, aes( y = rate.fatality, x = med_large.airports, label = state)) +
#     geom_point(aes(shape = pres.elec.2016,
#                    color = primary.industry.sector),
#                size = 3) +
#     geom_smooth(size=0.5, color = "grey", fill = "wheat", method = "lm") +
#     labs(title = "Med-Large Airport Number", x = "airport number", y = "Mortality Rate", shape = "Political Stands", color = "Primary Industry Sector") +
#     theme(plot.title = element_text(hjust = 0.5))
#   h = ggplotly(g) %>%
#     layout(legend = list(size = 0.4, orientation="h", x = 0,y = -0.5, yanchor="bottom"))
# })
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