-- Question #1
CREATE OR REPLACE FUNCTION suggest_movies(search text)
RETURNS SETOF text AS $$
DECLARE
  searchValVar text;
  searchTypeVar char(1);
BEGIN
  -- Determine if the search is for an actor or a movie by finding
  -- the closest match by Levenshtein distance.
  SELECT INTO searchTypeVar, searchValVar
              searchType, searchVal
  FROM 
    (SELECT 'A' AS searchType, 
            a.name AS searchVal,
            LEVENSHTEIN(lower(search), lower(a.name)) AS distance
     FROM   actors a
     UNION
     SELECT 'M' AS searchType, 
            m.title as searchVal,
            LEVENSHTEIN(lower(search), lower(m.title)) AS distance
     FROM   movies m
    ) search
  ORDER BY distance
  LIMIT 1;

  IF searchTypeVar = 'A' THEN
    -- Return movies the actor has starred in 
    RETURN QUERY EXECUTE
      'SELECT  m.title 
       FROM    movies m
       JOIN    movies_actors ma
       ON      m.movie_id = ma.movie_id
       JOIN    actors a 
       ON      ma.actor_id = a.actor_id
       WHERE   a.name = $1 
       LIMIT 5;' USING searchValVar;
  ELSE
    -- Return films with similar genres
    RETURN QUERY EXECUTE
      'SELECT  m.title
       FROM    movies m,
               (SELECT genre, title 
               FROM   movies
               WHERE  title = $1) s
       WHERE   cube_enlarge(s.genre, 5, 18) @> m.genre AND s.title <> m.title
       ORDER BY cube_distance(m.genre, s.genre)
       LIMIT 5;' USING searchValVar;
  END IF;
END;

$$ LANGUAGE plpgsql;

-- Question #2
CREATE TABLE comments(
  comment_id SERIAL PRIMARY KEY,
  user_name text,
  comment_text text,
  movie_id integer 
);

-- Create index comment_text for faster searching
CREATE INDEX comment_text_searchable ON comments USING gin(to_tsvector('english', comment_text));

-- Extract keywords from the comments table
-- and cross-reference with actor's last names
-- to find the most talked about actors. This
-- solution utilizes TSVector and TSQuery
SELECT  a.name, count(a.name) as ref_count
FROM    actors a,
        comments c
WHERE   to_tsvector('english', c.comment_text) @@ to_tsquery('english', a.name)
GROUP BY a.name
ORDER BY ref_count desc;

