---
published: true
layout: post
categories: machine learning; EDA
author: I ON
---
![]({{site.baseurl}}/assets/shared_mob.png)

## Predicting demand for shared mobility services

*The question I ask is: for any given time of day, day of the week, and location, how accurately can we predict the demand for shared mobility, i.e. the number of shared mobility trips taken?* 

# 4. Modelling and model assessment

This is a regression problem since the variable I am trying to predict is quantitative (the total number of pickups). Given a set of date, time, location, and weather features, the aim is to determine a model that predicts the target variable - number of trips – with reasonably high accuracy based on the value of its features. 

I run three different machine learning algorithms – **linear regression**, **k-nearest neighbors (k-NN) regression**, and **random forest regression**. Machine learning algorithms are used to leverage significant amounts of given data in order to extract some form of insight or knowledge and to ‘learn’ to make accurate predictions. Using Python’s scikit-learn library, all three algorithms are run several times with a varying combination of input variables and parameter settings specified for individual algorithms. 

I begin by dividing our dataset into two: the first part consists of all trips in April, May, and up until June 23rd. This is treated as ‘historical’ data used for training and validation purposes.  The second part contains the remaining seven days of June are then used to test the model by simulating prediction into the ‘future’. Note that all regression results reported below are for models run on the first dataset only. The second dataset is used merely to produce the predicted dataset that is eventually fed into the web-based application.

For useful assessment of model performance, I partition the dataset used for all machine learning algorithms: 70% are assigned to training data and the remaining 30% to test data. 

For the linear regression and the k-NN regression model I also perform 10-fold cross-validation across models, randomly partitioning our dataset into 10 equally sized subsamples and using each subsample once as the validation data for testing the model in 10 repeated cross-validation processes. The random forest regression already performs cross-validation by definition, since each bagged tree makes use of only a proportion of around two-thirds (on average) of the observation, leaving the remaining third of the observations out-of-bag. This means that the response for any particular instance can be predicted using all the trees in which that instance was not used to fit a given bag (James et al., 2015).

The root mean squared error (RMSE) is used to evaluate predictions, since it is one of the most intuitive and easily understandable metrics - having the units of the target associated with it (in our case the number of trips). It measures the standard deviation (measure of spread) of the residuals, i.e. the spread of the points about the fitted model. It essentially measures the ‘noise’ in the system. The RMSE is also often used for generating a range of uncertainty for predictions made. 

In addition, the R2 is reported for each model to evaluate what percentage of the variation in the data the model explains. 

Fine-tuning of each machine learning model is done using sci-kit-learn’s grid search – a powerful hyper-parameter  optimization technique that can further help improve the performance of a model by finding the optimal combination of hyper-parameter values.

# 5. Prediction

# Linear Regression
I start out with a linear regression model, which is generally a useful tool for predicting quantitative responses. Table 2 shows the results of individual models. I find that the linear regression model performs rather poorly with an RMSE of 0.88 and an R2 of 25%. This indicates that the true relationship between our target and the features is most likely non-linear. The best performing estimator has a fitted intercept and does not use normalized features.

# K-NN Regression
Next I turn to a non-parametric method, the k-nearest neighbor regression, which does not make any assumptions on the parametric form of the underlying relationship between features and target. It provides a much more flexible approach to performing regression. 

Feature scaling is a crucial step in preprocessing data for this model, as it typically behaves much better if features are on the same scale; for the simple reason that, as most algorithms, it would otherwise be busy optimizing weights according to the larger errors in features of larger scales. The kNN algorithm in particular is a good example because it relies on computed distance measures that will inevitably be dominated by larger scale features (Raschka, 2015).

Indeed, this algorithm performs much better on the data, with an RMSE of 0.35 and an R2 of 88%. The best performing kNN estimator uses k=1 neighbors.

# Random Forest Regression
Finally, I apply a random forest regression model. I choose this model because it is a powerful method for capturing highly non-linear and complex relationships between features and the target, prevents over fitting and is robust against outliers. An advantage of the decision tree algorithm is that it does not require any transformation of the features when dealing with nonlinear data (Raschka, 2015).

This model gives us by far the highest accuracy amongst the three models, with an RMSE of 0.14 and an R2 of 98%. The best performing Random Forest model uses 50 trees, a maximum depth of a tree of 30, and, as mentioned before, uses out-of-bag samples to estimate the R Squared on unseen data. 


|RMSE	|R-Squared|
|---	|---|
|Linear regression	|0.8806	0.2524|	
|k-NN regression	0.3517	|0.8806|	
|Random forest regression	|0.1338	0.9829|	

*Table 2 Performance table* 

To visualize the accuracy of the three models, Figure 5 depicts the correlation between real target values and predicted target values of each model.
   
![]({{site.baseurl}}//assets/p1.png) ![]({{site.baseurl}}//assets/p2.png) ![]({{site.baseurl}}//assets/p3.png)

*Figure 5 Correlation between predicted and real target values* 

In terms of feature importance, latitude and longitude are by far the most important factors influencing the number of trips, followed by time of the day, day of the week, and whether the day is a weekend or not. The average daily temperature appears to be a more important weather factor than total daily precipitation. Least significant is whether it is a weekday or not.

# Models by mode of transportation 

Given the different relationships I discovered during data exploration between pickup activity of the three transportation types and our set of features, I decide to split the dataset by mode of shared transportation - Taxi (I collapse yellow taxi and green taxi into one variable), Uber, and Citi Bike – and rerun the models. This will also provide the application user with more detailed information about demand for shared mobility at any given location and time.

Best performing model in all cases remains the random forest regression (results of other models are not reported here). The model performs best when run on the taxi dataset, followed by the Bike and the Uber datasets (see Table 3).  

In line with observations made during data exploration, I find that average daily temperature and daily precipitation appear more important for predicting Citi Bike pickups than for predicting Uber or Taxi pickups; it makes sense that bike users would be more sensitive to weather conditions than car users.


RMSE	|R-Squared	
---	|---
Taxi	|0.1296	0.9839	
Uber	|0.1461	0.9510	
Bike	|0.1589	0.9682	

*Table 3 Model performance of random forest regression by type of service*


# Final words

The aim of the project was to develop a data-driven solution to predict the demand for shared mobility services, given selected features from a dataset i.e. the time of the day, day of the week, and location.

I took into consideration the role of five variables (and engineered versions of them) to predict pickup demand: longitude, latitude, hour of day, day of the week, temperature, and precipitation. Different machine learning algorithms were implemented to identify the best performing one in terms of predictive power. 

This algorithm could be fed into an application focused on predicting the number of pickups to allow users to query predicted demand for shared mobility services by time and location. 

The algorithm also helped discover that location is by far the most important factor influencing the number of pickups, followed by time of the day and the day of the week.

**********************************************
Code used for this project can be found [here](https://github.com/ijeism/ijeism.github.io/tree/master/predicting_shared_mobility).