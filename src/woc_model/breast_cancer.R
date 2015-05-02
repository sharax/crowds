setwd("~/Documents/Sharad/crowds/src/woc_model")


source("aggregator.R")
library(rpart)
library(mlbench)


# Load Data
# The variable to predict must be called "y".
data(BreastCancer)
BreastCancer$Id<-NULL
BreastCancer$y <- as.numeric(BreastCancer$Class=="malignant" )
BreastCancer$Class<-NULL


# Randomize data
BreastCancer<-BreastCancer[sample(dim(BreastCancer)[1]),]
BreastCancer$row.names<-NULL

# Define Training data
ptr<- 2/3
train <- BreastCancer[1:ceiling(ptr*dim(BreastCancer)[1]),]

# Define Test data
test <- BreastCancer[(ceiling(ptr*dim(BreastCancer)[1])+1):dim(BreastCancer)[1],]

# Define Agent Creator

agent.creator <- function(agent.train,lambda){
  tree <- rpart(y ~ ., method="class",data = agent.train, control = rpart.control(maxdepth = lambda))
  agent <- function(x){
    predict(tree,newdata = x, type = "class")
  }
}

# Aggregation Function
# Mode
aggregator <- function(x) {
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}

# Error Aggregator
error.aggregator<- mean

# Distance for error
distance<- function(a,b){ 
  1-(a==b)
}

# Define Lambda
Lambda<-c(1,2,3,4)

# Number of agents
n.agents<- 10

# Number of observations seen by each agent
n.info<- 50

aux<- run(train,test,agent.creator,aggregator,error.aggregator,distance,Lambda,
          n.agents,n.info)


# Best Classification Tree
best.cart <- rpart(y~., data = train, method = "class")
best.cart <- prune(best.cart,cp = best.cart$cptable[which.min(best.cart$cptable[,"xerror"]),"CP"])
pred.best.cart <- predict(best.cart,newdata = test, type = "class")
error.best.cart <- 1-sum(as.numeric(pred.best.cart==1)==test$y)/dim(test)[1]

# Best Random Forest 



