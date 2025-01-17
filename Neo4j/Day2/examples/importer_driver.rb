# Example of importing a large data file into Neo4j using the Neo4j Ruby gem.
# This example is taken verbatim from the book and utilizes the REST interface.
# A better solution would utilize the neo4j gem or Neography and batch insertion.

REST_URL = "http://localhost:7474/"
HEADER = { "Content-Type" => "application/json" }

%w{rubygems json cgi faraday}.each{|r| require r}

# make a connection to the Neo4j REST server
conn = Faraday.new(:url => REST_URL) do |builder|
  builder.adapter :net_http
end

# method to get existing node from the index or create one
def get_or_create_node(conn, index, value)
  # look for node in the index
  r = conn.get("/db/data/index/node/#{index}/name/#{CGI.escape(value)}")
  node = (JSON.parse(r.body).first || {})['self'] if r.status == 200
  unless node
    # no indexed node found, so create a new one
    r = conn.post("/db/data/node", JSON.unparse({"name" => value}), HEADER)
    node = (JSON.parse(r.body) || {})['self'] if [200, 201].include? r.status
    # add new node to an index
    node_data = "{\"uri\" : \"#{node}\", 
                  \"key\" : \"name\", 
                  \"value\" : \"#{CGI.escape(value)}\"}"
    conn.post("/db/data/index/node/#{index}", node_data, HEADER)
  end
  node
end

puts "begin processing..."

count = 0
File.open(ARGV[0]).each do |line|
  _, _, actor, movie = line.split("\t")
  next if actor.empty? || movie.empty?

  # build the actor node and movie nodes
  actor_node = get_or_create_node(conn, 'actors', actor)
  movie_node = get_or_create_node(conn, 'movies', movie)

  # create relationship between actor and movie
  conn.post("#{actor_node}/relationships", 
            JSON.unparse({ :to => movie_node, :type => 'ACTED_IN' }), 
            HEADER)

  puts "  #{count} relationships loaded" if (count += 1) % 100 == 0
end

puts "done!"
