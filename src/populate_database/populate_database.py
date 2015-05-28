#!/usr/bin/python2
#
# Author: Imanol Arrieta Ibarra

"""
Populate the Wisdom of Crowds database from a list of foldernames containingdomain informaion in a json file and an assets folder containing the assets required. In case the assets are images, they will be resized. In case the files are videos, they will be uploaded to youtube, and in case they are audio files they will be uploaded to soundtrack.

Input:


Output:


"""

import time
import os
import json
import sys
import shutil
import hashlib
import random
import codecs
import youtube_upload
import Image
import soundcloud


TASK_PATH = '/Users/Imanol/Documents/Sharad/crowds/data/tasks'
DB_PATH = '/Users/Imanol/Documents/Sharad/crowds/data/database'
IMAGE_SIZE = 600,600

def youtube(domain,asset,new_name):
	name = TASK_PATH+'/'+domain+'/assets/'+asset
	youtube_id = youtube_upload.youtube_upload([name],new_name) 
	time.sleep(10)
	return(str(youtube_id))

def sound(domain,asset,new_name):
	name = TASK_PATH+'/'+domain+'/assets/'+asset
	client = soundcloud.Client(
		client_id = '22594f1b4d32dbec1566c54751aacd27',
		client_secret = '96c6e9dc1f78c845ed2e6a4803f0bf4e',
		username = 'wcrowds@gmail.com',
		password = 'Woc12345678'
	)
	track = client.post('/tracks/', track = {'title':asset,
		'asset_data': open(name,'rb')})
	sound_id = str(track.id)
	return(sound_id)

def move_image(domain,asset,new_name):
	old_path = TASK_PATH+'/'+domain+'/assets/'+asset
	new_path = DB_PATH+'/images/'+new_name
	im = Image.open(old_path)
	im.thumbnail(IMAGE_SIZE,Image.ANTIALIAS)
	im.save(new_path)
	
def string_to_int(s):
	conv = int(hashlib.md5(s).hexdigest(),16)
	return conv

def populate_domain_db(db_domains,info):
	domain_id = info['domain_id']
	domain_name = info['domain_name']
	domain_desc = info['domain_description']
	domain_time = info['time_limit']
	db_domains.write(','.join([domain_id,domain_name,domain_desc,str(domain_time)])+'\n')

def set_id(n):
	ids = []
	for i in range(1,n+1):
		if i<10:
			ids.append('0'+str(i))
		else:
			ids.append(str(i))
	return ids

def populate_tasks_db(db_tasks,info):
	domain_name = info['domain_name']
	domain_id = info['domain_id']
	random.seed(string_to_int(domain_name))
	old_ids =["task " +i for i in random.sample(set_id(20),20)]
	new_ids = set_id(20)
	for i in xrange(20):
		task_info = info['task_info'][old_ids[i]]
		task_id = domain_id+new_ids[i]
		title = task_info['description']
		
		t_type = info['asset_type']
		if t_type == 'no assets':
			data = ''
		elif t_type == 'video':
			asset = task_info['asset_file']
			new_asset_name = domain_name+task_id
			data = youtube(domain_name,asset,new_asset_name)
		elif t_type =='audio':
			asset = task_info['asset_file']
			new_asset_name = domain_name+task_id
			data = sound(domain_name,asset,new_asset_name)
		elif t_type =='image':
			asset = task_info['asset_file']
			ext = asset[-4:]
			new_asset_name = domain_name+task_id+ext
			data = '/images/'+new_asset_name
			move_image(domain_name,asset,new_asset_name)

		answer_type= info['answer_type']
		if answer_type == 'multiple choice':
			answer_data = task_info['possible_answers']
			correct_answer = task_info['correct_answer']
		else:
			answer_data = ''
			correct_answer = str(task_info['correct_answer'])
		line = ','.join([task_id,domain_id,title,t_type,data,answer_type,str(answer_data),correct_answer])
		db_tasks.write(line+'\n')
	

def populate_database():

	db_domains = codecs.open(DB_PATH+'/domains.csv','w',encoding='utf8')
	db_tasks = codecs.open(DB_PATH+'/tasks.csv','w',encoding='utf8')
	db_domains.write('id,name,description,time_limit\n')
	db_tasks.write('id,domain_id,title,type,data,answer_type,answer_data,correct_answer\n')
	for domain in sys.stdin:
		domain = domain.rstrip('\n')
		print domain
		with open(TASK_PATH+'/'+domain+'/info.json','r') as json_file:
			info = json.load(json_file)
		populate_domain_db(db_domains,info)
		populate_tasks_db(db_tasks,info)
	db_domains.close()
	db_tasks.close()

if __name__ =='__main__':
	populate_database()
