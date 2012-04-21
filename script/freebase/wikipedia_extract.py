#!/usr/bin/python -O

import utils
import sys


if len(sys.argv) != 5: raise RuntimeError("Usage: crawl.py 1000(limit) path/to/input path/to/output 862(parent_id)")

limit = sys.argv[1]
input_file = sys.argv[2]
output_file = open(sys.argv[3], 'w') # Where to write the names of the urls to fetch.
parent_id = sys.argv[4]

freebase_ids = []
for ids in utils.query_sql("SELECT freebase_id FROM entities WHERE parent_id = " + parent_id +
                           " ORDER BY content_size_rank DESC LIMIT " + limit):
  freebase_ids.append(ids[0])

out = ""
for line in open(input_file, 'r'):
  freebase_id = line[:line.index('\t')]
  if freebase_id in freebase_ids:
    out += freebase_id + "\thttp://en.wikipedia.org/wiki/" + line[line.index('\t')+1:]

output_file.write(out)
output_file.close
