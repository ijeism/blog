---
layout: post
title: >-
    Recommendation System Based on Item-Item Collaborative Filtering using
  Hadoop MapReduce
categories: junk
author: Bart Simpson
meta: Springfield
published: true
---
## Introduction

Online platforms - whether they are retailers, newspapers, or social media networks – have one goal: to attract the maximum volume of traffic to increase their own revenues. One way of achieving that is to enrich users’ experience when searching for content. For this purpose, an extensive class of web applications has been developed to help predict user responses to specific options. Examples include offering movies to customers of movie streaming services based on prediction of viewers’ interests, or offering customers of an on-line retailer such as Amazon suggestions about what they might want to buy, based on their purchase history, product searches, or other peoples’ ratings. Such a facility is referred to as a recommendation system (Rajaraman & Ullman, 2012).

Recommender systems basically generate meaningful recommendations to specific users for items, such as music, products, movies, or new articles that might be of interest to them. They are based on so-called ‘information filtering’ techniques commonly used on e-commerce websites. The aim of this project is to demonstrate how Hadoop can be used to effectively manage the large volumes of data typically involved in recommendation problems. For this purpose, Amazon product ratings data is used, and a MapReduce approach presented to identify appropriate products to recommend particularly to new users.

## Problem description and key concepts

So how do we go about recommending items to users? Let us imagine a user visiting Amazon’s website for the first time with no record or prior purchase history - a so-called cold user (Son, 2016). We could simply identify the most popular items on the website and recommend them to the new visitor. But this approach is rather static in nature and would not provide sufficient depth for personalization since it does not attempt to identify individual users’ interests or preferences in any way. How, then, can we ensure increased accuracy of recommendations when a user is new and there may be insufficient information to base a recommendation on? One way is to group items that are bought and preferred similarly by users and recommend items based on similarity to the other items in that group. 

### Preference and similarity
Similarity here is determined by an expression of a level of preference by other users for a particular item, which can be computed using simple similarity measures, such as Cosine Similarity, Pearson Correlation, Jaccard Similarity, etc., to group similar items together (Somani, 2015). A user of Amazon.com can express her opinion by rating items purchased, which we will use as a representation of users' indication of preference for items.

### Item-based Collaborative Filtering
There are two basic architectures for a recommendation system: i. content-based systems, focusing on properties of items; and ii. collaborative-filtering systems, focusing on the relationship between items and users (Rajaraman & Ullman, 2012). In this project, we focus on the quite popular collaborative filtering technique. 

Since our project focuses on a recommender system able to deal with new users, we look at the Item-based Collaborative Filtering approach – a specific type of collaborative filtering system that focuses on the similarity of user ratings for two items to identify items to recommend to new users (Rajaraman & Ullman, 2012). It finds relationships between the new user’s interests (e.g. an item she is looking at) and existing user ratings of that particular item and other items in order to determine useful recommendations for the new user. The basic idea we are exploring is: If a new Amazon.com visitor is viewing a particular product, what other products might be similar to that product? If she liked a particular product, what other products, that she might not have come across yet, seem similar based on peoples’ ratings?

### A big data problem
The large number of users and items are the main driving force behind recommendation systems, as they cannot provide relevant and effective recommendations without sufficient data supplying plenty of user data such as past purchases and associated ratings (Pal, 2015). In addition, recommendation system techniques involve finding items that are similar to an item a user is interested in. This requires computation of similarity metrics for all pairs of items considered, which presents a very large computational problem considering the number of products available at big online-retailers like Amazon. For this reason, it is practical to handle this type of problem using the divide and conquer pattern provided by the MapReduce framework. 

MapReduce is a programming model used in Hadoop - a framework that allows for the distributed processing of large data sets across clusters of computers using simple programming models - designed to process large volumes of data (White, 2015). Using the Hadoop Distributed File System (HDFS), data stored across a cluster of machines can be processed quickly and in parallel, by dividing a task into a set of independent sub-tasks, each performing the same type of computation (Radtka & Miner, 2016; White, 2015). MapReduce scales well to many thousands of nodes and can handle very large amounts of data – as required for recommendation problems. 

