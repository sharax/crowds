library(XML)



# First I will download the country's information as a table.
doc <- readHTMLTable(
  doc="http://en.wikipedia.org/wiki/List_of_countries_and_dependencies_by_population#cite_note-8")

# Get  and clean the countries and population table 
# I also taking away China's,UK's, US's and India's flags (It would not make any sense to ask this)
countries.info<-doc[[1]][-c(1,2,3,22),2:3]
names(countries.info) <- c('Country','Population')
# We need to convert the population column from character factor to numeric.
countries.info$Population<-as.numeric(gsub(",","",as.character(countries.info$Population)))
# The weights will be the country's population divided by the world's population
countries.info$Weights <- countries.info$Population/ sum(countries.info$Population)

# Random Sample 
set.seed(1242)
flags<- sample(countries.info$Country,20,prob = countries.info$Weights)
flags
