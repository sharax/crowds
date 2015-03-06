# -*- coding: utf-8 -*-
"""
Created on Thu Mar  5 17:07:58 2015

@author: Imanol
"""

import sys
import os

path = sys.argv[1]
os.chdir(path)
condition = True
# Check that all files and folders are present

# 1) README.txt
files = os.listdir(path)
if 'README.txt' not in files:
    print 'Could not find README.txt among the files submitted'
# 2) assets folder
if 'assets' not in files:
    print 'Could not find the assets folder among the files submitted'
    condition = False
else:
    assets = os.listdir(path+'/assets')
    
# 2) assets folder
if 'tasks.tsv' not in files:
    print 'Could not find the file tasks.tsv among the files submitted'
    condition = False

# Check the 'tasks.tsv' file.
if condition:
    with open(path+'/tasks.tsv') as tasks:
        tasks.readline()
	q = 1
        read_file = True
        for line in tasks:
            flag = True
	    print 'Question ' + str(q)
            try:
                task = line.split('\t')
                n = len(task)
                task[n-1] = task[n-1].strip()
            except: 
                print 'For some unknown reason the lines of your file can not be read'
                read_file = False                
                break
                
            if not n== 6:
                print 'The number of columns is wrong. There should be six columns'
                read_file = False                
                break
                
            if task[1] not in ['multiple choice','point estimate','map']:
                print 'The second column should be either : multiple choice, point estimate or map'
                flag = False
                
            if task[2] not in ['video','map','image','audio','none']:
                print 'The third column should be either : video, map,image,audio,none'
                flag = False
            else:
                if task[2] in ['video','image','audio']:
                    if task[3] not in assets:
                        print 'Can not find ' + task[3] + ' in assets folder for question ' + str(q)
			flag  = False
            if task[4] != 'no answers':
                multiple = task[4].split(',')
                if multiple <2:
                    'There is something wrong with your multiple choice column'
                    flag = False
                    
            if task[5] not in ['true','false']:
                'The sixth column should be either: true or false'
                flag =False
            if flag:
                print 'Question ' +str(q)+' appears to be correct.'
            else:
                print 'Fix problems with question ' +str(q)
            q+=1
            
    if read_file and q!=21:
       print' There should be exactly 20 rows in the file'
else:
    'Fix previous errors before we can look into the tasks.tsv file'
        

