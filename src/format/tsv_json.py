import json
import os
import sys

def create_dict(dirname,domain_name):
	domain = {}
	domain_info = dirname + '/domain.txt'
	tasks_info = dirname + '/tasks.tsv'
	domain['domain_name'] = domain_name
	with open(domain_info,'r') as fl:
		domain['domain_id'] = fl.readline().rstrip('\n')
		domain['domain_description'] = fl.readline().rstrip('\n')
	
	with open(tasks_info,'r') as fl:
		fl.readline()
		domain['task_info']={}
		i = 1
		for line in fl:
			line = line.rstrip('\n').rstrip('\r').split('\t')
			task = [ x.lower().strip() for x in line]
			if i<10:
				task_id = 'task 0'+str(i)
			else:	
				task_id = 'task '+str(i)
			domain['task_info'][task_id] = {}
			domain['task_info'][task_id]['description'] = line[6]
			if task[1]=='point estimate':
				domain['task_info'][task_id]['correct_answer'] = float(task[0])
			else:
				domain['task_info'][task_id]['correct_answer'] = task[0]
			if task[1] == 'multiple choice':
				domain['task_info'][task_id]['possible_answers'] = '"'+task[4]+'"'
			if task[3] !='no assets':
				domain['task_info'][task_id]['asset_file'] = line[3]
			i+=1 
		domain['answer_type'] = task[1]
		domain['asset_type'] = task[2]
		if task[1] == 'multiple choice':
			domain['randomize_answers']= task[5]
		if task[2] in ['audio','video']:
			domain['time_limit'] = 45
		else:
			domain['time_limit'] = 30	
	return(domain)
	


def tsv_json():
	TASK_PATHS = '/Users/Imanol/Documents/Sharad/crowds/data/tasks/'
	for task in sys.stdin:
			print task
			dirname = TASK_PATHS + task.rstrip('\n')
			domain = create_dict(dirname,task.rstrip('\n'))
			fname = dirname +'/info.json'
			with open(fname,'w') as fp:
				json.dump(domain,fp,indent=4,sort_keys=True)


if __name__ == '__main__':
	tsv_json()
