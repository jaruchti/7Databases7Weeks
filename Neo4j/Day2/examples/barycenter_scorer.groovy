/* 
Book example of using the Java Universal Network/Graph (JUNG) Framework to compute
Barycenter Score.  It is a measure of the distance of a vertex to all other vertices.
Lower scores imply a lesser distance to all other vertices.
*/

import edu.uci.ics.jung.algorithms.scoring.BarycenterScorer;

j = new GraphJung(g)
t = new EdgeLabelTransformer(['ACTED_IN'] as Set, false) // Filter only vertices with 'ACTED_IN' edges

barycenter = new BarycenterScorer<Vertex,Edge>(j, t)

// Determine the Barycentric score for Kevin Bacon
bacon = g.V.filter{ it.name =='Kevin Bacon'}.next()
bacon_score = barycenter.getVertexScore(bacon)

// Determine if any of Keven Bacon's co-stars have a lower
// Barycentric score
connected = [:]
bacon.costars.each{
  score = barycenter.getVertexScore(it)
  if (score < bacon_score) connected[id] = score
}
connected.sort{a,b->a.value <=> b.value}.collect{k, v -> k.name + " => " + v}
