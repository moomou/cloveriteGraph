
import requests, json
import redis


nodeIndex = "http://localhost:7474/db/data/index/node/"
relIndex = "http://localhost:7474/db/data/index/relationship/"

baseReq = {
  "name" : "REPLACE_ME",
  "config" : {
    "type" : "fulltext",
    "provider" : "lucene"
  }
}

with open('index.json', 'r') as f:
    print "setting up neo4j index..."
    indexConfig = json.loads(f.read())

    for index in indexConfig['relIndex']:
        newReq = baseReq.copy()
        newReq['name'] = index
        res = requests.post(relIndex, data=json.dumps(newReq))
        print res.status_code

    for index in indexConfig['nodeIndex']:
        newReq = baseReq.copy()
        newReq['name'] = index
        res = requests.post(nodeIndex, data=json.dumps(newReq))
        print res.status_code

print "setting up redis..."
rClient = redis.Redis()
rClient.sadd("_supertoken_", "superman")
