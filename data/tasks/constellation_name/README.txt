TASK #34
aditya.91.singh@gmail.com
bharatmunshi@gmail.com
chandra.arpita@gmail.com
eskiranmai94@gmail.com

TASK: Given the picture of a constellation, guess its name.

DESCRIPTION. You will be shown pictures of 20 celebrities and asked to guess their name from the given options.

CORPUS: The set of 88 modern constellations was used as the corpus. This can be found here: http://en.wikipedia.org/wiki/88_modern_constellations.
		
METHODOLOGY: 
	TASKS
	A list of most popular constellations was made by combining those given here:
	http://www.artofmanliness.com/2014/07/16/15-constellations-every-man-should-know/
	http://www.solarsystemquick.com/universe/star-constellations.htm
	http://stardate.org/nightsky/constellations
	
	This was done to make sure that people are quizzed on the well-known constellations because the corpus of 88 contained a lot of obscure constellations.
	
	A random sample of 20 constellations was extracted from the above list of 25.
	The following code snippet was used.

	table = read.csv("constellations.csv")
	sample(table, 20, replace=FALSE, prob=NULL)	

	The images of the constellations generated thus, were downloaded manually to form the assets of this task.
 	
	ANSWERS
	The correct answers were the names that were randomly sampled.

	MULTIPLE CHOICE OPTIONS:
	The other 4 incorrect options were randomly sampled from the corpus (holding 88 names).
