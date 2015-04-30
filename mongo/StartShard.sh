#!/bin/bash
# Details please read:
# http://stackoverflow.com/questions/19580202/can-1-shard-server-have-replica-set-while-the-rest-dont
# please replace all "localhost" instances with the actual hostname

# move to default directory first
cd /opt/nx/mongodb

# Start first shard 
mongod --replSet shard01 --logpath "shard01a.log" --logappend --dbpath ./shard01/shard01a --port 47017 --fork --shardsvr
mongod --replSet shard01 --logpath "shard01b.log" --logappend --dbpath ./shard01/shard01b --port 47018 --fork --shardsvr
mongod --replSet shard01 --logpath "shard01c.log" --logappend --dbpath ./shard01/shard01c --port 47019 --fork --shardsvr

# Start second shard
mongod --replSet shard02 --logpath "shard02a.log" --logappend --dbpath ./shard02/shard02a --port 47027 --fork --shardsvr
mongod --replSet shard02 --logpath "shard02b.log" --logappend --dbpath ./shard02/shard02b --port 47028 --fork --shardsvr
mongod --replSet shard02 --logpath "shard02c.log" --logappend --dbpath ./shard02/shard02c --port 47029 --fork --shardsvr

# Start config servers
mongod --logpath "config01.log" --logappend --dbpath ./config/config01 --port 60101 --fork --configsvr
mongod --logpath "config02.log" --logappend --dbpath ./config/config02 --port 60102 --fork --configsvr
mongod --logpath "config03.log" --logappend --dbpath ./config/config03 --port 60103 --fork --configsvr

# Now, start mongos as well
mongos --logpath "mongos.log" --logappend --port 60001 --configdb MW-GAMP103240:60101,MW-GAMP103240:60102,MW-GAMP103240:60103 --fork

exit 0
