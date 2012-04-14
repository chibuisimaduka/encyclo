#!/usr/bin/python -O

import sys
import commands

if len(sys.argv) != 3: raise RuntimeError("You must pass the type name, the file name and the column name!")

typename = sys.argv[1]
filename = sys.argv[2]

ids_str = commands.getoutput('echo "select freebase_id from freebase_entities where freebase_type=\\"' + typename +
  '\\";" | mysql -u root sorted_development')
ids = set(ids_str.split('\n'))

sys.stderr.write("Starting to fetch entries..")

statement = "INSERT INTO freebase_entities (freebase_id,name) VALUES "
num_entries = 0
for line in open(filename, 'r'):
  index = line.index('\t')
  if (line[index+1:].startswith("/type/object/name\t/lang/en")):
    entity_id = line[:index]
    if (entity_id in ids):
      rindex = line.rindex('\t') + 1
      statement += '("' + entity_id + '","' + line[rindex:-1].replace('"', '\\"') + '"),'
      num_entries += 1
      if (num_entries % 100 == 0): sys.stderr.write("Found 100 entities!")
statement = statement[:-1] # Strip the extra comma
statement += " ON DUPLICATE KEY UPDATE name=VALUES(name);"

sys.stderr.write("Fetching entries done!")
print(statement)

# FIXME: For some reason the following don't work silently sometimes. So instead do:
# extract.py /film/actor file.tsv > tmp.sql
# cat tmp.sql > mysql -u root sorted_development
sys.stderr.write(commands.getoutput('echo "' + statement + '" | mysql -u root sorted_development'))

sys.stderr.write("Entering entries done!")
