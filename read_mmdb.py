import maxminddb
import json
reader = maxminddb.open_database('MaxMind_DB_Writer_perl_create.mmdb')
result = reader.get('1.0.16.1')
reader.close()
print json.dumps(result, indent=2)
