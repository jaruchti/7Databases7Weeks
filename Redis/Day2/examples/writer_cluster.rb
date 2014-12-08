# Book example from Seven Databases in Seven Weeks.
# Script to insert data from the writer.tsv file into Redis.
# This example makes use of a distributed Redis configuration.

require "rubygems"
require "time"
require "redis"
require "redis/distributed"

$redis = Redis::Distributed::new([
  "redis://localhost:6379", 
  "redis://localhost:6380"
])
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

