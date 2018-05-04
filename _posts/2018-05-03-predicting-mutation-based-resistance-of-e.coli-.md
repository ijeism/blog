---
published: true
layout: post
categories: machine learning; EDA
author: I ON
---

![]({{site.baseurl}}/assets/protein.png)


# Predicting mutation-based resistance of E.Coli using machine learning

The aim of this project was to develop a predictive model for resistance phenotypes that accurately classifies resistance phenotypes on the basis of genotype represented by features of protein mutations.

One of the major challenges in analyzing the effects of protein mutations is that there are many disparate bioinformatics data sources available online that could be useful for this sort of analysis. These data sources are typically highly fragmented and their integration is not straightforward. 

This project aimed to approach this problem by first creating a useful dataset, integrating data from the Resistome, the Amino Acid Index, the uniprotKB, the Protein Database, and the R package rprotmut. It then proceeded to use machine learning algorithms to train classifiers on the data to accurately predict tolerance phenotype classes i) using a binary classification problem, the two classes of phenotypes being antibacterial-resistant and growth-resistant; and ii) using a multiclass prediction problem, the goal of which was to evaluate the extent to which the data are able to distinguish between antibiotics classes specifically.

General, updatable, and scalable code for various data extraction processes, such as from the Resistome database or the mCSM server, was produced. The machine learning exercise yields a fairly accurate binary classifier, but also a poorly performing multiclass classifier. Results indicate that more data on context-specific features might be required to improve predictive power of these models. While this data seems inadequate to distinguish between antibacterial sub-groups, it may be very useful to predict certain antibiotics sub-groups, such as aminoacids. 

### Project Workflow

1. Data sources
2. Exploratory data analysis
3. Modelling and prediction
4. Discussion

### 1. Data Sources