At a high level, every MapReduce program transforms a list of input data elements into a list of output data elements (at least) twice - once in the map phase and once in the reduce phase. The MapReduce framework itself is made up of three major phases: map, shuffle and sort, and reduce. Hadoop divides the job into separate map and reduce tasks scheduled to run on several nodes in a Hadoop cluster. The output of the mapper is the input for the reducer task. The output from both mappers and reducers are key-value pairs. Figure 1 illustrates the data flow for the general case when running a job on multiple machines, each reducer creating one partition for each reduce task (White, 2015).

## Software design: collaborative filtering

### Dataset
For this project we use Amazon product data. The full dataset - available at http://jmcauley.ucsd.edu/data/amazon/ - contains a total of 142.8 million product reviews from Amazon, spanning May 1996 - July 2014. It includes reviews, product metadata, and links. We use the ratings-only dataset, which is a small subset including only (user, item, rating, timestamp) tuples. Of the 24 different categories available, we choose the 'Baby' category, consisting of 915,446 records.

An excerpt of the input data is shown below. The selection contains the first five rows of the comma-delimited dataset, where each line represents a reviewerID (or userID) followed by an itemID, the rating given by the user for that item, and an associated timestamp. For the purpose of this exercise, we require, and therefore extract, only the (userID, itemID, ratings) tuple.

### High-level workflow
At a high level, the workflow of item-based collaborative filtering systems is as depicted in Figure 2. Starting off with an item-ratings matrix containing ratings by users for items they have rated, this data is then fed into the MapReduce algorithm designed to compute similarity metrics for items with respect to other items. This phase consists of i. computing similarity among items, i.e. predicting how likely they are to attract interest from a users, and ii. filtering out top similar products to recommend for a particular item. The final output consists of the most appropriate items to recommend to users - either for all items or filtered by item ID - ranked according to similarity.

### Collaborative Filtering: A Multiple Step MapReduce job 
The item-based collaborative filtering algorithim is implemented using the Hadoop MapReduce framework by chaining for MapReduce jobs together to obtain the recommended list of items. The first step involves finding every (item, rating) pair purchased by the same user; the second step computes the similarity of rating pairs for each item pair across all users who bought both items; the third step is merely a sorting exercise, resulting in a product list sorted by item ID and similarity score; and the fourth step filters out a desired number of most similar items for a specified item for recommendation.

The first step of our multi-step MapReduce job is responsible for creating an Inverted Index, which is a specific data structure that is used for information retrieval (Lin & Dyer, 2010). An inverted index basically provides a mapping from content to some related information, e.g. its location. In our case, the Inverted Index generates a list of (itemID, rating) pairs for each user ID. i.e. a list of items a specific user has previously purchased with their respective ratings. This job is divided into a map and a reduce job (see Figure 1): the mapper emits key-value pairs, where each key is a user ID and the value an (itemID, rating) pair; the reducer creates the inverted index, emitting userID as key and a list of associated (itemID, rating) pairs as value. Figure 3 illustrates the output from Mapper and Reducer, where ux reprsents a particular user, ix a particular itemID, and the numbers 1-5 the rating given.

The second step is responsible for the similarity computation phase of the recommendation problem, i.e. for generating a similarity matrix (Ekstrand et al., 2011), and is also divided into a map and a reduce job. The mapper emits key-value pairs where each key is a pair of item IDs and the value is the associated rating pair. As outlined in more detail in Section 4.3, the reducer is responsible for computing the similarity among emitted item IDs. The similarity computation involves:

i.	the generation of item pairs and associated rating pairs, 
ii.	the conversion of rating pairs into vectors, and 
iii.	finally the computation of similarity between two rating vectors. (Somani, 2015).  

Figure 4 shows the output from Mapper and Reducer in the second step. Note that we have completely dropped userID in this step, as we do not require this piece of information any further. It was necessary only to group items rated by the same user together.

