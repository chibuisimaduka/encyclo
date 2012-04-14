#!/bin/bash

type=$1
file=$2

escaped_type=`echo $type | sed 's/\//\\\//g'`

statement_1="INSERT INTO freebase_entities (freebase_type,freebase_id) VALUES('$type','"
statement_2=`grep -P "/type/object/type\t$type" $file | awk '{ print $1 }' | sed :a;N;$!ba;s/\n/\'\),\($escaped_type,/g`
statement_3="');"
statement=$statement_1$statement_2$statement_3
echo $statement | mysql -u root sorted_development
