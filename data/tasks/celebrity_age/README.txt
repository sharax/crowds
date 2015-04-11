TASK #5 
aditya.91.singh@gmail.com
bharat.munshi@gmail.com
chandra.arpita@gmail.com
eskiranmai94@gmail.com

TASK: Given the photograph of a celebrity, guess their correct age.

DESCRIPTION. You will be shown photographs of 20 celebrities and asked to guess their correct age.

CORPUS: The complete set of country names was extracted from:
	http://www.dumb.com/celebrityages/index.php (300 US/UK celebrities)
	http://filmschoolwtf.com/best-bollywood-actresses (100 female Bollywood celebrities)
	http://filmschoolwtf.com/best-bollywood-actors (100 male Bollywood celebrities)
		
	A set of 500 names was collected from the given websites.
	The complete corpus can be found here: http://goo.gl/2K8LIU

		
METHODOLOGY: 
	TASKS
	A random sample of 20 celebrities was chosen from the corpus.
	The following code snippet was used.

	table = read.csv("celebrities.csv")
	sample(table, 20, replace=FALSE, prob=NULL)	

	Their recent photographs (2014-2015) were manually downloaded to create the assets. 
 	
	ANSWERS
	Their ages were found out for correct answers.

