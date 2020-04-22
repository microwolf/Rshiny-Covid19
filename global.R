## setup ####
setwd("~/Dropbox/nycdsa/projects/proj1_covid19")
library(tidyverse);library(shiny)

## data import ####
covid19.us = read_csv("./data/COVID19_state_20200419.csv")

## data wrangle ####
covid19.us = covid19.us %>% mutate( Rate.positive = Infected / Tested, Rate.fatality = Deaths / Infected)



## to do ####
# connect API so get most updated data
# add interactive component: drop down, slide bar, etc.
# collect data: political stand, emergency declare, top industry, num of univ
# plots: vs economic status, vs policatical stand