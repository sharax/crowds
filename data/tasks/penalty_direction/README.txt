Task #12
atifahmed150893@gmail.com
tushardobhal@gmail.com
mayankpahadia1993@gmail.com
mani28shankar@gmail.com
vikasyaligar.it@gmail.com

Task: Predict the direction of penalty shot

Detailed Description shown to participants: We will now ask you a series of binary response questions. For each question, we will show you a video of a footballer (soccer player) taking a penalty kick and his last two attempted penalty directions (prior to the one being shown). You have to guess the direction in which he would have kicked the ball in the penalty being shown.

Input type: Video and text

Corpus:  Penalty list of last two seasons of English Premier League are given here: http://eplreview.com/statistics-penalty.htm . The list contains 144 penalty kicks and their penalty kick takers. Out of these penalties, only those penalties will be considered in which the penalty taker has taken 3+ penalties (this is because for every penalty, there should be the record of the previous two penalties). Video clips for these penalties will be downloaded manually (from youtube.com). First the match highlight video will be downloaded and then the penalty part of the video will cropped using any video processing tool. After this, the directions (left or right) will be noted in the dataset. 
	Now for every player, his first two penalties will not be downloaded because the first two penalties don’t have the previous statistics. Also, some penalty videos might not be available. So, in the dataset there will be a field called as ‘video_available’ which will be Boolean. So, the video clips for all the penalties with ‘video_available=true’ will form the universal video set, while the dataset will be used to provide the stats for last two penalties taken by the penalty taker.

Representative tasks methodology: Depending on the distribution of penalties in the original dataset, sample 20 penalties where the no. of penalties chosen (in each direction) is proportional to the no. of penalties taken in each direction in the original dataset [e.g. if there are 100 penalties in the original dataset and the ratio of left:right is 40:60, then in the sample of 20, we’ll have 8 penalties for the left direction and 12 for right direction]. This will ensure the same distribution as original dataset.
Also, the penalties chosen for each direction will be random.

Answer type: Binary (Left or Right)

Multiple choice option selection: NA

Steps that were taken by us:
1) First using this link ( http://eplreview.com/statistics-penalty.htm ) we got a list of 144 penalty kicks that were taken in the current and last season of the English Premier League.
2) Since for each penalty kick we have to provide the statistics of last two kicks taken by that penalty kick taker, we removed the penalty kicks for which the penalty kick taker has taken less than 3 kicks. Thus total number of penalties was reduced to 96.
3) Now we watched the highlights of the matches corresponding to these remaining 96 penalties on Youtube and manually tagged the direction of each penalty. This was done because standalone penalty videos are generally not available on Youtube, instead match highlight videos are available.
4) We also created a new field called as 'Video Available'. Since each penalty should have the statistics of the previous two penalties taken by that penalty taker, we marked the first two penalties for each player as NOT REQUIRED. These penalties will not be used to be asked as a question but only for statistical purpose.
5) After this we were left with 55 penalties. We marked the directions of the previous two penalties taken by that player for each penalty. This forms our universal set of penalties.

6) Now, for getting a representative sample of 20 penalties, we randomly selected 20 penalties such that the ratio of left to right direction in these was equal to the left:right ratio in the case of universal set.
7) Finally the match highlights for these 20 videos were downloaded from Youtube and the penalty parts were cropped and saved. The penalty clip shows the player until the moment he is just about to hit the ball. Also, the audio is removed from the clips. Since, there is no goal being shown and no commentary being heard in these clips, there is very less chance of copyright infringement.

