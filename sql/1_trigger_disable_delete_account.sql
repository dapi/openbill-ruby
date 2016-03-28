-- Запрещаем удаление и какое-либо изменение accounts

CREATE OR REPLACE FUNCTION disable_update_account() RETURNS TRIGGER AS $disable_update_account$
DECLARE
  query text;
BEGIN
  IF current_query() like 'insert into OPENBILL_TRANSACTIONS%' THEN
    RETURN NEW;
  ELSE
    RAISE EXCEPTION 'Cannot update directly update amount_cents and timestamps of account';
  END IF;
END

$disable_update_account$ LANGUAGE plpgsql;

CREATE TRIGGER disable_update_account
  BEFORE UPDATE ON OPENBILL_ACCOUNTS FOR EACH ROW EXECUTE PROCEDURE disable_update_account();

CREATE OR REPLACE FUNCTION disable_delete_account() RETURNS TRIGGER AS $disable_delete_account$
BEGIN
  RAISE EXCEPTION 'Cannot delete account';
END

$disable_delete_account$ LANGUAGE plpgsql;

CREATE TRIGGER disable_delete_account
  BEFORE DELETE ON OPENBILL_ACCOUNTS FOR EACH ROW EXECUTE PROCEDURE disable_delete_account();
