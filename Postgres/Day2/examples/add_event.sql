-- Book example of a stared procedure to add an event to the events table.
CREATE OR REPLACE FUNCTION add_event( title text, starts timestamp, ends timestamp, venue text, postal varchar(9), country char(2) )
RETURNS boolean AS $$
DECLARE
  did_insert boolean := false;
  found_count integer;
  the_venue_id integer;
BEGIN
  SELECT venue_id into the_venue_id
  FROM   venues v
  WHERE  v.postal_code = postal AND v.country_code = country AND v.name ILIKE venue
  LIMIT 1;

  If the_venue_id IS NULL THEN
    INSERT INTO venues(name, postal_code, country_code)
    VALUES (venue, postal, country)
    RETURNING venue_id INTO the_venue_id;

    did_insert := true;
  END IF;

  RAISE NOTICE 'Venue found %', the_venue_id;

  INSERT INTO events (title, starts, ends, venue_id) 
  VALUES (title, starts, ends, the_venue_id);

  RETURN did_insert;
END;

$$ LANGUAGE plpgsql;
