import json
import codecs

WIKIDATA_PATH         = '../Downloads/wikidata.json'
OUTPUT_PATH           = './csv_light' #the folder must exist.

def fix_string(s):
    return s.replace(',', '').replace('"', '').replace('\\', '').replace('\n', '')

def parse_time(time, precision):
    # llega algo como +2013-01-01T00:00:00Z
    state = 0
    year = ''
    month = ''
    day = ''
    for a in time:
        if state == 0:
            if a == '-':
                year += a
            state = 1
        elif state == 1: # leyendo el anio
            if a == '-':
                state = 2
            else:
                year += a
        elif state == 2: # leyendo el mes
            if a == '-':
                state = 3
            else:
                month += a
        elif state == 3: # leyendo el dia
            if a == 'T':
                break
            else:
                day += a
    
    if int(month) == 0 or precision < 10:
        fix_month = ''
    else:
        fix_month = str(int(month))
    
    if int(day) == 0 or precision < 11:
        fix_day = ''
    else:
        fix_day = str(int(day))
        
    
    return year, fix_month, fix_day

def xstr(s):
    if s is None:
        return ''
    return str(s)

entity_type  = ""
relationship = ""
item_to      = ""
string_value = ""

# wikidata json
json_file         = codecs.open('../Downloads/wikidata.json', 'r', encoding='utf-8')

# nodes
csv_entities      = codecs.open(OUTPUT_PATH + 'entity.csv',      'w', encoding='utf-8')
csv_strings       = codecs.open(OUTPUT_PATH + 'string.csv',      'w', encoding='utf-8')
csv_time          = codecs.open(OUTPUT_PATH + 'time.csv',        'w', encoding='utf-8')
csv_quantity      = codecs.open(OUTPUT_PATH + 'quantity.csv',    'w', encoding='utf-8')
csv_qualifiers    = codecs.open(OUTPUT_PATH + 'qualifiers.csv',  'w', encoding='utf-8')
csv_url           = codecs.open(OUTPUT_PATH + 'url.csv',         'w', encoding='utf-8')
csv_monolingual   = codecs.open(OUTPUT_PATH + 'monolingual.csv', 'w', encoding='utf-8')
csv_commons       = codecs.open(OUTPUT_PATH + 'commons.csv',     'w', encoding='utf-8')
csv_globe         = codecs.open(OUTPUT_PATH + 'globe.csv',       'w', encoding='utf-8')
csv_claims        = codecs.open(OUTPUT_PATH + 'claims.csv',      'w', encoding='utf-8')
csv_references    = codecs.open(OUTPUT_PATH + 'references.csv',  'w', encoding='utf-8')

# relationships
csv_relationships = codecs.open(OUTPUT_PATH + './relationships.csv', 'w', encoding='utf-8')

csv_claims.write        ('id:ID\n')
csv_qualifiers.write    ('id:ID\n')
csv_references.write    ('id:ID\n')
csv_entities.write      ('id:ID,:LABEL')
csv_commons.write       ('id:ID,value\n')
csv_url.write           ('id:ID,value\n')
csv_strings.write       ('id:ID,value\n')
csv_time.write          ('id:ID,value,timezone,before,after,precision,year:long,month:int,day:int\n')
csv_quantity.write      ('id:ID,value,unit,upperBound,lowerBound\n')
csv_globe.write         ('id:ID,value,latitude,longitude,altitude,precision,globe\n')
csv_monolingual.write   ('id:ID,value,language\n')

csv_relationships.write (':START_ID,:END_ID,:TYPE\n')
csv_entities.write('\n')

# first line is a {
line = json_file.readline()
line_number = 1

