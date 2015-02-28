__author__ = 'Camelia Simoiu'
import random
from collections import Counter


def load_preferences(file_name):
    """
    Load team rankings
    :param file_name: file path + name
    :return: dict {team_name (str): [1st_choice, 2nd_choice, ..., 10th_choice] as int
    """
    pref = {}
    f = open(file_name, 'r')
    f.readline()    # header
    for line in f:
        data = str(line)[:-1].split(',')
        team_name = str(line).split(',')[0]
        if team_name not in pref:
            pref[team_name] = map(int, data[1:])
    f.close()
    return pref


def sample_team(teams):
    """
    param: teams: a list of strings
    returns: a random item from the list
    """
    return random.choice(teams)


def init_top_choices(preferences):
    """
    Initializes the top choices for all teams to the values entered in the worksheet.
    :param preferences: {team_name (str): [1st_choice, 2nd_choice, ..., 10th_choice] as int
    :return: dict{team_name: task_id (of first choice, int)}
             dict{team_name: task_id (of second choice, int)}
    """
    team_names = [team for team in preferences]
    choice = dict(zip(team_names, [[0,0]]*len(team_names)))

    for team in team_names:
        choice[team] = [preferences[team][0], preferences[team][1]]
    return choice

def conflict_teams(pref):
    top_choices = [pref[t][0] for t in pref]
    c = Counter(top_choices)
    unique_choices = [task for task in c if c[task]==1]
    tied_team_names = []
    for task in c:
        if c[task] > 1:
            for team in pref:
                if pref[team][0] == task:
                    tied_team_names.append(team)
    return tied_team_names, unique_choices


def set_second_choice(pref):
    """
    Finds teams that chose a task that is unavailable
    :param choice_dict: dict{team_name: task_id}
    :return: list of team_names (str)
    """
    result = pref
    tied_team, unique_top_choices = conflict_teams(pref)
    # teams whose first choice is the same
    for t in xrange(len(tied_team)):
        random_team = sample_team(tied_team)
        second_choice = pref[random_team][1]
        # print "team", random_team, second_choice
        # if second choice is not taken, --> swap first and second choice
        if second_choice not in unique_top_choices:
            # swap first and second choice
            temp = result[random_team][0]
            result[random_team][0] = second_choice
            result[random_team][1] = temp
            unique_top_choices.append(second_choice)
        tied_team.remove(random_team)
    # for k in sorted(result):
    #     print k, result[k]
    return result



def double_ties(pref):
    """
    deals with situation when second choice is also taken by another team
    """
    # get names of teams whose first choice == the team's second pick
    for k in sorted(pref):
        print k, pref[k]
    tied_teams, already_assigned_tasks = conflict_teams(pref)
    print tied_teams
    # the second task that is the same
    trouble_task = pref[tied_teams[0]][1]
    print "trouble task", trouble_task
    switch_candidates = []
    for team in pref:
        if pref[team][0] == trouble_task:
            switch_candidates.append(team)
    print switch_candidates
    for t in xrange(len(switch_candidates)):
        random_team = sample_team(switch_candidates)
        second_choice = pref[random_team][1]
        # can swap conflict team's 1st & 2nd choices so that the random team
        # doesn't have to take their third choice
        if second_choice not in already_assigned_tasks:
            # swap first and second choice of conflict team
            temp = pref[random_team][0]
            pref[random_team][0] = second_choice
            pref[random_team][1] = temp
            already_assigned_tasks.remove(temp)
            already_assigned_tasks.append(second_choice)
            # swap first and second choice of target team
            temp_r = pref[random_team][0]
            pref[random_team][0] = second_choice
            pref[random_team][1] = temp_r
            already_assigned_tasks.remove(temp_r)
            already_assigned_tasks.append(second_choice)
        else:
            # take next choice
            third_choice = pref[random_team][2]
            temp1 = pref[random_team][0]
            temp2 = pref[random_team][1]
            pref[random_team][0] = third_choice
            pref[random_team][1] = temp1
            pref[random_team][2] = temp2
            already_assigned_tasks.remove(temp1)
            already_assigned_tasks.append(second_choice)
    # print ""
    # for k in pref:
    #     print k, pref[k]
    return pref


def export_to_file(data):
    pass


if __name__ == "__main__":
    # change file directory
    file = "preference_test.csv"
    preferences = load_preferences(file)
    top_choice = init_top_choices(preferences)
    ss = set_second_choice(top_choice)
    double_ties(ss)


    print ""
    print "Team      Tasks"
    print "-----------------------"
