from twisted.mail.smtp import ESMTPSenderFactory, SMTPFactory
from twisted.mail.protocols import ESMTPFactory, DomainDeliveryBase
from twisted.python.usage import Options, UsageError
#from twisted.internet.defer import Deferred
from twisted.internet import reactor, protocol, defer
from commgate.core import CGTransport
from twisted.mail import smtp
from twisted.application import internet

resultDeferred = defer.Deferred()

senderFactory = ESMTPSenderFactory('authenticationUsername','authenticationSecret','fromAddress','toAddress','messageFile',resultDeferred,contextFactory=None, requireAuthentication=False, requireTransportSecurity=False) 

def ebSentMessage(err):
  print("call-----ebSentMessage")
  err.printTraceback()

def cbSentMessage(result):
  print("call-----cbSentMessage")

class CGSmtpClient(CGTransport):
  heloFallback = True
  def __init__(self, node):
    CGTransport.__init__(self, node)
  def sendFragment(self, fragment):
    print "call-----sendFragment smtp", fragment
    msg = fragment
    result = smtp.sendmail('127.0.0.1', 'asoui@redacted.com', 'sack@redacted.com', msg, senderDomainName=None, port=25)
    result.addCallbacks(cbSentMessage, ebSentMessage)
  def canSend(self, dst):
    return 9

#SERVER

class ConsoleMessageDelivery(smtp.ESMTP):
  __implements__ = (smtp.IMessageDelivery)
  def receivedHeader(self, helo, origin, recipients):
    print "Header recu"
    return "BLI"
  def validateFrom(self,helo,origin):
    print "call-----validateFrom"
    return origin
  def validateTo(self,user):
    print "call-----validateTo" 
    print dir(self)
    return lambda: ConsoleMessage(self)

#ConsoleESMTPFactory = protocol.ServerFactory()

class ConsoleMessage():
  __implements__ = (smtp.IMessage)
  def __init__(self, a):
    self.lines = []
    self.tsp = a
  def lineReceived(self, line):
    print "call-----lineReceived ----- line=", line   
    if (line[:4] == "Frag"):
      self.lines.append(line)
  def eomReceived(self):
    print type(self.tsp)
    self.lines = None
    return defer.succeed(None)
  def connectionLost(self):
    self.lines = None
    print "call-----connectionLost" 

ConsoleESMTPFactory = ESMTPFactory(SMTPFactory)

class CGSmtpTransportServer(CGTransport):
  def __init__(self, node):
    CGTransport.__init__(self, node)
    ConsoleESMTPFactory.protocol = ConsoleMessageDelivery
  def connect(self):
    reactor.listenTCP(25, ConsoleESMTPFactory)
    print "internet.TCPServer lance"

