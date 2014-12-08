# Book example from Seven Databases in Seven Weeks.
# Script to insert data from the writer.tsv file into Redis.
# This example does not make use of pipelining; each record is inserted individually.

require "rubygems"
require "time"
require "redis"

$redis = Redis.new( :host => "127.0.0.1", :port => 6379 )
$redis.flushall
count, start = 0, Time.now

File.open(ARGV[0]).each do |line|
  count += 1
  next if count == 1
  writer, _, film = line.split("\t")
  next if writer.empty? || film == "\n"

  $redis.set(writer, film)
end

puts "#{count} items in #{Time.now - start} seconds"

