
bank <- read.csv("C:\\Users\\DELL\\Documents\\Msc R\\lab files\\projectI.csv", header=TRUE)
str(bank)
library(DataExplorer)
introduce(bank)

library(dplyr)

# Remove duplicate rows of the dataframe
bank <- bank %>% distinct()

# convert to the correct data type
bank$age <- cut(bank$age,breaks=c(16,34,64,99),labels=c('youth','middle.age','elderly'))
bank$age <- factor(bank$age)
bank$job <- as.factor(bank$job)
bank$marital <- as.factor(bank$marital)
education <- function(education){
  if (education=='basic.4y'|education=='basic.6y'|education=='basic.9y'|education=='illiterate'){
    return('basic')
  }else if (education=='high.school'|education=='professional.course'){
    return('intermediate')
  }else if(education=='university.degree'){
    return('advanced')
  }else{
    return(education)
  }
}
bank$education <- sapply(bank$education,education)
bank$education <- as.factor(bank$education)
bank$default<- as.factor(bank$default)
bank$housing<- as.factor(bank$housing)
bank$loan<- as.factor(bank$loan)
bank$contact <- as.factor(bank$contact)
bank$month <- as.factor(bank$month)
bank$day_of_week <- as.factor(bank$day_of_week)
bank$poutcome <- as.factor(bank$poutcome)
bank$pdays <- ifelse(bank$pdays==999, 0, 1)
bank$pdays <- factor(bank$pdays,labels=c("not previously contacted","previously contacted"))
table(bank$pdays)
table(bank$poutcome)
bank$pdays <- NULL #I remove it because it provides similar information with poutcome (poutcome "non existent" same with pdays "not previously contacted")
bank$SUBSCRIBED <- ifelse(bank$SUBSCRIBED== "yes", 1, 0)
bank$SUBSCRIBED <- factor(bank$SUBSCRIBED,labels=c('fail','success'))


####################### Univariate analysis ############################

# split data frame into numeric and categorical data frames
cat.bank <- bank[,c(1:10,14,20)]
num.bank <- bank[,c(11:13,15:19)]
colnames(cat.bank) <- c('age group','job','marital status','education','default','mortgage','loan','contact','month','day of week','previous outcome','subscribed')
colnames(num.bank) <- c('duration','campaign','number of past calls','employment variation rate','consumer price index','consumer confidence index','euribor 3m rate','number of employees')

# descriptive statistics of quantitative variables
library(sjPlot)
library(sjmisc)
library(sjlabelled)
library(psych)
tab_df(describe(num.bank), show.rownames = T)

# histograms of quantitative variables
par(mfrow = c(3,3))
for (i in 1:8) { 
  hist(num.bank[,i], xlab = names(num.bank)[i], col = 'seashell', main = paste("Average", names(num.bank[i]), '= ', signif(mean(num.bank[[i]]),3)), probability = TRUE)
  lines(density(num.bank[,i]), col=2)
  index <-seq(min(num.bank[,i]), max(num.bank[,i]), length.out=100)
  ynorm <- dnorm(index, mean=mean(num.bank[,i]), sd(num.bank[,i]))
  lines(index, ynorm, col='cadetblue', lty=3, lwd=3)
}

# vioplots of quantitative variables
library(vioplot)
par(mfrow=c(3,3))
for (i in 1:8) { 
  vioplot(num.bank[,i], col = 'seashell', main = names(num.bank)[i])
  }

# bar plots of qualitative variables
library(RColorBrewer)
coul <- brewer.pal(7, "PuBuGn") 
par(mfrow=c(4,3))
for (i in 1:12) { 
barplot(prop.table(sort(table(cat.bank[,i]),decreasing=T)), col=coul,main = names(cat.bank)[i])
  }


####################### Pairwise comparisons ############################

#Visualization of bivariate associations

#bar plots of associations 
par(mfrow=c(2,2))
barplot(prop.table(table(cat.bank$subscribed,cat.bank$`age group`)), main="Age group by outcome of call",
        xlab="Age group", col=c("khaki","lightskyblue2"),beside=TRUE)

legend("topright",legend=c("Not Subscribed","Subscribed"),fill=c("khaki","lightskyblue2")
       ,cex=0.7,bty="n")


barplot(prop.table(table(cat.bank$subscribed,cat.bank$job)), main="Job type by outcome of call",
        xlab="Job type", col=c("khaki","lightskyblue2"),beside=TRUE)

