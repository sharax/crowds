library(ggplot2)

# Estimation matrix function

prediction <- function(agent.list,test){
  # Function that creates a matrix M where the (i,j) entry corresponds to the
  # prediction of the ith agent in the jth test case.
  # Input: 
  #   List of dimension n where each element is an agent. An agent takes a test 
  #   dataframe and returns a vector with m predictions.
  # Output:
  #   nxm matrix with predictions
  
  n <- length(agents.list)
  m <- dim(test)[1]
  M <- matrix(rep(0,m*n),m,n) 
  for (i in 1:n){
    M[i,] <- agent.list[i](test)
  }
  return(M)
}

# Computation of error from true value

error <- function(prediction, test,distance){
  # Computes the error from a matrix or a vector of predictions from the test data.
  # Input:
  #   prediction vector or matrix
  #   dataframe with a vector of m predictions
  # Output:
  #   object with same dimension as prediction.
  
  true.value<- test[,1]
  m <- dim(prediction)[1]
  n <- dim(prediction)[2]
  True.Value <- matrix(rep(true.value,m),m,n)
  Error <- distance(prediction,True.Value)
}


# ranking computation

ranking<- function(x,vector){
  # Computes in which percentail the value of x lies with respect to elements in vector
  r <- sum(x>vector)/length(vector)
}

# Main function 

run<- function(train,test,agent.creator,aggregator, error.aggregator, distance,Lambda,
               n.agents,n.info){
  l = length(Lambda) 
  m = dim(train)[2]
  crowd.agg.error<-rep(0,l)
  best.agg.error<-rep(0,l)
  crowd.rank<-rep(0,l)
  for (k in 1:l){
    agent.list<- list()
    for (i in 1:n.agents){
      agent.train<-train[sample(nrow(agent.train),n.info),]
      agent.list[[i]]<-agent.creator(agent.train,Lambda[k])
    }
    best.agent<- agent.creator(train,Lambda[k])
    # Predictions
    pred.agents <- prediction(agent.list,test)
    pred.crowd <- matrix(apply(pred.agents,2,aggregator),1,m)
    pred.best <- prediction(list(best.agent),test)
    
    #Errors
    error.agents <- error(pred.agents,test,distance) 
    error.crowd <- error(pred.crowd,test,distance)
    error.best <- error(pred.best,test,distance)
    
    # Aggregated errors
    agents.agg.error<- error.aggregator(error.agents)
    crowd.agg.error[k]<-error.aggregator(error.crowd)
    best.agg.error[k]<-error.aggregator(error.best)
    crowd.rank[k]<- ranking(crowd.agg.error[k],agents.agg.error)
    
    
  }
}

