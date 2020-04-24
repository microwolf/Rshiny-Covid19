## setup ####
setwd("~/Dropbox/nycdsa/projects/proj1_covid19/Rshiny-Covid19")
#library(shiny);library(shinydashboard)
library(tidyverse);library(plotly)

## wrangle functions ####
clean_colname = function(df) {
  # replace all empty space with period, all names to lower case
  colnames(df) = sapply(colnames(df), str_replace_all, " ", ".")
  colnames(df) = sapply(colnames(df), tolower)
}

convert_epoch = function(time){
  # convert Epoch seconds to date & time
  date = as.POSIXct(time, origin="1970-01-01",tz="GMT")
  return(date)
}

boil_date = function(df){
  #to be used on 50 states of US time series covid19 case data
  # clean & change colnames
  # convert epoch seconds 
  # only save 1 row of data per each day, choose the later time of that day
  # keep only the essential columns
  colnames(df) = clean_colname(df)
  colnames(df) = str_replace(string = colnames(df), 
                             pattern = "positive", 
                             replacement = "infected")
  df = df %>% mutate(date.time = convert_epoch(seconds_since_epoch)) %>% 
    mutate(date = as.Date(date.time, "%Y-%m-%d", tz = "GMT"))
  df = df %>% group_by(date) %>% 
    arrange(date.time) %>% 
    slice(n()) %>% 
    select(date, tested, infected, deaths)
  return(df)
}



## case import & wrangle ####
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





# case ratios ####
# calculate ratios for covid19 cases
us = us %>% mutate( rate.positive = infected / tested, rate.fatality = deaths / infected)


# exclude DC ####
us = us %>% filter(abbr != "DC")


# party strength ####
# add political party strength by state
pps = pps %>% select(us.state, abbr, `pres.elec.2016`)
us = right_join(pps, us, by = c("us.state", "abbr"))



# convert and clean 50 states time series data
ts_us = lapply(ts_states, boil_date)



## state time series ####

# create a list of names of states
ts_names = paste0("/Users/luyu/Dropbox/nycdsa/projects/proj1_covid19/Rshiny-Covid19/timeSeries/", abbr$abbr, ".txt")
ts_states = lapply(ts_names, read_csv) # load state time series tables
names(ts_states) = abbr$abbr
ts_us = lapply(ts_states, boil_date) # convert & clean state


## TO DO ####
# create a list of state abbr
# connect API so get most updated data
# add interactive component: drop down, slide bar, etc.
# collect data: political stand, emergency declare, top industry, num of univ
# plots: vs economic status, vs policatical stand


## pilot runs ####

#ny = read_csv("./timeSeries/NY.txt")

# add time series data of NY
#ny = ny %>% mutate(date.time = convert_epoch(seconds_since_epoch)) %>% 
#  mutate(date = as.Date(date.time, "%Y-%m-%d", tz = "GMT"))
# only keep 1 row of data per day, use the later time of that day
#ny = ny %>% group_by(date) %>% arrange(date.time) %>% slice(n())
#boil_date(ny)

#test = ny[1,1] %>% as.character() %>% as.numeric()
#as.POSIXct(test,origin="1970-01-01",tz="GMT")
#pilot = head(ny)
#pilot %>% mutate(date = convert_time(seconds_since_epoch)) %>% mutate()
#test %>% convert_time() %>% as.Date("%Y-%m-%d", tz = "GMT")


