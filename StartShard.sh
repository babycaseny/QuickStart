#!/bin/bash
# Details please read:
# http://stackoverflow.com/questions/19580202/can-1-shard-server-have-replica-set-while-the-rest-dont
# please replace all "localhost" instances with the actual hostname

# move to default directory first
cd /opt/nx/mongodb

## Create some directories
mkdir -p ./shard01/shard01a ./shard01/shard01b ./shard01/shard01c 
mkdir -p ./shard02/shard02a ./shard02/shard02b ./shard02/shard02c 
mkdir -p ./config/config01  ./config/config02  ./config/config03

# Start first shard 
mongod --replSet shard01 --logpath "shard01a.log" --dbpath ./shard01/shard01a --port 47017 --fork --shardsvr
mongod --replSet shard01 --logpath "shard01b.log" --dbpath ./shard01/shard01b --port 47018 --fork --shardsvr
mongod --replSet shard01 --logpath "shard01c.log" --dbpath ./shard01/shard01c --port 47019 --fork --shardsvr

# Start second shard
mongod --replSet shard02 --logpath "shard02a.log" --dbpath ./shard02/shard02a --port 47027 --fork --shardsvr
mongod --replSet shard02 --logpath "shard02b.log" --dbpath ./shard02/shard02b --port 47028 --fork --shardsvr
mongod --replSet shard02 --logpath "shard02c.log" --dbpath ./shard02/shard02c --port 47029 --fork --shardsvr

# Start config servers
mongod --logpath "config01.log" --dbpath ./config/config01 --port 60101 --fork --configsvr
mongod --logpath "config02.log" --dbpath ./config/config02 --port 60102 --fork --configsvr
mongod --logpath "config03.log" --dbpath ./config/config03 --port 60103 --fork --configsvr

# Now, start mongos as well
mongos --logpath "mongos.log" --port 60001 --configdb MW-GAMP103240:60101,MW-GAMP103240:60102,MW-GAMP103240:60103 --fork

