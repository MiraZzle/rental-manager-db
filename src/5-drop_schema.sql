-- Author: Matěj Foukal

-- Drop pohledy
begin
  execute immediate 'drop view active_contracts';
  execute immediate 'drop view unpaid_payments';
  execute immediate 'drop view open_requests';
  execute immediate 'drop view employee_actions';
  execute immediate 'drop view contract_payment_summary';
exception when others then null;
end;
/

-- Drop package
begin
  execute immediate 'drop package db_person';
  execute immediate 'drop package db_owner';
  execute immediate 'drop package db_tenant';
  execute immediate 'drop package db_flat';
  execute immediate 'drop package db_contract';
  execute immediate 'drop package db_payment';
  execute immediate 'drop package db_request';
  execute immediate 'drop package db_employee';
  execute immediate 'drop package db_service_company';
  execute immediate 'drop package db_service_action';
exception when others then null;
end;
/

-- Drop sekvence
begin
  execute immediate 'drop sequence person_id_seq';
  execute immediate 'drop sequence flat_id_seq';
  execute immediate 'drop sequence contract_id_seq';
  execute immediate 'drop sequence payment_id_seq';
  execute immediate 'drop sequence request_id_seq';
  execute immediate 'drop sequence company_id_seq';
  execute immediate 'drop sequence action_id_seq';
exception when others then null;
end;
/

-- Drop triggery
begin
  execute immediate 'drop trigger contracts_insert';
  execute immediate 'drop trigger payments_insert';
  execute immediate 'drop trigger requests_insert';
exception when others then null;
end;
/

-- Drop tabulky
-- !Pozn: tabulky musí být dropnuty v tomto pořadí, jinak dojde k chybě kvůli cizím klíčům
begin
  execute immediate 'drop table service_actions';
  execute immediate 'drop table requests';
  execute immediate 'drop table payments';
  execute immediate 'drop table contracts';
  execute immediate 'drop table flats';
  execute immediate 'drop table employees';
  execute immediate 'drop table service_companies';
  execute immediate 'drop table owners';
  execute immediate 'drop table tenants';
  execute immediate 'drop table persons';
exception when others then null;
end;
/
