#!/usr/bin/python -O

import sys
import commands

if len(sys.argv) != 3: raise RuntimeError("You must pass the type name and the file name!")

typename = sys.argv[1] # The freebase type (ex: /film/actor) to extract to id and create a FreebaseEntity with.
filename = sys.argv[2] # The file path of data dump of quadruples.

sys.stderr.write("Starting to fetch entries..")

num_entries = 0
statement="INSERT INTO freebase_entities (freebase_type,freebase_id) VALUES"
for line in open(filename, 'r'):
  if line[:-1].endswith("/type/object/type\t" + typename + "\t"):
    index = line.find(' ')
    if (index == -1): index = line.index('\t')
    statement += "('" + typename + "','" + line[:index] + "'),"
    num_entries += 1
    if (num_entries % 100 == 0): sys.stderr.write("Entered 100 entities!")
statement = statement[:-1] + ';'

sys.stderr.write("Fetching entries done!")
print(statement)

# FIXME: For some reason the following don't work silently sometimes. Probably because of escaping quotes. So instead do:
# extract.py /film/actor file.tsv > tmp.sql
# cat tmp.sql > mysql -u root sorted_development
sys.stderr.write(commands.getoutput('echo "' + statement + '" | mysql -u root sorted_development'))

sys.stderr.write("Entering entries done!")
