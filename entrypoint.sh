#!/bin/bash
set -e

# set some needed variables
# Wait till cassandra is available on network
# Wait another extra 10 seconds for cassandra to accept client connections
# do a git clone from a git repo (with a db folder with a file called cassandra_fixtures.sql in it)
# Do the command to execute cqlsh with the cassandra_fixtures.sql script against the cassandra container

repo=$GITREPO
localroot="/usr/local/bin"

reponame="${repo##*/}"

name=$(echo $reponame | cut -f 1 -d '.')

git clone "$repo" "$localroot/$name"

echo "Waiting for cassandra $CASSANDRA on port $CASSANDRA_PORT to become available"

while ! nc -z $CASSANDRA $CASSANDRA_PORT; do sleep 2; done

echo "Cassandra is available, now waiting for Cassandra to accept client connections"

sleep 5

#FILES=$localroot/$name/db/$ACTION/*

echo "Found the following files"
ls $localroot/$name/db/$ACTION/*.sql | sort -V
ping -c 1 mycassandra
ping -c 1 $CASSANDRA

$(
for f in `ls $localroot/$name/db/$ACTION/*.sql | sort -V`
do
  echo "Executing: cqlsh $CASSANDRA $CASSANDRA_PORT --file=$f";
  bash -c "cqlsh mycassandra 9042 --file=$f"
done
) &>/dev/null

#echo Executing: cqlsh --file="$localroot/$name/db/$ACTION/0001-cassandra_fixtures.sql"

#exec cqlsh $CASSANDRA $CASSANDRA_PORT --file="$localroot/$name/db/cassandra_fixtures.sql"
