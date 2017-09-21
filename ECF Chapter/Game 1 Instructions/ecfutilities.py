# -*- coding: utf-8 -*-
"""
Created on Fri Mar 17 19:48:17 2017

@author: Steve

File: ecfutilities.py
"""

import pandas as pd

case1df = pd.read_csv('Workbook2.csv',index_col=0)
case2df = pd.read_csv('case2data.csv',index_col=0)
#%%
def tolatexrow(aseries):
    '''
    
    '''
    toPrint = str(round(aseries[0],1))
    for item in aseries.iloc[1:]:
        toPrint+= ' & '+str(round(item,1))
    print(toPrint)
        
def stringstolatexrow(obj):
    toPrint = obj.columns[0]
    for col in obj.columns[1:]:
        toPrint+= ' & ' + col
    print(toPrint)
    
def dropplayer(dataframe,role):
    '''
    Given a DataFrame, dataframe, and a role, as a string.
    Returns a copy of dataframe but with the role row removed.
    '''
    toReturn = dataframe.copy()
    return toReturn.drop(role)

#%%
def roleScores(role,df):
    '''
    Given role as an integer, returns a string for a LaTeX table of the
    role's payoff scores from df.
    '''
    numCols = len(df.columns)
    toReturn = str(df.iloc[role-1,0])
    for item in range(1,numCols):
        toReturn += ' & '+str(df.iloc[role-1,item])
    return toReturn
#==============================================================================
# r1 = dropplayer(df,'Role 1')
# r1.describe()
# r1median = r1.describe().iloc[5,:]
# 
# r1median
# r1medianlatex = tolatexrow(r1median)
# 80.0 & 80.0 & 50.0 & 20.0 & 20.0 & 30.0 & 40.0 & 50.0 & 60.0 & 70.0
#==============================================================================
#%%
#==============================================================================
df = case2df
scores = roleScores(4,df)
print(scores)
r = dropplayer(df,'Role 4') # 'Role 2' 'Role 3'
r.describe()
rmedian = r.describe().iloc[5,:]
 
rmedian
rmedianlatex = tolatexrow(rmedian)
# 70.0 & 80.0 & 55.0 & 25.0 & 20.0 & 30.0 & 40.0 & 50.0 & 60.0 & 70.0
#==============================================================================
