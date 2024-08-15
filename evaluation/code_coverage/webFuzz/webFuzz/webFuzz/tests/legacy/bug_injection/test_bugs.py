import re
import json
from sys import argv

log_file_path = argv[1] # fuzzer's log file
output_file = "dat_bugs.dat"
if len(argv) > 2:
    output_file = argv[2]

injected_bugs_file = "./bugs.txt" # injected bugs file

def extract_magic(injected_bugs):
    possible_magic=[]
    for in_bug in injected_bugs:
        for key in in_bug.keys():
            if(key!='_Request_Details_'):
                if in_bug[key][0].isdigit():
                    possible_magic.append(int(in_bug[key].split(' ')[0]))
                    
    return possible_magic


found_bugs=[]
start_date = ""
c = 0
with open(log_file_path, "r") as file:
    for line in file:
        if c == 0:
            datetime = re.search(r'\[([0-9 :_,-]*)\] webFuzz.simple_menu INFO print_stats', line)
            if datetime is not None:
                start_date = datetime.group(1)
            c += 1

        datetime = re.search(r'\[([0-9 :_,-]*)\] webFuzz.parser WARNING look_for_xss', line)
        if not start_date and datetime:
            start_date = datetime.group(1)

        xss_variable = re.search(r'Possible xss found in key (.+?)\.', line)
        node = re.search(r'Node: (.+?)', line)
        if node and xss_variable:
            found_bugs.append([json.loads(node.group(1)), xss_variable.group(1), datetime.group(1)])
#print(found_bugs)

injected_bugs=[]
with open(injected_bugs_file, "r") as file:
    for line in file:
        injected_bugs.append(json.loads(line))
#print(injected_bugs)

valid_bugs=0
false_positive=0
duplicates=0
found_magics=[]
possible_magics=extract_magic(injected_bugs)
# validate bugs:
for bug in found_bugs:
    url=bug[0]['_url']
    method=bug[0]['_method']
    parameter=bug[1]
    datetime=bug[2]

    temp=len(found_magics)
    temp2=duplicates

    for pos_mag in possible_magics:
        if str(pos_mag) in json.dumps(bug[0]):
            if pos_mag in list(map(lambda x: x[0], found_magics)):
                duplicates+=1
            else:
                found_magics.append([pos_mag, datetime])

    if temp==len(found_magics) and temp2==duplicates:
        false_positive+=1

count = 1
with open(output_file, "w+") as f:
    f.write(start_date + " 0\n")
    for (_, datetime) in found_magics:
        f.write(datetime + " " + str(count) + "\n")
        count += 1

with open("magics.dat", "w+") as f:
    for m,dt in found_magics:
        f.write(dt + " " + str(m)+ "\n")

print('++++++++++++++++++++++++++++++++++++')
print('Magic Found:', len(found_magics), ' in ', len(found_bugs)-false_positive-duplicates, ' Requests')
print('False Positive Requests : ', false_positive)
print('Duplicates', duplicates)
print('Total Requests: ', len(found_bugs))
print('++++++++++++++++++++++++++++++++++++')
print('TP may be more than 1 per request.')
