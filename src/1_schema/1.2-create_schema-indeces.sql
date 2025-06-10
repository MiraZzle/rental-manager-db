-- Autor: Matěj Foukal

-- flats.owner_id
create index ix_flats_owner_id on flats(owner_id);

-- contracts.tenant_id
create index ix_contracts_tenant_id on contracts(tenant_id);

-- requests.tenant_id
create index ix_requests_tenant_id on requests(tenant_id);

-- service_actions.request_id
create index ix_service_actions_request_id on service_actions(request_id);

-- service_actions.employee_id
create index ix_service_actions_employee_id on service_actions(employee_id);

-- service_actions.company_id
create index ix_service_actions_company_id on service_actions(company_id);

-- comp index on flat_id, start_date, end_date
create index ix_contracts_flat_dates on contracts(flat_id, start_date, end_date);

-- comp index on contract_id, payment_date
create index ix_payments_contract_date on payments(contract_id, payment_date);

-- comp index on flat_id, request_date
create index ix_requests_flat_date on requests(flat_id, request_date);

-- comp index on contracts start_date, end_date
create index ix_contracts_dates on contracts(start_date, end_date);

-- status indexy
create index ix_payments_status on payments(status);
create index ix_requests_status on requests(status);