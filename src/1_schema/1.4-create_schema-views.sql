-- Autor: Matěj Foukal

-- View na všechny aktivní nájemní smlouvy včetně údajů o bytě a nájemníkovi
create or replace view active_contracts as
select
  c.contract_id,
  f.address as flat_address,
  db_owner.get_owner_name(f.owner_id) as owner_name,
  db_tenant.get_tenant_name(c.tenant_id) as tenant_name,
  c.start_date,
  c.end_date,
  c.rent_amount
from contracts c
  join flats f on c.flat_id = f.flat_id
where c.end_date is null or c.end_date > sysdate;

-- View na všechny platby, které jsou ve stavu DUE nebo LATE
create or replace view unpaid_payments as
select
  p.payment_id,
  db_tenant.get_tenant_name(c.tenant_id) as tenant_name,
  db_flat.get_flat_address(c.flat_id) as flat,
  p.payment_date,
  p.amount,
  p.status
from payments p
  join contracts c on p.contract_id = c.contract_id
where p.status in ('DUE', 'LATE');

-- View na všechny nevyřešené žádosti (stav je NEW nebo IN_PROGRESS)
create or replace view open_requests as
select
  r.request_id,
  db_tenant.get_tenant_name(r.tenant_id) as tenant_name,
  db_flat.get_flat_address(r.flat_id) as flat,
  r.description,
  r.request_date,
  r.status
from requests r
where r.status in ('NEW', 'IN_PROGRESS');

-- View na všechny servisní akce rozdělené podle zaměstnance
create or replace view employee_actions as
select
  s.action_id,
  db_employee.get_employee_name(s.employee_id) as employee,
  db_service_company.get_company_name(s.company_id) as company,
  s.action_date,
  s.note
from service_actions s;

-- View na celkové zaplacené částky k jednotlivým smlouvám
create or replace view contract_payment_summary as
select
  c.contract_id,
  db_flat.get_flat_address(c.flat_id) as flat,
  db_tenant.get_tenant_name(c.tenant_id) as tenant,
  db_payment.get_total_paid(c.contract_id) as total_paid
from contracts c;
