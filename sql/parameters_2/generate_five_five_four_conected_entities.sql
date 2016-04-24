CREATE TABLE IF NOT EXISTS five_five_four_connected_entities (
  entity_a_id text,
  entity_b_id text,
  entity_c_id text,
  PRIMARY KEY (entity_a_id, entity_b_id, entity_c_id)
);

INSERT INTO five_five_four_connected_entities (entity_a_id, entity_b_id, entity_c_id)
SELECT DISTINCT
  entity_a.entity_id,
  entity_b.entity_a_id,
  entity_b.entity_b_id
FROM
  claims,
  entities_claim_quantities AS entity_a,
  five_four_connected_entities AS entity_b
WHERE
  claims.entity_id = entity_a.entity_id AND
  claims.valueitem = entity_b.entity_a_id AND
  entity_a.claims >= 5;
