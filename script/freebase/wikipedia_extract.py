#!/usr/bin/python -O

import utils
import sys

def hex2dec(s):
  return int(s, 16)

def base10to32(num):
    num_rep={10:'b',
         11:'c',
         12:'d',
         13:'f',
         14:'g',
         15:'h',
         16:'j',
         17:'k',
         18:'l',
         19:'m',
         20:'n',
         21:'p',
         22:'q',
         23:'r',
         24:'s',
         25:'t',
         26:'v',
         27:'w',
         28:'x',
         29:'y',
         30:'z',
         31:'_'}
    new_num_string=''
    current=num
    while current!=0:
        remainder=current%32
        if 36>remainder>9:
            remainder_string=num_rep[remainder]
        elif remainder>=36:
            remainder_string='('+str(remainder)+')'
        else:
            remainder_string=str(remainder)
        new_num_string=remainder_string+new_num_string
        current=current/32
    return new_num_string

if len(sys.argv) != 5: raise RuntimeError("Usage: crawl.py 1000(limit) path/to/input path/to/output 862(parent_id)")

limit = sys.argv[1]
input_file = sys.argv[2]
output_file = open(sys.argv[3], 'w') # Where to write the names of the urls to fetch.
parent_id = sys.argv[4]

freebase_ids = set()
for ids in utils.query_sql("SELECT freebase_id FROM entities WHERE parent_id = " + parent_id +
                           " ORDER BY content_size_rank DESC LIMIT " + limit):
  freebase_ids.add(ids[0])

print "Starting to read file."

# The dump file contains redirects. Only keep one document per entity.
documents = {}
for line in open(input_file, 'r'):
  guid = line[:line.index('\t')]
  freebase_id = "/m/0" + base10to32(hex2dec(guid[len("#9202a8c04000641f8"):]))
  if freebase_id in freebase_ids and freebase_id not in documents:
    documents[freebase_id] = "\thttp://en.wikipedia.org/wiki/" + line[line.index('\t')+1:].replace(' ','_')

out = ""
for freebase_id in documents:
  out += freebase_id + documents[freebase_id]

output_file.write(out)
output_file.close
