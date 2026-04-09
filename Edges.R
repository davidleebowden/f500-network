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

#import excel sheet with school names for each ceo

ceosInfo <- read_excel("C:\\Users\\AD12991\\OneDrive - Lumen\\Desktop\\ceos info.xlsx", col_names = c("ceo", "school", "program"))

f500[,2][f500$ceo == 'Haviv Ilan'] <- NA
f500[,2][f500$ceo == 'Kevin Murphy'] <- NA

# right here we need to add school to ceo list
f500 <- f500 %>%
  filter(ceo != 'Haviv Ilan' | ceo != 'Kevin Murphy') %>%
  inner_join(ceosInfo,by=join_by(ceo))


f500 %>%
  left_join(ceosInfo,by=join_by(ceo)) %>%
  group_by(ceo) %>%
  summarise(count = n()) %>%
  filter(count > 1)

# no duplicates above

globalF500 <- oldCEOs

globalF500 <- globalF500 %>%
  rename(school = Most.Recent.School...Alma.Mater) %>%
  mutate(clean_school = sub(" \\(.*", "", school, useBytes = TRUE))

# glue together, remember we don't have very many features for the non gloabl F500

 edges <- f500 %>%
  inner_join(globalF500, by = join_by(school)) %>%
  filter(!is.na(ceo.x), !is.na(ceo.y))
 
 # possible many to many problem here
 
 edges <- edges[, c(1, 5)]
 
 # good enough we can continue
 
 # lets check node has every vertex company here
 
edges %>%
  inner_join(nodes, by=join_by(company.x == company))
