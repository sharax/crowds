TASK #42
aditya.91.singh@gmail.com
bharat.munshi@gmail.com

TASK: Select the option representing the correct chronological order of the historical events.

DESCRIPTION: Every question presented to the participant contains a list of five historical events and four options. One of these options will be the correct chronological order of events and the other three will be randomly generated.  

INPUT TYPE: List of five historical events

CORPUS: The list has been populated manually. There are total of 131 questions in the dataset covering all the major
events in human history as far since 3000BC. The list can be viewed at http://research.iiit.ac.in/~bharat.munshi/data.txt

METHODOLOGY: A number is chosen at random from [20, 111]. 5 events are sampled randomly from a window of size 40 around the chosen point. This ensures that the events which are far apart are not present in the same question.     

ANSWERS: 

Multiple Choice - Participant needs to choose one of the 4 options listed.

Multiple choice Option Selection - 1 of the options is the correct answer and for the other 3, the set {1,2,3,4} is shuffled until 3 different sequences are generated, distinctness to the correct answer is also ensured.
