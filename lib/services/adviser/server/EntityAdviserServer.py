#!/usr/bin/env python

import sys
# your gen-py dir
sys.path.append('../gen-py')

import time

from adviser import EntityAdviser
from adviser.ttypes import *

# Thrift files
from thrift.transport import TSocket
from thrift.transport import TTransport
from thrift.protocol import TBinaryProtocol
from thrift.server import TServer

from EntityAdviserIndex import EntityAdviserIndex

# Server implementation
class EntityAdviserHandler:

  def __init__(self):
    pass
    self.adviser_index = EntityAdviserIndex()

  def ping(self):
    print('Ping')
    return True

  def get_suggestions(self, user_id, category_id, limit, offset, predicates):
    return self.adviser_index.get_suggestions(user_id, category_id, limit, offset, predicates)

  def add_association(self, association):
    self.adviser_index.add_association(association)

  def update_entity_rank(self, entity_id, rank, category_id):
    self.adviser_index.update_entity_rank(entity_id, rank, category_id)

# set handler to our implementation
handler = EntityAdviserHandler()

processor = EntityAdviser.Processor(handler)
transport = TSocket.TServerSocket(port=9090)
tfactory = TTransport.TBufferedTransportFactory()
pfactory = TBinaryProtocol.TBinaryProtocolFactory()

# set server
server = TServer.TThreadedServer(processor, transport, tfactory, pfactory)

print 'Starting server'
try:
  server.serve()
except KeyboardInterrupt: 
  print 'Interrupted'
