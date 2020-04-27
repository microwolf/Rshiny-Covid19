## setup ####
#setwd("~/Dropbox/nycdsa/projects/proj1_covid19/Rshiny-Covid19")
#library(shiny);library(shinydashboard)
library(tidyverse);library(plotly);library(googleVis);library(ggpubr)


## wrangle functions ####
api = "http://coronavirusapi.com/getTimeSeries/"
read_name = function(txt){
  # read csv file and create a new column indicate which state
  #file.name = paste0("timeSeries/", txt, ".txt")
  file.url = paste0(api, txt)
  #df = read_csv(file.name)
  df = read_csv(url(file.url))
  df$abbr = txt
  return(df)
}
clean_colname = function(df) {
  # replace all empty space with period, all names to lower case
  colnames(df) = sapply(colnames(df), str_replace_all, " ", ".")
  colnames(df) = sapply(colnames(df), str_replace_all, "-", "_")
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
# state abbreviation
#file.abbr = paste0(path, )
abbr = read_csv("state-abbr.csv")
colnames(abbr) = clean_colname(abbr)
colnames(abbr) = c("state", "abbr")
# state covid-19 cases
#file.us = paste0(path, "us-covid19-20200419.csv")
us = read_csv("us-covid19-20200419.csv")
colnames(us) = clean_colname(us)
us = right_join(abbr, us, by ="state")
# state politcal stands
#file.pps = paste0(path, "state-party-mod.csv")
pps = read_csv("state-party-mod.csv")
colnames(pps) = clean_colname(pps)
colnames(pps)[2] = "pres.elec.2016"
pps = right_join(abbr, pps, by = "state")
# state primary industry
#file.ind = paste0(path, "state-industry.csv")
ind.raw = read_csv("state-industry.csv")
colnames(ind.raw) = clean_colname(ind.raw)
ind = right_join(abbr, ind.raw, by = "state") %>% select(abbr, primary.industry.category)
ind = ind %>% mutate(primary.industry.sector = ifelse(primary.industry.category %in% c("energy", "farming", "chemistry"), "Primary & Secondary", "Tertiary"))
us = right_join(ind, us, by = "abbr")

# case ratios ####
us = us %>% mutate( pop.hospitals = hospitals / population,
                    pop.icu = icu.beds / population, 
                    pop.physicians = physicians / population)

# exclude DC ####
us = us %>% filter(abbr != "DC")

# party strength ####
# add political party strength by state
pps = pps %>% select(state, abbr, `pres.elec.2016`)
us = right_join(pps, us, by = c("state", "abbr"))


# state time series ####
# create a list of names of states
ts.df.raw = lapply(abbr$abbr, read_name)
names(ts.df.raw) = abbr$abbr
# convert & clean state cases
ts.df = lapply(ts.df.raw, boil_date) 
# combine to 1 big tibble
us.ts = do.call(args = ts.df, what = rbind)



## local test ####
#theDay = "2020-04-17"
#theDay = as.Date(theDay)
#us.ts %>% filter(date == theDay)

## TO DO ####
# add emergency declare date
# hospital per population
# age 55+: + cannot be replaced by str_replace
# collect temperature

## extras ####
# plots: map
# collect data: num of univ
# add interactive:  date range bar

## Done ####
# collect polictical stand
# clean us 50 state covid 19 & features data
# plot a correlation per each tab
# read in time series
# allow only certain dates
# add interactive: select date
# add data: top industry, time zone
# add interactive: select group for political stands
# plots: vs economic status, vs policatical stand
# hover points to show data
# airpot plot: change to bar graph
# connect API so get most updated data


## historical codes ####
#ts_names = paste0("/Users/luyu/Dropbox/nycdsa/projects/proj1_covid19/Rshiny-Covid19/timeSeries/", abbr$abbr, ".txt")
#ts_states = lapply(ts_names, read_csv) # load state time series tables
#path = "~/Dropbox/nycdsa/projects/proj1_covid19/Rshiny-Covid19/"

