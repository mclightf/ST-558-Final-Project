# Modeling

This page allows you to customize three different supervised learning methods. Here is a brief description of each. 

**General Linear Model**

A general linear regression model buils on the idea of a traditional multiple linear regression model of numerical predictors, but also allows for both categorical predictors. This is especially useful in our case, considering a majority of our predictive variables are categorical! 

For multiple linear regression, the model is as follows:

$Y_i = \beta_0 + \beta_1X_{i1} + ... + \beta_pX_{ip} + \epsilon_i$

for each observation $i = 1,...,n$ based on $p$ independent variables. For general linear regression, this changes slightly to:

$Y_{ij} = \beta{0j} + \beta_{1j}X_{i1} + ... + \beta_{pj}X_{ip}$

**Regression Tree**

A regression tree model is a non-linear model



**Random Forest**

A random forest model for regression builds on the idea of a regression tree, but incorporates bagging and random subsetting of the predictors. 


In the *model fitting* tab, you will be able to customize the train/test split and choose which of the predictive variables, if not all, you would like to use in your models! Then you will be able to run the models and see the resulting RMSE of each regression model on the test set along with some additional summaries. Each model utilizes 5-fold cross validation.

In the *prediction* tab, you can pick a value of your own for each of the predictive variables used in your models, and see what the resulting `Global_Sales` will be!