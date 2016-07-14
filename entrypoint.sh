#!/bin/bash
set -e

repo=$GIT_REPO
localroot="/usr/local/bin"

reponame="${repo##*/}"

name=$(echo $reponame | cut -f 1 -d '.')

git clone "$repo" "$localroot/$name"

echo "Waiting for cassandra $CASSANDRA_HOST on port $CASSANDRA_PORT to become available"

while ! nc -z $CASSANDRA_HOST $CASSANDRA_PORT; do sleep 2; done

echo "Cassandra is available, now waiting for Cassandra to accept client connections"

sleep 3

if ! [ -z "$CASSANDRA_KEYSPACE" ]
 then
	query="CREATE KEYSPACE $CASSANDRA_KEYSPACE WITH replication = {'class':'SimpleStrategy','replication_factor':1};"
	echo "Creating keyspace $CASSANDRA_KEYSPACE..."
	bash -c "cqlsh $CASSANDRA_HOST $CASSANDRA_PORT -e \"$query\""
fi

echo "Found the following files"
ls $localroot/$name/db/$ACTION/*.cql | sort -V

if [ "$ACTION" = "fixtures" ]
	then
	echo "Need to run fixtures, waiting 10 seconds for possible migrations to complete"
	sleep 10
fi

$(
for f in `ls $localroot/$name/db/$ACTION/*.cql | sort -V`
do
  echo "Executing: cqlsh $CASSANDRA_HOST $CASSANDRA_PORT --file=$f";
  bash -c "cqlsh $CASSANDRA_HOST $CASSANDRA_PORT --file=$f"
done
)


