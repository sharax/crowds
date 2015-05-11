library(stats)
library(dplyr)
library(ggplot2)
library(iterators)
library(xtable)
library(crowds)

# setwd("d:")
# dir <- "../../data/demo_data/"
dir <- "D:/Stanford/crowds/crowds/data/demo_data/"
setwd(dir)

# Set ggplot2 theme to black & white
theme_set(theme_bw())


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

responses <- responses %>% 
      mutate(time = as.numeric(difftime(strptime(submitted_at,"%Y-%m-%d %H:%M:%S"),
                                    strptime(created_at,"%Y-%m-%d %H:%M:%S"))))

# merge data frames
crowd_data <- responses %>% 
                inner_join(tasks, by="task_id") %>%
                inner_join(users, by="user_id") %>%
                select(task_id,
                       user_id, 
                       answer = data.x,
                       confidence,
                       domain_id,
                       qn_type = answer_type,
                       asset_type = type,
                       correct_answer,
                       age, 
                       gender, 
                       education,
                       employment,
                       experimental_condition,
                       time,
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

# employment
hist_employment <- qplot(employment, data=crowd_data, geom="histogram")

# asset type
hist_asset <- qplot(asset_type, data=crowd_data, geom="histogram")

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
                                 xlab = "average correct"))


# user performance -- point estimate questions (total 20 qns)
user_perf_pe <- crowd_data %>% 
                      filter(qn_type=="int") %>%
                      group_by(user_id) %>%  
                      summarise(av_rel_err = mean(as.numeric(rel_error))) %>%
                      with(qplot(x=av_rel_err, 
                                 geom="histogram", 
                                 binwidth = 0.3,
#                                  xlim=c(0,5),
                                 xlab = "average distance from correct answer"))


# average score for MC by asset type
score_by_asset <- crowd_data %>% 
                  filter(qn_type=="select") %>% 
                  group_by(asset_type) %>%  
                  summarise(av_score = mean(as.numeric(is_correct))) 

xtable(score_by_asset, caption = "Average score by asset type for all domains.")

#   type  av_score
# 1 audio 0.1018364
# 2 image 0.7067901
# 3 video 0.5745423



# time to answer qn
time_stats <- crowd_data %>% 
                  group_by(asset_type) %>%  
                  summarise(av_time = mean(time), 
                            median_time = median(time)) 

# asset_type  av_time   median_time
# 1      audio 18.04174          16
# 2      image 12.25598          11
# 3      video 17.72799          17





  
###################################################################################################

# Correlations


# education vs. performance on mc question   
score_by_edu <- group_by(crowd_data, education) %>%  
                accuracy_by_group()

xtable(score_by_edu, caption = "Average score by education level all domains.")

# education             pct_correct  av_dist
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
plot_conf_mc <- qplot(x = confidence, 
                      y = pct_correct, 
                      data = conf, 
                      ylim = c(0,1), 
                      size = 16, 
                      legend.position = "none")    # FIX!


# realtive distance - point estimate questions
plot_conf <-  qplot(x=confidence, 
                y=av_dist, 
                data=conf,  
                size=16, 
                legend.position = "none")


# time vs. relative error / confidence
time_confidence <- crowd_data %>% 
                      filter(qn_type=="int") %>%
                      group_by(task_id, user_id) %>%  
                      summarise(time = time, 
                                confidence = confidence, 
                                rel_error = rel_error)

ggplot(data = time_confidence,
       aes(x = time,
           y = rel_error, 
           color=confidence)) +
  geom_point()




# time vs. social condition
time_social <- crowd_data %>% 
                    group_by(experimental_condition) %>%  
                    summarise(time = mean(time))

# experimental_condition     time
# 1                control 15.67757
# 2                 social 15.26173



# individual user performance vs education (all tasks) - MC
scatter_edu <- filter(crowd_data, qn_type=="select")  %>% 
                group_by(education, user_id) %>% 
                agg.plot.users()
  

# # individual user performance vs education (all tasks) - point estimate
# plot10 <- filter(crowd_data, qn_type=="int")  %>% 
#           group_by(user_id, education) %>% 
#           agg.plot.users()




# accuracy, confidence vs. social condition - MC
crowd_data %>%
  filter(qn_type == "select") %>%
  group_by(task_id, experimental_condition) %>%
  summarise(confidence = mean(confidence),
            true_answer = correct_answer[1],
            crowd_answer = Mode(answer),
            is_correct = ifelse(true_answer == crowd_answer, TRUE, FALSE)) %>%
  group_by(experimental_condition) %>%
  summarise(av_confidence = mean(confidence),
            av_score = mean(is_correct))

