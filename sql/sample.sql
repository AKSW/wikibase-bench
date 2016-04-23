-- We create a table to store ids for entities with six or more claims.
CREATE TABLE entities_with_six_claims ( entity_id text );

-- We fill this table.
INSERT INTO entities_with_six_claims
SELECT entity_id
FROM claims
WHERE valueitem IS NOT NULL
GROUP BY entity_id
HAVING count(claim_id) >= 6;

-- We create another table to store 500 random entities ids of entities
-- with six or more claims.
CREATE TABLE some_entities_with_six_claims ( entity_id text );

-- We fill this second table.
INSERT INTO some_entities_with_six_claims
SELECT entity_id
FROM entities_with_six_claims
￼ORDER BY random()
LIMIT 500;

-- We copy the related claims to this 500 entities to the STDOUT. This is
-- no much data so we will process it with a ruby script.
COPY
  (
    SELECT claims.entity_id, claims.property, claims.valueitem
    FROM some_entities_with_six_claims, claims
    WHERE
      claims.entity_id = some_entities_with_six_claims.entity_id AND
      valueitem IS NOT NULL
  )
TO STDOUT WITH CSV;
