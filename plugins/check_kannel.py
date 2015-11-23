#!/usr/bin/env python

import urllib2
import base64
import sys
import optparse
import re

from xml.dom.minidom import parseString
from pprint import pprint
import xml.etree.cElementTree as et

p = optparse.OptionParser(conflict_handler="resolve", description= "This Nagios plugin checks monit services if they are actively monitoring.")
p.add_option('-H', '--host', action='store', type='string', dest='host', default='127.0.0.1', help='The hostname you want to connect to')
p.add_option('-P', '--port', action='store', type='string', dest='port', default='13000', help='The port you want to connect to')
p.add_option('-u', '--user', action='store', type='string', dest='user', default='username', help='The username to auth as')
p.add_option('-p', '--passwd', action='store', type='string', dest='passwd', default='password', help='The password to use for the user')
options, arguments = p.parse_args()


request = urllib2.Request("http://%s:%s/status.xml?password=%s" % (options.host, options.port, options.passwd ))
tree = et.parse( urllib2.urlopen(request))

statusXML = tree.getroot()

status={}
status["version"]=statusXML.find('version').text.splitlines()
status["status"]=statusXML.find('status').text.split(',', 1 )[0];
m = re.search('uptime (.*)d (.*)h (.*)m (.*)s', statusXML.find('status').text.split(',', 1 )[1] )
status["uptime"] = ( int(m.group(1))*24*60*60) + ( int(m.group(2))  *60*60) + ( int(m.group(3))  *60) + int(m.group(4))  ;

ec = 0
edetail=""
edetailOK = "uptime: "
edetailOK += str(status["uptime"])
edetailOK += "s; outgoing traffic msg/s: "
edetailOK += statusXML.find('sms/outbound').text
edetailOK += "; incoming traffic msg/s: "
edetailOK += statusXML.find('sms/inbound').text

edetailERR = ""

status["smscs"]=[]
for smsc in statusXML.findall('smscs/smsc'):
  smscinfo={}
  smscinfo["name"]=smsc.find('name').text
  smscinfo["status"]=smsc.find('status').text.split(' ', 1 )[0];

  if "online" != smscinfo["status"]:
    edetailERR += "SMSC [" +smscinfo["name"] + "] is " + smscinfo["status"] + ","
    ec=max(ec,2)
  m = re.search('(.*)s', smsc.find('status').text.split(' ', 1 )[1] )
  smscinfo["uptime"]=int(m.group(1))
  smscinfo["uptime_diff"]=status["uptime"] - int(m.group(1))

  if smscinfo["uptime"] < 300 and smscinfo["uptime_diff"] > 0:
    edetailERR += "SMSC [" +smscinfo["name"] + "] flapping,"
    ec=max(ec,1)
  status['smscs'].append(smscinfo)

if int(statusXML.find('smscs/count').text) < 1:
  edetailERR += "No SMSCs configured,"
  ec=max(ec,2)

if int(statusXML.find('sms/received/queued').text) > 100:
  edetailERR += "Received queue " + statusXML.find('sms/received/queued').text + ","
  ec=max(ec,2)

if int(statusXML.find('sms/sent/queued').text) > 100:
  edetailERR += "Send queue " + statusXML.find('sms/sent/queued').text + ","
  ec=max(ec,2)

#if int(statusXML.find('dlr/queued').text) > 5:
#  edetailERR += "DLR queue " + statusXML.find('dlr/queued').text + ","
#  ec=max(ec,2)


if ec == 0:
  es = "OK"
  edetail=edetailOK
if ec == 1:
  es = "WARNING"
  edetail=edetailERR
if ec == 2:
  es = "CRITICAL"
  edetail=edetailERR

print "KANNEL status %s (%s); %s" % (es,ec,edetail)
sys.exit(ec)
