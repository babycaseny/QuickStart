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

# Configure shard01
mongo --port 47017 << 'EOF'
rs.initiate(
    { _id: "shard01", members:[
        { _id : 0, host : "MW-GAMP103240:47017" },
        { _id : 1, host : "MW-GAMP103240:47018" },
        { _id : 2, host : "MW-GAMP103240:47019" }]
    });
EOF

# Configure shard02
mongo --port 47027 << 'EOF'
rs.initiate(
    { _id: "shard02", members:[
        { _id : 0, host : "MW-GAMP103240:47027" },
        { _id : 1, host : "MW-GAMP103240:47028" },
        { _id : 2, host : "MW-GAMP103240:47029" }]
    });
EOF

# Configure sharding
mongo --port 60001 <<'EOF'
db.adminCommand( { addshard : "shard01/"+"MW-GAMP103240:47017,MW-GAMP103240:47018,MW-GAMP103240:47019" } );
db.adminCommand( { addshard : "shard02/"+"MW-GAMP103240:47027,MW-GAMP103240:47028,MW-GAMP103240:47029" } );
db.adminCommand( {enableSharding: "test"});
db.adminCommand( {shardCollection: "test.foo", key: {bar: 1}});

# Details please check documentation
use demo
for (var i=0; i < 100000; i++) {db.books.save( {name:"Book of Change"})}
EOF

# mongos> use demo
# mongos> for (var i=0; i < 100000; i++) {db.books.save( {name:"Book of Change"})}
