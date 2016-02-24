import maxminddb
import json
reader = maxminddb.open_database('1.mmdb')
result = reader.get('1.0.16.1')
reader.close()
print json.dumps(result, indent=2)
