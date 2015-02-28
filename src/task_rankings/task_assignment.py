__author__ = 'Camelia Simoiu'


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


def init_top_choices(preferences):
    """
    Initializes the top choices for all teams to the values entered in the worksheet.
    :param preferences: {team_name (str): [1st_choice, 2nd_choice, ..., 10th_choice] as int
    :return: dict{team_name: task_id (of first choice, int)}
             dict{team_name: task_id (of second choice, int)}
    """
    team_names = [team for team in preferences]
    top_choice = dict(zip(team_names, [0]*len(team_names)))
    second_choice = dict(zip(team_names, [0]*len(team_names)))

    # top choice
    for team in team_names:
        top_choice[team] = preferences[team][0]
        second_choice[team] = preferences[team][1]
    return top_choice, second_choice


def find_conflicts(choice_dict):
    """
    Finds teams that chose a task that is unavailable
    :param choice_dict: dict{team_name: task_id}
    :return: list of team_names (str)
    """
    taken = []
    conflicts = []
    for team in choice_dict:
        task = choice_dict[team]
        if task not in taken:
            taken.append(task)
        else:
           conflicts.append(team)
    return conflicts


def finalize_top_choice(inital_choices):
    """
    Assigns the top ranked task for all teams, taking into account preferences
     while ensuring the task has not already been chosen by another team.
    :param inital_choices: dict {team_name (str): row_id of original top choice (int)}
    :return: dict {team_name: row_id of task}
    """
    conflicts = find_conflicts(init_top)
    taken = list(set([inital_choices[i] for i in inital_choices]))
    top_choices = inital_choices
    for team in conflicts:
        count = 1
        while count < 8:
            next_task = preferences[team][count]
            if next_task not in taken:
                top_choices[team] = next_task
                taken.append(next_task)
                break
            else:
                count += 1
    return top_choices


def finalize_second_choice(top_choices, choices):
    """
    Assigns the second task for all teams, taking into account preferences
     while ensuring the task has not already been chosen in the first round.
    :param top_choices: dict {team_name (str): row_id of final top choice (int)}
    :param choices: dict {team_name (str): row_id of second (int)}
    :return: dict {team_name: row_id of task}
    """
    taken = [top_choices[i] for i in top_choices]
    final_choices = choices
    for team in choices:
        task = choices[team]
        if task not in taken:
            taken.append(task)
        else:
            count = 1
            while count < 8:    # max 10 choices
                next_task = preferences[team][count]
                if next_task not in taken:
                    final_choices[team] = next_task
                    taken.append(next_task)
                    break
                else:
                    count += 1
    return final_choices


def combine_dicts(a, b):
    """
    Prints the union of the elements in a and b
    :param a: dictionary 1
    :param b: dictionary 2
    """
    for key in sorted(a.keys()):
        print key, ":", a[key], b[key]


if __name__ == "__main__":
    # change file directory
    file = "D:/Stanford/crowds/data/task_rankings/preference_test.csv"
    preferences = load_preferences(file)
    init_top, init_second = init_top_choices(preferences)
    top_choices = finalize_top_choice(init_top)
    second_choices = finalize_second_choice(top_choices, init_second)
    print ""
    print "Team      Tasks"
    print "-----------------------"
    combine_dicts(top_choices, second_choices)