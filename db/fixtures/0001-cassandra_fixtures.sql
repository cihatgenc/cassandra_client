CREATE KEYSPACE myservice
WITH replication = {
	'class' : 'SimpleStrategy',
	'replication_factor' : 1
};