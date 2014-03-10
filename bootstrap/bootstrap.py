
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

def createIndex(url, indexName):
    newReq = baseReq.copy()
    newReq['name'] = index
    res = requests.post(url, data=json.dumps(newReq))
    print index, res.status_code
    if res.status_code != 201:
        print res.text

with open('index.json', 'r') as f:
    print "setting up neo4j index..."
    indexConfig = json.loads(f.read())

    for index in indexConfig['relIndex']:
        createIndex(relIndex, index)
        
    for index in indexConfig['nodeIndex']:
        createIndex(nodeIndex, index)

print "setting up redis..."
rClient = redis.Redis()
rClient.sadd("_supertoken_", "superman")
