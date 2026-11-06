CREATE VIEW account_balances AS
SELECT a.id, a.name, COALESCE(SUM(e.amount_cents), 0) AS balance_cents
FROM accounts a
LEFT JOIN ledger_entries e ON e.account_id = a.id
GROUP BY a.id, a.name;