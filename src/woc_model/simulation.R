library(data.table)
library(glmnet)
library(ggplot2)

#Creation of model
create_model<- function(n,mu,sigma){
  beta<- runif(n)
  fun<- function(x){
    return(x%*%beta + rnorm(n,mu,sigma))
  }
  return(list(fun,beta))
}

model_agent<- function(train,n.train,p,lambda){
  
  a.train <- train[sample(n.train,p),]
  y<- as.matrix(a.train[,1])
  x<- as.matrix(a.train[,-1])
  agent<-glmnet(x=x,y=y,family="gaussian",lambda=lambda)
  return(agent)
  
}

model_dist_agent<- function(train,n.train,m,p,nfeat){
  feat<-sample(m-1,nfeat)+1
  a.train <- train[sample(n.train,p),]
  y<- as.matrix(a.train[,1])
  x<- as.matrix(a.train[,-1])
  data <-data.frame(y,x)[,feat]
  fit<- lm(y~.,data = data)
  agent<-function(x){
    x<-data.frame(x)[,feat-1]
    pred<- predict(fit,newdata=x)
    return(pred)
  }
  return(agent)
  
}
create_agents<- function(n.agents,train,n.train,obs,lambda){
  agents<-list()
  for (i in 1:n.agents){
    agents[[i]]<-model_agent(train,n.train,obs[i],lambda)
  }
  return(agents)
}

create_distracted_agents<-function(n.agents,train,n.train,m,obs,nfeat){
  agents<-list()
  for (i in 1:n.agents){
    agents[[i]]<-model_dist_agent(train,n.train,m,obs[i],nfeat)
  }
  return(agents)
}

agents_predictions<- function(x,agents,n.agents,n.lambda){
  predictions<- matrix(rep(0,n.agents*n.lambda),n.agents,n.lambda)
  for (i in 1:n.agents){
    pred<-predict(agents[[i]],newx=x)
    predictions[i,]<-pred
  }
  return(t(predictions))
}
dist_agents_predictions<- function(x,agents,n.agents){
  predictions<- rep(0,n.agents)
  for (i in 1:n.agents){
    pred<-agents[[i]](x)
    predictions[i]<-pred
  }
  return(predictions)
}

dist_crowd_estimates<- function(test,n.test,agents,n.agents,fun=mean){
  
  crowd<-data.frame(V1=0)
  for (i in 1:n.test){
    y<- as.matrix(test[i,1])
    x<- as.matrix(test[i,-1])
    pred<- dist_agents_predictions(x,agents,n.agents)
    #crowd[,i]<-rowMeans(pred)
    crowd[,i]<-sum((fun(pred)-y)*rep(1,length(pred))<abs(pred-y))/n.agents
  }
  crowd<-as.matrix(crowd)
  
}



crowd_estimates<- function(test,n.test,agents,n.agents,n.lambda,fun){
  
  crowd<-data.frame(V1=rep(0,n.lambda))
  for (i in 1:n.test){
    y<- as.matrix(test[i,1])
    x<- as.matrix(test[i,-1])
    y<- rep(y,n.lambda)
    pred<- agents_predictions(x,agents,n.agents,n.lambda)
    #crowd[,i]<-rowMeans(pred)
    crowd[,i]<-rowSums(abs(apply(pred,1,fun)-y)<abs(pred-y))/n.agents
  }
  crowd<-as.matrix(crowd)
  
}



# Number of features
m<-10
# Number of observations
n.train<-100
n.test<- 10
# Number of agents
n.agents<-10
# Mean and variance of noise
mu<- 0
sigma<-1
# Number of observations each agent has access to
obs<- ceiling(runif(n.agents)*10)+10


# Create  data
features.train<-matrix(rnorm(m*n.train),n.train)
features.test<-matrix(rnorm(m*n.test),n.test)
model<- create_model(m,mu,sigma)
y.train<- model[[1]](features.train)
y.test<- model[[1]](features.test)
train<- data.frame(y.train,features.train)
test<- data.frame(y.test,features.test)


# Best fitted line
fit<-lm(y.train~.,data=train)
est_coef<-coef(fit)
real_coef<-model[[2]]

#lambda<-exp(seq(0,20,.4))-1
lambda<-seq(0,1,0.01)
# Number of elements in lambda
n.lambda<- length(lambda)

agents <- create_agents(n.agents,train,n.train,obs,lambda)
crowd <- crowd_estimates(test,n.test,agents,n.agents,n.lambda,mean)


aux=data.frame(lambda=lambda,m=apply(crowd,1,mean),s=apply(crowd,1,sd)/sqrt(1000))
ggplot(aux,aes(x=lambda,y=m))+geom_point()

# Distracted Agents
#Number of features agents will observe
nfeat<-4
dist.agents <- create_distracted_agents(n.agents,train,n.train,m,obs,nfeat)
dist.crowd <- dist_crowd_estimates(test,n.test,dist.agents,n.agents,mean)


