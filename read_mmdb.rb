require 'maxminddb'
db = MaxMindDB.new('MaxMind_DB_Writer_perl_create.mmdb')
ret = db.lookup('1.0.16.1')
print ret.found?
