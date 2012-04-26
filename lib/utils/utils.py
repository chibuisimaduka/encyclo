import MySQLdb
import MySQLdb.cursors

def commit_sql(statement):
  db = MySQLdb.connect(host='localhost', user='root', db='sorted_development')
  c = db.cursor()
  try:
    c.execute(statement)
    db.commit()
  except:
    db.rollback
  db.close()

def loop_sql(process_function, accumulator, statement):
  db = MySQLdb.connect(host='localhost', user='root', db='sorted_development', cursorclass = MySQLdb.cursors.SSCursor)
  cursor = db.cursor()
  cursor.execute(statement)
  for row in cursor:
    result = process_function(row)
    if result != None: accumulator += result
  db.close()
  return accumulator

def query_sql(statement):
  db = MySQLdb.connect(host='localhost', user='root', db='sorted_development')
  c = db.cursor()
  c.execute(statement)
  result = c.fetchall()
  db.close()
  return result

def first(collection): return collection[0]
