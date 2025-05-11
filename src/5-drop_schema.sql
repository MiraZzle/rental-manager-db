-- Drop all Rental Manager database objects

-- Drop Views
begin
  execute immediate 'drop view active_contracts';
  execute immediate 'drop view unpaid_payments';
  execute immediate 'drop view open_requests';
  execute immediate 'drop view employee_actions';
  execute immediate 'drop view contract_payment_summary';
exception when others then null;
end;
/

-- Drop Packages
begin
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

-- Drop Sequences
begin
  execute immediate 'drop sequence owner_id_seq';
  execute immediate 'drop sequence tenant_id_seq';
  execute immediate 'drop sequence flat_id_seq';
  execute immediate 'drop sequence contract_id_seq';
  execute immediate 'drop sequence payment_id_seq';
  execute immediate 'drop sequence request_id_seq';
  execute immediate 'drop sequence employee_id_seq';
  execute immediate 'drop sequence company_id_seq';
  execute immediate 'drop sequence action_id_seq';
exception when others then null;
end;
/

-- Drop Triggers
begin
  execute immediate 'drop trigger owners_insert';
  execute immediate 'drop trigger tenants_insert';
  execute immediate 'drop trigger flats_insert';
  execute immediate 'drop trigger contracts_insert';
  execute immediate 'drop trigger payments_insert';
  execute immediate 'drop trigger requests_insert';
  execute immediate 'drop trigger employees_insert';
  execute immediate 'drop trigger service_companies_insert';
  execute immediate 'drop trigger service_actions_insert';
exception when others then null;
end;
/

-- Drop Tables (must be in dependency order)
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
exception when others then null;
end;
/
