import pandas as pd
import numpy as np
import os


def getRegressionDF(variable):

    D='period_cohort_splits/'+variable+'/'
    L=sorted(os.listdir(D))

    columns=['X','t','country','p','countryP']
    df=pd.DataFrame(columns=columns)

    X=np.asarray([])
    t=np.asarray([])
    p=np.asarray([])
    country=np.asarray([])
    countryP=np.asarray([])

    for l in L:
        #mean=pd.read_csv(D+'mean/'+l,index_col=0)
        mean=pd.read_csv(D+l,index_col=0)
        
        
        ii=np.where(mean.isnull().sum() != mean.shape[0])[0]
        mean = mean.iloc[:,ii]
        mean=mean.iloc[2:,:]
        
        #error=pd.read_csv(D+'sem/'+l,index_col=0)

        #mean.index=np.arange(mean.shape[0])+1
        CC=np.repeat(l,mean.shape[0]*mean.shape[1])
        period=np.tile(mean.columns.values,mean.shape[0])

        p=np.append(p,period)

        #Xsd=np.append(Xsd,error.values.flatten())
        X=np.append(X,mean.values.flatten())
        t=np.append(t,np.repeat(mean.index.values,mean.shape[1]))
        country=np.append(country,CC)
        #countryP = np.append(countryP,period)
        countryP = np.append(countryP,[a_+b_ for a_, b_ in zip(CC, period)])


    df.loc[:,'X'] = X
    df.loc[:,'p'] = p
    df.loc[:,'t'] = t
    df.loc[:,'country'] = country
    df.loc[:,'countryP'] = countryP
        
    return df

def integerize(df):
    
    for jj in ['countryP','t','p','country']: #'country',
        cc = df.loc[:,jj]

        U=sorted(cc.unique())
        I=np.arange(len(U))+1

        for u,i in zip(U,I): cc[cc==u] = i
            
        df.loc[:,jj] = cc
        
            
    return df

def createRegressionFile(variable):

    df=getRegressionDF(variable)


    #remove missing vlaues
    ii=df.isnull().sum(axis=1)
    df=df[ii==0]

    df=integerize(df)

    
    #normalize variables
    djub=df.loc[:,'X']
    M=djub.mean()
    E=djub.std()
    df.loc[:,'X'] = (df.loc[:,'X']-M)/E
    #df.loc[:,'Xsd'] = (df.loc[:,'Xsd'])/E


    directory='regressionFilesModelComparison/'
    if not os.path.exists(directory):
        os.makedirs(directory)

    df.to_csv(directory+variable) 
    
for variable in  ['RAT','COS']:
    createRegressionFile(variable)
