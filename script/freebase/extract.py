#!/usr/bin/python -O

import sys
import utils

if len(sys.argv) != 3: raise RuntimeError("You must pass the comma seperated types' names and the file name!")

typenames = sys.argv[1].split(',') # The freebase types (ex: /film/actor) to extract to id and create a FreebaseEntity with.
filename = sys.argv[2] # The file path of data dump of quadruples.

print("Starting to fetch entries..")

nb = 0
statement="INSERT INTO freebase_entities (freebase_type,freebase_id) VALUES"
for line in open(filename, 'r'):
  for typename in typenames:
    if line[:-1].endswith("/type/object/type\t" + typename + "\t"):
      index = line.find(' ')
      if (index == -1): index = line.index('\t')
      statement += "('" + typename + "','" + line[:index] + "'),"
      nb += 1

print("Fetching entries done!")
print("Found " + str(nb) + " matching entries.")

utils.commit_sql(statement[:-1])

print("Entering entries done!")
