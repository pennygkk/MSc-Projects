################################## REDIS ###################################

#Remote Connection
library("redux")
r <- redux::hiredis(redux::redis_config(host = "127.0.0.1",port = "6379"))
emails_sent<-read.csv(file.choose(),header=T)
mod_listings<-read.csv(file.choose(),header=T)

#1.1

#we create a separate data frame, from modified listings data frame, that includes only the respective data for January.
Jan_mod<- mod_listings[which(mod_listings$MonthID==1),]

for (i in 1:nrow(Jan_mod)){
  
    if (Jan_mod$ModifiedListing[i]==1) { r$SETBIT("ModificationsJanuary",i,"1")}
  
}

r$BITCOUNT("ModificationsJanuary") #9969 users modified their listing on January

#1.2

r$BITOP("NOT","NOT_ModificationsJanuary","ModificationsJanuary")
r$BITCOUNT("NOT_ModificationsJanuary") #10031 users did not modify their listing in January

length(Jan_mod$UserID) #19999
TTL<-sum(r$BITCOUNT("NOT_ModificationsJanuary"),r$BITCOUNT("ModificationsJanuary")) #20000
# 1 byte consists of 8 bits, thus to interpret the output of BITCOUNT operation from bits to bytes we need to divide with 8, so system creates one more bit
#to have zero remainder (19,999/8 =2499,67, 20,000/8= 2500)


#1.3

library(dplyr)

emails_sent["Total_emails"]<-1

#group emails by user and month
Emails<-emails_sent %>% group_by(UserID,MonthID) %>% summarize_at("Total_emails",sum)

#create three new columns
Emails["January"]<-0
Emails["February"]<-0
Emails["March"]<-0

#assign emails to columns according to month
for (i in 1:nrow(Emails)){
  
  if (Emails$MonthID[i]==1) {Emails$January[i]=Emails$Total_emails[i]}
  else if (Emails$MonthID[i]==2) {Emails$February[i]=Emails$Total_emails[i]}
  else if (Emails$MonthID[i]==3) {Emails$March[i]=Emails$Total_emails[i]}
  
}

Emails<-Emails[,-c(2,3)]

#summarize by userID
Emails<-Emails %>% group_by(UserID) %>% summarize_all(sum)

#replace with one if the user has received at least one e-mail per month and zero if they have not received any
for (i in 1:nrow(Emails)) {
  
  if (Emails$January[i]>0) {Emails$January[i]=1}
  else {Emails$January[i]=0}
}
for (i in 1:nrow(Emails)) {
  
  if (Emails$February[i]>0) {Emails$February[i]=1}
  else {Emails$February[i]=0}
}
for (i in 1:nrow(Emails)) {
  
  if (Emails$March[i]>0) {Emails$March[i]=1}
  else {Emails$March[i]=0}
}

#create BITMAPs for each month
for (i in 1:nrow(Emails)){
  
  if (Emails$January[i]==1) { r$SETBIT("Emails_in_January",i,"1")}
  
}
for (i in 1:nrow(Emails)){
  
  if (Emails$February[i]==1) { r$SETBIT("Emails_in_February",i,"1")}
  
}
for (i in 1:nrow(Emails)){
  
  if (Emails$March[i]==1) { r$SETBIT("Emails_in_March",i,"1")}
  
}

r$BITOP("AND","One_or_more_in_3M",c("Emails_in_January","Emails_in_February","Emails_in_March"))
r$BITCOUNT("One_or_more_in_3M") # 2,668 users with at least one email per month

#1.4

r$BITOP("NOT","NOT_Emails_in_February","Emails_in_February")
r$BITOP("AND","Jan&Mar",c("Emails_in_January","Emails_in_March"))

r$BITOP("AND","Jan&March_AND_NOT_Feb",c("NOT_Emails_in_February","Jan&Mar"))
r$BITCOUNT("Jan&March_AND_NOT_Feb") #2417 users received an e-mail on January and March but not on February

#1.5

