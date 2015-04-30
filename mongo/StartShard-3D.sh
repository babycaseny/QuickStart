#!/bin/bash
# Modified from StartShard.sh
# Details please read:
# http://stackoverflow.com/questions/19580202/can-1-shard-server-have-replica-set-while-the-rest-dont
# please replace all "localhost" instances inside the config files 
# with the actual hostname

# Start first shard
mongod --config shard01a.conf
mongod --config shard01b.conf
mongod --config shard01c.conf

# Start second shard
mongod --config shard02a.conf
mongod --config shard02b.conf
mongod --config shard02c.conf

# Start config servers
mongod --config config01.conf
mongod --config config02.conf
mongod --config config03.conf

# Now, start mongos as well
mongos --config mongos.conf