legend("topright",legend=c("Not Subscribed","Subscribed"),fill=c("khaki","lightskyblue2")
       ,cex=0.7,bty="n")


barplot(prop.table(table(cat.bank$subscribed,cat.bank$marital)), main="Marital status by outcome of call",
        xlab="Marital", col=c("khaki","lightskyblue2"),beside=TRUE)

legend("topright",legend=c("Not Subscribed","Subscribed"),fill=c("khaki","lightskyblue2")
       ,cex=0.7,bty="n")


barplot(prop.table(table(cat.bank$subscribed,cat.bank$education)), main="Education by outcome of call",
        xlab="Education", col=c("khaki","lightskyblue2"),beside=TRUE)

legend("topright", inset=-.05, legend=c("Not Subscribed","Subscribed"),fill=c("khaki","lightskyblue2")
       ,cex=0.6,bty="n")

par(mfrow=c(2,2))
barplot(prop.table(table(cat.bank$subscribed,cat.bank$default)), main="Default status by outcome of call",
        xlab="Default", col=c("khaki","lightskyblue2"),beside=TRUE)

legend("topright",legend=c("Not Subscribed","Subscribed"),fill=c("khaki","lightskyblue2")
       ,cex=0.7,bty="n")


barplot(prop.table(table(cat.bank$subscribed,cat.bank$mortgage)), main="Housing loan by outcome of call",
        xlab="Mortgage", col=c("khaki","lightskyblue2"),beside=TRUE)

legend('top', legend=c("Not Subscribed","Subscribed"),fill=c("khaki","lightskyblue2")
       ,cex=0.7,bty="n")


barplot(prop.table(table(cat.bank$subscribed,cat.bank$loan)), main="Personal loan by outcome of call",
        xlab="Loan", col=c("khaki","lightskyblue2"),beside=TRUE)

legend("topright",legend=c("Not Subscribed","Subscribed"),fill=c("khaki","lightskyblue2")
       ,cex=0.7,bty="n")


barplot(prop.table(table(cat.bank$subscribed,cat.bank$contact)), main="Contact type by outcome of call",
        xlab="Contact", col=c("khaki","lightskyblue2"),beside=TRUE)

legend("topright",legend=c("Not Subscribed","Subscribed"),fill=c("khaki","lightskyblue2")
       ,cex=0.7,bty="n")


par(mfrow=c(2,2))
barplot(prop.table(table(cat.bank$subscribed,cat.bank$month)), main="Month by outcome of call",
        xlab="Month", col=c("khaki","lightskyblue2"),beside=TRUE)

legend("topleft", legend=c("Not Subscribed","Subscribed"),fill=c("khaki","lightskyblue2")
       ,cex=0.7,bty="n")


barplot(prop.table(table(cat.bank$subscribed,cat.bank$`day of week`)), main="Day of week by outcome of call",
        xlab="Day of week", col=c("khaki","lightskyblue2"),beside=TRUE)


barplot(prop.table(table(cat.bank$subscribed,cat.bank$`previous outcome`)), main="Previous outcome by outcome of call",
        xlab="Previous outcome", col=c("khaki","lightskyblue2"),beside=TRUE)

legend("topleft",legend=c("Not Subscribed","Subscribed"),fill=c("khaki","lightskyblue2")
       ,cex=0.7,bty="n")


#correlation matrix
library(ggcorrplot)
ggcorrplot(cor(num.bank), type = "lower", lab = TRUE, insig = "blank")

#boxplots of associations
library(ggpubr)
library(gridExtra)
bank2<-num.bank
bank2$subscribed<- bank$SUBSCRIBED
b1<-ggboxplot(bank2, x = "subscribed", y = "duration", col="subscribed", main="Duration by outcome of call")
b2<-ggboxplot(bank2, x = "subscribed", y = "campaign", col="subscribed", main="Number of contacts during campaign by outcome of call")
b3<-ggboxplot(bank2, x = "subscribed", y = "number of past calls", col="subscribed", main="Number of past calls by outcome of call")
b4<-ggboxplot(bank2, x = "subscribed", y = "employment variation rate", col="subscribed", main="Employment variation rate by outcome of call")
b5<-ggboxplot(bank2, x = "subscribed", y = "consumer price index", col="subscribed", main="Consumer price index by outcome of call")
b6<-ggboxplot(bank2, x = "subscribed", y = "consumer confidence index", col="subscribed", main="Consumer confidence index by outcome of call")
b7<-ggboxplot(bank2, x = "subscribed", y = "euribor 3m rate", col="subscribed", main="Euribor 3m rate by outcome of call")
b8<-ggboxplot(bank2, x = "subscribed", y = "number of employees", col="subscribed", main="Number of employees by outcome of call")
grid.arrange(b1,b2,b3,b4)
grid.arrange(b5,b6,b7,b8)

