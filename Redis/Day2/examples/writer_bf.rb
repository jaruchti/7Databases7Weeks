# Book example of bloom filters from Seven Databases in Seven Weeks.
# Script to read each film name from the writer.tsv file,
# break the film name into words, and insert the word into a 
# Bloom Filter if it is not not yet present.

require "rubygems"
require "time"
require "redis"
require "bloomfilter-rb"

bloomfilter = BloomFilter::Redis.new(:size => 1000000)

$redis = Redis.new( :host => "127.0.0.1", :port => 6379 )
$redis.flushall

count, start = 0, Time.now
File.open(ARGV[0]).each do |line|
  count += 1
  next if count == 1
  _, _, film = line.split("\t")
  next if film == "\n"

  words = film.gsub(/[^\w\s]+/, '').downcase
  words = words.split(' ')
  words.each do |word|
    #skip any keyword already in the bloomfilter
    next if bloomfilter.include?(word)

    #output the very unique word
    puts word

    #add the new word to the bloomfilter
    bloomfilter.insert(word)
  end
end

puts "#{count} items in #{Time.now - start} seconds"

