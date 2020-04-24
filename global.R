## setup ####
setwd("~/Dropbox/nycdsa/projects/proj1_covid19/Rshiny-Covid19")
#library(shiny);library(shinydashboard)
library(tidyverse)

## wrangle functions ####
clean_colname = function(df) {
  # replace all empty space with period, all names to lower case
  colnames(df) = sapply(colnames(df), str_replace_all, " ", ".")
  colnames(df) = sapply(colnames(df), tolower)
}

convert_epoch = function(time){
  date = as.POSIXct(time, origin="1970-01-01",tz="GMT")
  return(date)
}

## data import & wrangle ####
abbr = read_csv("us-state-abbr.csv")
colnames(abbr) = clean_colname(abbr)
colnames(abbr)[2] = "abbr"

us = read_csv("COVID19_state_20200419.csv")
colnames(us) = clean_colname(us)
# abbreviate us states
us = right_join(abbr, us, by = c("us.state" = "state"))

pps = read_csv("politcal_party_us_mod.csv")
colnames(pps) = clean_colname(pps)
colnames(pps)[2] = "pres.elec.2016"
# abbreviate pps stats
pps = right_join(abbr, pps, by = c( "us.state" = "state"))

ny = read_csv("./timeSeries/NY.txt")
colnames(ny) = clean_colname(ny)

## data wrangle ####
# calculate ratios for covid19 cases
us = us %>% mutate( rate.positive = infected / tested, rate.fatality = deaths / infected)
# exclude DC ####
us = us %>% filter(abbr != "DC")


# add political party strength by state
pps = pps %>% select(us.state, abbr, `pres.elec.2016`)
us = right_join(pps, us, by = c("us.state", "abbr"))

# add time series data of NY
ny = ny %>% mutate(date.time = convert_epoch(seconds_since_epoch)) %>% 
  mutate(date = as.Date(date.time, "%Y-%m-%d", tz = "GMT"))
# only keep 1 row of data per day, use the later time of that day
ny = ny %>% group_by(date) %>% arrange(date.time) %>% slice(n())

## pilot runs
test = ny[1,1] %>% as.character() %>% as.numeric()
as.POSIXct(test,origin="1970-01-01",tz="GMT")
pilot = head(ny)
pilot %>% mutate(date = convert_time(seconds_since_epoch)) %>% mutate()
test %>% convert_time() %>% as.Date("%Y-%m-%d", tz = "GMT")


## to do ####
# connect API so get most updated data
# add interactive component: drop down, slide bar, etc.
# collect data: political stand, emergency declare, top industry, num of univ
# plots: vs economic status, vs policatical stand