################################# Model Selection ###############################

full.model<- glm(SUBSCRIBED~.,bank,family=binomial)
summary(full.model)

library(glmnet)
X <- model.matrix(SUBSCRIBED ~., bank)[,-1] 
y <- bank$SUBSCRIBED

#fit lasso
lasso3 <- cv.glmnet(X, y, alpha = 1,family=binomial)
plot(lasso3)
plot(lasso3$glmnet.fit, xvar = "lambda")
abline(v=log(c(lasso1$lambda.min, lasso1$lambda.1se)), lty =2)
coef(lasso3,s='lambda.1se',exact=TRUE)
lasso1$lambda.min 
lasso1$lambda.1se 
lasso.model <- glm(SUBSCRIBED~.-housing -loan -previous -cons.price.idx -euribor3m, data = bank, family = binomial()) # model with lasso selected variables 
summary(lasso.model) 
#remove non statistically important variables 
lasso.model2 <- glm(SUBSCRIBED~.-housing -loan -marital -contact -previous -cons.price.idx -cons.conf.idx -euribor3m, data = bank, family = binomial())
summary(lasso.model2)

Anova(lasso.model2, type="II", test="Wald") #anova type II test

bic.model <- step(lasso.model2,direction="both",k=log(nrow(bank))) #model with BIC variable selection 
summary(bic.model) 

library(car)
vif(bic.model) # check for multicollinearity 

step.model1 <- glm(SUBSCRIBED~age+default+month+duration+campaign+poutcome+nr.employed, data = bank, family = binomial())  # model with lasso selected variables 
summary(step.model1)
vif(step.model1) # multicollinearity is fixed by removing emp.var.rate

with(step.model1, null.deviance - deviance) #9972
with(step.model1, df.null - df.residual) #18
with(step.model1, pchisq(null.deviance - deviance, df.null - df.residual, lower.tail = FALSE)) #0
logLik(step.model1) #-7972(df=19)

library(pscl)
p <- pR2(step.model1)
format(p, scientific = FALSE)

aic.model <- step(lasso.model2, direction = "both") #model with AIC variable selection 
summary(aic.model) 
vif(aic.model) #remove emp.var.rate

step.model2 <- glm(SUBSCRIBED~age+job+default+month+duration+campaign+poutcome+nr.employed, data = bank, family = binomial())  
summary(step.model2)
vif(step.model2) #fixed
with(step.model2, null.deviance - deviance) #10019
with(step.model2, df.null - df.residual) #29
with(step.model2, pchisq(null.deviance - deviance, df.null - df.residual, lower.tail = FALSE)) #0
logLik(step.model2) #-7949.39 (df=30)

#Pseudo R2
p <- pR2(step.model2)
format(p, scientific = FALSE)

#summary of step.model2
library(stargazer)
stargazer(step.model2,title="Final Model",align=TRUE,single.row=T,
          out="C:\\Users\\DELL\\Documents\\Msc R\\table.htm")

#interpretation of coefficients
exp(cbind(OR = coef(step.model2), confint(step.model2)))

#####################Assumptions#############################
plot(step.model2, which = 4, id.n = 3) #influential points checked

vif(step.model2) #multicollinearity checked

library(tidyverse)
# Select only numeric predictors
bank3 <- as.data.frame(num.bank[,1])
colnames(bank3) <- 'duration'
predictors <- 'duration'
probabilities <- predict(step.model2, type = "response")
# Bind the logit and tidying the data for plot
bank3 <- bank3 %>%
  mutate(logit = log(probabilities/(1-probabilities))) %>%
  gather(key = "predictors", value = "predictor.value", -logit)
ggplot(bank3, aes(logit, predictor.value))+
  geom_point(size = 0.5, alpha = 0.5) +
  geom_smooth(method = "loess") + 
  theme_bw() + 
  facet_wrap(~predictors, scales = "free_y") #linearity of numeric predictor checked


library(broom)
bankr <- augment(step.model2) %>% 
  mutate(index = 1:n()) 
ggplot(bankr, aes(index, .std.resid)) + 
  geom_point(aes(color = SUBSCRIBED), alpha = .5) +
  theme_bw() #independence of residuals checked