Three main data sources used for this project are:
- the recently published [Resistome database](https://bitbucket.org/jdwinkler/resistome_release/overview), a formidable source for genomic data related to resistance; 
- the [Amino Acid Index Database](http://www.genome.jp/aaindex/), which contains a large number of context-independent features related to the change in amino acid type; 
- and an R package to predict protein stability by consensus analysis developed by a former student of the MSc Data Science and Analytics program at Brunel University for data on effects of single point mutations in proteins (Nahaul, 2016).

First, data on individual mutations and associated phenotypes are extracted from the Resistome database. Phenotype will be used again at the prediction stage. Mutation data is then used to pull general physiochemical and biochemical properties that characterize individual mutations from the AAindex. Mutation data is further used in a two-step process involving the Uniprot Knowledge Base (UniprotKB) and the Protein Database (PDB) to generate information that enables retrieval of relevant context-specific properties via the R package rprotmut. 

Data retrieval and integration for this project was quite lengthy and are beyond the scope of this post. The final dataset used for this analyis can be found [here](https://github.com/ijeism/ijeism.github.io/tree/master/predicting-phenotypes).

### 2. Exploratory Data Analysis

In this section, basic statistical analysis and visualization techniques will be applied to familiarize with the data and identify more obvious relationships. The first step to any data science project is a simple exploration and visualization of the data. Since the ultimate purpose of this dissertation is to predict mutationally-acquired tolerance phenotype, it seems a good idea to start by visualizing the target Tolerance Phenotype. 

![]({{site.baseurl}}/assets/f9.png)

*Figure 9 Bar plot of target variable tolerance phenotype*

There are 48 different tolerance phenotypes in the dataset (see Figure 9). To make this information useful for analysis, these are first grouped into two more general classes of phenotypes: one group that is tolerant to antibacterials, and the other that is tolerant to various growth conditions. The goal of this grouping is to see whether it is possible to distinguish mutations that are interesting for medical purposes as opposed to biotechnological use. 

The antibacterial resistance group contains a variety of antibiotics, such as ciprofloxacin or ampicillin. The phenotypes in the growth conditions group consist of a number of growth conditions, such as acid or heat (see Appendix J). In both classes, mutations have enabled bacterial survival. In the antibiotics class, mutations have enabled the bacterium withstand attempts to eliminate it. In the growth conditions class, the mutations enabled bacteria successfully survive within a particular medium with different/harsher conditions from the natural bacterial environment, such as extreme acidic medium (acid) or higher temperature (heat).

With this classification, 65% of records (10,631) fall into class 1 (antibacterials) and 35% (5,790) fall into class 2 (growth conditions). The hope is that the features in the dataset are sufficiently informative to enable machine learning algorithms discern patterns distinctive enough to successfully separate these two groups. As an example, Figure 10 shows box plots of the two context-specific properties for the two classes. It shows how differently distributed these variables are across the two groups, suggesting that they may be informative in the prediction. The median predicted ∆∆G, for instance, is slightly higher for growth-resistant mutations (group 0) than for antibacterial-resistant mutations (group 1), while the median RSA is significantly lower for antibacterial-resistant mutations than for growth-resistant ones. 

![]({{site.baseurl}}/assets/f10.png)

*Figure 10 Box plots of context-specific properties RSA and DDG for antibacterial and growth-condition phenotypes
Antibiotics=1 for antibacterial resistance; antibiotics=2 for growth-resistance*.


Next, only antibacterial phenotypes are taken into consideration. Antibiotics are assigned to their respective subgroups (Wikipedia, n.d.), reducing the dataset from 16,421 to 10.631 records and the number of classes from originally 31 antibiotics to 13 antibiotics types (see Appendix K). Figure 11 and Figure 12 show box plots of the two context-specific properties for the 13 classes. The variation across classes, again, suggests that these two features may play a significant discriminating role in the predictive model - although perhaps with less potential overall than in the binary separation just discussed since there are multiple classes with relatively similar distributions of data. In general, it will likely be more challenging to make accurate predictions for antibacterial phenotype subgroups.

![]({{site.baseurl}}/assets/f11.png)

*Figure 11 Box plot of RSA for antibiotics classes*

![]({{site.baseurl}}/assets/f12.png)
 
*Figure 12 Box plot of DDG for antibiotics classes*


It is worth mentioning that further exploratory data analysis did not yield useful information. For example, using Principal Component Analysis to did not help improve accuracy of machine learning models. On the contrary – models seemed to perform slightly worse using principal components (results not included in this dissertation). The reason for applying this unsupervised machine learning technique is that in analysis of bioinformatics data, a unique challenge often arises from the high dimensionality of measurements. This dataset contains close to 700 features – all characteristics of a single mutation - many of which turn out to be highly correlated. 

In addition, in order to understand perhaps less obvious relationships between the categories of our target variable, clustering methods were applied. Clustering seeks to find homogenous subgroups among the observations. The goal is to discover whether there is some heterogeneity among mutations. For instance, perhaps there are a few different unknown subtypes of mutations. A simple k-means clustering exercise, however, did not yield any conclusive insights. More data points may be required to gain more useful insights.


### 3. Modelling and prediction
Three different machine learning algorithms – logistic regression, k-nearest neighbor  classifier and random forest classifier - are run to address both the binary and multiclass classification problem. Using Python’s scikit-learn library, all three algorithms are run several times with varying combinations of input variables and parameter settings specified for individual algorithms. Fine-tuning of each model is achieved using scikit-learn’s GridSearchCV - a powerful hyper-parameter optimization technique that can help improve the performance of a model by finding the optimal combination of hyper-parameter values. 

### 3.1 Model assessment
For useful assessment of model performance, the dataset used for all machine learning exercises is partitioned using 70% as training data and the remaining 30% as test data.

*Prediction accuracy* is used to evaluate predictions. Accuracy provides general information about how many samples are correctly classified. Accuracy is calculated as the sum of correct predictions divided by the total number of predictions. In addition, specificity and sensitivity are reported for the binary prediction. A binary classifier labels data points with one of two classes such as 1 and 0 for a given input data. The class of interest is usually referred to as ‘positive’ and the other as ‘negative’. In this analysis, the majority class antibaterial-resistant is identified as positive and the growth-resistant class as negative. Specificity, or true negative rate, measures the proportion of negatives that are correctly classified as such (i.e. the percentage of growth-resistant mutations that are identified as such). Similarly sensitivity, often also called true positive rate or recall, measures the proportion of positives that are correctly classified as such. 

*Feature-scaling* is performed as it is an important step in preprocessing data for effective assessment of most machine learning algorithms as they typically behave much better with all features on the same scale. This is because otherwise most algorithms would be optimizing weights according to the larger errors in features of larger scales. For example, one of the general features in the dataset is the number of contacts between side chains derived from 1168 x-ray protein, and values of this variable range from 1,120 to 32,623; while the feature distance-dependent statistical potential for contacts longer than 12 Angstrooms ranges from -0.02 to 0.01.

### 3.2 Binary prediction problem
Identifying a suitable baseline precedes the machine learning analysis. A baseline is a trivial predictor that uses simple rules to evaluate how different machine learning algorithms behave against it. For this analysis, two strategies are used: one that always predicts the most frequent label in the training set - also referred to as the naïve classification rule – and one that generates predictions uniformly at random. These baseline predictors are implemented using sci-kit learn’s DummyClassifier. 

The *majority rule baseline* yields an accuracy of 0.65. This means that if there was no model and every mutation was classified as belonging to the most prevalent class (in this case antibacterial), the exercise would wrongly classify 35% of the dataset. By definition, this baseline predictor is strongly biased towards antibacterial-resistant mutations (positives). The randomly generated baseline, on the other hand, makes wrong classifications for around half of the dataset and is fairly neutral in predicting either class.

A 10-fold cross validation is performed across models. This involves randomly partitioning the dataset into 10 equally sized subsamples and using each subsample once as the validation data for testing the model in 10 repeated cross-validation processes.

### 3.3 Binary prediction results
The models were run independently (see Appendix H for relevant code) and results evaluated comparatively. The models’ accuracy improves as the analysis progresses from logistic regression to random forest. This sub-section discusses the choice of algorithms and results of created models in greater detail.

The analysis starts with a **logistic regression**, which is generally a useful tool for predicting binary response classes and a worthwhile starting point for classification problems, especially if features are expected to be roughly linear and the problem linearly separable. In statistical terms, it models the conditional distribution of the target variable Y, given the features (X). As a linear classifier, it makes classification decisions based on the value of a linear combination of characteristics. With an accuracy of 0.86, the logistic regression model outperforms both baseline predictors and is biased towards positives (antibacterial-resistant mutations). 

The next algorithm is **kNN** - a completely non-parametric approach. Non-parametric models have a potentially infinite number of parameters as the model complexity, i.e. number of parameters, grows with the number of training data . With non-parametric models, no assumptions are made about the shape of the decision boundary as no assumptions are made on the underlying distribution of the data. Therefore this approach is expected to outperform the logistic regression when the decision boundary is highly non-linear (Gareth et al., 2013). Indeed, this algorithm outperforms the logistic regression yielding an accuracy of 94% with a bias towards antibacterial-resistant mutations.

Finally, a **random forest** is applied. This algorithm has become hugely popular in recent years in machine learning applications thanks to its good classification performance, scalability, and ease of use (Raschka, 2015). It does not expect linear features or linear interaction of features, prevents over fitting and is robust against outliers. In addition, this algorithm handles high dimensional spaces as well as very well, which is a useful characteristic given the large number of features in this dataset. This model yields the highest accuracy with 95%, although not far off from the kNN classifier. Just like the kNN, the random forest classifier is biased towards antibacterial-resistant mutations.

Figure 13 shows baseline accuracy and best accuracy obtained for each model. The random forest model shows the highest improvement compared to no-model classification with an accuracy of 95%, closely followed by the kNN model (94%). The logistic regression classifier, with an accuracy of 86%, performs better than the baseline predictor but not as good as the other two models. 


| Accuracy                    | Specificity (TNR) | Sensitivity |       | 
|-----------------------------|-------------------|-------------|-------| 
| (TPR)                       |                   |             |       | 
| Baseline: Majority Rule     | 0.81              | 0           | 1.000 | 
| Baseline: Random Prediction | 0.50              | 0.506       | 0.492 | 
| Logistic Regression         | 0.86              | 0.758       | 0.981 | 
| kNN                         | 0.94              | 0.898       | 0.966 | 
| Random Forest               | 0.95              | 0.906       | 0.966 | 


*Figure 13 Performance analysis*

The random forest yields a precision of 0.951, meaning that 95% of mutations are classified correctly (only 5% are misclassified). About 91% of growth-resistant mutations truly are (specificity), and 97% of mutations identified as antibacterial-resistant truly are (sensitivity).

Another useful application of random forests is the selection of relevant features from a dataset. Figure 14 shows the ten most important features ranked by their importance. It can be concluded that the two local features ∆∆G and the RSA are the two most discriminative features in the dataset, each accounting for just over 20% of variation in the data. This result confirms evidence of the importance of these variables that already emerged in the EDA. It makes sense, since global features are calculated on average and therefore will be a lot less informative when comparing two mutations that may be similar but may vary significantly in terms of their impact on functionality according to the context in which they are situated. 

![]({{site.baseurl}}/assets/f14.png)

*Figure 14 Feature importance*

| PRED_DDG | Destabilizing effect of mutation                                               | 
|----------|--------------------------------------------------------------------------------| 
| RSA      | Solvent exposure of mutation                                                   | 
| F296     | Weights.for.coil.at.the.window.position.of.6                                   | 
| F397     | Dependence.of.partition.coefficient.on.ionic.strength..Zaslavsky.et.al....     | 
| F237     | Normalized.frequency.of.turn.in.alpha.beta.class..Palau.et.al...1981..         | 
| F461     | Surface.composition.of.amino.acids.in.intracellular.proteins.of.thermophiles.  | 
| F219     | Optimized.propensity.to.form.reverse.turn                                      | 
| F348     | Information.measure.for.middle.turn                                            | 
| F115     | Hydrophilicity.value                                                           | 
| F25      | A.parameter.defined.from.the.residuals.obtained.from.the.best.correlation.of.. | 


### 3.4 Multiclass prediction problem
Next, the goal is to evaluate the extent to which the features in this dataset may equally be useful to distinguish between antibiotics classes. For this purpose, only antibiotics-resistant mutations are retained in the dataset. The target variable for this exercise consists of the antibiotics subgroups that the antibiotics fall into (Wikipedia, n.d.). 

The same steps of the previous section are repeated in this one, however this time 5-fold cross validation is performed across models such as not to conflict with the small number of records in certain antibiotics classes (see Appendix I for relevant code).

### 3.5 Multiclass prediction results
Figure 15 shows model accuracy and confusion matrices for the baseline predictors and the three classifiers. Overall, model accuracy is poor. This time the logistic regression was the best classifier, with 28% of mutations correctly classified. Second was kNN (25%), which outperformed random forest (19%). All three models outperform both baseline models (see Figure 15). RSA and ∆∆G remain the two most relevant features (results not reported here).

A perfect prediction would yield a confusion matrix with positive numbers along the diagonal and zeros everywhere else, indicating that all true labels were correctly predicted. Figure 15 shows that this is not the case here. In fact, the majority of mutations are incorrectly predicted to be either Quinolones/Fluoroquinolones or Sulfonamides (9 and 10, respectively), leaving a comparatively sparse diagonal. The only antibiotics class that is consistently accurately predicted across all three models is Terpenes (class 11).

![]({{site.baseurl}}/assets/f15.png)
 
*Figure 15 Confusion matrices for baseline predictors and the three models*

Note that even though logistic regression outperformed other algorithms, a closer inspection of mutations by antibiotics class (Table 2) reveals varying strengths across models for the prediction of individual antibiotics classes. These may not be as easily deduced from the confusion matrices alone. 

The random forest, for instance, was the best predictor for identifying mutations of Aminoacids (class 0), on average correctly classifying 97% of them. This result is all the more significant, as the total number of records in this class is fairly small; it indicates that the features in this dataset may be quite useful to discriminate against Aminoacids using this model. Quinolones/Fluoroquinolones and Sulfonamides (9,10), on the other hand, are best identified by the logistic regression model, even if the percentages of correctly classified mutations are still quite low (49% and 58%, respectively). 


![]({{site.baseurl}}/assets/t2.png)

*Table 2 Percentage of mutations correctly classified*
*MR … Majority rule baseline*
*RP … Random predictor baseline*

### Discussion
For the binary classification problem, the random forest is the best performing model in terms of accuracy. Thus, on the surface, it might seem to be the obvious choice for anyone seeking to predict mutationally-acquired tolerance phenotypes. However, inspecting the results more closely reveals perhaps less evident choices, highlighting the issue of trade-off between sensitivity and specificity. Sensitivity is essentially how good the model is at correctly classifying positives, i.e. antibacterial-resistant mutations, while specificity is a measure of how accurate the model identifies a negative result, i.e. growth-resistant mutations. 

With this dataset, progressing from the logistic regression towards more complex models comes with an improvement in overall predictive power as well as improved ability to discriminate against growth-resistant mutation - however at the expense of the ability to correctly classify antibacterial-resistant mutations. 

This trade-off between the two measures plays an important role in deciding which model to select. Given the context of investment in antibiotic resistance, for example, decision makers might care less about the model’s ability to correctly classify an antibacterial-resistant mutation and instead might be more interested in a model that is good at correctly identifying mutations that are not antibacterial-resistant. Predicting when mutations will not develop resistance to specific drugs can be just as informative to the drug production process as knowing when they do. Consequently, they might be more attracted to the logistic regression, regardless of the overall lower accuracy of the model. 

The results of the multiclass prediction problem may appear discouraging at first as all three models exhibit rather low overall accuracy. But the fact that some classes were predicted with much higher accuracy than others is promising and highlights the importance of this analysis. It is very costly to conduct tests to find out whether or not a particular mutation is resistant to any one antibiotic. Therefore being able to accurately predict tolerance phenotype through experimental design can be incredibly helpful, saving enormous amounts of resources. 

This analysis underlines the importance of generating the information required to improve accuracy of predictions. In particular, it emphasizes the need i) for new indices that are context-specific; and ii) to extend the availability of 3D structures for proteins. Other context-specific properties can be calculated taking into account the atomistic environment of the mutation, such as, for example, a protein’s secondary structure. Does the mutation occur on an alpha helix or on a beta sheet? Secondary structure can be severely disrupted by some mutations. In addition, by recalculating AA indices while taking into consideration the environment, they can be rendered context-specific. Increasing the number of available protein structures can happen through expensive new experiments but also using much more cost-effective protein structure prediction techniques.


Data sets and code used for this exercise can be found [here](https://github.com/ijeism/ijeism.github.io/tree/master/predicting-phenotypes).