CREATE                      TABLE OPENBILL_INVOICES (
  id                        UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  date                      timestamp without time zone not null,
  number                    character varying(256) not null,
  title                     character varying(256) not null,
  destination_account_id    UUID not null,
  amount_cents              numeric not null default 0,
  amount_currency           char(3) not null default 'USD',
  created_at                timestamp without time zone default current_timestamp,
  updated_at                timestamp without time zone default current_timestamp,
  foreign key (destination_account_id) REFERENCES OPENBILL_ACCOUNTS (id) ON DELETE RESTRICT
);
CREATE UNIQUE INDEX index_invoices_on_id ON OPENBILL_INVOICES USING btree (id);
CREATE UNIQUE INDEX index_invoices_on_number ON OPENBILL_INVOICES USING btree (number);
