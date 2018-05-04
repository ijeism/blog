# Command line (example): !python ProductSimilarity.py ratings_Baby.csv > hi.txt

from mrjob.job import MRJob
from mrjob.step import MRStep
from math import sqrt

from itertools import combinations


class Recommendation_ProductSimilarities(MRJob):

	def configure_args(self):
	# Add configuration options to take desired itemID and top N values on the command line

		super(Recommendation_ProductSimilarities, self).configure_args()
		self.add_passthru_arg('--itemID', help=('specify itemID of interest'))
		self.add_passthru_arg('--topN', type=int, help=('Number of top entries to filter'))

	def steps(self):
	# Define multiple steps to execute more than one Map-Reduce # step
		return [
			MRStep(mapper=self.mapper,
			reducer=self.reducer),
			MRStep(mapper=self.mapper2,
			reducer=self.reducer2),
			MRStep(mapper=self.mapper3,
			reducer=self.reducer3),
			MRStep(reducer=self.reducer4)]


	def mapper(self, _, line):
	# Output (itemID, rating) pairs by userID 
		(userID, itemID, rating, timestamp) = line.split(',')
		yield userID, (itemID, float(rating))

	def reducer(self, userID, value):
	# Group (itemID, rating) pairs by userID
		ratings = []
		for x, y in value:
			ratings.append((x,y))
		yield userID, ratings


	def mapper2(self, userID, itemratings): 
		c = combinations(itemratings, 2) # Find every pair each user has rated
		for v1, v2 in c:
		# Output each pair with associated rating
			yield (v1[0], v2[0]), (v1[1], v2[1])
			yield (v2[0], v1[0]), (v2[1], v1[1])

	def cosine_similarity(self, ratingsPair):
	# Compute cosine similarity metric between two rating vectors

		countPair = 0 # initiate counter
		sumxy = sumxx = sumyy = 0 # initiate variables
		score = 0 # initiate similarity score
		for x, y in ratingsPair:
			sumxy += x * y
			sumxx += x * x
			sumyy += y * y
			countPair += 1

		denominator = sqrt(sumxx) * sqrt(sumyy)
		numerator = sumxy

		if (denominator): # if denominator is non-zero,
			score = (numerator / (float(denominator))) #compute score
		return (score, countPair)

	def reducer2(self, itemPair, value):	
		score, countPair = self.cosine_similarity(value) # Compute similarity metric between rating vectors for 			# each item pair rated by multiple people
		if (countPair > 10 and score > 0.95): # Define threshold for minimum score and number of co-rating for quality
			yield itemPair, (score, countPair) # Output (score, number of co-ratings) pair for each item pair


	def mapper3(self, itemPair, value):
	# Rearrange data elements to make (item1, score) key for sorted output
		item1, item2 = itemPair
		score, n = value
		yield (item1, score), (item2, n)

	def reducer3(self, key, value):
	# Rearrange data elements to prepare for sorting and filtering in final step

		item1, score = key
		for item2, n in value:
			yield None, (score, item1, item2, n)


	def reducer4(self, key, value):
		lis = []
		for score, item1, item2, n in value:
			if item1 == self.options.itemID:
				lis.append((score, item1, item2, n)) # Append # (score, item1, item2, n) tuples to new list and sorts by score in # ascending order
		lis.sort()
		top = lis[-self.options.topN:] # Extracts top N similar # items for a given item
		for score, item1, item2, n in top:
			yield item1, (item2, score, n)


if __name__ == '__main__':
    Recommendation_ProductSimilarities.run()
