---
layout: post
title: >-
  Recommendation System Based on Item-Item Collaborative Filtering using Hadoop
  MapReduce
categories: mapreduce
author: I ON
meta: Springfield
published: true
---
![]({{site.baseurl}}/assets/rec_sys.png)

## Introduction

Online platforms - whether they are retailers, newspapers, or social media networks – have one goal: to attract the maximum volume of traffic to increase their own revenues. One way of achieving that is to enrich users’ experience when searching for content. For this purpose, an extensive class of web applications has been developed to help predict user responses to specific options. Examples include offering movies to customers of movie streaming services based on prediction of viewers’ interests, or offering customers of an on-line retailer such as Amazon suggestions about what they might want to buy, based on their purchase history, product searches, or other peoples’ ratings. Such a facility is referred to as a *recommendation system*.

Recommender systems basically generate meaningful recommendations to specific users for items, such as music, products, movies, or new articles that might be of interest to them. They are based on so-called ‘information filtering’ techniques commonly used on e-commerce websites. The aim of this project is to demonstrate how Hadoop can be used to effectively manage the large volumes of data typically involved in recommendation problems. For this purpose, Amazon product ratings data is used, and a MapReduce approach presented to identify appropriate products to recommend particularly to new users.

## Workflow

1. Problem description and key concepts
2. Software design: collaborative filtering
3. Implementation
4. Results and Analysis


## 1. Problem description and key concepts

So how do we go about recommending items to users? Let us imagine a user visiting Amazon’s website for the first time with no record or prior purchase history - a so-called *cold user*. We could simply identify the most popular items on the website and recommend them to the new visitor. But this approach is rather static in nature and would not provide sufficient depth for personalization since it does not attempt to identify individual users’ interests or preferences in any way. How, then, can we ensure increased accuracy of recommendations when a user is new and there may be insufficient information to base a recommendation on? One way is to group items that are bought and preferred similarly by users and recommend items based on similarity to the other items in that group. 

### 1.1 Preference and similarity
Similarity here is determined by an expression of a level of preference by other users for a particular item, which can be computed using simple similarity measures, such as Cosine Similarity, Pearson Correlation, Jaccard Similarity, etc., to group similar items together. A user of Amazon.com can express her opinion by rating items purchased, which I will use as a representation of users' indication of preference for items.

### 1.2 Item-based Collaborative Filtering
There are two basic architectures for a recommendation system: i. content-based systems, focusing on properties of items; and ii. collaborative-filtering systems, focusing on the relationship between items and users. In this project, I focus on the quite popular collaborative filtering technique. 

Since this project focuses on a recommender system able to deal with new users, I look at the Item-based Collaborative Filtering approach – a specific type of collaborative filtering system that focuses on the similarity of user ratings for two items to identify items to recommend to new users. It finds relationships between the new user’s interests (e.g. an item she is looking at) and existing user ratings of that particular item and other items in order to determine useful recommendations for the new user. The basic idea I am exploring is: If a new Amazon.com visitor is viewing a particular product, what other products might be similar to that product? If she liked a particular product, what other products, that she might not have come across yet, seem similar based on peoples’ ratings?

### 1.3 A big data problem
The large number of users and items are the main driving force behind recommendation systems, as they cannot provide relevant and effective recommendations without sufficient data supplying plenty of user data such as past purchases and associated ratings. In addition, recommendation system techniques involve finding items that are similar to an item a user is interested in. This requires computation of similarity metrics for all pairs of items considered, which presents a very large computational problem considering the number of products available at big online-retailers like Amazon. For this reason, it is practical to handle this type of problem using the divide and conquer pattern provided by the MapReduce framework. 

