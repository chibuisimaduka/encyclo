#!/usr/bin/python -O

import sys
import utils
from lxml import etree

# Parses all documents and outputs the images found.
# It only keeps the first image for now if multiple are found.

if len(sys.argv) != 2: raise RuntimeError("Usage: parse_images.py path/to/output/file")

filename = sys.argv[1]

out = ""
for document in utils.query_sql('SELECT id,content FROM remote_documents WHERE url LIKE "http://en.wikipedia.org%"'):
  tree = etree.HTML(document[1])
  images = tree.xpath('//table[starts-with(@class, "infobox")]//img')
  if len(images) == 0:
    print("No images found.")
  else:
    out += str(document[0]) + "\thttp:" + images[0].get('src') + "\n"

f = open(filename, 'w')
f.write(out)
f.close()
