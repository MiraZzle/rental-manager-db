create sequence flat_id_seq start with 1 increment by 1;
create sequence owner_id_seq start with 1 increment by 1;
create sequence tenant_id_seq start with 1 increment by 1;
create sequence contract_id_seq start with 1 increment by 1;
create sequence payment_id_seq start with 1 increment by 1;
create sequence request_id_seq start with 1 increment by 1;
create sequence employee_id_seq start with 1 increment by 1;
create sequence company_id_seq start with 1 increment by 1;
create sequence action_id_seq start with 1 increment by 1;

create or replace trigger owners_insert
before insert on owners
for each row
begin
  select owner_id_seq.nextval into :new.owner_id from dual;
end;
/

create or replace trigger tenants_insert
before insert on tenants
for each row
begin
  select tenant_id_seq.nextval into :new.tenant_id from dual;
end;
/

create or replace trigger flats_insert
before insert on flats
for each row
begin
  select flat_id_seq.nextval into :new.flat_id from dual;
end;
/

create or replace trigger contracts_insert
before insert on contracts
for each row
begin
  if (:new.end_date is not null and :new.start_date > :new.end_date) then
    raise_application_error(-20101, 'Start date must be before or equal to end date.');
  end if;

  select contract_id_seq.nextval into :new.contract_id from dual;
end;
/

create or replace trigger payments_insert
before insert on payments
for each row
begin
  if (:new.amount <= 0) then
    raise_application_error(-20102, 'Payment amount must be greater than 0.');
  end if;

  if (:new.status not in ('PAID', 'DUE', 'LATE')) then
    raise_application_error(-20103, 'Invalid payment status.');
  end if;

  select payment_id_seq.nextval into :new.payment_id from dual;
end;
/

create or replace trigger requests_insert
before insert on requests
for each row
begin
  if (:new.status not in ('NEW', 'IN_PROGRESS', 'RESOLVED')) then
    raise_application_error(-20104, 'Invalid request status.');
  end if;

  select request_id_seq.nextval into :new.request_id from dual;
end;
/

create or replace trigger employees_insert
before insert on employees
for each row
begin
  select employee_id_seq.nextval into :new.employee_id from dual;
end;
/

create or replace trigger service_companies_insert
before insert on service_companies
for each row
begin
  select company_id_seq.nextval into :new.company_id from dual;
end;
/

create or replace trigger service_actions_insert
before insert on service_actions
for each row
begin
  select action_id_seq.nextval into :new.action_id from dual;
end;
/
