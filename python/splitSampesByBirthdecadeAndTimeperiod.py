import pandas as pd
import numpy as np
import os

factors = ['RAT','COS']

X=pd.read_csv('data/compressedWEVS',index_col=0)

year=X.loc[:,'S020']
age=X.loc[:,'X003']
dob=X.loc[:,'X002']


#impute missing dob with year-age dob calculation
dob2=year-age
dob[dob.isnull()]=dob2[dob.isnull()]

#remove data with missing date of birth date
ii=np.where(~dob.isnull())[0]
X=X.iloc[ii,:]


#data for period of time
period=X.loc[:,'S020']
period[period==1989]=1990
period=np.floor(period/5.)*5.

#recode Serbia & Montenegro and Bosnia
country=X.loc[:,'S003']
country[country==688]=891
country[country==499]=891
country[country==914]=70


#express date of birth as decade of birth
gen=X.loc[:,'X002']
gen=np.floor(gen/10.)*10.

#lookup country names and factor names 
lookup=pd.read_csv('data/country_code.csv',index_col=0).iloc[:,0]


#create timeperiod-birthcohort matrix for the variables in factors
for f in factors:    
    y=X.loc[:,f]

    for c in country.unique():

        V=pd.DataFrame(index=sorted(gen.unique()),columns=sorted(period.unique()))

        for p in period.unique():
            for g in gen.unique():
                #obtain the values which intersect at the goven country, period and genereration
                ii = np.sum(np.asarray([period==p,gen==g,country==c]),axis=0)
                ym=y[ii==3]
                
                ym_size=len(ym)

                # only include sample if it is greater than ym_size
                if ym_size > 150:
                    V.loc[g,p]=np.mean(ym)


        clab=lookup.loc[c] # name of country
        flab=f

        #save the mean, error and population size
        directory='period_cohort_splits/'+f+'/'
        if not os.path.exists(directory):
            os.makedirs(directory)

        V.to_csv(directory+clab+'.csv')


