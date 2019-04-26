library('rethinking')


# my trace plot function
#rethink_palette <- c("#5BBCD6","#F98400","#F2AD00","#00A08A","#FF0000")
rethink_palette <- c("#8080FF","#F98400","#F2AD00","#00A08A","#FF0000")
rethink_cmyk <- c(col.alpha("black",0.25),"cyan")
tracerplot <- function( object , pars , col=rethink_palette , alpha=1 , bg=col.alpha("black",0.15) , ask=TRUE , window , n_cols=3 , max_rows=5 , ... ) {

 
    # get all chains, not mixed, from stanfit
    if ( missing(pars) )
        post <- extract(object,permuted=FALSE,inc_warmup=TRUE)
    else
        post <- extract(object,pars=pars,permuted=FALSE,inc_warmup=TRUE)
    
    # names
    dimnames <- attr(post,"dimnames")
    chains <- dimnames$chains
    pars <- dimnames$parameters
    chain.cols <- rep_len(col,length(chains))
    # cut out "dev" and "lp__"
    wdev <- which(pars=="dev")
    if ( length(wdev)>0 ) pars <- pars[-wdev]
    wlp <- which(pars=="lp__")
    if ( length(wdev)>0 ) pars <- pars[-wlp]
    
    # figure out grid and paging
    n_pars <- length( pars )
    n_rows=ceiling(n_pars/n_cols)
    n_rows_per_page <- n_rows
    paging <- FALSE
    n_pages <- 1
    if ( n_rows_per_page > max_rows ) {
        n_rows_per_page <- max_rows
        n_pages <- ceiling(n_pars/(n_cols*n_rows_per_page))
        paging <- TRUE
    }
    n_iter <- object@sim$iter
    n_warm <- object@sim$warmup
    wstart <- 1
    wend <- n_iter
    if ( !missing(window) ) {
        wstart <- window[1]
        wend <- window[2]
    }
    
    # worker
    plot_make <- function( main , par , neff , ... ) {
        ylim <- c( min(post[wstart:wend,,par]) , max(post[wstart:wend,,par]) )
        plot( NULL , xlab="" , ylab="" , type="l" , xlim=c(wstart,wend) , ylim=ylim , ... )
        # add polygon here for warmup region?
        diff <- abs(ylim[1]-ylim[2])
        ylim <- ylim + c( -diff/2 , diff/2 )
        polygon( n_warm*c(-1,1,1,-1) , ylim[c(1,1,2,2)] , col=bg , border=NA )
        mtext( paste("n_eff =",round(neff,0)) , 3 , adj=1 , cex=0.9 )
        mtext( main , 3 , adj=0 , cex=1 )
    }
    plot_chain <- function( x , nc , ... ) {
        lines( 1:n_iter , x , col=col.alpha(chain.cols[nc],alpha) , lwd=0.5 )
    }
    
    # fetch n_eff
    n_eff <- summary(object)$summary[,'n_eff']
    
    # make window
    #set_nice_margins()
    par(mgp = c(0.5, 0.5, 0), mar = c(1.5, 1.5, 1.5, 1) + 0.1, 
            tck = -0.02)
    par(mfrow=c(n_rows_per_page,n_cols))
    
    # draw traces
    n_ppp <- n_rows_per_page * n_cols # num pars per page
    for ( k in 1:n_pages ) {
        if ( k > 1 ) message( paste("Waiting to draw page",k,"of",n_pages) )
        for ( i in 1:n_ppp ) {
            pi <- i + (k-1)*n_ppp
            if ( pi <= n_pars ) {
                if ( pi == 2 ) {
                    if ( ask==TRUE ) {
                        ask_old <- devAskNewPage(ask = TRUE)
                        on.exit(devAskNewPage(ask = ask_old), add = TRUE)
                    }
                }
                plot_make( pars[pi] , pi , n_eff[pi] , ... )
                for ( j in 1:length(chains) ) {
                    plot_chain( post[ , j , pi ] , j , ... )
                }#j
            }
        }#i
        
    }#k
    
}



makeMeansDF <- function(target,CCindex,modelPath){

    fn<-paste(modelPath,target,sep='')
    Y1<-read.csv(fn,row.name=1)

    
    Y1<-Y1[CCindex,]

    return(Y1)
}



shiftTargetVariable <- function(Y,target,culture,adultAge) {


    #shift the target by adult age if it is a cultural variable
    if (target %in% culture){ Y <- shift(Y,0,adultAge) }

    V<-c(t(Y)) 
    
    return(V)
    
}

shift <- function(Y,lag,adultAge) {
    #shift for the linear regression
    blank<-data.frame(matrix(ncol=lag+adultAge,nrow=dim(Y)[1]))
    

    end=dim(Y)[2]-lag-adultAge
    Y<-Y[,1:end]
    Y<-cbind(blank,Y)
    
    return(Y)
    
}

