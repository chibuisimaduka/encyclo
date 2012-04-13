#!/bin/bash

type=$1
file=$2
tbl_name (a,b,c) VALUES(1,2,3),(4,5,6),(7,8,9);
statement= "INSERT INTO freebase_entities (freebase_type,freebase_id) VALUES($type," +
  `grep -P "/type/object/type\t$type" $file | awk '{ print $1 }' | tr -s "\n" "),($type,"` + ");"
mysql -u root encyclo_development < statement
