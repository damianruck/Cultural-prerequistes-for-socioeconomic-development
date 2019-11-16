mydata<-read.csv('figure3Data/log_multiple_regression.csv')
fit <- lm(opnrat ~ germanic + italic + slavic, data = mydata)#, family = "binomial")
print(summary(fit))

