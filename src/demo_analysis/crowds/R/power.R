#' Mode
#' 
#' Computes the mode of a vector.
#' 
#' @param x a vector of integers / doubles
#' @return The mode of the vector
#' @export 
Mode <- function(x) {  
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}

#' Remove outliers
#' 
#' Removes outliers outside 95% confidence interval.
#' 
#' @param x a vector of integers / doubles
#' @return a vector with outlier observations removed
#' @export 
remove_outliers <- function(x, na.rm = TRUE, ...) {
  qnt <- quantile(x, probs=c(.05, .95), na.rm = na.rm, ...)
  H <- 1.5 * IQR(x, na.rm = na.rm)
  y <- x
  y[x < (qnt[1] - H)] <- NA
  y[x > (qnt[2] + H)] <- NA
  y
}

#' Geometric Mean
#' 
#' Computes the geometric mean of a vector
#' 
#' @param x a vector of integers / doubles
#' @return The geometric mean of the vector.
#' @export 
geometric_mean <- function(x, na.rm=FALSE){
  gm <- exp(sum(log(x[x > 0]), na.rm=na.rm) / length(x))
  gm
}


#' Truncated Mean
#' 
#' Computes the truncated mean of a vector
#' 
#' @param x a vector of integers / doubles
#' @param trunc real-value between 0 and .5 specifying the level of truncation
#' @param na.rm removes missing values of x
#' 
#' @return The truncated mean at (0.5, 0.95).
#' @export 
truncated_mean <- function(x, trunc=.05, na.rm=FALSE) {
  qnt <- quantile(x, probs=c(trunc, 1-trunc), na.rm=na.rm)
  x_trunc <- subset(x, x >= qnt[1] & x <= qnt[2])
  m <- mean(x_trunc)
  m
}


#' Truncated Geometric Mean
#' 
#' Computes the truncated geometric mean of a vector
#' 
#' @param x a vector of integers / doubles
#' @param trunc real-value between 0 and .5 specifying the level of truncation
#' @param na.rm removes missing values of x
#' 
#' @return The truncated geometric mean at (0.5, 0.95).
#' @export 
truncated_geometric_mean <- function(x, trunc=.05, na.rm=FALSE){
  qnt <- quantile(x, probs=c(trunc, 1-trunc), na.rm=na.rm)
  x_trunc <- subset(x, x >= qnt[1] & x <= qnt[2])
  m <- geometric_mean(x_trunc)
  m
}


#' Trim leading and trailing spaces
#'
#' @param x a vector of character
#' @return the original string, without any trailing / leading spaces
#' @export 
trim <- function (x) gsub("^\\s+|\\s+$", "", x)


#' Rank
#' 
#' Computes the percent of entries in v that x is better than
#' in terms of their distance from TrueValue.
#' 
#' @param v vector of individual answers
#' @param x crowd estimate
#' @param TrueValue the correct answer
#' 
#' @return The percentage of entries in v that are further from TrueValue than x.
#' @export 
rank <- function(v, x, TrueValue, na.rm=FALSE){
  dist <- abs(v-TrueValue)
  m <- abs(x-TrueValue)
  p <- mean(dist >= m, na.rm=FALSE)
  p
}


#' Accuracy by group
#' 
#' Computes the percentage correct and average relative error for a grouped data set.
#' 
#' @param df grouped data frame
#' @return plot of education vs. pct. correct
#' @export 
accuracy_by_group <- function(df) {
  summarise(df, 
            pct_correct = mean(is_correct, na.rm=TRUE), 
            av_dist = mean(rel_error, na.rm=TRUE))
  
}  


#' Plot education vs accuracy
#' 
#' computes the overall accuracy score (pct. correct) vs. education level 
#' 
#' @param df grouped data frame
#' @return plot of education vs. pct. correct
#' @export 
agg_plot_users <- function(df) {  
  summarise(df, 
            pct_correct = mean(is_correct, na.rm=TRUE), 
            av_dist = mean(rel_error, na.rm=TRUE))  %>%
    with(qplot(x=user_id, 
               y=pct_correct,
               color=education,
               geom=c("point"), 
               data = ., 
               ylim=c(0,1),
               ylab = "pct correct"))
}


#' Maximum sample size
#' 
#' Computes the maximum sample size for a domain (min nr of responses of any task)
#' 
#' @param id integer (domain id)
#' @return the min nr of responses of any task in the domain
max_sample_size <- function(id) {
  # 
  domain_data <- crowd_data %>%
    filter(domain_id==id) %>%
    group_by(task_id) %>%
    summarise(count = n())
  
  max_sample <- min(domain_data$count)
  return(max_sample)
}


