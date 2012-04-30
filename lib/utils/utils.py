if True:
  import psycopg2
else:
  import MySQLdb
  import MySQLdb.cursors

import os
import sys

# Convert all variables options to environment variables. Like rake.
# Only syntax supported for now: SOME_VARIABLE=something
def parse_args():
  args = []
  for arg in sys.argv[1:]:
    val = __parse_arg(arg)
    if val: args.append(val)
  return args

def __parse_arg(arg):
  for i in xrange(len(arg)):
    if arg[i] == '=':
      os.environ[arg[:i]] = arg[i+1:]
      return None
  return arg

def connect_db(cursorclass=None):
  if True:
    if os.environ["RAILS_ENV"] == "production" if os.environ.has_key("RAILS_ENV") else False:
      return psycopg2.connect("dbname=encyclo_production user=postgres host=localhost password=887database", cursorclass = cursorclass)
    else:
      return psycopg2.connect("dbname=encyclo_development user=postgres host=localhost password=887database", cursorclass = cursorclass)
  else:
    return MySQLdb.connect(host='localhost', user='root', db='sorted_development', cursorclass = cursorclass)

def commit_sql(statement):
  db = connect_db()
  c = db.cursor()
  try:
    c.execute(statement)
    db.commit()
  except:
    db.rollback
  db.close()

def loop_sql(process_function, accumulator, statement):
  db = connect_db(MySQLdb.cursors.SSCursor)
  cursor = db.cursor()
  cursor.execute(statement)
  for row in cursor:
    result = process_function(row)
    if result != None: accumulator += result
  db.close()
  return accumulator

def query_sql(statement):
  db = connect_db()
  c = db.cursor()
  c.execute(statement)
  result = c.fetchall()
  db.close()
  return result

def first(collection): return collection[0]
