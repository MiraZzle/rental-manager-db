-- Autor: Matěj Foukal

-- 1. Zobrazení aktuálních vlastníků
select * from owners;
-- Přidání nového vlastníka
exec db_owner.new_owner('Test Owner', 'test.owner@example.com', '601000001');
select * from owners;

-- 2. Zobrazení bytů
select * from flats;
-- Přidání nového bytu přiřazeného existujícímu vlastníkovi
exec db_flat.new_flat('Testovaci 1, Praha', 70, 3, 1);
select * from flats;

-- 3. Zobrazení nájemníků
select * from tenants;
-- Přidání nového nájemníka
exec db_tenant.new_tenant('Test Tenant', 'test.tenant@example.com', '777123123');
select * from tenants;

-- 4. Vytvoření nové nájemní smlouvy
exec db_contract.new_contract(1, 1, DATE '2024-04-01', null, 14500);
select * from contracts;

-- 5. Neplatná smlouva (datum konce před datem začátku) – test validace
begin
  db_contract.new_contract(1, 2, DATE '2024-05-01', DATE '2024-03-01', 14000);
exception when others then dbms_output.put_line(sqlerrm);
end;
/

-- 6. Záznam platby ke smlouvě
exec db_payment.new_payment(1, DATE '2024-04-01', 14500, 'PAID');
select * from payments;

-- 7. Neplatná platba (částka 0) – test kontrol v proceduře
begin
  db_payment.new_payment(1, DATE '2024-04-01', 0, 'PAID');
exception when others then dbms_output.put_line(sqlerrm);
end;
/

-- 8. Založení žádosti a její následné řešení
exec db_request.new_request(1, 1, 'Zásuvka nefunguje.', 'NEW');
select * from requests;

-- 9. Přidání zaměstnance
exec db_employee.new_employee('Test Employee', 'Elektrikář', 'test.emp@example.com');
select * from employees;

-- 10. Přidání servisní společnosti
exec db_service_company.new_company('Test Services', 'contact@testservices.cz', '602998877');
select * from service_companies;

-- 11. Přidání servisního zásahu na žádost
exec db_service_action.new_action(1, 1, 1, DATE '2024-04-05', 'Oprava provedena a zaznamenána.');
select * from service_actions;

-- 12. Kontrola pohledů (VIEW) pro ověření funkčnosti systému
select * from active_contracts;
select * from unpaid_payments;
select * from open_requests;
select * from employee_actions;
select * from contract_payment_summary;

-- 13. Ověření výstupu funkcí
-- Adresa bytu podle ID
select db_flat.get_flat_address(1) as address from dual;
-- Jméno vlastníka podle ID
select db_owner.get_owner_name(1) as owner from dual;
-- Celkem zaplacené nájemné
select db_payment.get_total_paid(1) as paid from dual;
-- Počet aktivních smluv k bytu
select db_contract.get_active_contract_count(1) as count from dual;

-- 14. Komplexní: více plateb ke smlouvě, ověření výsledku
exec db_payment.new_payment(1, DATE '2024-05-01', 14500, 'PAID');
exec db_payment.new_payment(1, DATE '2024-06-01', 14500, 'PAID');
select db_payment.get_total_paid(1) as total_paid_for_contract_1 from dual;

-- 15. Komplexní: více žádostí k jednomu bytu, ověření otevřených
exec db_request.new_request(1, 1, 'Rozbité okno.', 'NEW');
exec db_request.new_request(1, 1, 'Nejde topení.', 'IN_PROGRESS');
select db_request.count_open_requests(1) as unresolved_requests_for_flat_1 from dual;

-- 16. Komplexní: více servisních zásahů k jedné žádosti
exec db_service_action.new_action(1, 1, 1, DATE '2024-04-10', 'Kontrola funkčnosti');
exec db_service_action.new_action(1, 1, 1, DATE '2024-04-15', 'Finální oprava');
select db_service_action.get_action_count(1) as action_count_for_request_1 from dual;

-- 17. Komplexní: nájemník + byt + smlouva + platba + ověření ve view
exec db_tenant.new_tenant('Nested Flow', 'nested@example.com', '601777000');
exec db_flat.new_flat('Nestedova 10, Praha', 68, 2, 1);
exec db_contract.new_contract(8, 8, DATE '2024-04-01', null, 16500);
exec db_payment.new_payment(8, DATE '2024-04-05', 16500, 'PAID');
select * from contract_payment_summary where contract_id = 8;

-- 18. Kompletní životní cyklus nájmu: založení, platby, žádost, servis, shrnutí
exec db_owner.new_owner('Lifecycle Owner', 'owner.lifecycle@example.com', '601999000');
exec db_flat.new_flat('Lifecycleova 99, Praha', 90, 4, 8);
exec db_tenant.new_tenant('Lifecycle Tenant', 'tenant.lifecycle@example.com', '777888999');
exec db_contract.new_contract(9, 9, DATE '2024-01-01', null, 19000);
exec db_payment.new_payment(9, DATE '2024-01-01', 19000, 'PAID');
exec db_payment.new_payment(9, DATE '2024-02-01', 19000, 'PAID');
exec db_payment.new_payment(9, DATE '2024-03-01', 19000, 'DUE');
exec db_request.new_request(9, 9, 'Rozbitý zámek.', 'NEW');
exec db_employee.new_employee('Lifecycle Repairman', 'Zámečník', 'locksmith@example.com');
exec db_service_company.new_company('LockFix s.r.o.', 'contact@lockfix.cz', '603444333');
exec db_service_action.new_action(8, 8, 8, DATE '2024-03-05', 'Zámek vyměněn a přenastaven');

