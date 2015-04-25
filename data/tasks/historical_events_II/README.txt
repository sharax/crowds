TASK #42
aditya.91.singh@gmail.com
bharatmunshi@gmail.com
chandra.arpita@gmail.com
eskiranmai94@gmail.com

TASK: Select the option representing the correct chronological order of the historical events.

DESCRIPTION: You will be shown a list of five historical events and 5 options for the order in which they took place. You have to guess the option corresponding to the correct chronological order of these events.  

INPUT TYPE: List of five historical events (image file).

CORPUS: The list has been populated manually. There are total of 131 items in the dataset covering all the major
events in human history as early as 3000BC. The list can be viewed at http://goo.gl/beb3zl

METHODOLOGY: A number is chosen at random from [0, 80]. 5 events are sampled randomly from a window of size 50 after the chosen point. This ensures that the events which are centuries apart are not present in the same question. The code used to generate a single question is here: http://goo.gl/hW51yC.     

ANSWERS: 
Multiple Choice - Participant needs to choose one of the 5 options listed.

Multiple choice Option Selection - 1 of the options is the correct answer and for the other 4, the set {1,2,3,4,5} is shuffled until 4 different incorrect sequences are generated. Distinctness to the correct answer is always ensured.
