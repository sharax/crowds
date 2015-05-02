dir <- "D:/Stanford/crowds/crowds/data/demo_data/"
setwd(dir)
tasks<- read.csv(file = "tasks.tsv", header = TRUE, sep = "\t")
users<- read.csv(file = "users.tsv", header = TRUE, sep = "\t")
domains<- read.csv(file = "domains.tsv", header = TRUE, sep = "\t")
answers<- read.csv(file = "answers.tsv", header = TRUE, sep = "\t")

Mode <- function(x) {
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}

gm_mean = function(x, na.rm=TRUE, zero.propagate = FALSE){
  if(any(x < 0, na.rm = TRUE)){
    return(NaN)
  }
  if(zero.propagate){
    if(any(x == 0, na.rm = TRUE)){
      return(0)
    }
    exp(mean(log(x), na.rm = na.rm))
  } else {
    exp(sum(log(x[x > 0]), na.rm=na.rm) / length(x))
  }
}

remove_outliers <- function(x, na.rm = TRUE, ...) {
  qnt <- quantile(x, probs=c(.05, .95), na.rm = na.rm, ...)
  H <- 1.5 * IQR(x, na.rm = na.rm)
  y <- x
  y[x < (qnt[1] - H)] <- NA
  y[x > (qnt[2] + H)] <- NA
  y
}

truncated.mean<- function(x){
  qnt<- quantile(x,probs = c(.05,.95))
  y<-x
  y[x < (qnt[1])] <- NA
  y[x > (qnt[2])] <- NA
  mean(y,na.rm=TRUE)
}

truncated.gm_mean<- function(x){
  qnt<- quantile(x,probs = c(.05,.95))
  y<-x
  y[x < (qnt[1])] <- NA
  y[x > (qnt[2])] <- NA
  gm_mean(y)
}

aggregate<- function(domain,type = "MC"){
  m<- dim(domain)[1]
  n<- dim(domain)[2]
  crowds<-list()
  if (type=="MC"){
    crowds$mode <- apply(domain,2,Mode) 
  } else if (type == "PE"){
    crowds$mean<- apply(domain,2,mean)
    crowds$median<-apply(domain,2,median)
    crowds$gmean<- apply(domain,2,gm_mean)
    crowds$tmean<-apply(domain,2,truncated.mean)
    crowds$tgmean<- apply(domain,2,truncated.gm_mean)
  }
  crowds
}

ranking <-function(x,domain.error,type = "MC"){
  if (type == "MC" || type == "RP"){
    scores<-apply(domain.error,1,sum)
    ranked<-sum(x)
    sum(ranked<=scores)/length(scores)[1]
  } else if (type == "AR"){
    m = dim(domain.error)[1]
    n = dim(domain.error)[2]
    X<- t(matrix(rep(x,m),n,m))
    crowd.rankings<- apply(X>=domain.error,2,sum)/m
    mean(crowd.rankings)
    
  }
}


simple.domain.analysis<-function(domain.id,type = "MC"){
  info<- list()
  
  task.ids<-tasks[tasks$domain_id==domain.id,]$id
  d.answers<-answers[sapply(answers$task_id,function(x){x %in% task.ids}),]
  complete.users<- as.numeric(names(table(d.answers$user_id))[table(d.answers$user_id)==20])
  complete.answers<- d.answers[sapply(d.answers$user_id,function(x){x %in% complete.users}),]
  n.users<- dim(table(complete.answers$user_id))
  domain<- matrix(rep(0,n.users*20),n.users,20)
  n.answers<- dim(complete.answers)[1]
  rownames(domain)<-complete.users
  colnames(domain)<-task.ids
  for ( i in 1:n.answers){
    usr<-as.character(complete.answers$user_id[i])
    tsk<- as.character(complete.answers$task_id[i])
    ans<- as.character(complete.answers$data)[i]
    domain[usr,tsk]<-ans
  }
  if (type =="MC"){
    true.answers<- as.character(tasks[tasks$domain_id==domain.id,]$correct_answer)
    true.answer.matrix<- t(matrix(rep(true.answers,n.users),20,n.users))
    crowds <- aggregate(domain)
    domain.error<- 1-(true.answer.matrix==domain)
    crowd.error<- 1-(true.answers==crowds$mode)
    info$correct<-sum(1-crowd.error)
    info$ranking<-ranking(crowd.error,domain.error)
  } else {
    finished.domain<-apply(domain[apply(domain=="timeout",1,sum)==0,],c(1,2),as.numeric)
    n.users<-dim(finished.domain)[1]
    true.answers<-as.numeric(as.character(tasks[tasks$domain_id==domain.id,]$correct_answer))
    true.answer.matrix<- t(matrix(rep(true.answers,n.users),20,n.users))
    crowds<-aggregate(finished.domain,type = type)
    domain.error<- abs(finished.domain-true.answer.matrix)/(true.answer.matrix+1)
    crowd.error<- lapply(crowds,function(x){abs(x-true.answers)/(true.answers+1)})
    info$mean.error<- lapply(crowd.error,mean)
    info$rank.RP<-lapply(crowd.error,function(x){ranking(x,domain.error,type = "RP")})
    info$rank.AR<-lapply(crowd.error,function(x){ranking(x,domain.error,type = "AR")})    
  }
  info
}


# Multiple Choice Table
domain.name<-c()
crowd.ranking<-c()
crowd.correct<-c()
for (i in 1:dim(domains)[1]){
  domain.id<-domains$id[i]
  if(as.character(unique(tasks[tasks$domain_id==domain.id,]$answer_type))!="int"){
    info<-simple.domain.analysis(domain.id)
    domain.name<-c(domain.name,as.character(domains$name[i]))
    crowd.ranking<-c(crowd.ranking,info$ranking)
    crowd.correct<-c(crowd.correct,info$correct)
  }
}
crowd.ranking.table<-data.frame(domain.name,crowd.ranking,crowd.correct)
names(crowd.ranking.table)<- c("Domain","Crowd Ranking", "Correct Answers")


# Point Estimate Table
by_task <- group_by(answers,task_id, confidence)
by_task_by_confidence <- group_by(by_task, confidence)
output <- summarise(by_task_by_confidence, count = n())