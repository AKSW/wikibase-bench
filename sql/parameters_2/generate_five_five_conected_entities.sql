CREATE TABLE IF NOT EXISTS five_five_connected_entities (
  entity_a_id text,
  entity_b_id text,
  PRIMARY KEY (entity_a_id, entity_b_id)
);

INSERT INTO five_five_connected_entities (entity_a_id, entity_b_id)
SELECT DISTINCT
  entity_a.entity_id,
  entity_b.entity_id
FROM
  claims,
  entities_claim_quantities AS entity_a,
  entities_claim_quantities AS entity_b
WHERE
  claims.entity_id = entity_a.entity_id AND
  claims.valueitem = entity_b.entity_id AND
  entity_a.claims >= 5 AND
  entity_b.claims >= 5;