#subset of emails sent in January
Jan<- emails_sent[which(emails_sent$MonthID==1),-c(1,3)]
#create a data frame with the sum of opened emails for each user in January
Emails.Jan<-Jan %>% group_by(UserID) %>% summarize_at("EmailOpened",sum)
Emails.Jan<-as.data.frame(Emails.Jan)

#replace the sum of opened emails with 0 in case they have opened at least one email
#and with 1 in case they have not opened any
for (i in 1:nrow(Emails.Jan)){
  if(Emails.Jan[i,2]!=0){Emails.Jan[i,2]=0}
  else{Emails.Jan[i,2]=1}
}

#bitmap for not opened emails in January
for (i in 1:nrow(Emails.Jan)){
  r$SETBIT("EmailsNotOpenedInJanuary",Emails.Jan[i,1],Emails.Jan[i,2])
}

r$BITCOUNT("EmailsNotOpenedInJanuary") #3972 users have not opened any emails in January

#subset of modified listings in January
Jan_mod2<- mod_listings[which(mod_listings$MonthID==1),-2]

#bitmap for modified listings in January
for (i in 1:nrow(Jan_mod2)){
  r$SETBIT("ModificationsJanuary2",Jan_mod2[i,1],Jan_mod2[i,2])
}

r$BITCOUNT("ModificationsJanuary2") #9969 users have modified their listing in January

#perform AND operation in order to consolidate the information derived from the previous two bitmaps and
#calculate the users that received an email on January which they did not open but they updated their listing anyway
r$BITOP("AND","JanNotOpenedButUpdated",c("ModificationsJanuary2","EmailsNotOpenedInJanuary"))
j1<- r$BITCOUNT("JanNotOpenedButUpdated") #1961 users

#1.6

#subset of emails sent in February
Feb<- emails_sent[which(emails_sent$MonthID==2),-c(1,3)]
#create a data frame with the sum of opened emails for each user in February
Emails.Feb<-Feb %>% group_by(UserID) %>% summarize_at("EmailOpened",sum)
Emails.Feb<-as.data.frame(Emails.Feb)

#replace the sum of opened emails with 0 in case they have opened at least one email
#and with 1 in case they have not opened any
for (i in 1:nrow(Emails.Feb)){
  if(Emails.Feb[i,2]!=0){Emails.Feb[i,2]=0}
  else{Emails.Feb[i,2]=1}
}

#bitmap for not opened emails in February
for (i in 1:nrow(Emails.Feb)){
  r$SETBIT("EmailsNotOpenedInFebruary",Emails.Feb[i,1],Emails.Feb[i,2])
}

r$BITCOUNT("EmailsNotOpenedInFebruary") #3945 users have not opened any emails in February


#subset of modified listings in February
Feb_mod<- mod_listings[which(mod_listings$MonthID==2),-2]

#bitmap for modified listings in February
for (i in 1:nrow(Feb_mod)){
  r$SETBIT("ModificationsFebruary",Feb_mod[i,1],Feb_mod[i,2])
}

r$BITCOUNT("ModificationsFebruary") #10007 users have modified their listing in February

#perform AND operation in order to consolidate the information derived from the previous two bitmaps and
#calculate the users that received an email on February which they did not open but they updated their listing anyway
r$BITOP("AND","FebNotOpenedButUpdated",c("ModificationsFebruary","EmailsNotOpenedInFebruary"))
f1<- r$BITCOUNT("FebNotOpenedButUpdated") #1971 users 

#subset of emails sent in March
Mar<- emails_sent[which(emails_sent$MonthID==3),-c(1,3)]
#create a data frame with the sum of opened emails for each user in March
Emails.Mar<-Mar %>% group_by(UserID) %>% summarize_at("EmailOpened",sum)
Emails.Mar<-as.data.frame(Emails.Mar)

#replace the sum of opened emails with 0 in case they have opened at least one email
#and with 1 in case they have not opened any
for (i in 1:nrow(Emails.Mar)){
  if(Emails.Mar[i,2]!=0){Emails.Mar[i,2]=0}
  else{Emails.Mar[i,2]=1}
}

#bitmap for not opened emails in March
for (i in 1:nrow(Emails.Mar)){
  r$SETBIT("EmailsNotOpenedMarch",Emails.Mar[i,1],Emails.Mar[i,2])
}

