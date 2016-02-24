require 'maxminddb'
db = MaxMindDB.new('/tmp/1.mmdb')
ret = db.lookup('1.0.16.1')
print ret.found?
