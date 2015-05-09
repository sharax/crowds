library(stats)
library(dplyr)
library(ggplot2)
library(iterators)
library(xtable)

# setwd("d:")
# dir <- "D:/Stanford/crowds/crowds/data/demo_data/"
dir <- "../../data/demo_data/"
setwd(dir)

# Set ggplot2 theme to black & white
theme_set(theme_bw())


######################################################################################################

# move this to library

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


remove_outliers <- function(x, na.rm = TRUE, ...) {
  # Removes outliers outside 95% confidence interval.
  #
  # Args:
  #   x: a vector of integers / doubles
  #
  # Returns:
  #   y: a vector with outlier observations removed
  
  qnt <- quantile(x, probs=c(.05, .95), na.rm = na.rm, ...)
  H <- 1.5 * IQR(x, na.rm = na.rm)
  y <- x
  y[x < (qnt[1] - H)] <- NA
  y[x > (qnt[2] + H)] <- NA
  y
}


geometric_mean <- function(x, na.rm=FALSE){
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

truncated_mean <- function(x, trunc=.05, na.rm=FALSE) {
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

truncated_geometric_mean <- function(x){
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
  geometric_mean(y)
}


# Trim leading and trailing spaces
#
# Args:
#   x: a vector of characters
#
# Returns:
#   x: the original string, without any trailing / leading spaces

trim <- function (x) gsub("^\\s+|\\s+$", "", x)


rank <- function(v, x, TrueValue, na.rm=FALSE){
  # Computes the percent of entries in v that x is better than
  # in terms of their distance from TrueValue.
  #
  # Args:
  #   v: vector of individual answers
  #   x: crowd estimate
  #   TrueValue: the correct value
  #
  # Returns:
  #   The percentage of entries in v that are further from TrueValue than x.
  #
  dist <- abs(v-TrueValue)
  m <- abs(x-TrueValue)
  p <- mean(dist >= m, na.rm=FALSE)
  p
}


######################################################################################################

# Load data
# treat empty cells as NA
responses <- read.delim('../../data/demo_data/answers.tsv', header = TRUE, na.strings=c("","NA"))
users <- read.delim('../../data/demo_data/users.tsv', header = TRUE, na.strings=c("","NA"))
domains <- read.delim('../../data/demo_data/domains.tsv', header = TRUE, na.strings=c("","NA"))
tasks <- read.delim('../../data/demo_data/tasks.tsv', header = TRUE, na.strings=c("","NA"))

# shorten domain names
domains$name <-c("MagicTrick","Landmarks","Penalties","Calories","ThemeSongs")

# change "id" to "task_id" / "user_id" so it can be merged with responses data
tasks <- rename(tasks, task_id=id)
users <- rename(users, user_id=id)
domains <- rename(domains, domain_id=id)


# merge data frames
# TODO: select
crowd_data <- responses %>% 
                inner_join(tasks, by="task_id") %>%
                inner_join(users, by="user_id") %>%
                select(task_id,
                       user_id, 
                       answer = data.x,
                       confidence,
                       domain_id,
                       qn_type = answer_type,
                       type,
                       correct_answer,
                       age, 
                       gender, 
                       education,
                       employment,
                       experimental_condition,
                       status)  %>%
                inner_join(domains, by="domain_id")  %>% 
                select(-c(created_at, updated_at, description, time_limit))
              


# change type for the answer & correct_answer columns
# takes the place of "stringsAsFactors = FALSE"
crowd_data <- crowd_data %>% 
  mutate(answer = as.character(answer), 
         correct_answer = trim(as.character(correct_answer)))

# flag answers that "timedout" and "null" with NA
crowd_data <- filter(crowd_data, answer!="timeout", answer!="null")

# check
dim(crowd_data)
names(crowd_data)
summary(crowd_data)

# transposed view, similar to "strucutre" function
glimpse(crowd_data)  



######################################################################################################

# was the answer correct?
# 
# new columns
#  is_correct: binary 0 or 1. 
#               For multiple choice quesitons only. 1 if correct, 0 if incorrect
#  abs_error: the absolute difference between the individual answer and the correct answer
#  rel_error: the relative difference between the individual answer and the correct answer
crowd_data <- crowd_data %>% 
  mutate(is_correct = ifelse(qn_type == "select" & as.character(answer) == as.character(correct_answer), TRUE, FALSE), 
         abs_error = ifelse(qn_type == "int", abs(as.numeric(answer)-as.numeric(correct_answer)), NA),
         rel_error = ifelse(qn_type == "int", abs_error/as.numeric(correct_answer), NA))
 
# fix 'Inf' values in rel_error (assign to 1)
crowd_data <- crowd_data %>% 
  mutate(rel_error = ifelse(qn_type == "int" & rel_error=="Inf", 1, rel_error))

head(crowd_data)
 
####################################################################################################
# exploratory analysis

# age
hist_age <- qplot(age, data=crowd_data, geom="histogram", binwidth=1)

# education
hist_edu <- qplot(education, data=crowd_data, geom="histogram")  

# gender
hist_gender <- qplot(gender, data=crowd_data, geom="histogram")

# confidence
hist_confidence <- ggplot(crowd_data, aes(x=confidence)) +
                    geom_histogram(binwidth = 0.5) +
                    scale_x_continuous(breaks=0:5)
                  

# user performance -- MC questions (total 80 questions)
user_perf_mc <- crowd_data %>% 
                      filter(qn_type=="select") %>%
                      group_by(user_id) %>%  
                      summarise(av_correct = mean(is_correct)) %>%
                      with(qplot(x=av_correct, 
                                 geom="histogram", 
                                 stat="bin",
                                 binwidth = 0.05,
                                 xlim = c(0,1),
                                 xlab = "average correct"))


# distribution of user performance -- point estimate questions (total 20 qns)
user_perf_pe <- crowd_data %>% 
  filter(qn_type=="int") %>%
  group_by(user_id) %>%  
  summarise(av_rel_err = mean(as.numeric(rel_error))) %>%
  with(qplot(x=av_rel_err, 
             geom="histogram", 
             binwidth = 0.3,
             xlim=c(0,5),
             xlab = "average distance from correct answer"))


# average score by asset type
score_by_asset <- crowd_data %>% 
                  filter(qn_type=="select") %>% 
                  group_by(type) %>%  
                  summarise(av_score = mean(as.numeric(is_correct))) 

xtable(score_by_asset, caption = "Average score by asset type for all domains.")

#   type  av_score
# 1 audio 0.1018364
# 2 image 0.7067901
# 3 video 0.5745423


  
#########################################


accuracy_by_group <- function(df) {
  # computes the overall accuracy score 
  # ie. pct. correct or average relative distance
  # for a grouped data set
  # 
  # args: 
  #  df: grouped data frame
  # 
  # returns:
  #  plot of education vs. pct. correct
  #
  
  # Multiple choice questions
  summarise(df, 
            pct_correct = mean(is_correct, na.rm=TRUE), 
            av_dist = mean(rel_error, na.rm=TRUE))

}  


# education vs. performance on mc question   
score_by_edu <- group_by(crowd_data, education) %>%  
                accuracy_by_group()

xtable(score_by_edu, caption = "Average score by education level all domains.")

# education pct_correct  av_dist
# 1            Bachelor   0.3899791 1.456040
# 2              Master   0.4800000 1.278620
# 3   Primary education   0.4218750 1.215210
# 4 Secondary education   0.3766578 1.424537



# confidence vs. performance on mc question   
score_by_conf <- group_by(crowd_data, confidence) %>%  
                  accuracy_by_group()

# confidence pct_correct   av_dist
# 1          1   0.2154341 1.3504182
# 2          2   0.1599265 1.5002094
# 3          3   0.3000000 1.3280794
# 4          4   0.4785276 2.0073925
# 5          5   0.6930295 0.6639404
xtable(score_by_conf, caption = "Average score by confidence level all domains.")


# % correct - MC questions
plot_conf_mc <- qplot(x=confidence, 
              y=pct_correct, 
              data=conf, 
              ylim=c(0,1), 
              size=16, 
              legend.position = "none")    # FIX!

# realtive distance - point estimate questions
plot_conf <-  qplot(x=confidence, 
                y=av_dist, 
                data=conf,  
                size=16, 
                legend.position = "none")


###########################################################################################

agg.plot.users <- function(df) {
  # computes the overall accuracy score (pct. correct) vs. education level 
  # 
  # args: 
  #  df: grouped data frame
  # 
  # returns:
  #  plot of education vs. pct. correct

  summarise(df, 
            pct_correct = mean(is_correct, na.rm=TRUE), 
            av_dist = mean(rel_error, na.rm=TRUE))  %>%
  with(qplot(x=user_id, y=pct_correct,
               color=education,
               geom=c("point"), 
               data = ., 
               ylim=c(0,1),
               ylab = "pct correct"))
}
  

# individual user performance vs education (all tasks) - MC
scatter_edu <- filter(crowd_data, qn_type=="select")  %>% 
                group_by(education, user_id) %>% 
                agg.plot.users()
  

# individual user performance vs education (all tasks) - point estimate
plot10 <- filter(crowd_data, qn_type=="int")  %>% 
          group_by(user_id, education) %>% 
          agg.plot.users()




####################################################################################################
# aggregation

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


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -   

# point estimate
# add relative / absolute error
crowd_stats_pe <- crowd_data %>%
          filter(qn_type=="int")  %>%
          group_by(task_id, domain_id) %>%
          summarise(domain = domain_id[1],
                    nr.responses = n(),
                    true_answer = as.numeric(correct_answer[1]),
                    crowd_mean = mean(as.numeric(answer)), 
                    crowd_median = median(as.numeric(answer)),
                    crowd_geom_mean = geometric_mean(as.numeric(answer)),
                    crowd_trunc_mean = truncated_mean(as.numeric(answer)), 
                    crowd_trunc_geom_mean = truncated_geometric_mean(as.numeric(answer)),
                    rank_mean = rank(as.numeric(answer), crowd_mean, true_answer), 
                    rank_median = rank(as.numeric(answer), crowd_median, true_answer),
                    rank_geom = rank(as.numeric(answer), crowd_geom_mean, true_answer),
                    rank_trunc_mean = rank(as.numeric(answer), crowd_trunc_mean, true_answer),
                    rank_trunc_geom_mean = rank(as.numeric(answer), crowd_trunc_geom_mean, true_answer)) %>%
          group_by(domain) %>%
          summarise(rank_mean = mean(as.numeric(rank_mean)), 
                    rank_median = mean(as.numeric(rank_median)), 
                    rank.geom.mean = mean(as.numeric(rank_geom)), 
                    rank_trunc_mean = mean(as.numeric(rank_trunc_mean)), 
                    rank_trunc_geom_mean = mean(as.numeric(rank_trunc_geom_mean)))

xtable(crowd_stats_pe, 
       caption = "Point estimate domains ranked according to average ranking. Columns represent 
       the ranking by using the corresponding method of aggregation. Average ranking takes the 
       mean of the crowd percentiles for each task.")


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# vector of individual scores / domain for ranking

# find the score of each individual for the domain 
i_scores <- crowd_data %>%
  filter(qn_type=="select") %>%
  group_by(domain_id, user_id)  %>%
  summarise(score = sum(is_correct)) 

# create an iterator object to loop over domains, 
# and a list to store the vector of individual scores
i_responses <- vector('list', nr_domains)
unique_domains <- unique(i_scores$domain_id)
nr_domains <- length(unique_domains)
domains <- iter(unique_domains)

# scores for individuals by domain
for (i in 1:nr_domains){
  domain_i <- nextElem(domains)
  print(domain_i)
  indiv_i <- subset(i_scores, as.numeric(domain_id)==as.numeric(domain_i))
  i_responses[[i]] <- indiv_i$score
}        
i_responses


# crowd score by domain (taking the mode of the answers for each task)
crowd_stats_mc <- crowd_data %>%
  filter(qn_type=="select") %>%
  group_by(task_id)  %>%
  summarise(domain_id = domain_id[1],
            crowd_response = Mode(answer),
            true_answer = correct_answer[1],
            crowd_is_correct=sum(ifelse(crowd_response==true_answer,1,0))) %>%
  group_by(domain_id) %>%
  summarise(crowd_score = sum(crowd_is_correct))


# find crowd ranking
results <- data.frame(matrix(NA, nr_domains, 4))
names(results) <- c('domain_id', 'domain_name', 'crowd_score', 'crowd_rank')
for (i in 1:nr_domains){
  results[i,1] <- unique_domains[i]
  results[i,2] <- domains$name[i]
  results[i,3] <- crowd_stats_mc$crowd_score[i]
  results[i,4] <- rank(i_responses[[i]], crowd_stats_mc$crowd_score[i], 20) 
}
            

results
# domain_id crowd_score crowd_rank
# 1         3          20  1.0000000
# 2         7          18  0.9166667
# 3        12          12  0.8235294
# 4        53          13  1.0000000

xtable(results, 
       caption = "Multiple Choice domains. The Crowd Ranking column contains
       the percentage of users the crowd performs better than. 
       Score is the number of answers the crowd got right.")

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
