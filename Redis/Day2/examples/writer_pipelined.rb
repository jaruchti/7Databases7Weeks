# Book example from Seven Databases in Seven Weeks.
# Script to insert data from the writer.tsv file into Redis.
# This example makes use of pipelining, so data is inserted in a batch manner,
# greatly improving processing time.

require "rubygems"
require "time"
require "redis"

$redis = Redis.new( :host => "127.0.0.1", :port => 6379 )
$redis.flushall

def flush(batch)
  $redis.pipelined do 
    batch.each do |saved_line|
      writer, _, film = saved_line.split("\t")
      next if writer.empty? || film == "\n"
      $redis.set(writer, film)
    end
  end

  batch.clear
end

batch = []
count, start = 0, Time.now
File.open(ARGV[0]).each do |line|
  count += 1
  next if count == 1

  # push lines into an array
  batch << line

  # if the array grows to 1000, flush it
  if batch.size == 1000 
    flush(batch)
    puts "#{count - 1} items"
  end
end

# flush any remaining values
flush(batch)

puts "#{count} items in #{Time.now - start} seconds"
