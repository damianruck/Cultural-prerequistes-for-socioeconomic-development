import pandas as pd
import numpy as np
from scipy import stats
from scipy.optimize import curve_fit
import matplotlib.pyplot as plt
import os

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

fig,[ax1,ax]=plt.subplots(1,2,figsize=[12,4])

LABEL = ['germanic', 'italic','slavic']

for western,name,col,label,shape in zip([germanic,italic,slavic], ['germanic','italic','slavic'],['b','r','darkgreen'], LABEL,['^','o','s']):

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

    def logit(w0vec,k,inter):
        linpred = inter + (w0vec * k)
        IRfit = linpred
        
        return IRfit

    popt, pcov = curve_fit(logit, prop3, vals)
    
    tfit=np.linspace(0.,1.,100)
    yfit=logit(tfit,*popt)
    
    datafit=logit(prop3,*popt)
    
    if shape == 's': ax.plot(prop3,vals,marker=shape,c=col,alpha=0.6,ls='None',label=label)
    if shape != 's': ax.plot(prop3,vals,marker=shape,ms=9,c=col,alpha=0.6,ls='None',label=label)
    
    ax.plot(tfit,yfit,'-',c=col,lw=3)
    ax.set_xlim([0,1])
    ax.set_ylabel(r'$S_{R+C}$',fontsize=26)
    ax.set_xlabel('% European Descent',fontsize=16)

    CC=pd.concat([vals,prop3],axis=1)
    CC.columns = ['opnrat','prop']

    directTemp = 'figure3Data/log_regresssion_files/'
    if not os.path.exists(directTemp):
        os.makedirs(directTemp)
    
    CC.to_csv(directTemp + name + '.csv')

leg=ax.legend(loc=0,fontsize=14,fancybox=True)
leg.get_frame().set_alpha(0.1)

Z=pd.read_csv('figure3Data/cos_rat.csv',index_col=0).sum(axis=1)

lang=pd.read_csv('random_effects/lanSmall.csv',index_col=0).iloc[:,0]

X=pd.DataFrame(columns=['mean','se','N'])
for l in lang.unique():
    z=Z[lang==l]

    if len(z) > 0:
        X.loc[l,'mean'] = z.mean()
        X.loc[l,'se'] = z.sem()
        X.loc[l,'N'] = len(z)
        
    else:
        print(l, z.index.values, z.mean())        
        
X=X.sort_values('mean')#[::-1]

X[X.isnull()] = 0
ax1.errorbar(X.loc[:,'mean'],np.arange(X.shape[0]),xerr=X.loc[:,'se'], ecolor='k', fmt='o',
             elinewidth=4,capsize=5)
ax1.plot(X.loc[:,'mean'],np.arange(X.shape[0]),'ko',ms=12)

ax1.set_xlabel(r'$S_{R+C}$',fontsize=26)

xticklabs=X.index.values
xticklabs[xticklabs=='Niger_Congo'] = 'Niger-Congo'

for lab,num in zip(xticklabs,X.loc[:,'N']):
    xticklabs[xticklabs==lab] = lab + ' (n=' + str(num) + ')'

ax1.set_yticks(np.arange(X.shape[0]))
ax1.set_yticklabels(xticklabs,fontsize=16)
ax1.set_ylim([-0.5,X.shape[0]-0.5])
    
plt.tight_layout()
plt.savefig('plots/logisitc_fit_langauge_breakdown.png')
plt.close()


