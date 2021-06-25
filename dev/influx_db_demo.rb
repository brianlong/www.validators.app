
require 'influxdb'

# curl -G 'http://34.127.13.154:8086/query?pretty=true&u=user&p=password' --data-urlencode "db=mainnet-beta" --data-urlencode "q=SELECT mean(\"replay_time\") FROM \"autogen\".\"replay-slot-stats\" WHERE time > now() - 1h"

database = 'NOAA_water_database'
# database = 'mainnet-beta'
# database = 'testnet-live-cluster'
username = 'blong'
password = 'blong@123'
host = '34.127.13.154'
port = '8086'

influxdb = InfluxDB::Client.new database,
                                host: host,
                                port: port,
                                username: username,
                                password: password
puts influxdb.query "SHOW RETENTION POLICIES;"
# {"name"=>nil, "tags"=>nil, "values"=>[{"name"=>"autogen", "duration"=>"0s", "shardGroupDuration"=>"168h0m0s", "replicaN"=>1, "default"=>true}]}