A critical design element of implementing collaborative filtering is the choice of similarity function. We choose the popularly adopted cosine similarity function that is simple, fast and typically produces good predictive accuracy (Ekstrand et al., 2011). Cosine similarity is a vector-space approach based on linear algebra. Items are represented as n - dimensional vectors, and similarity is measured by the cosine distance, i.e. the cosine of the angle, between two rating vectors (Perone, 2013; Ekstrand et al., 2011). The cosine distance is computed by dividing the dot products of two rating vectors by the product of the square root of their sums:

The third step involves sorting and filtering, as illustrated in Figure 5, to generate a meaningfully sorted output as well as to prepare for effective information retrieval. Since a recommendation system typically deals with an enormous number of items, we want to decrease the density of the similarity matrix generated in Step 2 (Schelter et al., 2012). To do this we get rid of pairs with near-zero similarity by specifying a similarity threshold and size constraint to prune lower scoring item pairs. This threshold is best determined experimentally to avoid negative effects in prediction quality, as it depends on the particular data at hand. 

In our final step, we retain only a fraction of most similar items for recommendation purposes, as this approach has shown to be sufficient for good item-based prediction quality (Schelter et al., 2012). To derive recommendations for each item, the ranking among the item pairs (item1, item2) needs to be computed. For each item pair (item1, item2) a ranking is computed based on the descending order of similarity value of item x with the rest of the items. This process is repeated for all item pairs. From the pool of similar items for any particular item x, an arbitrarily chosen number of top N items are then selected and provided as the recommendation to the user (Somani, 2015). We also add the ability to specify the particular item x we want to see the output for.

Steps involved are:
1.	Fetch the list of item-pairs containing the target item x with similarity 	values;
2.	Sort the list of item-pairs in descending order of the similarity values;
3.	Once sorted, select the top N items from the sorted list of item-pairs;
4.	Once selected, recommend the selected list of items for the target item x (Somani, 2015).

## Implementation

