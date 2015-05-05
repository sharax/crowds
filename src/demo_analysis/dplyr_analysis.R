library(stats)
library(dplyr)
library(ggplot2)

dir <- "../../data/demo_data/"
setwd(dir)

# Set ggplot2 theme to black & white
theme_set(theme_bw())


######################################################################################################

# Aggregation functions


Mode <- function(x) {
  # Computes the mode of a vector.
  #
  # Args:
  #   x: a vector of integers / doubles
  #
  # Returns:
  #   The mode of the vector
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
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

TruncatedGeometricMean <- function(x){
  # Computes the truncated mean of a vector.
  #
  # Args:
  #   x: a vector of integers / doubles
  #
  # Returns:
  #   The truncated geometric mean at (0.5, 0.95).
  #
  qnt<- quantile(x,probs = c(.05,.95))
  y<-x
  y[x < (qnt[1])] <- NA
  y[x > (qnt[2])] <- NA
  GeometricMean(y)
}


# Trim leading and trailing spaces
#
# Args:
#   x: a vector of characters
#
# Returns:
#   x: the original string, without any trailing / leading spaces
#
trim <- function (x) gsub("^\\s+|\\s+$", "", x)


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

######################################################################################################

# Load data
# treat empty cells as NA
answers <- read.delim('../../data/demo_data/answers.tsv', header = TRUE, sep="\t", na.strings=c("","NA"))
users <- read.delim('../../data/demo_data/users.tsv', header = TRUE, sep="\t", na.strings=c("","NA"))
domains <- read.delim('../../data/demo_data/domains.tsv', header = TRUE, sep="\t", na.strings=c("","NA"))
tasks <- read.delim('../../data/demo_data/tasks.tsv', header = TRUE, sep="\t", na.strings=c("","NA"))

# shorten domain names
domains$name <-c("MagicTrick","Landmarks","Penalties","Calories","ThemeSongs")

# change "id" to "task.id" / "user.id" so it can be merged with the answers DF
names(tasks)[1]<-"task_id"
names(users)[1]<-"user_id"
names(domains)[1]<-"domain_id"

# merge data frames
first.merge <- merge(answers, tasks, by="task_id")
second.merge <- merge(first.merge, users, by="user_id")
third.merge <- merge(second.merge, domains, by="domain_id")
names(third.merge)

# create clean data frame with required columns
data <- data.frame(task.id =          third.merge$task_id, 
                   domain.id =        third.merge$domain_id, 
                   user.id =          third.merge$user_id,
                   confidence =       third.merge$confidence,
                   question =         as.character(third.merge$name),
                   answer =           trim(as.character(third.merge$data.x)),
                   gender =           as.character(third.merge$gender),
                   education =        as.character(third.merge$education),
                   group =            as.character(third.merge$experimental_condition),
                   social.condition = third.merge$status,
                   age =              third.merge$age,
                   correct.answer =   trim(as.character(third.merge$correct_answer)),
                   answer.type =      as.character(third.merge$answer_type),
                   asset.type =       as.character(third.merge$type), 
                   stringsAsFactors = FALSE)

# check
dim(data)
names(data)
glimpse(data)


# flag answers that "timedout" and "null" with NA
data <-  data %>% 
            mutate(answer = replace(answer, answer=="timeout" | answer=="null", NA)) 


# TODO: change answer_type in place 
#
# data <-  data %>% 
#   mutate(answer.num = ifelse(answer.type=="int", as.numeric(answer), NA),
#          answer.mc = ifelse(answer.type=="select", as.character(answer), NA))


# remove all answers that are NA (either timed-out or not answered)
data <- na.omit(data)




######################################################################################################

# was the answer correct?
# 
# new columns
#  got.correct: binary 0 or 1. 
#               For multiple choice quesitons only. 1 if correct, 0 if incorrect
#  abs.error: the absolute difference between the individual answer and the correct answer
#  rel.error: the relative difference between the individual answer and the correct answer
data <- data %>% 
  mutate(got.correct = ifelse(answer.type == "select" & as.character(answer) == as.character(correct.answer), 1, 0), 
         abs.error = ifelse(answer.type == "int", abs(as.integer(answer)-as.integer(correct.answer)), NA),
         rel.error = ifelse(answer.type == "int", abs.error/as.integer(correct.answer), NA))
  
  

####################################################################################################
# exploratory analysis

# age
qplot(age, data=users, geom="histogram", binwidth=1)

# education
qplot(education, data=users, geom="histogram")  

# gender
qplot(gender, data=users, geom="histogram")

# confidence
ggplot(data, aes(x=confidence)) +
  geom_histogram(binwidth = 0.5) +
  scale_x_continuous(breaks=0:5)


#########################################
# TODO
#
# error bars
# test for: confidence, education, group, asset.type, social.condition

agg.plot <- function(df) {
  # computes the overall accuracy score (pct. correct) by education level
  # 
  # args: 
  #  df: grouped data frame
  # 
  # returns:
  #  plot of education vs. pct. correct
  #
  
  # Multiple choice questions
  if (Mode(df$answer.type=="select")){
    summarise(df, pct.correct = sum(got.correct)/n()) %>%
      with(qplot(x=education, y=pct.correct, 
                 geom=c("point"), 
                 data = ., 
                 ylim = c(0, 1),
                 ylab = "pct correct"))}
  
  # point-estimate questions
  else {
      mutate(df, rel.error = ifelse(is.infinite(rel.error), 1, rel.error)) %>%
      summarise(av.dist = mean(rel.error, na.rm=T), 
                se.dist = sd(rel.error, na.rm=T)) %>%
      with(qplot(x=education, y=av.dist, 
                 geom="point", 
                 data = ., 
                 ylab = "average absolute error"))
   }
  }  

agg.plot.users <- function(df) {
  # computes the overall accuracy score (pct. correct) by education level
  # 
  # args: 
  #  df: grouped data frame
  # 
  # returns:
  #  plot of education vs. pct. correct
  #
  
  # Multiple choice questions
  if (Mode(df$answer.type=="select")){
  summarise(df, 
            count = n(),
            score=sum(got.correct), 
            av.score = score/count) %>% 
  with(qplot(x=user.id, y=av.score,
               color=education,
               geom=c("point"), 
               data = ., 
               ylim = c(0, 1),
               ylab = "pct correct"))
  }
  # point-estimate questions
  else {
    mutate(df, rel.error = ifelse(is.infinite(rel.error), 1, rel.error)) %>%
    summarise(av.dist = mean(rel.error, na.rm=T), 
                se.dist = sd(rel.error, na.rm=T)) %>%
    with(qplot(x=education, y=av.dist, 
                 geom="point", 
                 data = ., 
                 ylab = "average absolute error"))
  }
}
  



# education vs. performance on mc question   
group_by(data, education) %>%  
  filter(answer.type=="select") %>% 
  agg.plot()

# education vs. performance on point-estimate question   
group_by(data, education) %>%  
    filter(answer.type=="int") %>% 
    agg.plot()
  

# individual user performance vs education (all tasks) - MC
filter(data, answer.type=="select")  %>% 
  group_by(user.id, education) %>% 
  agg.plot.users()
  

# individual user performance vs education (all tasks) - point estimate
filter(data, answer.type=="int")  %>% 
  group_by(user.id, education) %>% 
  agg.plot.users()



####################################################################################################
# aggregation

# point estimate 
data %>%
  filter(answer.type=="int")  %>%
  group_by(task.id) %>%
  summarise(domain = Mode(domain.id),
            nr.responses = n(),
            true.answer = as.numeric(Mode(correct.answer)),
            crowd.mean = mean(as.numeric(answer)), 
            crowd.median = median(as.numeric(answer)),
            crowd.geom.mean = GeometricMean(as.numeric(answer)),
            crowd.trunc.mean = TruncatedMean(as.numeric(answer)), 
            crowd.trunc.geom.mean = TruncatedGeometricMean(as.numeric(answer)),
            rank.mean = Rank(as.numeric(answer), crowd.mean, true.answer), 
            rank.median = Rank(as.numeric(answer), crowd.median, true.answer),
            rank.geom = Rank(as.numeric(answer), crowd.geom.mean, true.answer),
            rank.trunc.mean = Rank(as.numeric(answer), crowd.trunc.mean, true.answer),
            rank.trunc.geom.mean = Rank(as.numeric(answer), crowd.trunc.geom.mean, true.answer)) %>%
  group_by(domain) %>%
  summarise(rank.mean = mean(as.numeric(rank.mean)), 
            rank.median = mean(as.numeric(rank.median)), 
            rank.geom.mean = mean(as.numeric(rank.geom)), 
            rank.trunc.mean = mean(as.numeric(rank.trunc.mean)), 
            rank.trunc.geom.mean = mean(as.numeric(rank.trunc.geom.mean)))




# MC / binary 
data %>%
  filter(answer.type=="select") %>%
  group_by(task.id) %>%
  summarise(domain.id = Mode(domain.id),
            true.answer = Mode(correct.answer),
            crowd.answer = Mode(answer),
            is.correct = ifelse(true.answer == crowd.answer, 1,0),
            nr.responses = n(),
            nr.correct = sum(got.correct),
            pct.correct.answ = nr.correct/nr.responses) %>%
  group_by(domain.id) %>%
  summarise(crowd.score = sum(is.correct))

# domain        domain.id nr.correct
# magic trick     3         20 
# landmark        7         18 
# penalty        12         12 
# songs          53         13 *


# rank crowd
# get vector of individual answers for each domain
mc.data <- filter(data, answer.type=="select") 
grouped <- group_by(mc.data, domain.id, user.id) 
s <- summarise(grouped, score=sum(got.correct)) 
individual.answ <- subset(s$score, s$domain.id==7)
Rank(individual.answ, 18, 20)


####################################################################################################

# time-dependency - point estimate 
max.pop.size <- 5
nr.runs <- 10
results <- vector('list', max.pop.size)



results <- vector('list', max.pop.size)
data %>%
  filter(answer.type=="int") %>%
  group_by(task.id) %>%
  for (i in 1:max.pop.size) {
    for (j in 1:nr.runs) {
      sample_n(group.by.task, i)
      summarise(s, true.answer = Mode(as.numeric(correct.answer)),
                 crowd.answer = mean(as.numeric(answer)),
                 av.rel.error = mean(rel.error),
                 rank = Rank(as.numeric(answer), crowd.answer, true.answer))
      # results[[i]] <- c(results[[i]], rank)
  }
}
  
  