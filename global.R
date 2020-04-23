## setup ####
setwd("~/Dropbox/nycdsa/projects/proj1_covid19/Rshiny-Covid19")
#library(shiny);library(shinydashboard)
library(tidyverse)

## data import ####
us = read_csv("COVID19_state_20200419.csv")
abbr = read_csv("us-state-abbr.csv")
pps = read_csv("politcal_party_us_mod.csv")
ny = read_csv("./timeSeries/NY.txt")

## wrangle functions ####
clean_colname = function(df) {
  # replace all empty space with period, all names to lower case
  colnames(df) = sapply(colnames(df), str_replace_all, " ", ".")
  colnames(df) = sapply(colnames(df), tolower)
}

## clean colname ####
colnames(us) = clean_colname(us)
colnames(abbr) = clean_colname(abbr)
colnames(pps) = clean_colname(pps)
colnames(ny) = clean_colname(ny)

## colname change ###
colnames(abbr)[2] = "abbr"
colnames(pps)[2] = "pres.elec.2016"

## data wrangle ####
# calculate ratios for covid19 cases
us = us %>% mutate( rate.positive = infected / tested, rate.fatality = deaths / infected)
# abbreviate states, clean up colnames
us = right_join(abbr, us, by = c("us.state" = "state"))
# exclude DC ####
us = us %>% filter(abbr != "DC")

# add political party strength by state
pps = right_join(abbr, pps, by = c( "us.state" = "state"))
pps = pps %>% select(us.state, abbr, `pres.elec.2016`)
us = right_join(pps, us, by = c("us.state", "abbr"))

## pilot plot ####
ggplot(data = us, aes(x = rate.fatality, y = pop.density)) +
  geom_point()

## to do ####
# connect API so get most updated data
# add interactive component: drop down, slide bar, etc.
# collect data: political stand, emergency declare, top industry, num of univ
# plots: vs economic status, vs policatical stand