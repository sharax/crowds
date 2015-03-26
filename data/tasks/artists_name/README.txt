TASK #30
aditya.91.singh@gmail.com
bharatmunshi@gmail.com
chandra.arpita@gmail.com
eskiranmai94@gmail.com

TASK: Given an audio clip of a song, identify the primary artist/band.

DESCRIPTION: You will hear a 15-second audio clip of a song, after which you have to guess the primary artist/band of the song.

CORPUS: The list of top 100 singles of 2014 was chosen as the corpus. (Billboard Hot 100 Year End 2014)
	http://en.wikipedia.org/wiki/Billboard_Year-End_Hot_100_singles_of_2014
		
METHODOLOGY: 
	TASKS
	20 songs were chosen at random from the corpus of 100 and the list was manually edited to ensure the any artist/band was not repeating.
	
	The following code snippet was used.

	table = read.csv("songs.csv")
	sample(table, 20, replace=FALSE, prob=NULL)	

	The songs of the names generated were downloaded manually and trimmed to get a 15 second audio clip.
 	
	ANSWERS
	The correct answers were the names of the artists.
