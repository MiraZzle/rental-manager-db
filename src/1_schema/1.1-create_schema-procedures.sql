-- Autor: Matěj Foukal

-- ==============================================
-- OWNERS
-- ==============================================
-- Balíček pro správu vlastníků bytů
create or replace package db_owner is
  -- Vloží nového vlastníka
  procedure new_owner(p_name varchar2, p_email varchar2, p_phone varchar2);
  -- Vrátí jméno vlastníka podle ID
  function get_owner_name(p_owner_id number) return varchar2;
end db_owner;
/

create or replace package body db_owner is
  procedure new_owner(p_name varchar2, p_email varchar2, p_phone varchar2) is
  begin
    insert into owners(owner_id, owner_name, email, phone)
    values (owner_id_seq.nextval, p_name, p_email, p_phone);
  end;

  function get_owner_name(p_owner_id number) return varchar2 is
    v_name varchar2(100);
  begin
    select owner_name into v_name from owners where owner_id = p_owner_id;
    return v_name;
  exception
    when no_data_found then
      return null;
  end;
end db_owner;
/

-- ==============================================
-- TENANTS
-- ==============================================
-- Balíček pro správu nájemníků
create or replace package db_tenant is
  -- Vloží nového nájemníka
  procedure new_tenant(p_name varchar2, p_email varchar2, p_phone varchar2);
  -- Vrátí jméno nájemníka podle ID
  function get_tenant_name(p_tenant_id number) return varchar2;
end db_tenant;
/

create or replace package body db_tenant is
  procedure new_tenant(p_name varchar2, p_email varchar2, p_phone varchar2) is
  begin
    insert into tenants(tenant_id, tenant_name, email, phone)
    values (tenant_id_seq.nextval, p_name, p_email, p_phone);
  end;

  function get_tenant_name(p_tenant_id number) return varchar2 is
    v_name varchar2(100);
  begin
    select tenant_name into v_name from tenants where tenant_id = p_tenant_id;
    return v_name;
  exception
    when no_data_found then
      return null;
  end;
end db_tenant;
/

-- ==============================================
-- FLATS
-- ==============================================
-- Balíček pro správu bytů
create or replace package db_flat is
  -- Vloží nový byt
  procedure new_flat(p_address varchar2, p_area number, p_rooms number, p_owner_id number);
  -- Vrátí adresu bytu podle ID
  function get_flat_address(p_flat_id number) return varchar2;
end db_flat;
/

create or replace package body db_flat is
  procedure new_flat(p_address varchar2, p_area number, p_rooms number, p_owner_id number) is
  begin
    insert into flats(flat_id, address, area, rooms, owner_id)
    values (flat_id_seq.nextval, p_address, p_area, p_rooms, p_owner_id);
  end;

  function get_flat_address(p_flat_id number) return varchar2 is
    v_address varchar2(255);
  begin
    select address into v_address from flats where flat_id = p_flat_id;
    return v_address;
  exception
    when no_data_found then
      return null;
  end;
end db_flat;
/

-- ==============================================
-- CONTRACTS
-- ==============================================
-- Balíček pro správu nájemních smluv
create or replace package db_contract is
  -- Vytvoří novou smlouvu k bytu a nájemníkovi
  procedure new_contract(p_flat_id number, p_tenant_id number, p_start date, p_end date, p_rent number);
  -- Ukončí smlouvu nastavením data ukončení
  procedure terminate_contract(p_contract_id number, p_end_date date);
  -- Prodlouží smlouvu na nové datum
  procedure extend_contract(p_contract_id number, p_new_end date);
  -- Změní částku nájmu ve smlouvě
  procedure change_rent(p_contract_id number, p_new_rent number);
  -- Vrátí počet aktivních smluv k bytu
  function get_active_contract_count(p_flat_id number) return number;
end db_contract;
/

create or replace package body db_contract is
  procedure new_contract(p_flat_id number, p_tenant_id number, p_start date, p_end date, p_rent number) is
  begin
    if p_end is not null and p_start > p_end then
      raise_application_error(-20101, 'Start date must be before end date.');
    end if;
    insert into contracts(contract_id, flat_id, tenant_id, start_date, end_date, rent_amount)
    values (contract_id_seq.nextval, p_flat_id, p_tenant_id, p_start, p_end, p_rent);
  end;

  procedure terminate_contract(p_contract_id number, p_end_date date) is
  begin
    update contracts
    set end_date = p_end_date
    where contract_id = p_contract_id;

    if sql%rowcount = 0 then
      raise_application_error(-20102, 'No such contract.');
    end if;
  end;

  procedure extend_contract(p_contract_id number, p_new_end date) is
    v_start date;
  begin
    select start_date into v_start from contracts where contract_id = p_contract_id;
    if v_start > p_new_end then
      raise_application_error(-20103, 'New end date must be after start.');
    end if;
    update contracts set end_date = p_new_end where contract_id = p_contract_id;
  end;

  procedure change_rent(p_contract_id number, p_new_rent number) is
  begin
    if p_new_rent <= 0 then
      raise_application_error(-20104, 'Rent must be positive.');
    end if;
    update contracts set rent_amount = p_new_rent where contract_id = p_contract_id;
  end;

  function get_active_contract_count(p_flat_id number) return number is
    v_count number;
  begin
    select count(*) into v_count from contracts
    where flat_id = p_flat_id and (end_date is null or end_date > sysdate);
    return v_count;
  end;
