#!/bin/bash

# create a database
# using DNS:
# HOST="cloudant5.torolab.ibm.com"

# bypassing DNS:
AUTH="admin:cloudant"
HOST="10.10.11.5"
REMOTE_HOST="performance:halbongo@performance.cloudant.com"
echo "create local database"
curl -X PUT http://${AUTH}@${HOST}/db_master

echo "insert 3 document"
for NUM in {0..100}; do
  OUTPUT=`curl -sX POST "http://${AUTH}@${HOST}/db_master/" \
            -H "Content-Type: application/json" \
            -d '{ "_id": "'$NUM'", "team": "CloudLab'$NUM'" }'`
  REVISION=`echo $OUTPUT | cut -d':' -f4 | sed s'/.$//'`
  echo $REVISION
done

echo "replicate (push) to a local database"
# create local replica database
curl -X PUT http://${AUTH}@${HOST}/db_replica_local
/usr/bin/time curl -X POST "http://${AUTH}@${HOST}/_replicate" \
 -d '{"source": "db_master", "target": "db_replica_local"}' \
 -H "Content-Type: application/json" 

echo "replicate (push) to a remote database"
# create remote replica database
curl -X PUT http://${REMOTE_HOST}/db_replica_remote
/usr/bin/time curl -X POST "http://${AUTH}@${HOST}/_replicate" \
 -H "Content-Type: application/json" \
 -d '{"source": "db_master", "target": "https://'${REMOTE_HOST}'/db_replica_remote"}'

echo "delete the databases"
curl -X DELETE http://${AUTH}@${HOST}/db_master
curl -X DELETE http://${AUTH}@${HOST}/db_replica_local
curl -X DELETE http://${REMOTE_HOST}/db_replica_remote
