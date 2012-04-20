import MySQLdb

def commit_sql(statement):
  db = MySQLdb.connect(host='localhost', user='root', db='sorted_development')
  c = db.cursor()
  try:
    c.execute(statement)
    db.commit()
  except:
    db.rollback
  db.close()

def query_sql(statement):
  db = MySQLdb.connect(host='localhost', user='root', db='sorted_development')
  c = db.cursor()
  c.execute(statement)
  result = c.fetchall()
  db.close()
  return result

def first(collection): return collection[0]
