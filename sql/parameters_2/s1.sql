-- We create a table to store ids and quantities of claims.
CREATE TABLE IF NOT EXISTS entities_claim_quantities (
  claims int,
  entity_id text,
  PRIMARY KEY (claims, entity_id)
);

-- We fill this table.
INSERT INTO entities_claim_quantities (claims, entity_id)
SELECT count(claim_id), entity_id
FROM claims
WHERE valueitem IS NOT NULL
GROUP BY entity_id
HAVING count(claim_id) >= 4;

-- We create another table to store 500 random entities ids of entities
-- with six or more claims.
CREATE TABLE IF NOT EXISTS some_entity_pairs (
  entity_a_id text,
  entity_b_id text,
  claim_id text,
  property text
);

-- We fill this second table.
INSERT INTO some_entity_pairs (entity_a_id, entity_b_id, claim_id, property)
SELECT
  a.entity_id,
  b.entity_id,
  claims.claim_id,
  claims.property
FROM
  entities_claim_quantities AS a,
  entities_claim_quantities AS b,
  claims
WHERE
  a.entity_id = claims.entity_id AND
  b.entity_id = claims.valueitem AND
  a.claims >= 5 AND
  a.claims >= 4
￼ORDER BY random()
LIMIT 500;
