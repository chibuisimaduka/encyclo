#!/usr/bin/env python

# This server demonstrates Thrift's connection and "oneway" asynchronous jobs
# showCurrentTimestamp : which returns current time stamp from server
# asynchronousJob() : prints something, waits 10 secs and print another string
# 
# Osman Yuksel < yuxel {{|AT|}} sonsuzdongu |-| com >

port = 9090

import sys
# your gen-py dir
sys.path.append('../gen-py')

import time

# Example files
from Example import *
from Example.ttypes import *

# Thrift files
from thrift.transport import TSocket
from thrift.transport import TTransport
from thrift.protocol import TBinaryProtocol
from thrift.server import TServer

import advisor

# Server implementation
class ExampleHandler:

  categories = ...

  def init ...: advisor.init()

  # return current time stamp
  def get_suggestions(self, category_id, limit, offset):
    return advisor.get_suggestions(categories[category_id], limit, offset)

  def get_filtered_suggestions(self, category_id, limit, offset, predicate_ids):
    return advisor.get_suggestions(categories[category_id], limit, offset)

# set handler to our implementation
handler = ExampleHandler()

processor = Example.Processor(handler)
transport = TSocket.TServerSocket(port)
tfactory = TTransport.TBufferedTransportFactory()
pfactory = TBinaryProtocol.TBinaryProtocolFactory()

# set server
server = TServer.TThreadedServer(processor, transport, tfactory, pfactory)

print 'Starting server'
server.serve()
