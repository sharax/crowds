# script to add users to a github repository
#
# usage: cat users.txt | python add_collabs.py
# 
# the script assumes that a file named .github-creds is in the 
# local directory with one line formatted as: username password
#
# update the repo parameter below before running

import requests
import sys

# set the github repo
repo = '5harad/crowds'

# read and set github credentials
with open('.github-creds') as f:
    user, passwd = f.readline().strip().split()

# load collaborators to add
collabs = set([line.strip() for line in sys.stdin.readlines()])

# get the current list of collaborators
cur_collabs = []
url = 'https://api.github.com/repos/%s/collaborators' % repo
while url:
    r = requests.get(url, auth=(user, passwd))
    cur_collabs += [item['login'] for item in r.json()]
    
    url = False
    if 'link' in r.headers:
        links = [link.split(';') for link in r.headers['link'].split(',')]
        links = [(l[0].strip('<>'), l[1].strip()) for l in links]
        urls = [l[0] for l in links if l[1]=='rel="next"']
        if len(urls) > 0:
            url = urls[0]
            
# add the additional collaborators
cur_collabs = set(cur_collabs)
collabs_to_add = collabs - cur_collabs
for c in collabs_to_add:
    print 'adding: %s' % c
    url = 'https://api.github.com/repos/%s/collaborators/%s' % (repo, c)
    requests.put(url, auth=(user, passwd))