-- Ověření zaplacených částek a viditelnosti
select db_payment.get_total_paid(9) as total_paid_lifecycle from dual;
select * from active_contracts where flat_address like '%Lifecycleova%';
select * from open_requests where flat like '%Lifecycleova%';
select * from employee_actions where employee = 'Lifecycle Repairman';

-- Ukončení smlouvy
exec db_contract.terminate_contract(9, DATE '2024-05-31');
select * from contracts where contract_id = 9;

-- Změna výše nájemného (po ukončení smlouvy)
exec db_contract.change_rent(9, 21000);
select * from contracts where contract_id = 9;

-- 19. Konfliktní smlouva pro stejný byt (měla by skončit chybou)
begin
  db_contract.new_contract(9, 2, DATE '2024-03-01', DATE '2024-12-01', 21000);
exception when others then dbms_output.put_line('Očekávaná chyba: ' || sqlerrm);
end;
/

-- 20. Sekvenční nájemníci – tři smlouvy po sobě
exec db_tenant.new_tenant('Speed One', 'one@example.com', '601000111');
exec db_tenant.new_tenant('Speed Two', 'two@example.com', '601000112');
exec db_tenant.new_tenant('Speed Three', 'three@example.com', '601000113');
exec db_flat.new_flat('Speedova 7, Brno', 55, 2, 2);
exec db_contract.new_contract(10, 10, DATE '2024-01-01', DATE '2024-03-31', 12000);
exec db_contract.new_contract(10, 11, DATE '2024-04-01', DATE '2024-06-30', 13000);
exec db_contract.new_contract(10, 12, DATE '2024-07-01', null, 13500);
select * from contracts where flat_id = 10 order by start_date;

-- 21. Integrace napříč systémem – výpisy z view
select * from contract_payment_summary order by total_paid desc;
select * from unpaid_payments where status = 'DUE';
select db_contract.get_active_contract_count(10) as active_contracts_speedova from dual;

-- 22. Negativní test – pokus o smazání vlastníka s navázaným bytem (FK porušen)
begin
  delete from owners where owner_id = 1;
exception when others then dbms_output.put_line('Očekávaná chyba (FK): ' || sqlerrm);
end;
/

-- 23. Vložení bytu s neexistujícím vlastníkem (FK porušen)
begin
  db_flat.new_flat('Nonexistentova 1, Praha', 45, 1, 999);
exception when others then dbms_output.put_line('Očekávaná chyba (neexistující vlastník): ' || sqlerrm);
end;
/

-- 24. Vložení smlouvy k neexistujícímu bytu
begin
  db_contract.new_contract(999, 1, DATE '2024-06-01', null, 13000);
exception when others then dbms_output.put_line('Očekávaná chyba (neexistující byt): ' || sqlerrm);
end;
/

-- 25. Neplatný status platby
begin
  db_payment.new_payment(1, DATE '2024-07-01', 15000, 'INVALID_STATUS');
exception when others then dbms_output.put_line('Očekávaná chyba (neplatný status): ' || sqlerrm);
end;
/

-- 26. Neplatný status žádosti
begin
  db_request.new_request(1, 1, 'Chybný vstup', 'INVALID');
exception when others then dbms_output.put_line('Očekávaná chyba (neplatný status): ' || sqlerrm);
end;
/

-- 27. Servisní zásah s neexistujícím zaměstnancem a společností
begin
  db_service_action.new_action(1, 999, 999, DATE '2024-04-01', 'Chybné odkazy');
exception when others then dbms_output.put_line('Očekávaná chyba (FK odkazy): ' || sqlerrm);
end;
/

-- 28. Edge case – žádost založená a vyřízená hned
exec db_request.new_request(2, 2, 'Zatéká stropem.', 'NEW');
exec db_service_action.new_action(9, 1, 1, DATE '2024-04-15', 'Opraveno v den hlášení');
select * from open_requests where request_id = 9;
select db_service_action.get_action_count(9) from dual;

-- 29. Business check – výpis všech bytů a počtu aktivních smluv
select
  f.flat_id,
  f.address,
  db_owner.get_owner_name(f.owner_id) as owner,
  (select count(*) from contracts c where c.flat_id = f.flat_id and (c.end_date is null or c.end_date > sysdate)) as active_contracts
from flats f;

-- 30. Business check – nájemníci s nejvíce aktivními žádostmi
select
  r.tenant_id,
  db_tenant.get_tenant_name(r.tenant_id) as tenant,
  count(*) as open_requests
from requests r
where r.status in ('NEW', 'IN_PROGRESS')
group by r.tenant_id
order by open_requests desc;