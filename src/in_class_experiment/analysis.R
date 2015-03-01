# Survey Analysis Script
# Imanol Arrieta Ibarra, Camelia Simoiu
# February 16, 2015

library(data.table)
library(ggplot2)
library(fBasics)
library(scales)

# Set ggplot2 theme
theme_set(theme_bw())

# Set the output directory
output_dir <- '../../output/inClass_exp/'

RemoveOutliers <- function(x, na.rm = TRUE) {
  # Removes outliers based on the interquartile range.
  #
  # Args:
  #   x: a vector of integers / doubles
  #   na.rm: removes missing values of x
  #
  # Returns:
  #   The vector with outliers removed
  #
  qnt <- quantile(x, probs=c(.25, .75), na.rm = na.rm)
  H <- 1.5 * IQR(x, na.rm = na.rm)
  y <- subset(x, x <= qnt[2] & x >= qnt[1])
  y
}


GeometricMean <- function(x, na.rm=FALSE){
  # Computes the geometric mean of a vector.
  #
  # Args:
  #   x: a vector of integers / doubles
  #
  # Returns:
  #   The geometric mean of the vector
  #
  gm <- exp(sum(log(x[x > 0]), na.rm=na.rm) / length(x))
  gm
}

TruncatedMean <- function(x, trunc=.05, na.rm=FALSE) {
  # Computes the truncated mean of a vector.
  #
  # Args:
  #   x: a vector of integers / doubles
  #   trunc: real-value between 0 and .5 specifying the level of truncation
  #   na.rm: removes missing values of x
  #
  # Returns:
  #   The truncated mean.
  #
  qnt <- quantile(x, probs=c(trunc, 1-trunc), na.rm=na.rm)
  x_trunc <- subset(x, x >= qnt[1] & x <= qnt[2])
  m <- mean(x_trunc)
  m
}

Rank <- function(v, x, TrueValue, na.rm=FALSE){
  # Computes the percentile rank of x relative to the vector v
  # in terms of their distance from TrueValue.
  #
  # Args:
  #   v: a vector of integers / doubles
  #   x: an arbitrary value
  #   TrueValue: the correct value
  #
  # Returns:
  #   The percentage of entries in v that are further from TrueValue than x.
  #
  dist <- abs(v-TrueValue)
  m <- abs(x-TrueValue)
  p <- mean(dist >= m)
  p
}

SummaryStats <- function(v, TrueValue, name){
  # Outputs summary statistics
  #
  # Args:
  #   v: a vector of integers / doubles representing the participant guesses
  #   TrueValue: the correct value
  #
  # Returns:
  #   Summary table of descriptive statistics.
  #
  
  # compute crowd estimates
  Mean <- mean(v)
  Median <- median(v)
  TruncMean = TruncatedMean(v)
  GeomMean = GeometricMean(v) 
  
  data.table(
	  Task = name,
	  TrueAnswer = TrueValue, 
	  
      Mean = Mean, 
	  RankMean = Rank(v, Mean, TrueValue),
	  
      Median = Median, 
	  RankMedian = Rank(v, Median, TrueValue),
	  
      TruncMean = TruncMean,
	  RankTruncMean = Rank(v, TruncMean, TrueValue),
	  
	  GeomMean = GeomMean, 
	  RankGeomMean = Rank(v, GeomMean, TrueValue),

      Min = min(v), 
      Max = max(v), 
      SD = stdev(v), 
	  Skewness = skewness(v)
   )   
}


# Main Script
TrueAnswers = c(1890,1149,300,224,3287590)
Responses <- fread(input='../../data/inClass_exp/responses.csv', header = TRUE)

# Compute summary statistics
Stats <- rbind(
  SummaryStats(v=Responses$India, TrueValue=3287590, name='IndiaSize'),
  SummaryStats(v=Responses$Year, TrueValue=1890, name='Painting'),
  SummaryStats(v=Responses$Dots, TrueValue=1149, name='Dots'),
  SummaryStats(v=Responses$IndiaRuns, TrueValue=300, name='IndiaRuns'),
  SummaryStats(v=Responses$PakistanRuns, TrueValue=224, name='PakistanRuns')
)

#
# Painting
#

PlotData = data.frame(x=Responses$Year)
m <- ggplot(PlotData, aes(x=x))
m <- m + geom_histogram()
m <- m + scale_x_continuous('\nYear')
m <- m + scale_y_continuous('Count\n')
m
ggsave(plot=m, file=paste0(output_dir, 'painting.pdf'), width=5, height=5)

#
# Dots
#

PlotData = data.frame(x=Responses$Dots)
m <- ggplot(PlotData, aes(x=x))
m <- m + geom_histogram()
m <- m + geom_vline(xintercept = 1149) 
m <- m + geom_vline(xintercept = 700, linetype="longdash") 
m <- m + scale_x_continuous('\nDots',limits = c(0,10000))
m <- m + scale_y_continuous('Count\n')
m
ggsave(plot=m, file=paste0(output_dir, 'dots.pdf'), width=5, height=5)

#
# Runs India
#

PlotData = data.frame(x=Responses$IndiaRuns)
m <- ggplot(PlotData, aes(x=x))
m <- m + geom_histogram()
m <- m + geom_vline(xintercept = 300) 
m <- m + geom_vline(xintercept = 280, linetype="longdash") 
m <- m + scale_x_continuous('\nRuns India',limits = c(0,500))
m <- m + scale_y_continuous('Count\n')
m
ggsave(plot=m, file=paste0(output_dir, 'runsindia.pdf'), width=5, height=5)

#
# Runs Pakistan
#

PlotData = data.frame(x=Responses$PakistanRuns)
m <- ggplot(PlotData, aes(x=x))
m <- m + geom_histogram()
m <- m + geom_vline(xintercept = 224) 
m <- m + geom_vline(xintercept = 250, linetype="longdash") 
m <- m + scale_x_continuous('\nRuns Pakistan',limits = c(0,500))
m <- m + scale_y_continuous('Count\n')
m
ggsave(plot=m, file=paste0(output_dir, 'runspakistan.pdf'), width=5, height=5)

#
# India Landmass
#

PlotData = data.frame(x=Responses$India)
m <- ggplot(PlotData, aes(x=x))
m <- m + geom_histogram()
m <- m + geom_vline(xintercept = 3287590) 
m <- m + geom_vline(xintercept = 1500000, linetype="longdash") 
m <- m + scale_x_continuous('\nIndia Landmass',limits = c(0,10000000))
m <- m + scale_y_continuous('Count\n')
m
ggsave(plot=m, file=paste0(output_dir, 'india.pdf'), width=5, height=5)





