# Create some directories
mkdir -p ./s0/ ./s1/rs0 ./s1/rs1 ./s1/rs2 ./cfg/

# Start first shard 
mongod --logpath "s0.log" --dbpath ./s0/ --port 37017 --fork --shardsvr

# Start second shard
mongod --replSet s1 --logpath "s1-r0.log" --dbpath ./s1/rs0 --port 47017 --fork --shardsvr
mongod --replSet s1 --logpath "s1-r1.log" --dbpath ./s1/rs1 --port 47018 --fork --shardsvr
mongod --replSet s1 --logpath "s1-r2.log" --dbpath ./s1/rs2 --port 47019 --fork --shardsvr

# Start config server and mongos
mongod --logpath "cfg.log" --dbpath ./cfg/ --port 57040 --fork --configsvr
mongos --logpath "mongos.log" --configdb localhost:57040 --fork


# Configure rs
mongo --port 47017 << 'EOF'
rs.initiate(
    { _id: "s1", members:[
        { _id : 0, host : "localhost:47017" },
        { _id : 1, host : "localhost:47018" },
        { _id : 2, host : "localhost:47019" }]
    });
EOF


# Configure sharding
mongo <<'EOF'
db.adminCommand( { addshard : "localhost:37017" } );
db.adminCommand( { addshard : "s1/"+"localhost:47017,localhost:47018,localhost:47019" } );
db.adminCommand({enableSharding: "test"})
db.adminCommand({shardCollection: "test.foo", key: {bar: 1}});
EOF