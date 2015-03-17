#!/usr/bin/env python
#
# Usage:
#
# $ HAWK=`python gen_hawk_header.py`
# $ curl -H "$HAWK" http://127.0.0.1/hello/api/greeting
#
import sys
import hmac
import hashlib
import time
import base64
from random import random

client_id = 'bb190a0c210f'
client_key = 'saRgjL5mz305xgKdKm7wtyH3uXbJb1YMtGEFbiGB5kAukFessyq1KiVNJ3rGDPT'

ts = int(time.time())
nonce = hashlib.sha1(str(random())).hexdigest()[:12]
method = 'GET'
resource = '/hello/api/greeting'
host = 'localhost'
port = 80
hashval = ''
ext = 'gen_hawk_header'

data = 'hawk.1.header\n%s\n%s\n%s\n%s\n%s\n%d\n%s\n%s\n' % (ts, nonce, method, resource, host, port, hashval, ext)
sig = hmac.new(client_key, data, hashlib.sha256)
mac = base64.b64encode(sig.digest())

header = 'Hawk id="%s", ts="%s", nonce="%s", ext="%s", mac="%s"' % (client_id, ts, nonce, ext, mac)
print 'Authorization: %s' % header
