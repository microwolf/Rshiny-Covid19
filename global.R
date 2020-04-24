## setup ####
setwd("~/Dropbox/nycdsa/projects/proj1_covid19/Rshiny-Covid19")
#library(shiny);library(shinydashboard)
library(tidyverse);library(plotly)

## wrangle functions ####
read_name = function(txt){
  # read csv file and create a new column indicate which state
  file.name = paste0("/Users/luyu/Dropbox/nycdsa/projects/proj1_covid19/Rshiny-Covid19/timeSeries/", txt, ".txt")
  df = read_csv(file.name)
  df$abbr = txt
  return(df)
}
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
  df = rename(df, infected = positive)
  
  df = df %>% mutate(date.time = convert_epoch(seconds_since_epoch),
                     date = as.Date(date.time, "%Y-%m-%d", tz = "GMT"),
                     index = format(date, "%Y-%m-%d"))
  df = df %>% group_by(date) %>% 
    arrange(date.time) %>% 
    slice(n()) %>% 
    select(abbr, index, date, tested, infected, deaths)
  return(df)
}

## case import & wrangle ####
abbr = read_csv("state-abbr.csv")
colnames(abbr) = clean_colname(abbr)
colnames(abbr)[2] = "abbr"

us = read_csv("us-covid19-20200419.csv")
colnames(us) = clean_colname(us)
# abbreviate us states
us = right_join(abbr, us, by = c("us.state" = "state"))

pps = read_csv("state-party-mod.csv")
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


## state time series ####

# create a list of names of states
ts.df.raw = lapply(abbr$abbr, read_name)
names(ts.df.raw) = abbr$abbr
# convert & clean state cases
ts.df = lapply(ts.df.raw, boil_date) 
# combine to 1 big tibble
us.ts = do.call(args = ts.df, what = rbind)

# choose a date and create a date-specific us table
theDay = "2020-04-17"
theDay = as.Date(theDay)
us.ts %>% filter(date == theDay)

getDay = function(day){
  
}
## TO DO ####
# add interactive: select group, date range bar
# plots: vs economic status, vs policatical stand
# plots: mag

## extras ####
# connect API so get most updated data
# collect data: political stand, emergency declare, top industry, num of univ

## Done ####
# clean us 50 state covid 19 & features data
# plot a correlation per each tab
# read in time series
# allow only certain dates
# add interactive: select date

## pilot runs ####
#test = ny[1,1] %>% as.character() %>% as.numeric()
#as.POSIXct(test,origin="1970-01-01",tz="GMT")
#pilot = head(ny)
#pilot %>% mutate(date = convert_time(seconds_since_epoch)) %>% mutate()
#test %>% convert_time() %>% as.Date("%Y-%m-%d", tz = "GMT")

## old codes ####
#ny = read_csv("./timeSeries/NY.txt")

#ny = ny %>% mutate(date.time = convert_epoch(seconds_since_epoch)) %>% 
#  mutate(date = as.Date(date.time, "%Y-%m-%d", tz = "GMT"))
# only keep 1 row of data per day, use the later time of that day
#ny = ny %>% group_by(date) %>% arrange(date.time) %>% slice(n())
#boil_date(ny)

#ts_names = paste0("/Users/luyu/Dropbox/nycdsa/projects/proj1_covid19/Rshiny-Covid19/timeSeries/", abbr$abbr, ".txt")
#ts_states = lapply(ts_names, read_csv) # load state time series tables
