CREATE TABLE IF NOT EXISTS five_five_four_connected_entities (
  entity_a_id text,
  entity_b_id text,
  entity_c_id text,
  PRIMARY KEY (entity_a_id, entity_b_id, entity_c_id)
);

INSERT INTO five_five_four_connected_entities (entity_a_id, entity_b_id, entity_c_id)
SELECT DISTINCT
  entity_a.entity_id,
  entity_b.entity_id,
  entity_c.entity_id
FROM
  claims AS claims_ab,
  claims AS claims_bc,
  entities_claim_quantities AS entity_a,
  entities_claim_quantities AS entity_b,
  entities_claim_quantities AS entity_c
WHERE
  claims_ab.entity_id = entity_a.entity_id AND
  claims_ab.valueitem = entity_b.entity_id AND
  claims_bc.entity_id = entity_b.entity_id AND
  claims_bc.valueitem = entity_c.entity_id AND
  entity_a.claims >= 5 AND
  entity_b.claims >= 5 AND
  entity_c.claims >= 4;
