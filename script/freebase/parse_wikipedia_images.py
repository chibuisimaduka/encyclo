#!/usr/bin/python -O

import sys
import utils
from lxml import etree

# Parses all documents and outputs the images found.
# It only keeps the first image for now if multiple are found.

if len(sys.argv) != 2: raise RuntimeError("Usage: parse_images.py path/to/output/file")

filename = sys.argv[1]

def parse_document(document):
  tree = etree.HTML(document[1])
  images = tree.xpath('//table[starts-with(@class, "infobox")]//img')
  if len(images) == 0:
    print("No images found.")
  else:
    return str(document[0]) + "\thttp:" + images[0].get('src') + "\n"
  
out = utils.loop_sql(parse_document, "", 'SELECT id,content FROM remote_documents WHERE url LIKE "http://en.wikipedia.org%"')

f = open(filename, 'w')
f.write(out)
f.close()
