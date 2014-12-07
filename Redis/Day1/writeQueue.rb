# Answer to Seven Databases in Seven Weeks Redis Exercise 2
# Create a program which writes to a message list.  Another program will be
# reading from this list.
require "rubygems"
require "redis"

r = Redis.new
r.lpush("msg:queue", "Test Message!");
