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
newCEOs <- cbind(newdf[,2], newdf[,8])
newCEOs <- as.data.frame(newCEOs)
f500 <- newCEOs %>%
  rename('company' = V1, 'ceo' = V2)


# This is going to be for past data (global F500)
oldCEOs <- read.csv("C:\\Users\\AD12991\\OneDrive - Lumen\\Desktop\\f500.csv")

ceosInfo <- read_excel("C:\\Users\\AD12991\\OneDrive - Lumen\\Desktop\\ceos info.xlsx", col_names = c("ceo", "school", "program"))

f500[,2][f500$ceo == 'Haviv Ilan'] <- NA
f500[,2][f500$ceo == 'Kevin Murphy'] <- NA

# right here we need to add school to ceo list
f500 <- f500 %>%
  filter(ceo != 'Haviv Ilan' | ceo != 'Kevin Murphy') %>%
  left_join(ceosInfo,by=join_by(ceo == ceo))

# no duplicates above

globalF500 <- oldCEOs

globalF500 <- globalF500 %>%
  rename(school = Most.Recent.School...Alma.Mater) %>%
  mutate(clean_school = sub(" \\(.*", "", school, useBytes = TRUE))

f500 <- f500 %>%
  anti_join(globalF500, by = join_by(company == company))


# glue together, remember we don't have very many features for the non gloabl F500
combined_companies <- f500 %>%
  full_join(globalF500, by = join_by(company == company, ceo == ceo))


# you can see that there are no duplicates
combined_companies %>%
  dplyr::group_by(company) %>%
  summarise(count = n()) %>%
  filter(count > 1)

# since no duplicates we can proceed

nodes <- combined_companies

nodes <- nodes %>%
  filter(!is.na(ceo))

nodes <- nodes %>%
  mutate(school = if_else(!is.na(school.x), school.x, clean_school)) %>%
  select(company, ceo, school, revenue_change, profit_change, employees)

