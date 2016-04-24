-- We create a table to store ids and quantities of claims.
CREATE TABLE IF NOT EXISTS entities_out_degree (
  claims int,
  entity_id text,
  PRIMARY KEY (claims, entity_id)
);

-- We fill this table.
INSERT INTO entities_out_degree (claims, entity_id)
SELECT count(claim_id), entity_id
FROM claims
WHERE valueitem IS NOT NULL
GROUP BY entity_id
HAVING count(claim_id) >= 4;
