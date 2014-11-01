-- Question #1
CREATE OR REPLACE RULE delete_venues AS ON DELETE TO venues DO INSTEAD
  UPDATE venues 
  SET active = FALSE 
  WHERE venue_id = old.venue_id;

-- Question #2
SELECT * 
FROM   CROSSTAB(
  'SELECT   extract(year from starts) as year,
            extract(month from starts) as month,
            count(*)
   FROM     events
   GROUP BY year, month', 

  'SELECT   * 
   FROM     generate_series(1, 12)'
) AS (
  year int,
  jan int, feb int, mar int, apr int, may int, jun int,
  jul int, aug int, sep int, oct int, nov int, dec int
) ORDER BY year;

-- Question #3
SELECT *
FROM   CROSSTAB(
  'SELECT   extract(week from starts) as week,
            extract(dow from starts) as dow,
            count(*)
   FROM     events
   GROUP BY week, dow',

   'SELECT  *
    FROM    generate_series(0, 6)'
) AS (
  week int,
  "Sun" int, "Mon" int, "Tue" int, "Wed" int, "Thur" int, "Fri" int, "Sat" int
) ORDER BY week;
             
