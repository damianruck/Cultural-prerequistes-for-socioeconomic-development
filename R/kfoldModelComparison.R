library('rstanarm')

options(mc.cores = parallel::detectCores())

warmup <- 500
iter <- 1000

model1  <- 'X ~ t + (1 + t | country)'
model21 <- 'X ~ t + (1 | country) + (0 + t | countryP)'
model22 <- 'X ~ t + (1 | countryP) + (0 + t | country)'
model3  <- 'X ~ t + (1 + t | countryP)'

for (variable in c('COS','RAT')) {

    directory<-paste('regressionFilesModelComparison/',variable,sep='')
    df<-read.table(directory,sep=',',header=TRUE,row.names = 1)

    path <- 'modelComparisonKfold/'
    dir.create(path, showWarnings = FALSE, recursive = TRUE)
    
    
    fit1 <- stan_glmer(model1, data = df,
    prior = normal( 0 , 2 ), prior_intercept = normal(0, 5),  prior_aux = cauchy( 0 , 1 ), 
                       prior_covariance = decov(regularization = 1, concentration = 1, shape = 10, scale = 10),
                     QR = FALSE, warmup=warmup,iter = iter, chains = 4, cores=4) 


    fit21 <- stan_glmer(model21, data = df,
    prior = normal( 0 , 2 ), prior_intercept = normal(0, 5),,  prior_aux = cauchy( 0 , 1 ), 
                       prior_covariance = decov(regularization = 1, concentration = 1, shape = 10, scale = 10),
                     QR = FALSE, warmup=warmup,iter = iter, chains = 4, cores=4) 


    fit22 <- stan_glmer(model22, data = df,
    prior = normal( 0 , 2 ), prior_intercept = normal(0, 5),  prior_aux = cauchy( 0 , 1 ), 
                       prior_covariance = decov(regularization = 1, concentration = 1, shape = 10, scale = 10),
                     QR = FALSE, warmup=warmup,iter = iter, chains = 4, cores=4) 


    fit3 <- stan_glmer(model3, data = df,
    prior = normal( 0 , 2 ), prior_intercept = normal(0, 5),  prior_aux = cauchy( 0 , 1 ), 
                       prior_covariance = decov(regularization = 1, concentration = 1, shape = 10, scale = 10),
                     QR = FALSE, warmup=warmup,iter = iter, chains = 4, cores=4)     
    
    
    kfold1 <- kfold(fit1, K = 2)
    kfold21 <- kfold(fit21, K = 2)
    kfold22 <- kfold(fit22, K =2)
    kfold3 <- kfold(fit3, K = 2)

    cm <- compare_models(kfold1, kfold21, kfold22,kfold3, detail=TRUE)
    DD <- paste(path,variable,sep='')
    write.table(cm,DD,sep=',')
    
    }
