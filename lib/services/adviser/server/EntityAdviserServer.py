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

  #def __init__(self):
  #  pass
  #  self.adviser_index = EntityAdviserIndex()

  def ping(self):
    print('Ping')
    return True

  #def get_suggestions(self, category_id, limit, offset, predicates):
  #  return self.adviser.get_suggestions(categories[category_id], limit, offset, predicates)

  #def add_association(association):
  #  self.adviser.add_association(association)

  #def update_entity_rank(entity_id, rank):
  #  self.adviser.add_association(entity_id, rank)

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
