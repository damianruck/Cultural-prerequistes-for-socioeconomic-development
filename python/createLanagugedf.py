import pandas as pd
import numpy as np
from scipy import stats
from scipy.optimize import curve_fit
import matplotlib.pyplot as plt

germanic=['Austria', 'Belgium', 'Denmark',
        'Finland','Germany', 'Norway',
       'Great Britain', 'Iceland',
        'Ireland',
       'Luxembourg', 'Netherlands', 'Sweden', 'Switzerland']

italic=[ 'France', 'Italy', 'Malta', 'Portugal','Romania', 'Spain']

slavic=[ 'Belarus', 'Bosnia', 'Bulgaria', 'Croatia', 'Czech Rep.',
       'Estonia', 'Latvia', 
        'Lithuania', 'Macedonia','Moldova', 'Poland', 'Russia',
       'Serbia and Montenegro', 'Slovakia', 'Slovenia',
        'Ukraine']

vals=pd.read_csv('figure3Data/cos_rat.csv',index_col=0)
Z=pd.DataFrame(index=vals.index.values,columns=['opnrat','germanic','italic','slavic'])
Z.loc[:,'opnrat'] = vals.sum(axis=1)

LABEL = ['germanic', 'italic','slavic']

for western,name,col,label,shape in zip([germanic,italic,slavic], ['germanic','italic','slavic'],['b','r','darkgreen'], LABEL,['^','o','s']):
#for western,name,col in zip([all,all,all], ['germanic','italic','slavic'],['b','r','k']):

    prop=pd.read_excel('figure3Data/putterman_data.xls',index_col=1).iloc[:,1:-1]
    prop.columns=prop.index.values

    vals=pd.read_csv('figure3Data/cos_rat.csv',index_col=0)

    countryN=vals.index.values
    countryO=prop.index.values

    new=['Bosnia', 'Cyprus (G)', 'Czech Rep.',
           'Dominican Rep.', 'Egypt', 'Great Britain', 'Iran',
           'Israel', 'South Korea','Taiwan', 'Viet Nam']

    old=['Bosnia and Herzegovina','Cyprus','Czech Republic','Dominican Republic','Egypt, Arab Rep.',
        'United Kingdom', 'Iran, Islamic Rep.', 'Israel/Palestine', 'Korea, Rep. (South)', 'Taiwan, China',
        'Vietnam']

    for n, o in zip(new,old): countryO[countryO==o] = n
    prop.columns=countryO
    prop.index=countryO
 
    prop2=prop.loc[vals.index,western].sum(axis=1) # 
    prop3=prop2[~prop2.isnull()]
    vals2=vals[~prop2.isnull().values]

    vals=vals2.sum(axis=1)

    Z.loc[:,name] = prop3
    
    #CC.to_csv('data/log_regresssion_files/' + name + '.csv')

ii=Z.isnull().sum(axis=1)
ii=ii[ii==0].index.values
Z=Z.loc[ii,:]
Z.to_csv('figure3Data/log_multiple_regression.csv')
