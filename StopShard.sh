#!/bin/bash
# Stopping the Shard in the proper way
# Details please read: ./StartShard.sh and
# https://groups.google.com/forum/#!topic/mongodb-user/TQLlRI6HG1M
# mongos first, then shards, then config servers.

# move to default directory first
cd /opt/nx/mongodb

# shutdown mongos first
mongo admin --port 60001 --eval "db.shutdownServer()"

# Shutdown second shard
mongo admin --port 47029  --eval "db.shutdownServer()"
mongo admin --port 47028  --eval "db.shutdownServer()"
mongo admin --port 47027  --eval "db.shutdownServer()"

# Shutdown first shard
mongo admin --port 47019  --eval "db.shutdownServer()"
mongo admin --port 47018  --eval "db.shutdownServer()"
mongo admin --port 47017  --eval "db.shutdownServer()"

# Shutdown config servers
mongo admin --port 60103  --eval "db.shutdownServer()"
mongo admin --port 60102  --eval "db.shutdownServer()"
mongo admin --port 60101  --eval "db.shutdownServer()"

