# -*- coding: utf-8 -*-
"""
Created on Tue Feb 14 14:51:36 2017

@author: A240947
"""

import os
import numpy as np
import pandas as pd
import matplotlib
import matplotlib.pyplot as plt
import scipy.stats as stats
import missingno as msno

from sklearn import linear_model
from sklearn import preprocessing

matplotlib.style.use('ggplot')


plt.figure(figsize=(9,9))

def sigmoid(t):                          # Define the sigmoid function
    return (1/(1 + np.e**(-t)))    

plot_range = np.arange(-6, 6, 0.1)       

y_values = sigmoid(plot_range)

# Plot curve
#plt.plot(plot_range, y_values, color="red")

os.chdir('C:\\Users\\A240947\\Desktop\\dev\\ML\\Python') # Set working directory

titanic_train = pd.read_csv("titanic_train.csv")    # Read the data

#msno.matrix(titanic_train)

char_cabin = titanic_train["Cabin"].astype(str)     # Convert cabin to str
new_Cabin = np.array([cabin[0] for cabin in char_cabin]) # Take first letter
titanic_train["Cabin"] = pd.Categorical(new_Cabin)  # Save the new cabin var

# Impute median Age for NA Age values
new_age_var = np.where(titanic_train["Age"].isnull(), # Logical check
                       28,                       # Value if check is true
                       titanic_train["Age"])     # Value if check is false

titanic_train["Age"] = new_age_var 

label_encoder = preprocessing.LabelEncoder()
encoded_sex = label_encoder.fit_transform(titanic_train["Sex"])

log_model = linear_model.LogisticRegression()

log_model.fit(X=pd.DataFrame(encoded_sex),
              y=titanic_train["Survived"])

print(log_model.intercept_)
print(log_model.coef_)

# Make predictions
preds = log_model.predict_proba(X=pd.DataFrame(encoded_sex))
preds = pd.DataFrame(preds)
preds.columns = ["Death_prob", "Survival_prob"]

# Generate table of predictions vs Sex
print(pd.crosstab(titanic_train["Sex"], preds.ix[:, "Survival_prob"]))