end db_contract;
/

-- ==============================================
-- PAYMENTS
-- ==============================================
-- Balíček pro správu plateb
create or replace package db_payment is
  -- Vloží novou platbu k dané smlouvě
  procedure new_payment(p_contract_id number, p_date date, p_amount number, p_status varchar2);
  -- Vrátí celkovou zaplacenou částku k dané smlouvě (pouze status 'PAID')
  function get_total_paid(p_contract_id number) return number;
end db_payment;
/

create or replace package body db_payment is
  procedure new_payment(p_contract_id number, p_date date, p_amount number, p_status varchar2) is
  begin
    if p_amount <= 0 then
      raise_application_error(-20102, 'Payment amount must be greater than zero.');
    end if;
    insert into payments(payment_id, contract_id, payment_date, amount, status)
    values (payment_id_seq.nextval, p_contract_id, p_date, p_amount, p_status);
  end;

  function get_total_paid(p_contract_id number) return number is
    v_total number;
  begin
    select sum(amount) into v_total
    from payments
    where contract_id = p_contract_id and status = 'PAID';
    return nvl(v_total, 0);
  end;
end db_payment;
/

-- ==============================================
-- REQUESTS
-- ==============================================
-- Balíček pro správu žádostí od nájemníků
create or replace package db_request is
  -- Vloží novou žádost o opravu či servis
  procedure new_request(p_flat_id number, p_tenant_id number, p_description varchar2, p_status varchar2);
  -- Vrátí počet aktuálně nevyřešených žádostí pro daný byt
  function count_open_requests(p_flat_id number) return number;
end db_request;
/

create or replace package body db_request is
  procedure new_request(p_flat_id number, p_tenant_id number, p_description varchar2, p_status varchar2) is
  begin
    insert into requests(request_id, flat_id, tenant_id, description, request_date, status)
    values (request_id_seq.nextval, p_flat_id, p_tenant_id, p_description, sysdate, p_status);
  end;

  function count_open_requests(p_flat_id number) return number is
    v_count number;
  begin
    select count(*) into v_count
    from requests
    where flat_id = p_flat_id and status != 'RESOLVED';
    return v_count;
  end;
end db_request;
/

-- ==============================================
-- EMPLOYEES
-- ==============================================
-- Balíček pro správu zaměstnanců provádějících servis
create or replace package db_employee is
  -- Vloží nového zaměstnance
  procedure new_employee(p_name varchar2, p_role varchar2, p_email varchar2);
  -- Vrátí jméno zaměstnance podle ID
  function get_employee_name(p_employee_id number) return varchar2;
end db_employee;
/

create or replace package body db_employee is
  procedure new_employee(p_name varchar2, p_role varchar2, p_email varchar2) is
  begin
    insert into employees(employee_id, employee_name, role, email)
    values (employee_id_seq.nextval, p_name, p_role, p_email);
  end;

  function get_employee_name(p_employee_id number) return varchar2 is
    v_name varchar2(100);
  begin
    select employee_name into v_name from employees where employee_id = p_employee_id;
    return v_name;
  exception
    when no_data_found then return null;
  end;
end db_employee;
/

-- ==============================================
-- SERVICE COMPANIES
-- ==============================================
-- Balíček pro správu servisních společností
create or replace package db_service_company is
  -- Vloží novou servisní společnost
  procedure new_company(p_name varchar2, p_email varchar2, p_phone varchar2);
  -- Vrátí název společnosti podle ID
  function get_company_name(p_company_id number) return varchar2;
end db_service_company;
/

create or replace package body db_service_company is
  procedure new_company(p_name varchar2, p_email varchar2, p_phone varchar2) is
  begin
    insert into service_companies(company_id, company_name, email, phone)
    values (company_id_seq.nextval, p_name, p_email, p_phone);
  end;

  function get_company_name(p_company_id number) return varchar2 is
    v_name varchar2(100);
  begin
    select company_name into v_name from service_companies where company_id = p_company_id;
    return v_name;
  exception
    when no_data_found then return null;
  end;
end db_service_company;
/

-- ==============================================
-- SERVICE ACTIONS
-- ==============================================
-- Balíček pro správu jednotlivých servisních zásahů
create or replace package db_service_action is
  -- Přidá nový servisní zásah (akci)
  procedure new_action(p_request_id number, p_employee_id number, p_company_id number, p_date date, p_note varchar2);
  -- Vrátí počet servisních akcí k dané žádosti
  function get_action_count(p_request_id number) return number;
end db_service_action;
/

create or replace package body db_service_action is
  procedure new_action(p_request_id number, p_employee_id number, p_company_id number, p_date date, p_note varchar2) is
  begin
    insert into service_actions(action_id, request_id, employee_id, company_id, action_date, note)
    values (action_id_seq.nextval, p_request_id, p_employee_id, p_company_id, p_date, p_note);
  end;

  function get_action_count(p_request_id number) return number is
    v_count number;
  begin
    select count(*) into v_count from service_actions where request_id = p_request_id;
    return v_count;
  end;
end db_service_action;
/