#initializing generated ids
url_generated_id       = 0
mono_generated_id      = 0
time_generated_id      = 0
claim_generated_id     = 0
globe_generated_id     = 0
string_generated_id    = 0
commons_generated_id   = 0
quantity_generated_id  = 0
qualifier_generated_id = 0
reference_generated_id = 0


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

    entity_id   = j['id']
    entity_type = j['type']

    # write the item/property in entities.csv
    if entity_type == 'item':
        csv_entities.write(entity_id + ',Item;Entity')
    elif entity_type == 'property':
        csv_entities.write(entity_id + ',Property;Entity')
    else:
        print('Entity no es Item ni Property, linea:' + str(line_number))

    csv_entities.write('\n')

    if 'claims' in j:
        claims = j['claims']
        for c in claims:
            relationship = c
            p = j['claims'][c]
            for p2 in p:
                claim_generated_id += 1
                claim = 'CL' + str(claim_generated_id)
                if 'qualifiers' in p2:
                    qualifiers = p2['qualifiers']
                    for c in qualifiers:
                        q = qualifiers[c]
                        for q2 in q:
                            qualifier_generated_id += 1
                            csv_qualifiers.write('C'+str(qualifier_generated_id)+'\n')
                            csv_relationships.write(claim + ',C' + str(qualifier_generated_id) + ',QUAL_FROM\n')
                            csv_relationships.write('C' + str(qualifier_generated_id) + ',' + c + ',PROPERTY\n')

                            datatype = q2['datatype']

                            if datatype == 'wikibase-item':
                                if 'datavalue' not in q2:
                                    continue
                                item = q2['datavalue']['value']['numeric-id']
                                item = "Q" + str(item)
                                csv_relationships.write('C'+str(qualifier_generated_id) + ',' + item + ",QUAL_TO\n")

                            elif datatype == 'time':
                                if 'datavalue' not in q2:
                                    continue
                                time      = q2['datavalue']['value']['time']
                                timezone  = str(q2['datavalue']['value']['timezone'])
                                before    = str(q2['datavalue']['value']['before'])
                                after     = str(q2['datavalue']['value']['after'])
                                precision = str(q2['datavalue']['value']['precision'])
                                year, month, day = parse_time(time, int(precision))
                                csv_time.write('T'+str(time_generated_id) +','+time+','+timezone+','+before+','+after+','+precision+','+year+','+month+','+day+'\n')
                                csv_relationships.write('C'+str(qualifier_generated_id) + ',T' + str(time_generated_id) + ",QUAL_TO\n")
                                time_generated_id += 1

                            elif datatype == 'string':
                                if 'datavalue' not in q2:
                                    continue
                                string_value = q2['datavalue']['value']
                                csv_strings.write('S'+str(string_generated_id) + ','+ fix_string(string_value) + '\n')
                                csv_relationships.write('C'+str(qualifier_generated_id) + ',S' + str(string_generated_id) + ",QUAL_TO\n")
                                string_generated_id += 1

                            elif datatype == 'quantity':
                                if 'datavalue' not in q2:
                                    continue
                                amount     = q2['datavalue']['value']['amount']
                                unit       = q2['datavalue']['value']['unit']
                                upperBound = q2['datavalue']['value']['upperBound']
                                lowerBound = q2['datavalue']['value']['lowerBound']
                                csv_quantity.write('QT'+str(quantity_generated_id)+','+amount+','+unit+','+upperBound+','+lowerBound+'\n')
                                csv_relationships.write('C'+str(qualifier_generated_id) + ",QT" + str(quantity_generated_id) + ',QUAL_TO\n')
                                quantity_generated_id += 1

                            elif datatype == 'url':
                                if 'datavalue' not in q2:
                                    continue
                                url_value = fix_string(q2['datavalue']['value'])
                                csv_url.write('U' + str(url_generated_id) + ',' + url_value + '\n')
                                csv_relationships.write('C'+str(qualifier_generated_id) + ",U" + str(url_generated_id) + ',QUAL_TO\n')
                                url_generated_id += 1

                            elif datatype == 'monolingualtext':
                                if 'datavalue' not in q2:
                                    continue
                                mono_text = fix_string(q2['datavalue']['value']['text'])
                                mono_lang = q2['datavalue']['value']['language']
                                csv_monolingual.write('MT'+ str(mono_generated_id) + ',' + mono_text + ',' + mono_lang + '\n')
                                csv_relationships.write('C'+str(qualifier_generated_id) + ",MT" + str(mono_generated_id) + ',QUAL_TO\n')
                                mono_generated_id += 1

                            elif datatype == 'commonsMedia':
                                if 'datavalue' not in q2:
                                    continue
                                commons_value = fix_string(q2['datavalue']['value'])
                                csv_commons.write('CM' + str(commons_generated_id) + ',' + commons_value + '\n')
                                csv_relationships.write('C'+str(qualifier_generated_id) + ",CM" + str(commons_generated_id) + ',QUAL_TO\n')
                                commons_generated_id += 1

                            elif datatype == 'globe-coordinate':
                                if 'datavalue' not in q2:
                                    continue
                                latitude    = xstr(q2['datavalue']['value']['latitude'])
                                longitude   = xstr(q2['datavalue']['value']['longitude'])
                                altitude    = xstr(q2['datavalue']['value']['altitude'])
                                precision   = xstr(q2['datavalue']['value']['precision'])
                                globe       = xstr(q2['datavalue']['value']['globe'])
                                globe_value = 'lat:' + latitude + ' lon:' + longitude
                                csv_globe.write('GC'+str(globe_generated_id)+','+globe_value+','+latitude+','+longitude+','+altitude+','+precision+','+globe+'\n')
                                csv_relationships.write('C'+str(qualifier_generated_id) + ",GC" + str(globe_generated_id) + ',QUAL_TO\n')
                                globe_generated_id += 1

                if 'references' in p2:
                    references_list = p2['references']
                    for reference in references_list:
                        snaks = reference['snaks']
                        for prop_snak in snaks:
                            prop_snak_list = snaks[prop_snak]
                            for snak in prop_snak_list:
                                reference_generated_id += 1
                                csv_references.write('R'+str(reference_generated_id)+'\n')
                                csv_relationships.write(claim + ',R' + str(reference_generated_id) + ',REF_FROM\n')
                                csv_relationships.write('R' + str(reference_generated_id) + ',' + prop_snak + ',PROPERTY\n')
                                datatype = snak['datatype']
                                
                                if datatype == 'wikibase-item':
                                    if 'datavalue' not in snak:
                                        continue
                                    item = "R" + str(snak['datavalue']['value']['numeric-id'])
                                    csv_relationships.write('R'+str(reference_generated_id) + ',' + item + ",REF_TO\n")

                                elif datatype == 'string':
                                    if 'datavalue' not in snak:
                                        continue
                                    string_value = snak['datavalue']['value']
                                    csv_strings.write('S'+str(string_generated_id) + ','+ fix_string(string_value) + '\n')
                                    csv_relationships.write('R'+str(reference_generated_id) + ',S' + str(string_generated_id) + ",REF_TO\n")
                                    string_generated_id += 1

                                elif datatype == 'time':
                                    if 'datavalue' not in snak:
                                        continue
                                    time      = snak['datavalue']['value']['time']
                                    timezone  = str(snak['datavalue']['value']['timezone'])
                                    before    = str(snak['datavalue']['value']['before'])
                                    after     = str(snak['datavalue']['value']['after'])
                                    precision = str(snak['datavalue']['value']['precision'])
                                    year, month, day = parse_time(time, int(precision))
                                    csv_time.write('T'+str(time_generated_id) +','+time+','+timezone+','+before+','+after+','+precision+','+year+','+month+','+day+'\n')
                                    csv_relationships.write('R'+str(reference_generated_id) + ',T' + str(time_generated_id) + ",REF_TO\n")
                                    time_generated_id += 1

                                elif datatype == 'quantity':
                                    if 'datavalue' not in snak:
                                        continue
                                    amount     = snak['datavalue']['value']['amount']
                                    unit       = snak['datavalue']['value']['unit']
                                    upperBound = snak['datavalue']['value']['upperBound']
                                    lowerBound = snak['datavalue']['value']['lowerBound']
                                    csv_quantity.write('QT'+str(quantity_generated_id)+','+amount+','+unit+','+upperBound+','+lowerBound+'\n')
                                    csv_relationships.write('R'+str(reference_generated_id) + ",QT" + str(quantity_generated_id) + ',REF_TO\n')
                                    quantity_generated_id += 1

                                elif datatype == 'url':
                                    if 'datavalue' not in snak:
                                        continue
                                    url_value = fix_string(snak['datavalue']['value'])
                                    csv_url.write('U' + str(url_generated_id) + ',' + url_value + '\n')
                                    csv_relationships.write('R'+str(reference_generated_id) + ",U" + str(url_generated_id) + ',REF_TO\n')
                                    url_generated_id += 1

                                elif datatype == 'monolingualtext':
                                    if 'datavalue' not in snak:
                                        continue
                                    mono_text = fix_string(snak['datavalue']['value']['text'])
                                    mono_lang = snak['datavalue']['value']['language']
                                    csv_monolingual.write('MT'+ str(mono_generated_id) + ',' + mono_text + ',' + mono_lang + '\n')
                                    csv_relationships.write('R'+str(qualifier_generated_id) + ",MT" + str(mono_generated_id) + ',REF_TO\n')
                                    mono_generated_id += 1

                                elif datatype == 'commonsMedia':
                                    if 'datavalue' not in snak:
                                        continue
                                    commons_value = fix_string(snak['datavalue']['value'])
                                    csv_commons.write('CM' + str(commons_generated_id) + ',' + commons_value + '\n')
                                    csv_relationships.write('R'+str(reference_generated_id) + ",CM" + str(commons_generated_id) + ',REF_TO\n')
                                    commons_generated_id += 1

                                elif datatype == 'globe-coordinate':
                                    if 'datavalue' not in snak:
                                        continue
                                    latitude    = xstr(snak['datavalue']['value']['latitude'])
                                    longitude   = xstr(snak['datavalue']['value']['longitude'])
                                    altitude    = xstr(snak['datavalue']['value']['altitude'])
                                    precision   = xstr(snak['datavalue']['value']['precision'])
                                    globe       = xstr(snak['datavalue']['value']['globe'])
                                    globe_value = 'lat:' + latitude + ' lon:' + longitude
                                    csv_globe.write('GC'+str(globe_generated_id)+','+globe_value+','+latitude+','+longitude+','+altitude+','+precision+','+globe+'\n')
                                    csv_relationships.write('C'+str(qualifier_generated_id) + ",GC" + str(globe_generated_id) + ',REF_TO\n')
                                    globe_generated_id += 1

                if 'datatype' in p2['mainsnak']:
                    datatype = p2['mainsnak']['datatype']
                    csv_claims.write(claim + '\n')
                    csv_relationships.write(claim + "," + relationship + ',PROPERTY\n')
                    csv_relationships.write(entity_id + "," + claim + ",PROP_FROM\n")
                    
                    if datatype == 'wikibase-item':
                        if 'datavalue' not in p2['mainsnak']:
                            continue
                        item = p2['mainsnak']['datavalue']['value']['numeric-id']
                        item = "Q" + str(item)
                        csv_relationships.write(claim + "," + item + ",PROP_TO\n")

                    elif datatype == 'wikibase-property':
                        if 'datavalue' not in p2['mainsnak']:
                            continue
                        prop = p2['mainsnak']['datavalue']['value']['numeric-id']
                        prop = "P" + str(prop)
                        csv_relationships.write(claim + "," + prop + ",PROP_TO\n")
                    
                    elif datatype == 'string':
                        if 'datavalue' not in p2['mainsnak']:
                            continue
                        string_id = p2['id']
                        string_value = p2['mainsnak']['datavalue']['value']
                        csv_strings.write(string_id + ','+ fix_string(string_value) + '\n')
                        csv_relationships.write(claim + "," + string_id + ',PROP_TO\n')

                    elif datatype == 'time':
                        if 'datavalue' not in p2['mainsnak']:
                            continue
                        time_id   = p2['id']
                        time      = p2['mainsnak']['datavalue']['value']['time']
                        timezone  = str(p2['mainsnak']['datavalue']['value']['timezone'])
                        before    = str(p2['mainsnak']['datavalue']['value']['before'])
                        after     = str(p2['mainsnak']['datavalue']['value']['after'])
                        precision = str(p2['mainsnak']['datavalue']['value']['precision'])
                        year, month, day = parse_time(time, int(precision))
                        csv_time.write(time_id +','+time+','+timezone+','+before+','+after+','+precision+','+year+','+month+','+day+'\n')
                        csv_relationships.write(claim + "," + time_id + ',PROP_TO\n')

                    elif datatype == 'quantity':
                        if 'datavalue' not in p2['mainsnak']:
                            continue
                        quantity_id = p2['id']
                        amount      = p2['mainsnak']['datavalue']['value']['amount']
                        unit        = p2['mainsnak']['datavalue']['value']['unit']
                        upperBound  = p2['mainsnak']['datavalue']['value']['upperBound']
                        lowerBound  = p2['mainsnak']['datavalue']['value']['lowerBound']
                        csv_quantity.write(quantity_id + ','+ amount + ',' + unit + ',' + upperBound + ',' + lowerBound + '\n')
                        csv_relationships.write(claim + "," + quantity_id + ',PROP_TO\n')
                    
                    elif datatype == 'url':
                        if 'datavalue' not in p2['mainsnak']:
                            continue
                        url_value = fix_string(p2['mainsnak']['datavalue']['value'])
                        csv_url.write('U' + str(url_generated_id) + ',' + url_value + '\n')
                        csv_relationships.write(claim + ",U" + str(url_generated_id) + ',PROP_TO\n')
                        url_generated_id += 1

                    elif datatype == 'monolingualtext':
                        if 'datavalue' not in p2['mainsnak']:
                            continue
                        mono_text = fix_string(p2['mainsnak']['datavalue']['value']['text'])
                        mono_lang = p2['mainsnak']['datavalue']['value']['language']
                        csv_monolingual.write('MT'+ str(mono_generated_id) + ',' + mono_text + ',' + mono_lang + '\n')
                        csv_relationships.write(claim + ",MT" + str(mono_generated_id) + ',PROP_TO\n')
                        mono_generated_id += 1

                    elif datatype == 'commonsMedia':
                        if 'datavalue' not in p2['mainsnak']:
                            continue
                        commons_value = fix_string(p2['mainsnak']['datavalue']['value'])
                        csv_commons.write('CM' + str(commons_generated_id) + ',' + commons_value + '\n')
                        csv_relationships.write(claim + ",CM" + str(commons_generated_id) + ',PROP_TO\n')
                        commons_generated_id += 1
                    
                    elif datatype == 'globe-coordinate':
                        if 'datavalue' not in p2['mainsnak']:
                            continue
                        latitude    = xstr(p2['mainsnak']['datavalue']['value']['latitude'])
                        longitude   = xstr(p2['mainsnak']['datavalue']['value']['longitude'])
                        altitude    = xstr(p2['mainsnak']['datavalue']['value']['altitude'])
                        precision   = xstr(p2['mainsnak']['datavalue']['value']['precision'])
                        globe       = xstr(p2['mainsnak']['datavalue']['value']['globe'])
                        globe_value = 'lat:' + latitude + ' lon:' + longitude
                        csv_globe.write('GC'+str(globe_generated_id)+','+globe_value+','+latitude+','+longitude+','+altitude+','+precision+','+globe+'\n')
                        csv_relationships.write(claim + ",GC" + str(globe_generated_id) + ',PROP_TO\n')
                        globe_generated_id += 1


# close all open files
csv_url.close()
csv_time.close()
csv_globe.close()
json_file.close()
csv_claims.close()
csv_commons.close() 
csv_strings.close()
csv_quantity.close()
csv_entities.close()
csv_qualifiers.close()
csv_references.close()
csv_monolingual.close()
csv_relationships.close()