#' Plot Accuracy vs Sample Size (MC)
#' 
#' Computes the geometric mean of a vector for MC questions
#' 
#' @param id integer (domain id)
#' @param nr_simulations the number of random samples to average over
#' 
#' @return plot of accuracy vs sample size
#' @export 
sample_size <- function(id, nr_simulations){
  
  # set title according to domain name
  s <- subset(crowd_data, domain_id == id)
  domain_name <- s$name[1]
  title <- paste("Crowd score vs. size of crowd - ", domain_name)
  
  # find maximum sample size 
  max_sample <- max_sample_size(id)
  results <- vector("list", max_sample)
  
  # run simulation 
  # sample i responses from population from each task
  for (i in 1:max_sample) {
    for (j in 1:nr_simulations) {
      
      # find score of sample 
      sample <- crowd_data %>%
        filter(domain_id==id) %>%
        group_by(task_id) %>%
        sample_n(i) %>%
        summarise(domain_id = id,
                  true_answer = Mode(correct_answer),
                  crowd_answer = Mode(answer),
                  is_correct = ifelse(true_answer == crowd_answer, TRUE, FALSE)) %>%
        
        # find crowd score
        group_by(domain_id) %>%
        summarise(crowd_score = sum(is_correct))
      results[[i]] <- c(results[[i]], sample$crowd_score)
    }
    print(i)
  }
  
  # find sample mean and standard deviation
  sample_mean <- unlist(lapply(results, mean, na.rm=TRUE))
  sample_sd <- unlist(lapply(results, sd, na.rm=TRUE))
  
  # save to data frame
  d <- data.frame(size = 1:max_sample, 
                  mean = sample_mean, 
                  se0 = sample_mean - sample_sd, 
                  se1 = sample_mean + sample_sd)
  
  # plot crowd score as a fn of sample size
  ggplot(data=d, 
         aes(x=size, y=mean)) +
    geom_errorbar(aes(ymin=se0, ymax=se1), width=.1, color="grey") +
    geom_point() +
    ylim(0, 20) +
    ylab("Average score of sample") + 
    xlab("Sample size") +
    ggtitle(title)
  
  return(d)
}


#' Plot Accuracy vs Sample Size (point estimate)
#' 
#' Computes the geometric mean of a vector for point estimate questions
#' 
#' @param id integer (domain id)
#' @param nr_simulations the number of samples to generate
#' 
#' @return plot of accuracy vs sample size
#' @export 
sample_size_cont <- function(id, nr_simulations){
  
  # set title according to domain name
  s <- subset(crowd_data, domain_id == id)
  domain_name <- s$name[1]
  title <- paste("Crowd score vs. size of crowd - ", domain_name)
  
  # find maximum sample size 
  max_sample <- max_sample_size(id)
  results_mean <- vector("list", max_sample)
  results_median <- vector("list", max_sample)
  results_trunc_mean <- vector("list", max_sample)
  results_geom_mean <- vector("list", max_sample)
  
  # run simulation 
  # sample i responses from population from each task
  for (i in 1:max_sample) {
    for (j in 1:nr_simulations) {
      
      # find score of sample 
      sample <- crowd_data %>%
        filter(domain_id==id) %>%
        group_by(task_id) %>%
        sample_n(i) %>%
        summarise(domain_id = id,
                  true_answer = Mode(correct_answer),
                  score_mean = mean(rel_error), 
                  score_median = median(rel_error),
                  score_trunc_mean = truncated_mean(rel_error),
                  score_geom_mean = geometric_mean(rel_error)) %>%
        
        # find crowd score
        group_by(domain_id) %>%
        summarise(crowd_mean = mean(score_mean),
                  crowd_median = mean(score_median),
                  crowd_trunc_mean = mean(score_trunc_mean),
                  crowd_geom_mean = mean(score_geom_mean))
      
      # save results
      results_mean[[i]] <- c(results_mean[[i]], sample$crowd_mean)
      results_median[[i]] <- c(results_median[[i]], sample$crowd_median)
      results_trunc_mean[[i]] <- c(results_trunc_mean[[i]], sample$crowd_trunc_mean)
      results_geom_mean[[i]] <- c(results_geom_mean[[i]], sample$crowd_geom_mean)
      
    }
    print(i)
  }
  
  # find sample mean and standard deviation
  sample_mean <- unlist(lapply(results_mean, mean, na.rm=TRUE))
  sample_median <- unlist(lapply(results_median, mean, na.rm=TRUE))
  sample_trunc_mean <- unlist(lapply(results_trunc_mean, mean, na.rm=TRUE))
  sample_geom_mean <- unlist(lapply(results_geom_mean, mean, na.rm=TRUE))
  
  sample_sd_mean <- unlist(lapply(results_mean, sd, na.rm=TRUE))
  sample_sd_median <- unlist(lapply(results_median, sd, na.rm=TRUE))
  sample_sd_trunc_mean <- unlist(lapply(results_trunc_mean, sd, na.rm=TRUE))
  sample_sd_geom_mean <- unlist(lapply(results_geom_mean, sd, na.rm=TRUE))
  
  # save to data frame
  d <- data.frame(size = 1:max_sample, 
                  mean = sample_mean, 
                  median = sample_median,
                  trunc_mean = sample_trunc_mean,
                  geom_mean = sample_geom_mean)
  
  # plot crowd score as a fn of sample size
  crowd_performance <- melt(d, id="size")  # convert to long format
  
  ggplot(data=crowd_performance,
         aes(x=size, y=value, colour=variable)) +
    geom_line() + 
    geom_point() +
    ylab("Relative Error of sample") + 
    xlab("Sample size") +
    ggtitle(title)
  
}