# experimental_condition av_confidence av_score
# 1                control      3.284140   0.6625
# 2                 social      3.541124   0.6750



####################################################################################################
# aggregation

# MC - crowd score
crowd_data %>%
  filter(qn_type=="select") %>%
  group_by(task_id) %>%
  summarise(domain_id = domain_id[1],
            name = Mode(name),
            true_answer = correct_answer[1],
            crowd_answer = Mode(answer),
            is_correct = ifelse(true_answer == crowd_answer, TRUE, FALSE)) %>%
  group_by(domain_id) %>%
  summarise(name = name[1],
            crowd_score = sum(is_correct))

# domain_id       name crowd_score
# 1         3 MagicTrick          20
# 2         7  Landmarks          18
# 3        12  Penalties          12
# 4        53 ThemeSongs           4


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# domain / confidence & accuracy
crowd_data %>%
    group_by(task_id) %>%
    summarise(domain_id = domain_id[1],
              name = name[1],
              confidence = mean(confidence), 
              correct_answer = correct_answer[1],
              crowd_answer = Mode(answer),
              correct = ifelse(correct_answer == crowd_answer, TRUE, FALSE),
              av_relerror = mean(rel_error), 
              median_relerror = median(rel_error)) %>%
    group_by(domain_id) %>%
    summarise(name = name[1], 
              confidence = median(confidence),
              crowd_score_mc = sum(correct),
              crowd_av_error = mean(av_relerror),
              crowd_median_err = mean(median_relerror)) 

# domain_id       name confidence crowd_score_mc crowd_av_error crowd_median_err
# 1         3 MagicTrick   3.836667             20             NA               NA
# 2         7  Landmarks   3.876833             18             NA               NA
# 3        12  Penalties   2.750278             12             NA               NA
# 4        19   Calories   2.754301             NA       1.430227        0.6902689
# 5        53 ThemeSongs   2.823958              4             NA               NA


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# point estimate

# add relative / absolute error
crowd_stats_pe <- crowd_data %>%
          filter(qn_type=="int")  %>%
          group_by(task_id, domain_id) %>%
          summarise(domain = domain_id[1],
                    nr.responses = n(),
                    true_answer = as.numeric(correct_answer[1]),
                    abs_error_av = mean(abs_error),
                    abs_error_med = median(abs_error),
                    rel_error_av = mean(rel_error),
                    rel_error_med = median(rel_error),
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
          summarise(abs_error_mean = mean(abs_error_av),
                    abs_error_median = mean(abs_error_med),
                    rel_error_mean = mean(rel_error_av),
                    rel_error_median = mean(rel_error_med),
                    rank_mean = mean(as.numeric(rank_mean)), 
                    rank_median = mean(as.numeric(rank_median)), 
                    rank.geom.mean = mean(as.numeric(rank_geom)), 
                    rank_trunc_mean = mean(as.numeric(rank_trunc_mean)), 
                    rank_trunc_geom_mean = mean(as.numeric(rank_trunc_geom_mean)))

xtable(t(crowd_stats_pe), 
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
domains_iter <- iter(unique_domains)

# scores for individuals by domain
for (i in 1:nr_domains){
  domain_i <- nextElem(domains_iter)
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
  crowd_points <- crowd_stats_mc$crowd_score[i]
  results[i,1] <- unique_domains[i]
  results[i,2] <- domains$name[i]
  results[i,3] <- crowd_stats_mc$crowd_score[i]
  results[i,4] <- rank(i_responses[[i]], crowd_points, 20) 
}
results


# domain_id crowd_score crowd_rank
# 1         3          20  1.0000000
# 2         7          18  0.9166667
# 3        12          12  0.8235294
# 4        53           4  1.0000000

xtable(results, 
       caption = "Multiple Choice domains. The Crowd Ranking column contains
       the percentage of users the crowd performs better than. 
       Score is the number of answers the crowd got right.")



# plot crowd score vs sample size 
sample_size(3, 100)      # MagicTrick
sample_size(7, 100)      # Landmarks
sample_size(12, 100)     # Penalties
sample_size(53, 100)     # ThemeSongs
sample_size_cont(19,100) # Calories