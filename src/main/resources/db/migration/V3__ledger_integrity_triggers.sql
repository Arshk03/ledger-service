CREATE FUNCTION check_transfer_balanced() RETURNS trigger AS $$
DECLARE
  total BIGINT;
BEGIN
  SELECT COALESCE(SUM(amount_cents), 0) INTO total
  FROM ledger_entries
  WHERE transfer_id = NEW.transfer_id;

  IF total <> 0 THEN
    RAISE EXCEPTION 'Transfer % is unbalanced: entries sum to %', NEW.transfer_id, total;
  END IF;

  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER transfer_must_balance
AFTER INSERT ON ledger_entries
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW
EXECUTE FUNCTION check_transfer_balanced();

CREATE FUNCTION forbid_entry_changes() RETURNS trigger AS $$
BEGIN
  RAISE EXCEPTION 'ledger_entries is append-only: % is not allowed', TG_OP;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ledger_entries_append_only
BEFORE UPDATE OR DELETE ON ledger_entries
FOR EACH ROW
EXECUTE FUNCTION forbid_entry_changes();