r$BITCOUNT("EmailsNotOpenedMarch") #3948 users have not opened any emails in March


#subset of modified listings in March
Mar_mod<- mod_listings[which(mod_listings$MonthID==3),-2]

#bitmap for modified listings in February
for (i in 1:nrow(Mar_mod)){
  r$SETBIT("ModificationsMarch",Mar_mod[i,1],Mar_mod[i,2])
}

r$BITCOUNT("ModificationsMarch") #9991 users have modified their listing in March

#perform AND operation in order to consolidate the information derived from the previous two bitmaps and
#calculate the users that received an email on March which they did not open but they updated their listing anyway
r$BITOP("AND","MarNotOpenedButUpdated",c("ModificationsMarch","EmailsNotOpenedMarch"))
m1<- r$BITCOUNT("MarNotOpenedButUpdated") #1966 users 

#perform OR operation in order to consolidate the information derived from the three bitmaps regarding January,February,March and
#calculate the users that received an email on January that they did not open but they updated their listing anyway on January 
#OR they received an e-mail on February that they did not open but they updated their listing anyway on February 
#OR they received an e-mail on March that they did not open but they updated their listing anyway on March
r$BITOP("OR","JanFebMarNotOpenedButUpdated",c("JanNotOpenedButUpdated","FebNotOpenedButUpdated","MarNotOpenedButUpdated"))
r$BITCOUNT("JanFebMarNotOpenedButUpdated") #5249 users 

#1.7

#bitmap for opened emails in January
for (i in 1:nrow(Emails.Jan)){
  if (Emails.Jan[i,2]=="0"){
  r$SETBIT("EmailsOpenedInJanuary",Emails.Jan[i,1],"1")
  }
  else{r$SETBIT("EmailsOpenedInJanuary",Emails.Jan[i,1],"0")}
}
r$BITCOUNT("EmailsOpenedInJanuary")

r$BITOP("AND","JanOpenedButUpdated",c("ModificationsJanuary2","EmailsOpenedInJanuary"))
j2<- r$BITCOUNT("JanOpenedButUpdated") #2797 users opened email and updated their listing on January

#bitmap for opened emails in February
for (i in 1:nrow(Emails.Feb)){
  if (Emails.Feb[i,2]=="0"){
    r$SETBIT("EmailsOpenedInFebruary",Emails.Feb[i,1],"1")
  }
  else{r$SETBIT("EmailspOpenedInFebruary",Emails.Feb[i,1],"0")}
}
r$BITCOUNT("EmailsOpenedInFebruary")

r$BITOP("AND","FebOpenedButUpdated",c("ModificationsFebruary","EmailsOpenedInFebruary"))
f2<- r$BITCOUNT("FebOpenedButUpdated") #2874 users opened email and updated their listing on February

#bitmap for opened emails in March
for (i in 1:nrow(Emails.Mar)){
  if (Emails.Mar[i,2]=="0"){
    r$SETBIT("EmailsOpenedInMarch",Emails.Mar[i,1],"1")
  }
  else{r$SETBIT("EmailsOpenedInMarch",Emails.Mar[i,1],"0")}
}
r$BITCOUNT("EmailsOpenedInMarch")

r$BITOP("AND","MarOpenedButUpdated",c("ModificationsMarch","EmailsOpenedInMarch"))
m2<- r$BITCOUNT("MarOpenedButUpdated") #2783 users opened email and updated their listing on March

#sum the previous results for all three months
TotalNotOpenedButUpdated <- j1+f1+m1 #5898 users did not open any email and updated their listing
TotalOpenedButUpdated <- j2+f2+m2 #8454 users opened email and updated their listing

#find total users who modified their listings
mod<- mod_listings[which(mod_listings$ModifiedListing==1),]
uniq.user<- length(unique(mod$UserID)) #17541 users

#find percentages
perc.not.opened <- (TotalNotOpenedButUpdated/uniq.user)*100 #33.6%
perc.opened <- (TotalOpenedButUpdated/uniq.user)*100 #48.2%

