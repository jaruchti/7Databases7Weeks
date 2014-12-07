# Answer to Seven Databases in Seven Weeks Redis Exercise 1
require "rubygems"
require "redis"

r = Redis.new

r.multi do
  r.incr "testValue" # Insert and increment a value within a transaction
end
