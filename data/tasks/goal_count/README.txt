TASK #46
technopreneur.pulkit@gmail.com

TASK: Goals Prediction in a Match.

SHORT DESCRIPTION: Given the league name, league ranking of teams before the match, predict the number of goals that will be scored during the match

DETAILED DESCRIPTION shown to participants: "We will now ask you a series of questions. For each question, we will show the details of a soccer match from MLS Regular Season, and ask you to predict the number of goals that will be scored in that match. You will have to fill your prediction in the box provided. Please note that you can find the current league standings here: http://www.mlssoccer.com/standings/2015”

INPUT TYPE: Text (Tabular Form)

CORPUS: 
MLS Schedule for April 2015
http://goo.gl/u9qQyI

METHODOLOGY:
Sample 20 matches from this list using ”Weighted Sampling without replacement”. The weights assigned to matches that are closer to the survey date will be higher so that prediction task becomes easier.

Weighted Sampling where weights are more for matches nearer to current date is used to generate a set of representative tasks. This approach will also eliminate the chances of random guessing for later matches. The weighted sampling is based on http://epubs.siam.org/doi/abs/10.1137/0209009

Note: Since the sampling needs to be done just before the survey, tasks.tsv has 178 matches listed in it.

MULTIPLE CHOICE OPTIONS:
Not Applicable

NOTE:
Explaination for Correct_answer column in tasks.tsv:
Email from Imanol dated March 13, 2015: "In the correct answer you should write TBD since there is no correct answer yet."



