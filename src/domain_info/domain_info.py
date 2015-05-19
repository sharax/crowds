import os

path = '/Users/Imanol/Documents/Sharad/crowds/data'
domain_des = open(path+'/domain_descr.tsv','r') 
lines = domain_des.readlines()
counter = 0
for folder in os.listdir(path+'/tasks'):
	if folder[0]!='.':
		wfl = open(path+'/tasks/'+folder+'/domain.txt','w')
		domain = lines[counter].rstrip('\n').rstrip('\r').split('\t')
		wfl.write(domain[0]+'\n'+domain[1])
		wfl.close()
		print folder
		counter+=1

domain_des.close()
