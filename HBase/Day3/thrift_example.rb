$:.push('./gen-rb')
require 'thrift'
require 'hbase'

# Example of connecting to a remote HBase instance using Thrift.
# The HBase database is then queried for basic metadata.
socket = Thrift::Socket.new( '<SERVER_NAME>', <SERVER_PORT> ) # This needs to be modified to connect to the remote server
transport = Thift::BufferedTransport.new( socket )
protocol = Thift::BinaryProtocol.new( transport )
client = Apache::Hadoop::Hbase::Thrift::Hbase::Client.new( protocol )

transport.open()

client.getTableNames().sort.each do | table |
  puts "#{table}"
  client.getColumnDescriptors( table ).each do |col, desc|
    puts "#{desc.name}"
    puts " maxVersions: #{desc.maxVersions}"
    puts " compression: #{desc.compression}"
    puts " bloomFilterType: #{desc.bloomFilterType}"
  end
end

transport.close()