getCountryVector <- function(Y) {  
    

    #the legthn of time series and number of coutries
    size<-dim(Y)
    ts_length=size[2]
    N_countries=size[1]

    #the time and country of each obsveration
    T<-rep(1:ts_length,N_countries)
    country<-rep(1:N_countries, each=ts_length)
    
    country<-as.numeric(country)
    country <- as.factor(country)
    
    return(country)

}

getLanguageCategories <- function(Y,culturalHistoryControl){
    
    size<-dim(Y)
    ts_length=size[2]

    #get language categories
    fn <- paste('random_effects/',culturalHistoryControl,'.csv',sep='')
    H<-read.table(fn,sep=',',header=FALSE,row.name=1)
    F<-H[rownames(Y),]

    

    x<-rep(F,each=ts_length)
    
    x<-as.integer(x)

    #convert langauge categories to numbers
    x <- as.factor(x)

    return(x)
    
}
        
getModelNoCulturalHistoricControl <- function(dependent) {

    phymodel<-'data{
        int<lower=1> N;
        int<lower=1> N_country;
        real Y[N];
        int country[N];

    '

    for (pp in dependent){

        #pp<-substr(pp, 1, 3)

        exec <- '
        real %s[N];


    '
        exec<-sprintf(exec, pp,pp,pp,pp,pp,pp,pp,pp,pp,pp) 

        phymodel <- paste(phymodel,exec,sep='')

        }
    exec<-'}
    parameters{
        real alpha_g;
        vector[N_country] alpha_c;
        real<lower=0> sigma;

    '

        phymodel <- paste(phymodel,exec,sep='')

        for (pp in dependent){

            
            #pp<-substr(pp, 1, 3)

            exec <- '
        real beta%s;

    '

            exec<-sprintf(exec, pp,pp,pp,pp,pp,pp,pp,pp,pp,pp) 

            phymodel <- paste(phymodel,exec,sep='')

            }

        exec<-'}
    model{
        vector[N] alpha;
        vector[N] mu;

    '

        phymodel <- paste(phymodel,exec,sep='')


        for (pp in dependent){

            #pp<-substr(pp, 1, 3)

            exec <- ' beta%s ~ normal( 0 , 1 ); 

    '


            exec<-sprintf(exec, pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp) 

            phymodel <- paste(phymodel,exec,sep='')

            }

        exec<-'    sigma ~ cauchy( 0 , 2 );
        alpha_c ~ normal( 0 , 0.1 );
        alpha_g ~ normal( 0 , 9.9 );
        for ( i in 1:N ) {
            alpha[i] = alpha_g + alpha_c[country[i]];
        }

        for ( i in 1:N ) {
            mu[i] = alpha[i]'

        phymodel <- paste(phymodel,exec,sep='')


        for (pp in dependent){

            #pp<-substr(pp, 1, 3)
            exec <-'+ beta%s * %s[i]'
            exec<-sprintf(exec, pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp) 

            phymodel <- paste(phymodel,exec,sep='')
            }

        exec<-';
            }

            Y ~ normal( mu , sigma );}'

        phymodel <- paste(phymodel,exec,sep='')
        

    
    
    return(phymodel)
    
    }


getModel <- function(dependent) {

    phymodel<-'data{
        int<lower=1> N;
        int<lower=1> N_country;
        int<lower=1> N_H;
        real Y[N];
        int country[N];
        int H[N]; 

    '

    for (pp in dependent){

        #pp<-substr(pp, 1, 3)

        exec <- '
        real %s[N];

    '
        exec<-sprintf(exec, pp,pp,pp,pp,pp,pp,pp,pp,pp,pp) 

        phymodel <- paste(phymodel,exec,sep='')

        }
    exec<-'}
    parameters{
        real alpha_g;
        vector[N_country] alpha_c;
        vector[N_H] alpha_h;
        real<lower=0> sigma;

    '

        phymodel <- paste(phymodel,exec,sep='')

        for (pp in dependent){

            
            #pp<-substr(pp, 1, 3)

            exec <- '
        real beta%s;

    '

            exec<-sprintf(exec, pp,pp,pp,pp,pp,pp,pp,pp,pp,pp) 

            phymodel <- paste(phymodel,exec,sep='')

            }

        exec<-'}
    model{
        vector[N] alpha;
        vector[N] mu;

    '

        phymodel <- paste(phymodel,exec,sep='')


        for (pp in dependent){

            #pp<-substr(pp, 1, 3)

            exec <- ' beta%s ~ normal( 0 , 1 ); 

    '


            exec<-sprintf(exec, pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp) 

            phymodel <- paste(phymodel,exec,sep='')

            }

        exec<-'    sigma ~ cauchy( 0 , 2 );
        alpha_h ~ normal( 0 , 0.1 );
        alpha_c ~ normal( 0 , 0.1 );
        alpha_g ~ normal( 0 , 0.1);
        for ( i in 1:N ) {
            alpha[i] = alpha_g + alpha_c[country[i]] + alpha_h[H[i]];
        }

        for ( i in 1:N ) {
            mu[i] = alpha[i]'

        phymodel <- paste(phymodel,exec,sep='')


        for (pp in dependent){

            #pp<-substr(pp, 1, 3)
            exec <-'+ beta%s * %s[i]'
            exec<-sprintf(exec, pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp,pp) 

            phymodel <- paste(phymodel,exec,sep='')
            }

        exec<-';
            }

            Y ~ normal( mu , sigma );}'

        phymodel <- paste(phymodel,exec,sep='')
        

    
    
    return(phymodel)
    
    }

getDataFile <- function(target,dependent,culture,CCindex,adultAge,lag,modelPath,culturalHistoryControl) {

    Y<-makeMeansDF(target,CCindex,modelPath)

    
    country <- getCountryVector(Y)
    if (is.na(culturalHistoryControl)) {
        H <- getLanguageCategories(Y,'lanSmall')

    }


    if (!is.na(culturalHistoryControl)) {
        H <- getLanguageCategories(Y,culturalHistoryControl)
    }
    
    
    
    
   


    Y<-shiftTargetVariable(Y,target,culture,adultAge) 

    for (pp in dependent){

        #pp<-substr(ppLong, 1, 3)

        dep<-makeMeansDF(pp,CCindex,modelPath)


        if (pp %in% culture){dep <- shift(dep,lag,adultAge) } else {dep <- shift(dep,lag,0)}

        dep<-c(t(dep)) 

        Y<-cbind(Y,dep)

            }



    Y<-cbind(Y,country)
    Y<-cbind(Y,H)

    dep<-dependent
    dep<-gsub('.{4}$', '', dep)

    colnames(Y) <- c(c('Y'),dep,c('country','H'))

    ii<-rowSums(is.na(Y))
    Y<-Y[ii==0,]


    country <- as.integer(Y[,'country'])
    H <- as.integer(Y[,'H'])


    X<-as.numeric(Y[,'Y'])

    miss<-which(is.na(X))
    Lmiss<-length(miss)

    X[miss] <- 999

    M<-mean(X[X != 999])
    SD<-sd(X[X != 999])

    X<-(X-M)/SD

    data=list(       

            H=as.integer(H),
            country=as.integer(country),

            Y=X,

            N=length(X),

            N_missing=Lmiss,
            Y_missingness=miss

    )

    for (pp in dependent){

        #pp<-substr(ppLong, 1, 3) 

        miss<-which(is.na(Y[,pp]))
        Lmiss<-length(miss)

        X<-as.numeric(Y[,pp])

        X[miss] <- 999

        M<-mean(X[X != 999])
        SD<-sd(X[X != 999])
        

        X<-(X-M)/SD
        
        print(length(X))
        



        exec <- paste('data$',pp,'<-X',sep='')
        eval(parse( text=exec ))

        exec <- paste('data$N_',pp,'_missing<-Lmiss',sep='')
        eval(parse( text=exec ))

        exec <- paste('data$',pp,'_missingness<-miss',sep='')
        eval(parse( text=exec ))

        }


    #make counrtry and language codes sequential

    country<-data$country

    or<-unique(country)
    rp<-seq(1,length(or))

    country2 <-  country

    for (i in rp) {country[country2==or[i]] <- i}

    data$country <- country

    data$N_country <- length(unique(country))

    country<-data$H

    or<-unique(country)
    rp<-seq(1,length(or))

    country2 <-  country

    for (i in rp) {country[country2==or[i]] <- i}

    data$H <- country
    data$N_H <- length(unique(country))

    #data$countryGDP <- data$country
    
    return(data)
    }

saveDiagnostics <- function(pathDiag,stan) {

    dir.create(pathDiag, showWarnings = FALSE, recursive = TRUE)

    pdf(paste(pathDiag,"trace.pdf",sep=''))
    tracerplot(stan)
    dev.off() 

    diag <- precis(stan,depth=2)
    diag <- diag@output
    write.table(diag,paste(pathDiag,"precis",sep=''),sep=',')


    }
        
        

saveResults <- function(pathResults,phystan) {

    
    dir.create(pathResults, showWarnings = FALSE, recursive = TRUE)

    D<-extract.samples(phystan)
    names<-names(D)

    cnt=1
    for(i in D){
        fileN<-names[cnt]

        if (startsWith(fileN, 'beta')) {write.table(i,paste(pathResults,fileN,sep=''), sep=',')}
        if (startsWith(fileN, 'alpha')) {write.table(i,paste(pathResults,fileN,sep=''), sep=',')}

        cnt=cnt+1

        }

    }
        
        
RunStanModel <- function(modelName,culturalHistoryControl,targets,dependent,culture,imputeType,averageOrPeriod,warmup,iter,LAG,AdultAges) {

    if (imputeType == 'quad') {AdultAges <- c(0)}
    if (averageOrPeriod == 'period') {AdultAges <- c(0)}

    coun<-read.table('countries.csv',sep=',',header=TRUE,row.names = 1)
    ii<-rowSums(is.na(coun))
    CCindex<-rownames(coun)
    
    
    for (target in targets) {
        for (lag in LAG) {
            for (adultAge in AdultAges) {
                if (averageOrPeriod == 'average') {  

                    modelPath <- paste('time_series_normalized/',modelName,'/',imputeType,'/',averageOrPeriod,'/',sep='')

                    pathResults <- paste('results/',modelName,'/MultiLevel/',imputeType,'/',averageOrPeriod,'/',toString(adultAge),'/',toString(lag),
                          '/',substr(target, 1, 3),'/',sep='')

                    pathDiag <- paste('diagnostics/',modelName,'/MultiLevel/',imputeType,'/',averageOrPeriod,'/',toString(adultAge),'/',toString(lag),
                          '/',substr(target, 1, 3),'/',sep='')   

                    data<-getDataFile(target,dependent,culture,CCindex,adultAge,lag,modelPath,culturalHistoryControl)
                    
                    
                    
                    if (is.na(culturalHistoryControl)) {
                        print('cultural history: no')
                        model<-getModelNoCulturalHistoricControl(dependent)

                    }


                    if (!is.na(culturalHistoryControl)) {
                        print('cultural history: yes')
                        model<-getModel(dependent)

                    }       
                    

                    stan <- stan(model_code = model, data=data , warmup=warmup,iter = iter, chains = 4, cores=4, control = list(max_treedepth = 75,adapt_delta = 0.999))

                    #saveDiagnostics and Results
                    saveResults(pathResults,stan)
                    saveDiagnostics(pathDiag,stan)

                    }

                if (averageOrPeriod == 'period') { 

                    path <- paste('time_series_normalized/',modelName,'/',imputeType,'/',averageOrPeriod,'/',sep='')
                    periods <- list.files(path)
                    
                    
                    for (per in periods ) {


                        modelPath <- paste('time_series_normalized/',modelName,'/',imputeType,'/',averageOrPeriod,'/',
                                           per,'/' ,sep='')
                        

                        pathResults <- paste('results/',modelName,'/MultiLevel/',imputeType,'/',averageOrPeriod,'/',toString(adultAge),'/'
                                             ,per,'/' ,toString(lag),'/',substr(target, 1, 3),'/',sep='')

                        pathDiag <- paste('diagnostics/',modelName,'/MultiLevel/',imputeType,'/',averageOrPeriod,'/',toString(adultAge),'/',
                                          per,'/' ,toString(lag),'/',substr(target, 1, 3),'/',sep='')   

                        data<-getDataFile(target,dependent,culture,CCindex,adultAge,lag,modelPath,culturalHistoryControl)
                        if (is.na(culturalHistoryControl)) {
                            print('cultural history: no')
                            model<-getModelNoCulturalHistoricControl(dependent)


                        }


                        if (!is.na(culturalHistoryControl)) {
                            print('cultural history: yes')
                            model<-getModel(dependent)

                        }

            

                        stan <- stan(model_code = model, data=data , warmup=warmup,iter = iter, chains = 4, cores=4, control = list(max_treedepth = 35,adapt_delta = 0.999))

                        #saveDiagnostics and Results
                        saveResults(pathResults,stan)
                        saveDiagnostics(pathDiag,stan)


                        }

                    }            

            }}}

    }
        


warmup <- 500#1000
iter <- 1000#2000

culturalHistoryControl <- 'lanSmall'

AdultAges <- c(2)

imputeType <- 'linear' 
averageOrPeriod <- 'average'


modelName<-'RBL2test'

targets  <- c('GDP','RAT','COS','EDS','LEX','DEM')
dependent <- c('GDP','RAT','COS','EDS','LEX','DEM')
culture <- c('RAT','COS')

LAG <- c(1,2,3) #seq


RunStanModel(modelName,culturalHistoryControl,targets,dependent,culture,imputeType,averageOrPeriod,
             warmup,iter,LAG,AdultAges)



