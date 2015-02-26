#!/bin/bash
# Details please read:
# http://stackoverflow.com/questions/19580202/can-1-shard-server-have-replica-set-while-the-rest-dont
## Create some directories
mkdir -p ./shard01/shard01a ./shard01/shard01b ./shard01/shard01c 
mkdir -p ./shard02/shard02a ./shard02/shard02b ./shard02/shard02c 
mkdir -p ./cfg/

# Start first shard 
mongod --replSet shard01 --logpath "shard01a.log" --dbpath ./shard01/shard01a --port 47017 --fork --shardsvr
mongod --replSet shard01 --logpath "shard01b.log" --dbpath ./shard01/shard01b --port 47018 --fork --shardsvr
mongod --replSet shard01 --logpath "shard01c.log" --dbpath ./shard01/shard01c --port 47019 --fork --shardsvr

# Start second shard
mongod --replSet shard02 --logpath "shard02a.log" --dbpath ./shard02/shard02a --port 47027 --fork --shardsvr
mongod --replSet shard02 --logpath "shard02b.log" --dbpath ./shard02/shard02b --port 47028 --fork --shardsvr
mongod --replSet shard02 --logpath "shard02c.log" --dbpath ./shard02/shard02c --port 47029 --fork --shardsvr

# Start config server
mongod --logpath "cfg.log" --dbpath ./cfg/ --port 57040 --fork --configsvr

# Now, start mongos as well
mongos --logpath "mongos.log" --configdb localhost:57040 --fork

# Configure shard01
mongo --port 47017 << 'EOF'
rs.initiate(
    { _id: "shard01", members:[
        { _id : 0, host : "localhost:47017" },
        { _id : 1, host : "localhost:47018" },
        { _id : 2, host : "localhost:47019" }]
    });
EOF

# Configure shard02
mongo --port 47017 << 'EOF'
rs.initiate(
    { _id: "shard02", members:[
        { _id : 0, host : "localhost:47027" },
        { _id : 1, host : "localhost:47028" },
        { _id : 2, host : "localhost:47029" }]
    });
EOF


# Configure sharding
mongo <<'EOF'
db.adminCommand( { addshard : "localhost:37017" } );
db.adminCommand( { addshard : "s1/"+"localhost:47017,localhost:47018,localhost:47019" } );
db.adminCommand({enableSharding: "test"})
db.adminCommand({shardCollection: "test.foo", key: {bar: 1}});
EOF