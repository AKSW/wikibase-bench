import json
import codecs

lang_labels       = []
lang_descriptions = []
lang_aliases      = []

file_labels       = open('./language-labels'     , 'w')
file_descriptions = open('./language-description', 'w')
file_aliases      = open('./language-aliases'    , 'w')

# wikidata json
json_file         = codecs.open('../Downloads/wikidata.json', 'r', encoding='utf-8')

# first line is a {
line = json_file.readline()
line_number = 1

while True:
    line = json_file.readline()
    line_number += 1
    if not line:
        break

    # last line in json is different
    if line[-2] == ',':
        fixline = line[:-2]
    else:
        fixline = line[:-1]

    try:
        j = json.loads(fixline)
    except ValueError:
        print('invalid line in json file: ' + str(line_number) + '.')
        continue


    if 'labels' in j:
        labels = j['labels']
        for l in labels:
            lang = j['labels'][l]['language']
            if lang not in lang_labels:
                lang_labels.append(lang)
        
    if 'descriptions' in j:
        descriptions = j['descriptions']
        for d in descriptions:
            lang = j['descriptions'][d]['language']
            if lang not in lang_descriptions:
                lang_descriptions.append(lang)
    
    if 'aliases' in j:
        aliases = j['aliases']
        for a in aliases:
            if len(j['aliases'][a]) > 0:
                lang = j['aliases'][a][0]['language']
                if lang not in lang_aliases:
                    lang_aliases.append(lang)

for lang in lang_labels:
    file_labels.write(lang+'\n')
for lang in lang_descriptions:
    file_descriptions.write(lang+'\n')
for lang in lang_aliases:
    file_aliases.write(lang+'\n')

json_file.close()
file_labels.close()
file_descriptions.close()
file_aliases.close()
