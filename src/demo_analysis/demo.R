library(xtable)

setwd("~/Documents/Sharad/crowds/data/demo_data")
tasks<- read.csv(file = "tasks.tsv", header = TRUE, sep = "\t")
users<- read.csv(file = "users.tsv", header = TRUE, sep = "\t")
domains<- read.csv(file = "domains.tsv", header = TRUE, sep = "\t")
answers<- read.csv(file = "answers.tsv", header = TRUE, sep = "\t")

# Fix spaces in answers
answers$data<-as.character(answers$data)

answers$data<-sapply(answers$data,function(x){
  if(substr(x,1,1)!=" "){x }else{substring(x,2)}})

# Fix Long Domain Names
domains$name<-c("Ball Trick","Historical Landmark","Penalties","Food Calories","Movie Song")



# Aggregation Functions
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
  # Produces the crowd or crowds estimations depending if it is a Multiple Choice question (MC)
  # or a Point Estimate (PE)Question
  # IN
  # domain: mxn matrix 
  #       m is the number of users who answered
  #       n is the number of tasks
  #       domain(i,j) is what user i responded in task j
  # type: MC or PE
  #
  # OUT
  # crowds: list
  #     List containing the crowd's estimate acording to the distinct methods of aggregation
  
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

ranking <-function(x,domain.error,type = "MC", better = FALSE){
  # Computes the ranking (or percentile) of x relative to the rest of the users estimate
  # IN
  # x: matrix 1x20
  #   user (or crowd) error to be ranked
  # domain.error: matrix mxn
  #   matrix of the errors from all users.
  # type: String
  #   MC (Multiple Choice), RP (Relative Performance), AR (Average Ranking)
  # better: boolean
  #   Is True if we want to compute how many did the user (or crowd ) did strictly better than
  if (type == "MC" || type == "RP"){
    scores<-apply(domain.error,1,sum)
    ranked<-sum(x)
    if(better){
      sum(ranked<scores)/length(scores)[1]
    } else {
      sum(ranked<=scores)/length(scores)[1]
    }
  } else if (type == "AR"){
    m = dim(domain.error)[1]
    n = dim(domain.error)[2]
    X<- t(matrix(rep(x,m),n,m))
    if(better){
      crowd.rankings<- apply(X<domain.error,2,sum)/m
      
    } else {
      crowd.rankings<- apply(X<=domain.error,2,sum)/m
      
    }
    mean(crowd.rankings)
    
  }
}


domain.analysis<-function(domain.id,type = "MC",social=-1, better = FALSE){
  # Computes the ranking of the crowd for a specific domain
  # IN
  # domain.id: int
  #   Domain identification number
  # type: String
  #   MC for Multiple Choice, PE for Point Estimate
  # social: int
  #   social condition: 0 for control, 1 for statistics, 2 for last 5 responses, 3 for first 5
  #   responses , 4 for 5 most confident responses.
  # better: boolean
  #   If we are interested in the crowd being strictly better than other users when ranking it.
  info<- list()
  info$possible <- TRUE
  # Creation of domain matrix consisting on task answers per user
  
  task.ids<-tasks[tasks$domain_id==domain.id,]$id
  d.answers<-answers[sapply(answers$task_id,function(x){x %in% task.ids}),]
  complete.users<- as.numeric(names(table(d.answers$user_id))[table(d.answers$user_id)==20])
  if (social>=0){
    social.users<-users$id[users$status==social]
    complete.users<-intersect(social.users,complete.users)
  }
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
  
  # Given the domain matrix, computation of crowd ranking
  if (type =="MC"){
    true.answers<- as.character(tasks[tasks$domain_id==domain.id,]$correct_answer)
    true.answer.matrix<- t(matrix(rep(true.answers,n.users),20,n.users))
    crowds <- aggregate(domain)
    domain.error<- 1-(true.answer.matrix==domain)
    crowd.error<- 1-(true.answers==crowds$mode)
    info$correct<-sum(1-crowd.error)
    info$ranking<-ranking(crowd.error,domain.error,better=better)
  } else {
    if (sum(apply(domain=="timeout",1,sum)==0)>1){
      finished.domain<-apply(domain[apply(domain=="timeout",1,sum)==0,],c(1,2),as.numeric)
      n.users<-dim(finished.domain)[1]
      true.answers<-as.numeric(as.character(tasks[tasks$domain_id==domain.id,]$correct_answer))
      true.answer.matrix<- t(matrix(rep(true.answers,n.users),20,n.users))
      crowds<-aggregate(finished.domain,type = type)
      domain.error<- abs(finished.domain-true.answer.matrix)/(true.answer.matrix+1)
      crowd.error<- lapply(crowds,function(x){abs(x-true.answers)/(true.answers+1)})
      info$mean.error<- lapply(crowd.error,mean)
      info$rank.RP<-lapply(crowd.error,function(x){ranking(x,domain.error,type = "RP",better = better)})
      info$rank.AR<-lapply(crowd.error,function(x){ranking(x,domain.error,type = "AR",better = better)})
      
    } else{
      info$possible<-FALSE
    }
    
    
    
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
    info<-domain.analysis(domain.id, better =  FALSE)
    domain.name<-c(domain.name,as.character(domains$name[i]))
    crowd.ranking<-c(crowd.ranking,info$ranking)
    crowd.correct<-c(crowd.correct,info$correct)
  }
}
MC.table<-data.frame(domain.name,crowd.ranking,crowd.correct)
names(MC.table)<- c("Domain","Crowd Ranking", "Correct Answers")

