__author__ = 'Camelia'
import csv
import random
import os.path
from collections import Counter


def load_preferences(file_name):
    """
    Load team preferences
    :param file_name: file path + name
    :return: dict {team_name (str): [1st_choice, 2nd_choice, ..., 10th_choice] as int
    """
    pref = {}
    f = open(file_name, 'r')
    for line in f:
        data = str(line)[:-1].split(',')
        team_name = str(line).split(',')[0]
        if team_name not in pref:
            pref[team_name] = map(int, data[1:])
    f.close()
    return pref


def load_teams(file_name):
    """
    Load list of data science teams
    :param file_name: file path + name
    :return: dict {team_name (str): [1st_choice, 2nd_choice, ..., 10th_choice] as int
    """
    teams = []
    f = open(file_name, 'r')
    for line in f:
        team_name = str(line[:-1])
        teams.append(team_name)
    f.close()
    return teams


def export_to_file(data, output_file):
    f = open(output_file, 'wb')
    writer = csv.writer(f)
    m = []
    for t in sorted(data):
        row = [t]
        try:
            row.append(data[t][0])
            row.append(data[t][1])
            m.append(row)
        except:
            pass
    writer.writerows(m)
    f.close()



def sample_team(teams):
    return random.choice(teams)



def conflicts(pref, TAKEN):
    """
    Finds the tasks that more than two teams selected as their top two choices
    :param pref: dict {team_name (str): [1st_choice, 2nd_choice, ..., 10th_choice] as int
    :param TAKEN: global variable of already taken tasks
    :return: dictionary with the teams that chose the same task
            dict {task_id (int): [1st_team, 2nd_team, ...] as str
    """
    teams = [t for t in pref]
    result = {}
    choices = []
    for t in teams:
        choices.append(pref[t][0])
        choices.append(pref[t][1])
        TAKEN.append(pref[t][0])
        TAKEN.append(pref[t][1])
    # check if task id selected more than 2x
    c = Counter(choices)
    conflict_tasks = [task for task in c if c[task]>2]
    for task in conflict_tasks:
        if task not in result:
            result[task] = []
        for team in pref:
            if (pref[team][0] == task) or (pref[team][1]==task):
                result[task].append(team)
    for i in result:
        print i, result[i]
    return result, list(set(TAKEN))





def assign_tasks(pref, TAKEN):
    """
    assigns tasks to teams based on prefences
    :param pref: dict {team_name (str): [1st_choice, 2nd_choice, ..., 10th_choice] as int
    :param TAKEN: global variable of already taken tasks
    :return: dict {team_name (str): [1st_task, 2nd_task] as int
    """
    print ""
    print "original pref"
    for k in sorted(pref):
        print k, pref[k]
    print ""
    print "Conflicts"
    ties, TAKEN = conflicts(pref, TAKEN)

    for task_id in ties:
        conflicted_teams = ties[task_id]
        # one team gets to keep choice
        lucky_team = sample_team(conflicted_teams)
        conflicted_teams.remove(lucky_team)
        for i in xrange(len(conflicted_teams)):
            # teams switch to next-best pref
            team = sample_team(conflicted_teams)
            index = pref[team].index(task_id)
            # take next available task that is availabe
            for i in xrange(7):
                next_choice = pref[team][i+2]
                if next_choice not in TAKEN:
                    # swap choices
                    print task_id, team, "swap", pref[team][index], "-->", next_choice
                    pref[team][index] = next_choice
                    pref[team][i+2] = task_id
                    TAKEN.append(next_choice)
                    conflicted_teams.remove(team)
                    break
    print "updated"
    for t in pref:
        print t, "   ", [pref[t][0], pref[t][1]]

    # will only run if no conflicts result after permutation above
    new_ties, TAKEN = conflicts(pref, TAKEN)
    print "new conflicts:", new_ties
    return pref



def random_assign(matched_teams):

    results = {}
    for t in matched_teams:
        results[t] = [matched_teams[t][0], matched_teams[t][1]]
    unassigned_teams = [t for t in teams_list if t not in matched_teams]

    all =[i+2 for i in xrange(53)]
    all = [all]*2
    available_tasks = all[0]
    available_tasks.extend(all[1])

    for t in matched_teams:
        available_tasks.remove(matched_teams[t][0])
        available_tasks.remove(matched_teams[t][1])
    print ""
    print "unasigned teams", len(unassigned_teams)
    print "available tasks", len(available_tasks)
    print ""
    # assign tasks to unassigned_teams
    for i in xrange(len(unassigned_teams)-1):
        team = random.choice(unassigned_teams)
        if team not in matched_teams:
            results[team] = []
        # assign tasks
        while len(results[team]) < 2:
            try:
                task_id = random.choice(available_tasks)
                results[team].append(task_id)
                available_tasks.remove(task_id)
                print "task assiged to ", team, results[team]
            except:
                break
                print "no more tasks"
        unassigned_teams.remove(team)
    "final assignment"
    for t in results:
        print t, results[t]
    return results


if __name__ == "__main__":
    ## change paths
    TAKEN = []
    path = '../../data/task_rankings/'
    output_f = '../../output/task_rankings/assignments.csv'
    orig_preferences = load_preferences('preferences.csv')
    teams_list = load_teams('teams.csv')
    matched_teams = assign_tasks(orig_preferences, TAKEN)
    final_assignment = random_assign(matched_teams)
    export_to_file(final_assignment, output_f)
    print "file done"



