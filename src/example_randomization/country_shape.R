library(XML)

# TASK: Given a country outline, guess the name of the country.

# Download all countries as a table
url <- "http://en.wikipedia.org/wiki/List_of_countries_and_dependencies_by_population#cite_note-8"
doc <- readHTMLTable(url)

# Clean the country and population table 
countries.info<-doc[[1]][2:3]
names(countries.info) <- c('Country','Population')

# Convert the population column from character factor to numeric
countries.info$Population<-as.numeric(gsub(",","",as.character(countries.info$Population)))

# Weights: the country's population divided by the world's population
countries.info$Weights <- countries.info$Population/ sum(countries.info$Population)

# Random Sample 
countries <- sample(countries.info$Country,20,prob = countries.info$Weights)
countries





