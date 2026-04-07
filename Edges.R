library(dplyr)
library(tidyverse)
library(readr)
library(tidyr)

# this is for current data (non-global 500)
site <- rvest::read_html("https://www.50pros.com/fortune500")
newtable <- site %>%
  rvest::html_node("table") %>%
  rvest::html_table()
newdf <- as.data.frame(newtable)
newCEOs <- cbind(newdf[,2], newdf[,7])
newCEOs <- as.data.frame(newCEOs)
f500 <- newCEOs %>%
  rename('company' = V1, 'ceo' = V2)


# This is going to be for past data (global F500)
oldCEOs <- read.csv("C:\\Users\\AD12991\\OneDrive - Lumen\\Desktop\\f500.csv")


globalF500 <- oldCEOs


# glue together, remember we don't have very many features for the non gloabl F500
edges <- f500 %>%
  full_join(globalF500, by = join_by(ceo)) %>%
  filter(!is.na(company.y), !is.na(company.x))


# I guess ceos aren't a good edge for f500s, but maybe schools are a good edge