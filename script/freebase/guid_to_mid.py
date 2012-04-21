#!/usr/bin/python -O

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

if len(sys.argv) != 3: raise RuntimeError("Usage: extract.py path/to/data path/to/destination")

input_file = sys.argv[1]
destination_file = sys.argv[2]

f = open(destination_file, 'w')
for line in open(input_file, 'r'):
  guid = line[:line.index('\t')]
  mid = "/m/0" + base10to32(hex2dec(guid[len("#9202a8c04000641f8"):]))
  f.write(mid + line[line.index('\t'):].replace(' ','_'))
