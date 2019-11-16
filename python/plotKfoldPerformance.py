import pandas as pd
import numpy as np
import os
import matplotlib.pyplot as plt


def plotModelComparison(variables,informationCriterion):

    lookup=pd.Series(['AxO','D','GDP','Secular-Rational','Cosmopolitan','CH','U','P','GINI','P','W','O','G','S','CON','CON','E','C','G','Gold','AxP','A',
                      'CFL','E','L','SEC','ENG','I','VIO','OUT','I','Post-Material'],
                index=['AxO','DEM','GDP','RAT','COS','CHU','URB','POP','IQZ','LRP','WAR','ONE','TRU','SUP','CON','COP',
                       'PAR','COM','GIN','INS','AXP','AUT','CFL','EDS','LEX','SEC','ENG','INV','INN','OUT','CPL','POS'])

    f, ax = plt.subplots(figsize=[8,5])
    ii = np.asarray([0,3,1,2])

    colors = ['r','b','purple','k']
    markers = ['o','^','s','P','X','D','V']
    lines=['-','--',':']

    t=np.asarray([1,2,3,4])


    for var,mark in zip(variables,lines):

        print(var)

        C=pd.read_csv('modelComparisonKfold/' + var,index_col=0)#.iloc[ii,:]

        #for ic,line in zip(informationCriterion,lines):
        c=C.loc[:,'elpd_kfold']#C.loc[:,ic].values
        cSE=C.loc[:,'se_elpd_kfold']
        ii = ['fit1', 'fit21', 'fit22','fit3']

        c=c.loc[ii]
        cSE=cSE.loc[ii]
        #ax.plot(t,c,'-',color='k',marker=mark,linestyle=line, ms=12)

        ax.errorbar(t,c,yerr=cSE,color='k',ls=mark,label=lookup.loc[var],lw=3,capsize=6)

        #ax.plot(t,c,'-',color='k',label=lookup.loc[var],marker=mark,ms=12)




    if len(informationCriterion) == 1:
        ax.set_ylabel(informationCriterion[0],fontsize=22)

    if len(informationCriterion) > 1:
        ax.set_ylabel('Information Criterion',fontsize=22)

    t=np.asarray([1,2,3,4])
    ax.set_xticks(t)
    ax.set_xticklabels(['M1','M2.1','M2.2','M3'],fontsize=18)

    plt.legend(fontsize=20)

    fileName = '_'.join(variables)
    directory = 'plots/'+ fileName +'/'

    if not os.path.exists(directory):
        os.makedirs(directory)


    if len(informationCriterion) == 1:
        plt.savefig(directory + 'kfold' +'.png')

    if len(informationCriterion) > 1:
        plt.savefig(directory + 'allInformationCriterion' +'.png')

    plt.close()
    
    return

variables = ['RAT','COS']
informationCriterion = ['predction performance']

plotModelComparison(variables,informationCriterion)
