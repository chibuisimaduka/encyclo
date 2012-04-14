#!/usr/bin/python -O

import commands
import sys

typename = sys.argv[1]
filename = sys.argv[2]

ids_str = commands.getoutput('echo "select freebase_id from freebase_entities where type=' + typename +
  ';" | mysql -u root sorted_development')
ids = set(ids_str.split('\n'))
entities = {}

print("Starting to fetch entries..")

num_entries = 0
for line in open(filename, 'r'):
  entity_id = line[:line.index('\t')]
  if (entity_id in ids)
    if entities[entity_id]
      entities[entity_id]
    else
      entities[entity_id]
    num_entries += 1
    if (num_entries % 100 == 0): print("Entered 100 entities!")

print("Fetching entries done!")

for entity_id, entity_values in entities.items():
  
