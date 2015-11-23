#!/usr/bin/env python

import urllib2
import base64
import sys
import optparse

from xml.dom.minidom import parseString


p = optparse.OptionParser(conflict_handler="resolve", description= "This Nagios plugin checks monit services if they are actively monitoring.")
p.add_option('-H', '--host', action='store', type='string', dest='host', default='127.0.0.1', help='The hostname you want to connect to')
p.add_option('-P', '--port', action='store', type='string', dest='port', default='2812', help='The port you want to connect to')
p.add_option('-u', '--user', action='store', type='string', dest='user', default='username', help='The username to auth as')
p.add_option('-p', '--passwd', action='store', type='string', dest='passwd', default='password', help='The password to use for the user')
options, arguments = p.parse_args()



request = urllib2.Request("http://%s:%s/_status?format=xml" % (options.host, options.port))
base64string = base64.encodestring('%s:%s' % (options.user, options.passwd)).replace('\n', '')
request.add_header("Authorization", "Basic %s" % base64string)
result = urllib2.urlopen(request)

dom = parseString("".join(result.readlines()))

ec = 0
edetail = ""

for service in dom.getElementsByTagName('service'):
        name = service.getElementsByTagName('name')[0].firstChild.data
        monitor = int(service.getElementsByTagName('monitor')[0].firstChild.data)
        status = int(service.getElementsByTagName('status')[0].firstChild.data)
        et = 0
        if status != 0:
                edetail = edetail + "%s not running or accessible;" % name
                et = 2
        if monitor == 0:
                edetail = edetail + "%s not monitored;" % name
                et = 1
        if et >= ec:
                ec = et

if ec == 0:
  es = "OK"
if ec == 1:
  es = "WARNING"
if ec == 2:
  es = "CRITICAL"

print "MONIT status %s (%s); %s" % (es,ec,edetail)
sys.exit(ec)
