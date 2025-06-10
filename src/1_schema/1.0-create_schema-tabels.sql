-- Autor: Matěj Foukal

/*
  Rental Manager
  Aplikace eviduje byty, majitele, nájemníky, smlouvy, platby, servisní akce, zaměstnance a servisní společnosti.
  Vztahy mezi entitami reflektují životní cyklus nájemního vztahu a jeho správu.
*/

-- table osob
create table persons (
  person_id number(22)
    constraint persons_pk primary key,
  name varchar2(100 char) not null,
  email varchar2(100 char)
    constraint persons_uq_email unique,
  phone varchar2(20 char)
    constraint persons_uq_phone unique
);

-- table majitelů
create table owners (
  owner_id number(22)
    constraint owners_pk primary key,
  person_id number(22) not null
    constraint owners_fk_person references persons(person_id)
      on delete cascade,
  bank_account varchar2(50 char) not null
    constraint owners_uq_bank_account unique
);

-- table nájemníků
create table tenants (
  tenant_id number(22)
    constraint tenants_pk primary key,
  person_id number(22) not null
    constraint tenants_fk_person references persons(person_id)
      on delete cascade,
  notes varchar2(255 char)
);

-- table zaměstnanců
create table employees (
  employee_id number(22)
    constraint employees_pk
      primary key,
    person_id number(22) not null
    constraint employees_fk_person references persons(person_id)
      on delete cascade,
  role varchar2(50 char)
);

-- table bytů
create table flats (
  flat_id number(22)
    constraint flats_pk
      primary key,
  address varchar2(255 char) not null
    constraint flats_uq_address
      unique,
  area number(5,2) not null
    constraint check_flat_area
      check (area > 0),
  rooms number(2) not null
    constraint check_flat_rooms
      check (rooms > 0),
  owner_id number(22) not null
    constraint flats_fk_owner
      references owners(owner_id)
);

-- table smluv
create table contracts (
  contract_id number(22)
    constraint contracts_pk
      primary key,
  flat_id number(22) not null
    constraint contracts_fk_flat
      references flats(flat_id)
        on delete cascade,
  tenant_id number(22) not null
    constraint contracts_fk_tenant
      references tenants(tenant_id),
  start_date date not null,
  end_date date,
  rent_amount number(7,2) not null
    constraint check_rent_amount
      check (rent_amount > 0),
  constraint check_contract_dates
    check (end_date is null or start_date <= end_date),
  constraint contracts_uq
    unique(flat_id, tenant_id, start_date)
);

-- table plateb
create table payments (
  payment_id number(22)
    constraint payments_pk
      primary key,
  contract_id number(22) not null
    constraint payments_fk_contract
      references contracts(contract_id)
        on delete cascade,
  payment_date date not null,
  amount number(7,2) not null
    constraint check_payment_amount
      check (amount > 0),
  status char(10 char) default 'DUE' not null
    constraint check_payment_status
      check (status in ('PAID', 'DUE', 'LATE'))
);

-- table servisních společností
create table service_companies (
  company_id number(22)
    constraint service_companies_pk
      primary key,
  company_name varchar2(100 char) not null
    constraint service_companies_uq_name
      unique,
  email varchar2(100 char),
  phone varchar2(20 char)
);

-- table žádostí o servis
create table requests (
  request_id number(22)
    constraint requests_pk
      primary key,
  flat_id number(22) not null
    constraint requests_fk_flat
      references flats(flat_id)
        on delete cascade,
  tenant_id number(22) not null
    constraint requests_fk_tenant
      references tenants(tenant_id)
        on delete cascade,
  description varchar2(500 char) not null,
  request_date date default sysdate not null,
  status char(15 char) default 'NEW' not null
    constraint check_request_status
      check (status in ('NEW', 'IN_PROGRESS', 'RESOLVED'))
);

-- table servisních akcí
create table service_actions (
  action_id number(22)
    constraint service_actions_pk
      primary key,
  request_id number(22) not null
    constraint service_actions_fk_request
      references requests(request_id)
        on delete cascade,
  employee_id number(22)
    constraint service_actions_fk_employee
      references employees(employee_id),
  company_id number(22)
    constraint service_actions_fk_company
      references service_companies(company_id),
  action_date date not null,
  note varchar2(500 char)
);
