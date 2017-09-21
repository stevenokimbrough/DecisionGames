# -*- coding: utf-8 -*-
"""
Created on Mon Apr 24 11:13:40 2017

@author: Steve

File: ecfanalytics.py
"""

import pandas as pd
import numpy as np

df1 = pd.read_table('EnterpriseCrowdFunding1Case2.txt',sep='\t')

df11 = df1[df1['Player']==1]
df12 = df1[df1['Player']==2]
df13 = df1[df1['Player']==3]
df14 = df1[df1['Player']==4]
df15 = df1[df1['Player']==5]

(df11n,_) = df11.shape
(df12n,_) = df12.shape
(df13n,_) = df13.shape
(df14n,_) = df14.shape
(df15n,_) = df15.shape



def makeoutcome(count=1):
    results = np.zeros((count,10),dtype='int')
    for trial in range(count):
        row11 = np.random.randint(0,df11n)
        row12 = np.random.randint(0,df12n)
        row13 = np.random.randint(0,df13n)
        row14 = np.random.randint(0,df14n)
        row15 = np.random.randint(0,df15n)
        df = pd.DataFrame([df11.iloc[row11,:],df12.iloc[row12,:],
                           df13.iloc[row13,:],df14.iloc[row14,:],
                            df15.iloc[row15,:]])
        #print(df)
        sums = df.iloc[:,2:12].sum()
        #sumsvalues = sums.values
        for idx in range(10):
            #print(str(sums[idx])+'\t',end='')
            results[trial,idx]=sums[idx]
    #print('\n')
    return results
    

if __name__ == '__main__':
    pass
    trials = 10000
    results = makeoutcome(trials)
#    for count in range(20):
#        df = makeoutcome()
    funded = (results >= 100).astype('int')
    fundedbyproject = funded.sum(axis=0)
    fundedcounts = funded.sum(axis=1)
    # results.max(axis=1)
    print('Number of trials: {}'.format(trials))
    print('Mean number of projects funded: {}'.format(fundedcounts.mean()))
    print('Funded by projects: {}'.format(fundedbyproject))
    print('Number of trials with 0 projects funded: {}'.format((fundedcounts < 1).sum()))
    print('Number of trials with > 1 project funded: {}'.format((fundedcounts > 1).sum()))
    print('Largest number of projects funded in a trial: {}'.format(fundedcounts.max()))




