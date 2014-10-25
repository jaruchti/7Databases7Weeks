Answers to the exercises given in Day #1 

1)
SELECT e.title, c.country_name
FROM   events e
JOIN   venues v
ON     e.venue_id = v.venue_id
JOIN   countries c
ON     v.country_code = c.country_code
WHERE  e.title = 'LARP Club';

2)
ALTER TABLE venues ADD COLUMN active BOOLEAN DEFAULT TRUE;