Since we are using a programming language other than the ones suggested for completion of this coursework, a brief introduction seems appropriate. Created by Yelp, mrjob is a Python MapReduce library that allows multistep MapReduce jobs to be written in pure Python. Hadoop provides an API - Hadoop Streaming - as the interface between Hadoop and programs written in languages other than Java (MapReduce's native language) (White, 2015). MapReduce jobs written with mrjob can be tested locally, run on a Hadoop cluster, or run in the cloud using Amazon Elastic MapReduce (EMR) (Radtka & Miner, 2016). 

The fact that a program can be executed and tested without having Hadoop installed is a very useful feature as it allows for development and testing before actually deploying to a Hadoop cluster. Another plus, as we will show, is that mrjob also allows MapReduce applications to be written in a single class instead of separate programs for the mapper and reducer. Note, however, that while these might be attractive advantages, mrjob is rather simplified and does not give the same level of access to Hadoop that other APIs offer. In addition, it does not use typedbytes, meaning that other libraries may be faster (Radtka & Miner, 2016). Nonetheless, it is a great solution for experimenting and getting to understand the MapReduce process.

### Multiple-Step MapReduce Job
We begin by defining multiple steps in order to execute more than one Map-Reduce step in one job. The class mrjob.step.MRStep (see Source Code) represents steps - and the sequence in which they are to be run - handled by the script containing our job (Yelp and Contributors, 2016). With the code below, we determine that our MapReduce job contains three steps divided into a map and a reduce job each, with an additional fourth step consisting of one reducer only. As we will see, this final step enables us produce an arbitrary number of filtered recommendations for specified items. 

### Step 1: Inverted Index Creation
The first step involves parsing the input data to extract user IDs and their associated (item, rating) pairs in the mapper; and grouping these (item, rating) pairs by user ID in the reducer. The output from this step is a list of individual user IDs and all (item, rating) pairs associated with each user individually.

### Step 2: Similarity Computation and Pruning
The Mapper of the second step finds every pair of items each user has rated and outputs each pair with its associated ratings. As mentioned earlier, we drop userID entirely; instead we output the pair of items as the key and the associated pair of ratings as the value. In order to find every possible pair of items, we utilize the Python function 'combinations', which generates a sequence of all possible k-tuples of elements in an iterable, ignoring order (McKinney, 2013). In our case, this function produces every possible pair from the list of (item, rating) pairs for a particular user. This means that if user1 had (item, rating) pairs (i17, 5) (i19, 1) and (i20, 4), the combinations function would generate a sequence of the following combinations: [(i17,5),(i19,1); (i17,5)(i20,4);(i19,1),(i20,4)]. These are represented by v1, v2 in our code. 

In order to yield individual item pairs with associated rating pairs, we then extract and group the first element - the item element - of v1 (e.g. i17) with the first element of v2 (e.g. i19), and the second element - the rating element - of v1 (e.g. 5) with the second element of v2 (e.g. 1). This results in item pair (i19,i17) and associated rating pair (5,1).

Note that we produce item pairs and associated rating pairs bi-directionally, yielding information for pairs (item1,i, item2,i) as well as (item2,i, item1,i), e.g. (i19,i17), (5,1) and (i17,i19), (5,1). This is to ensure a complete list of item IDs for effective subsequent information retrieval. 

Next, a function cosine_similarity is defined for calculating the cosine similarity metric - discussed in Section 3 - which is used in the Reducer. The Reducer is responsible for computing the similarity score between the ratings vectors for each item pair rated by multiple users. Put differently, it calculates the similarity of each unique pair of items across all users who rated both item1 and item2. It does so by invoking the previously defined cosine_similarity function, using (item, rating) pairs as the argument and specifying the desired number of elements of combinations as 2. 

As discussed earlier, we choose to specify a similarity threshold - retaining only pairs with a similarity score above 0.95 - and size constraint - retaining only pairs with at least 10 co-ratings - to remove lower scoring item pairs. The output consists of the pair of items as the key and the associated similarity with number of mutual ratings as the value. Similarities are normalized to [0,1] scale.




### Step 3: Sorting 
The third step of the job serves as a way to rearrange the data elements to ensure a meaningfully sorted output, which is useful for further processing.  To this end, the Mapper emits (item1, score) as a key to sort by itemID, and the Reducer emits an empty key and the (score, item1, item2, n) tuple as a value to prepare for sorting and filtering in the final step. Note that score is positioned as the first element of the tuple. This is to enable us sort and filter by score in the final step.  

### Step 4: Filtering for Recommendation
The last part of the implementation is to derive recommendations for items based on the similarity score of the item pairs. This final step consists of only one reduce job. It is responsible for producing recommendations for a user related to a particular item in the form of a specified number of items that are top ranking based on their similarity score relative to that specific item. To achieve this, we construct a filter allowing us to specify records that contain a specific number (in our case the desired number of most similar products) or a string of text (in our case the item ID). One way to achieve this in Python is to: 

i.	create a new list; 
ii.	append all tuples (score, item1, item2, n) using the append() function;
iii.	sort the list using the sort() function; and 
iv.	slice the list to select only the specified number of tuples with highest scores. 

Since the sort() function automatically sorts in ascending order, negative indices are used to slice the list relative to the end (McKinney, 2013). This allows us to select only the most similar items to recommend in relation to a particular item.


In order to be able to specify - in addition to input and output directories - the desired item ID and number of top similar items in the command line, we define configuration options at the beginning of the Source Code. These allow us to pass the specific item ID and number of top similar items specified as additional arguments --itemID and --topN in the command line through to the program (self.options.itemID and  self.options.topN,  respectively) as it is run.


## Results and Analysis

### Recommendation job
The output from the Recommendation job emitting the top 10 most similar products, in ascending order, for the item ID 'B00003TL7P', as specified in the command line, are as follows: 


The most data intensive part of this job is the second step: as shown in Figure 6, Step 2 dominates the total execution time of steps, taking 5 minutes, compared to Steps 1, 3, and 4 taking 2, 1, and 1 and minute(s), respectively. This gives an indication of where to focus possible improvements of the program design to reduce the amount of data written to the HDFS. One possibility is the specification of a combiner function between mapper and reducer in Step 2 to aggregate the output by key before writing to the HDFS. This would reduce the amount of data passed through the shuffle phase as a result of the combinations computation in the mapper. 
 
Figure 6 Runtime per step

The information on runtime of map and reduce tasks also gives an idea of how many more machines to dedicate to running the job to reduce run time. Of course this project deals with only a very small dataset just for demonstration purposes, but when dealing with massive datasets using large-scale data storage and processing infrastructures, as is often the case in modern organizations, this issue becomes a real concern.

### Product Similarities job
For comparison purposes, we also run just the first three steps of the MapReduce job in order to generate the entire list of items with their respective list of similar products. Runtimes for steps 1-3 are similar to the ones reported for the Recommendation job. The following is an excerpt of the first couple of rows of output from this MapReduce job:
 


Note that this job was run on one machine only, which is why we obtain a nicely sorted output. When running the job on multiple machines using multiple reducers, however, the results will be only partially sorted. In this case we would find an ordered set of records for the item ID "B0003TL7P", for instance, at the beginning of the list as well as further down - in several groupings, depending on the number of machines the job was distributed to. This is because the reducers performing the sorting exercise run on various machines, each emitting an individually sorted output. One way of tackling this issue is by using a partitioner that respects the order of the output, making sure partition sizes are chosen to be fairly even so that job times are not dominated by a single reducer (White, 2015).

## Conclusion

This project demonstrated the use of the MapReduce framework using Hadoop's Distributed File System to i. compute similarity scores for an Amazon product list; and ii. generate a specified number of recommendations for any given item. It used an item-based collaborative filtering approach to produce recommendations for users without purchase history or any information other than a particular item of interest.

Possible enhancements of our approach could involve experimenting with similarity metrics, e.g. trying out other metrics, combining a number of different metrics, or even including the number of co-ratings per item pair as a weighting factor to see whether there is any improvement to the accuracy of product similarities. As mentioned earlier, improvements to the MapReduce program's design could also result in a significant reduction of data communication to the HDFS.

It is also noteworthy that running the program on applications that require real-time or low-latency data access will not work well with Hadoop's HDFS. Therefore, instead of storing the Hadoop sequence file into the HDFS, other frameworks such as HBase or Sqoop could be used to support real-time retrieval (Divya & Divya Krishnaveni, 2015; White, 2015).

The collaborative filtering technique itself, however, is useful, particularly - although not exclusively - for recommendations to cold users. Once the purchase history of users starts to build, items can be recommended based on users' own ratings of products purchased and their similarity to other items not purchased. Using a combination of both item-based and user-based collaborative filtering, recommendation systems could provide even more accurate recommendations to users.



```html
<html>
  <head>
  </head>
  <body>
    <p>Hello, World!</p>
  </body>
</html>
```




- First item, yo
- Second item, dawg
- Third item, what what?!
- Fourth item, fo sheezy my neezy

### Oh hai, an ordered list!!

In arcu magna, aliquet vel pretium et, molestie et arcu. Mauris lobortis nulla et felis ullamcorper bibendum. Phasellus et hendrerit mauris.

1. First item, yo
2. Second item, dawg
3. Third item, what what?!
4. Fourth item, fo sheezy my neezy




### Tables

Title 1               | Title 2               | Title 3               | Title 4
--------------------- | --------------------- | --------------------- | ---------------------
lorem                 | lorem ipsum           | lorem ipsum dolor     | lorem ipsum dolor sit
lorem ipsum dolor sit | lorem ipsum dolor sit | lorem ipsum dolor sit | lorem ipsum dolor sit
lorem ipsum dolor sit | lorem ipsum dolor sit | lorem ipsum dolor sit | lorem ipsum dolor sit
lorem ipsum dolor sit | lorem ipsum dolor sit | lorem ipsum dolor sit | lorem ipsum dolor sit


Title 1 | Title 2 | Title 3 | Title 4
--- | --- | --- | ---
lorem | lorem ipsum | lorem ipsum dolor | lorem ipsum dolor sit
lorem ipsum dolor sit amet | lorem ipsum dolor sit amet consectetur | lorem ipsum dolor sit amet | lorem ipsum dolor sit
lorem ipsum dolor | lorem ipsum | lorem | lorem ipsum
lorem ipsum dolor | lorem ipsum dolor sit | lorem ipsum dolor sit amet | lorem ipsum dolor sit amet consectetur
