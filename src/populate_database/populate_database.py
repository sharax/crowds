import os
import json
import sys
import shutil
import hashlib
import random
import codecs
TASK_PATH = '/Users/Imanol/Documents/Sharad/crowds/data/tasks'
DB_PATH = '/Users/Imanol/Documents/Sharad/crowds/data/database'

def move_asset(domain,asset,new_name):
	old_path = TASK_PATH+'/'+domain+'/assets/'+asset
	new_path = DB_PATH+'/assets/'+new_name
	shutil.copy2(old_path,new_path)
	
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
		else:
			asset = task_info['asset_file']
			ext = asset[-4:]
			new_asset_name = domain_name+task_id+ext
			data = 'http://crowds.5harad.com/assets/'+new_asset_name
			move_asset(domain_name,asset,new_asset_name)
		answer_type= info['answer_type']
		if answer_type == 'multiple choice':
			answer_data = task_info['possible_answers']
			correct_answer = task_info['correct_answer']
		else:
			answer_data = ''
			correct_answer = str(task_info['correct_answer'])
		line = ','.join([task_id,domain_id,title,t_type,data,answer_type,answer_data,correct_answer])
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
