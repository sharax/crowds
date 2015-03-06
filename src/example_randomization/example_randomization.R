library(XML)

# TASK: Given a country, guess its capital city.

# Download the country information as a table
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
set.seed(1242)
flags<- sample(countries.info$Country,20,prob = countries.info$Weights)
flags

# Get country capitals
# source: http://techslides.com/list-of-countries-and-capitals
capitals <- read.csv("country_capitals.csv", stringsAsFactors=FALSE, na.strings = "NA")
capitals <- capitals[1:2]
capitals[capitals==""] <- NA
capitals[capitals=="N/A"] <- NA
na.omit(capitals)
names(capitals)

# Set weights for capitals
# use population weights for the corresponding country
# may be better to sample based on continent

# Get capitals for countries
for (i in 1:20 ) {
	correct_answ <- (capitals[capitals$CountryName == flags[i], 2])
	mc_answers <- sample(capitals$CapitalName,4,prob = capitals$Weights)
	print(mc_answers)
}




