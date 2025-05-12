-- Autor: Matěj Foukal

-- flats.owner_id
create index ix_flats_owner_id on flats(owner_id);

-- contracts.flat_id, contracts.tenant_id
create index ix_contracts_flat_id on contracts(flat_id);
create index ix_contracts_tenant_id on contracts(tenant_id);

-- payments.contract_id
create index ix_payments_contract_id on payments(contract_id);

-- requests.flat_id, requests.tenant_id
create index ix_requests_flat_id on requests(flat_id);
create index ix_requests_tenant_id on requests(tenant_id);

-- service_actions.request_id, employee_id, company_id
create index ix_service_actions_request_id on service_actions(request_id);
create index ix_service_actions_employee_id on service_actions(employee_id);
create index ix_service_actions_company_id on service_actions(company_id);

-- owners.email
create index ix_owners_email on owners(email);

-- tenants.email
create index ix_tenants_email on tenants(email);

-- payments.status
create index ix_payments_status on payments(status);

-- requests.status
create index ix_requests_status on requests(status);

-- service_companies.name
create index ix_service_companies_name on service_companies(company_name);
