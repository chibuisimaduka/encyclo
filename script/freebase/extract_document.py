#!/usr/bin/python -O

import utils
import sys

if len(sys.argv) != 6: raise RuntimeError("Usage: extract_document.py path/to/input path/to/output 862(parent_id) key site_prefix")

input_file = sys.argv[1]
output_filename = sys.argv[2] # Where to write the names of the urls to fetch.
parent_id = sys.argv[3]
key = sys.argv[4]
site_prefix = sys.argv[5]

freebase_ids = map(utils.first, utils.query_sql("SELECT freebase_id FROM entities WHERE parent_id = " + parent_id +
                                                   " ORDER BY content_size_rank DESC"))
freebase_ids_set = set(freebase_ids)

print "Starting to read file."

# The dump file contains redirects. Only keep one document per entity.
documents = dict()
for line in open(input_file, 'r'):
  freebase_id = line[:line.index('\t')]
  if freebase_id in freebase_ids_set and line[line.index('\t'):line.rindex('\t')] == ("\t/type/object/key\t" + key):
    documents[freebase_id] = site_prefix + line[line.rindex('\t')+1:]

out = ""
# Use the oredered freebase ids.
for freebase_id in freebase_ids:
  if freebase_id in documents:
    out += freebase_id + "\t" + documents[freebase_id] 

output_file = open(output_filename, 'w')
output_file.write(out)
output_file.close