[MapReduce](http://javaarm.com/file/apache/Hadoop/books/Hadoop-The.Definitive.Guide_4.edition_a_Tom.White_April-2015.pdf) is a programming model used in Hadoop - a framework that allows for the distributed processing of large data sets across clusters of computers using simple programming models - designed to process large volumes of data. Using the Hadoop Distributed File System (HDFS), data stored across a cluster of machines can be processed quickly and in parallel, by dividing a task into a set of independent sub-tasks, each performing the same type of computation. MapReduce scales well to many thousands of nodes and can handle very large amounts of data – as required for recommendation problems. 

![]({{site.baseurl}}/assets/MR_dataflow.png)
*Figure 1 MapReduce data flow with multiple reduce tasks. Source: (White, 2015)*


At a high level, every MapReduce program transforms a list of input data elements into a list of output data elements (at least) twice - once in the map phase and once in the reduce phase. The MapReduce framework itself is made up of three major phases: map, shuffle and sort, and reduce. Hadoop divides the job into separate map and reduce tasks scheduled to run on several nodes in a Hadoop cluster. The output of the mapper is the input for the reducer task. The output from both mappers and reducers are key-value pairs. Figure 1 illustrates the data flow for the general case when running a job on multiple machines, each reducer creating one partition for each reduce task (White, 2015).

## 2. Software design: collaborative filtering

### 2.1 Dataset
For this project I use Amazon product data. The full dataset - available [here](http://jmcauley.ucsd.edu/data/amazon/) - contains a total of 142.8 million product reviews from Amazon, spanning May 1996 - July 2014. It includes reviews, product metadata, and links. I use the ratings-only dataset, which is a small subset including only (user, item, rating, timestamp) tuples. Of the 24 different categories available, I choose the 'Baby' category, consisting of 915,446 records.

An excerpt of the input data is shown below. The selection contains the first five rows of the comma-delimited dataset, where each line represents a reviewerID (or userID) followed by an itemID, the rating given by the user for that item, and an associated timestamp. For the purpose of this exercise, I require, and therefore extract, only the (userID, itemID, ratings) tuple.

```html
A28O3NP6WR5517,0188399313,5.0,1369612800
AX0M1Z6ZWO52J,0188399399,5.0,1365465600
A1KD7N84L7NIUT,0188399518,4.0,1392336000
A29CUDEIF4X1UO,0188399518,3.0,1373241600
A32592TYN6C9EM,0316967297,4.0,1378425600
```

### 2.2 High-level workflow
At a high level, the workflow of item-based collaborative filtering systems is as depicted in Figure 2. Starting off with an item-ratings matrix containing ratings by users for items they have rated, this data is then fed into the MapReduce algorithm designed to compute similarity metrics for items with respect to other items. This phase consists of i. computing similarity among items, i.e. predicting how likely they are to attract interest from a users, and ii. filtering out top similar products to recommend for a particular item. The final output consists of the most appropriate items to recommend to users - either for all items or filtered by item ID - ranked according to similarity.

![]({{site.baseurl}}/assets/workflow_iic.png)
*Figure 2 Workflow of item-based collaborative filtering systems. Source: (Divya & Divya Krishnaveni, 2015)* 

### 2.3. Collaborative Filtering: A Multiple Step MapReduce job 
The item-based collaborative filtering algorithim is implemented using the Hadoop MapReduce framework by chaining for MapReduce jobs together to obtain the recommended list of items. The first step involves finding every (item, rating) pair purchased by the same user; the second step computes the similarity of rating pairs for each item pair across all users who bought both items; the third step is merely a sorting exercise, resulting in a product list sorted by item ID and similarity score; and the fourth step filters out a desired number of most similar items for a specified item for recommendation.

The first step of our multi-step MapReduce job is responsible for creating an Inverted Index, which is a specific data structure that is used for information retrieval (Lin & Dyer, 2010). An inverted index basically provides a mapping from content to some related information, e.g. its location. In our case, the Inverted Index generates a list of (itemID, rating) pairs for each user ID. i.e. a list of items a specific user has previously purchased with their respective ratings. This job is divided into a map and a reduce job (see Figure 1): the mapper emits key-value pairs, where each key is a user ID and the value an (itemID, rating) pair; the reducer creates the inverted index, emitting userID as key and a list of associated (itemID, rating) pairs as value. Figure 3 illustrates the output from Mapper and Reducer, where ux reprsents a particular user, ix a particular itemID, and the numbers 1-5 the rating given.

![]({{site.baseurl}}/assets/mr_step1.png)
*Figure 3 Map and Reduce jobs of Step 1.*

The second step is responsible for the similarity computation phase of the recommendation problem, i.e. for generating a similarity matrix (Ekstrand et al., 2011), and is also divided into a map and a reduce job. The mapper emits key-value pairs where each key is a pair of item IDs and the value is the associated rating pair. As outlined in more detail in Section 4.3, the reducer is responsible for computing the similarity among emitted item IDs. The similarity computation involves:

i.	the generation of item pairs and associated rating pairs, 
ii.	the conversion of rating pairs into vectors, and 
iii.	finally the computation of similarity between two rating vectors. (Somani, 2015).  

![]({{site.baseurl}}/assets/mr_step2.png)
*Figure 4 Output Map and Reduce jobs of Step 2.*

Figure 4 shows the output from Mapper and Reducer in the second step. Note that I have completely dropped userID in this step, as I do not require this piece of information any further. It was necessary only to group items rated by the same user together.

A critical design element of implementing collaborative filtering is the choice of similarity function. I choose the popularly adopted cosine similarity function that is simple, fast and typically produces good predictive accuracy. Cosine similarity is a vector-space approach based on linear algebra. Items are represented as n - dimensional vectors, and similarity is measured by the cosine distance, i.e. the cosine of the angle, between two rating vectors. The cosine distance is computed by dividing the dot products of two rating vectors by the product of the square root of their sums:

![]({{site.baseurl}}/assets/equation.png)

The third step involves sorting and filtering, as illustrated in Figure 5, to generate a meaningfully sorted output as well as to prepare for effective information retrieval. Since a recommendation system typically deals with an enormous number of items, I want to decrease the density of the similarity matrix generated in Step 2 (Schelter et al., 2012). To do this I get rid of pairs with near-zero similarity by specifying a similarity threshold and size constraint to prune lower scoring item pairs. This threshold is best determined experimentally to avoid negative effects in prediction quality, as it depends on the particular data at hand. 

![]({{site.baseurl}}/assets/mr_step3.png)
*Figure 5 Output of Map and Reduce jobs of Step 3

In the final step, I retain only a fraction of most similar items for recommendation purposes, as this approach has shown to be sufficient for good item-based prediction quality (Schelter et al., 2012). To derive recommendations for each item, the ranking among the item pairs (item1, item2) needs to be computed. For each item pair (item1, item2) a ranking is computed based on the descending order of similarity value of item x with the rest of the items. This process is repeated for all item pairs. From the pool of similar items for any particular item x, an arbitrarily chosen number of top N items are then selected and provided as the recommendation to the user (Somani, 2015). I also add the ability to specify the particular item x I want to see the output for.

Steps involved are:
1.	Fetch the list of item-pairs containing the target item x with similarity 	values;
2.	Sort the list of item-pairs in descending order of the similarity values;
3.	Once sorted, select the top N items from the sorted list of item-pairs;
4.	Once selected, recommend the selected list of items for the target item x (Somani, 2015).

## 3. Implementation

Created by Yelp, `mrjob` is a Python MapReduce library that allows multistep MapReduce jobs to be written in pure Python. Hadoop provides an API - Hadoop Streaming - as the interface between Hadoop and programs written in languages other than Java (MapReduce's native language) (White, 2015). MapReduce jobs written with `mrjob` can be tested locally, run on a Hadoop cluster, or run in the cloud using Amazon Elastic MapReduce (EMR) (Radtka & Miner, 2016). 

The fact that a program can be executed and tested without having Hadoop installed is a very useful feature as it allows for development and testing before actually deploying to a Hadoop cluster. Another plus, as I will show, is that mrjob also allows MapReduce applications to be written in a single class instead of separate programs for the mapper and reducer. Note, however, that while these might be attractive advantages, mrjob is rather simplified and does not give the same level of access to Hadoop that other APIs offer. In addition, it does not use typedbytes, meaning that other libraries may be faster (Radtka & Miner, 2016). Nonetheless, it is a great solution for experimenting and getting to understand the MapReduce process.

### 3.1 Multiple-Step MapReduce Job
I begin by defining multiple steps in order to execute more than one Map-Reduce step in one job. The class `mrjob.step.MRStep` (see Source Code) represents steps - and the sequence in which they are to be run - handled by the script containing our job (Yelp and Contributors, 2016). With the code below, I determine that our MapReduce job contains three steps divided into a map and a reduce job each, with an additional fourth step consisting of one reducer only. As we will see, this final step enables us produce an arbitrary number of filtered recommendations for specified items. 

{% highlight python %}
def steps(self):
	return [
		MRStep(mapper=self.mapper,
			reducer=self.reducer),
		MRStep(mapper=self.mapper2,
			reducer=self.reducer2),
		MRStep(mapper=self.mapper3,
			reducer=self.reducer3),
		MRStep(reducer=self.reducer4)]

{% endhighlight %}

### Step 1: Inverted Index Creation
The first step involves parsing the input data to extract user IDs and their associated (item, rating) pairs in the mapper; and grouping these (item, rating) pairs by user ID in the reducer. The output from this step is a list of individual user IDs and all (item, rating) pairs associated with each user individually.

{% highlight python %}
def mapper(self, _, line):
	(userID, itemID, rating, timestamp) = line.split(',')
	yield userID, (itemID, float(rating))

def reducer(self, userID, value):
	itemratings = []
	for itemID, rating in value:
		itemratings.append((itemID, rating))
	yield userID, itemratings
{% endhighlight %}

### Step 2: Similarity Computation and Pruning
The Mapper of the second step finds every pair of items each user has rated and outputs each pair with its associated ratings. As mentioned earlier, I drop userID entirely; instead I output the pair of items as the key and the associated pair of ratings as the value. In order to find every possible pair of items, I utilize the Python function 'combinations', which generates a sequence of all possible k-tuples of elements in an iterable, ignoring order (McKinney, 2013). In this case, this function produces every possible pair from the list of (item, rating) pairs for a particular user. This means that if user1 had (item, rating) pairs (i17, 5) (i19, 1) and (i20, 4), the combinations function would generate a sequence of the following combinations: [(i17,5),(i19,1); (i17,5)(i20,4);(i19,1),(i20,4)]. These are represented by v1, v2 in our code. 

In order to yield individual item pairs with associated rating pairs, I then extract and group the first element - the item element - of v1 (e.g. i17) with the first element of v2 (e.g. i19), and the second element - the rating element - of v1 (e.g. 5) with the second element of v2 (e.g. 1). This results in item pair (i19,i17) and associated rating pair (5,1).

Note that U produce item pairs and associated rating pairs bi-directionally, yielding information for pairs (item1,i, item2,i) as well as (item2,i, item1,i), e.g. (i19,i17), (5,1) and (i17,i19), (5,1). This is to ensure a complete list of item IDs for effective subsequent information retrieval. 

Next, a function ```cosine_similarity``` is defined for calculating the cosine similarity metric - discussed in Section 3 - which is used in the Reducer. The Reducer is responsible for computing the similarity score between the ratings vectors for each item pair rated by multiple users. Put differently, it calculates the similarity of each unique pair of items across all users who rated both item1 and item2. It does so by invoking the previously defined ```cosine_similarity``` function, using (item, rating) pairs as the argument and specifying the desired number of elements of combinations as 2. 

As discussed earlier, I choose to specify a similarity threshold - retaining only pairs with a similarity score above 0.95 - and size constraint - retaining only pairs with at least 10 co-ratings - to remove lower scoring item pairs. The output consists of the pair of items as the key and the associated similarity with number of mutual ratings as the value. Similarities are normalized to [0,1] scale.

{% highlight python %}
def mapper2(self, userID, itemratings):
	c = combinations(itemratings, 2)
	for v1, v2 in c:
		yield (v1[0], v2[0]), (v1[1], v2[1])
		yield (v2[0], v1[0]), (v2[1], v1[1])


def cosine_similarity(self, ratingsPair):
	countPair = 0
	sumxy = sumxx = sumyy = 0
	score = 0
	for x, y in ratingsPair:
		sumxy += x * y
		sumxx += x * x
		sumyy += y * y
		countPair += 1
	denominator = sqrt(sumxx) * sqrt(sumyy)
	numerator = sumxy
	if (denominator):
		score = (numerator / (float(denominator)))
	return (score, countPair)


def reducer2(self, itemPair, value):
	score, countPair = self.cosine_similarity(value)
	if (countPair > 10 and score > 0.95):
		yield itemPair, (score, countPair)
{% endhighlight %}


### Step 3: Sorting 
The third step of the job serves as a way to rearrange the data elements to ensure a meaningfully sorted output, which is useful for further processing.  To this end, the Mapper emits (item1, score) as a key to sort by itemID, and the Reducer emits an empty key and the (score, item1, item2, n) tuple as a value to prepare for sorting and filtering in the final step. Note that score is positioned as the first element of the tuple. This is to enable us sort and filter by score in the final step. 

{% highlight python %}
def mapper3(self, itemPair, value):
	item1, item2 = itemPair
	score, n = value
	yield (item1, score), (item2, n)


def reducer3(self, key, value):
	item1, score = keys
	for item2, n in value:
		yield None, (score, item1, item2, n)
{% endhighlight %}

### Step 4: Filtering for Recommendation
The last part of the implementation is to derive recommendations for items based on the similarity score of the item pairs. This final step consists of only one reduce job. It is responsible for producing recommendations for a user related to a particular item in the form of a specified number of items that are top ranking based on their similarity score relative to that specific item. To achieve this, I construct a filter to specify records that contain a specific number (in our case the desired number of most similar products) or a string of text (in our case the item ID). One way to achieve this in Python is to: 

i.	create a new list; 
ii.	append all tuples (score, item1, item2, n) using the append() function;
iii.sort the list using the sort() function; and 
iv.	slice the list to select only the specified number of tuples with highest scores. 

Since the `sort()` function automatically sorts in ascending order, negative indices are used to slice the list relative to the end (McKinney, 2013). This allows to select only the most similar items to recommend in relation to a particular item.

{% highlight python %}
def reducer4(self, key, value):
	lis = []
	for score, item1, item2, n in value:
		if item1 == self.options.itemID:
			lis.append((score, item1, item2, n))
	lis.sort()
	top = lis[-self.options.topN:]
	for score, item1, item2, n in top:
		yield item1, (item2, score, n)

{% endhighlight %}

In order to be able to specify - in addition to input and output directories - the desired item ID and number of top similar items in the command line, I define configuration options at the beginning of the Source Code. These allow us to pass the specific item ID and number of top similar items specified as additional arguments --itemID and --topN in the command line through to the program (```html self.options.itemID``` and  ```html self.options.topN```,  respectively) as it is run.

{% highlight python %}
def configure_options(self):
super(ProductSimilarities, self).configure_options()
self.add_passthrough_option('--itemID', help=('specify itemID of interest'))
self.add_passthrough_option('--topN', type = int, help=('Number of top entries to filter'))
{% endhighlight %}

## 4. Results and Analysis

### 4.1 Recommendation job
The output from the Recommendation job emitting the top 10 most similar products, in ascending order, for the item ID 'B00003TL7P', as specified in the command line, are as follows: 

"ITEM ID"|["ITEM ID", SIMILARITY SCORE, NUMBER OF CO-RATINGS]
---|---
"B00003TL7P"|["B00005BYUR", 0.9715450958589567, 14]
"B00003TL7P" | ["B0000DEW8N", 0.9719810695253235, 18]
"B00003TL7P" | ["B00006G963", 0.9727989913506497, 12]
"B00003TL7P" | ["B000067EH7", 0.9790109038932515, 65]
"B00003TL7P" | ["B0006FHFYS", 0.9815308005362453, 42]
"B00003TL7P" | ["B0000936LR", 0.9829371361047635, 12]
"B00003TL7P" | ["B00005C6OI", 0.9848737185901497, 12]
"B00003TL7P" | ["B00065H55W", 0.9875106606839943, 12]


The most data intensive part of this job is the second step: as shown in Figure 6, Step 2 dominates the total execution time of steps, taking 5 minutes, compared to Steps 1, 3, and 4 taking 2, 1, and 1 and minute(s), respectively. This gives an indication of where to focus possible improvements of the program design to reduce the amount of data written to the HDFS. One possibility is the specification of a combiner function between mapper and reducer in Step 2 to aggregate the output by key before writing to the HDFS. This would reduce the amount of data passed through the shuffle phase as a result of the combinations computation in the mapper. 
 
![]({{site.baseurl}}/assets/runtime_ps.png)
*Figure 6 Runtime per step

The information on runtime of map and reduce tasks also gives an idea of how many more machines to dedicate to running the job to reduce run time. Of course this project deals with only a very small dataset just for demonstration purposes, but when dealing with massive datasets using large-scale data storage and processing infrastructures, as is often the case in modern organizations, this issue becomes a real concern.

### 4.2 Product Similarities job
For comparison purposes, I also run just the first three steps of the MapReduce job in order to generate the entire list of items with their respective list of similar products. Runtimes for steps 1-3 are similar to the ones reported for the Recommendation job. The following is an excerpt of the first couple of rows of output from this MapReduce job:

"ITEM ID"|["ITEM ID", SIMILARITY SCORE, NUMBER OF CO-RATINGS]
---|---
"B00003TL7P"|["B0002N3OMG", 0.9507868781289148, 14]
"B00003TL7P"|["B00005BTB1", 0.9541089219908963, 12]
"B00003TL7P"|["B000056OV0", 0.9555225962625125, 31]
"B00003TL7P"|["B00009P7I5", 0.9580170197702604, 14]
"B00003TL7P"|["B000056HNZ", 0.9585245325202532, 14]
"B00003TL7P"|["B000059XOD", 0.9649060784569715, 30]
"B00003TL7P"|["B0001IU5HY", 0.9654727361161941, 29]
"B00003TL7P"|["B000056J9F", 0.9658472446812929, 12]
"B00003TL7P"|["B00005JIVI", 0.9682728956857302, 16]
"B00003TL7P"|["B0002ZOI9W", 0.9696611877713683, 14]
"B00003TL7P"|["B000S35QLC", 0.9702820941895154, 30]
"B00003TL7P"|["B000324Y7U", 0.971042963758939, 33]
"B00003TL7P"|["B00005BYUR", 0.9715450958589567, 14]
"B00003TL7P"|["B0000DEW8N", 0.9719810695253235, 18]
"B00003TL7P"|["B00006G963", 0.9727989913506497, 12]
"B00003TL7P"|["B000067EH7", 0.9790109038932515, 65]
"B00003TL7P"|["B0006FHFYS", 0.9815308005362453, 42]
"B00003TL7P"|["B0000936LR", 0.9829371361047635, 12]
"B00003TL7P"|["B00005C6OI", 0.9848737185901497, 12]
"B00003TL7P"|["B00065H55W", 0.9875106606839943, 12]
"B00003TL7P"|["B000056OUH", 0.9887809514275694, 42]
"B00003TL7P"|["B0000936M4", 0.9928268682883957, 11]
"B00004TFLB"|["B000YDDF6O", 0.9602217969019541, 27]
"B00004TFLB"|["B000BNQC58", 0.9604664985878935, 12]
"B00004TFLB"|["B001UF8BL4", 0.9876590252123215, 15]
"B000056C86"|["B000IDSLOG", 0.9517713799167301, 14]
"B000056C86"|["B000YDDF6O", 0.9927945535915402, 13]
"B000056HNX"|["B000056OUF", 0.96715211568869, 23]
"B000056HNX"|["B000056OUH", 0.9713586960611499, 38]
"B000056HNX"|["B0000AY9XY", 0.997040538050167, 12]


Note that this job was run on one machine only, which is why I obtain a nicely sorted output. When running the job on multiple machines using multiple reducers, however, the results will be only partially sorted. In this case I would find an ordered set of records for the item ID "B0003TL7P", for instance, at the beginning of the list as well as further down - in several groupings, depending on the number of machines the job was distributed to. This is because the reducers performing the sorting exercise run on various machines, each emitting an individually sorted output. One way of tackling this issue is by using a partitioner that respects the order of the output, making sure partition sizes are chosen to be fairly even so that job times are not dominated by a single reducer (White, 2015).

## Conclusion
This project demonstrated the use of the MapReduce framework using Hadoop's Distributed File System to i. compute similarity scores for an Amazon product list; and ii. generate a specified number of recommendations for any given item. It used an item-based collaborative filtering approach to produce recommendations for users without purchase history or any information other than a particular item of interest.

Possible enhancements of this approach could involve experimenting with similarity metrics, e.g. trying out other metrics, combining a number of different metrics, or even including the number of co-ratings per item pair as a weighting factor to see whether there is any improvement to the accuracy of product similarities. As mentioned earlier, improvements to the MapReduce program's design could also result in a significant reduction of data communication to the HDFS.

It is also noteworthy that running the program on applications that require real-time or low-latency data access will not work well with Hadoop's HDFS. Therefore, instead of storing the Hadoop sequence file into the HDFS, other frameworks such as HBase or Sqoop could be used to support real-time retrieval (Divya & Divya Krishnaveni, 2015; White, 2015).

The collaborative filtering technique itself, however, is useful, particularly - although not exclusively - for recommendations to cold users. Once the purchase history of users starts to build, items can be recommended based on users' own ratings of products purchased and their similarity to other items not purchased. Using a combination of both item-based and user-based collaborative filtering, recommendation systems could provide even more accurate recommendations to users.

***************
Code used for this project can be found [here](https://github.com/ijeism/ijeism.github.io/tree/master/recommendation_system).