# Point Estimate Relative Performance Table
info<-domain.analysis(19,type="PE")
RP.table<-data.frame(as.character(domains$name[4]), info$rank.RP$mean,info$rank.RP$median,
                     info$rank.RP$gmean,info$rank.RP$tmean,info$rank.RP$tgmean)
names(RP.table)<-c("Domain","Mean ", "Median ","Geometric Mean ",
                   "Trunc Mean ","TruncGeomMean ")

# Point Estimate Average Ranking Table
info<-simple.domain.analysis(19,type="PE")
AR.table<-data.frame(as.character(domains$name[4]), info$rank.AR$mean,info$rank.AR$median,
                     info$rank.AR$gmean,info$rank.AR$tmean,info$rank.AR$tgmean)
names(AR.table)<-c("Domain","Mean ", "Median ","Geometric Mean ",
                   "Trun Mean ","Trunc GeomMean Ranking")

# Latex Format


xtable(MC.table, caption = "Multiple Choice domains. The Crowd Ranking column 
       contains the percentage of users the crowd performs equal or better than. Correct
       Answers is the number of answers the crowd got right.")
xtable(RP.table, caption = " Point estimate domains ranked according to relative performance.
       Columns represent the ranking by using the corresponding method of aggregation. Relative 
       performance of a user is the sum of the normalized errors.")
xtable(AR.table, caption = " Point estimate domains ranked according to average ranking.
       Columns represent the ranking by using the corresponding method of aggregation. Average ranking 
       takes the mean of the crowd percentiles for each task.")
##########################################################################################
# Social Conditions

# Multiple Choice Table
domain.name<-c()
for (i in 1:dim(domains)[1]){
  domain.id<-domains$id[i]
  if(as.character(unique(tasks[tasks$domain_id==domain.id,]$answer_type))!="int"){
    domain.name<-c(domain.name,as.character(domains$name[i]))
  }
}
MC.social<-data.frame(domain.name)

for (j in 2:6){
  soc<-c()
  for (i in 1:dim(domains)[1]){
    domain.id<-domains$id[i]
    if(as.character(unique(tasks[tasks$domain_id==domain.id,]$answer_type))!="int"){
      info<-domain.analysis(domain.id, social=j-2)
      soc<- c(soc,info$ranking)
    }
  }
  MC.social[,j]<-soc
}


names(MC.social)<- c("Domain", "Control","Median,IQR,Count","Recent 5","First 5","5 Confident")
xtable(MC.social)


# Point Estimate Relative Performance Table
RP.social<- data.frame(food = c("Control","Median,IQR,Count","Recent 5","First 5","5 Confident"))
RP.mean<-c()
RP.median<-c()
RP.gmean<-c()
RP.tmean<-c()
RP.tgmean<-c()

for( i in 1:5){
  info<-domain.analysis(19,type="PE",social = i-1)
  if (info$possible){
    RP.mean<-c(RP.mean,info$rank.RP$mean)
    RP.median<-c(RP.median,info$rank.RP$median)
    RP.gmean<-c(RP.gmean,info$rank.RP$gmean)
    RP.tmean<-c(RP.tmean,info$rank.RP$tmean)
    RP.tgmean<-c(RP.tgmean,info$rank.RP$tgmean)
  } else{
    RP.mean<-c(RP.mean,NaN)
    RP.median<-c(RP.median,NaN)
    RP.gmean<-c(RP.gmean,NaN)
    RP.tmean<-c(RP.tmean,NaN)
    RP.tgmean<-c(RP.tgmean,NaN)
  }
  
  
}
RP.social$Mean<-RP.mean
RP.social$Median<-RP.median
RP.social$Gmean<-RP.gmean
RP.social$Tmean<-RP.tmean
RP.social$Tgmean<-RP.tgmean

names(RP.social)<-c("Calories RP","Mean ", "Median ","Geometric Mean ",
                   "Trunc Mean ","TruncGeomMean ")

# Point Estimate Average Ranking Table
AR.social<- data.frame(food = c("Control","Median,IQR,Count","Recent 5","First 5","5 Confident"))
AR.mean<-c()
AR.median<-c()
AR.gmean<-c()
AR.tmean<-c()
AR.tgmean<-c()

for( i in 1:5){
  info<-domain.analysis(19,type="PE",social = i-1)
  if (info$possible){
    AR.mean<-c(AR.mean,info$rank.AR$mean)
    AR.median<-c(AR.median,info$rank.AR$median)
    AR.gmean<-c(AR.gmean,info$rank.AR$gmean)
    AR.tmean<-c(AR.tmean,info$rank.AR$tmean)
    AR.tgmean<-c(AR.tgmean,info$rank.AR$tgmean)
  } else{
    AR.mean<-c(AR.mean,NaN)
    AR.median<-c(AR.median,NaN)
    AR.gmean<-c(AR.gmean,NaN)
    AR.tmean<-c(AR.tmean,NaN)
    AR.tgmean<-c(AR.tgmean,NaN)
  }
  
  
}
AR.social$Mean<-AR.mean
AR.social$Median<-AR.median
AR.social$Gmean<-AR.gmean
AR.social$Tmean<-AR.tmean
AR.social$Tgmean<-AR.tgmean

names(AR.social)<-c("Calories AR","Mean ", "Median ","Geometric Mean ",
                    "Trunc Mean ","TruncGeomMean ")
