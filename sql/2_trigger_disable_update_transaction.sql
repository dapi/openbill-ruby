-- Запрещаем удаление и какое-либо изменение transactions

CREATE OR REPLACE FUNCTION disable_update_transaction() RETURNS TRIGGER AS $disable_update_transaction$
BEGIN
  RAISE EXCEPTION 'Cannot update or delete transaction';
END

$disable_update_transaction$ LANGUAGE plpgsql;

CREATE TRIGGER disable_update_transaction
  BEFORE UPDATE OR DELETE ON OPENBILL_TRANSACTIONS FOR EACH ROW EXECUTE PROCEDURE disable_update_transaction();
