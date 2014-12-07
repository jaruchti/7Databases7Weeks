# Answer to Seven Databases in Seven Weeks Redis Exercise 2
# Create a program that reads a blocking message list.  Another program
# will write to the same list.
require "rubygems"
require "redis"

r = Redis.new
_, msg = r.blpop("msg:queue")
puts msg
