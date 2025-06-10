-- Autor: Matěj Foukal

-- Zobrazení všech vlastníků
select * from owners;

-- Přidání nového vlastníka
exec db_owner.new_owner('Test Owner', 'test.owner@example.com', '601000001', '999888777/0800');
select * from owners;

-- Změna kontaktních údajů
exec db_owner.update_contact_info(1, 'updated@example.com', '123456789');
select * from owners where owner_id = 1;

-- Ověření chyby při aktualizaci neexistujícího vlastníka
begin
  db_owner.update_contact_info(999, 'fail@example.com', '000000000');
exception
  when others then dbms_output.put_line('Očekávaná chyba: Owner with ID 999 not found.');
end;
/

-- Pokus o smazání vlastníka s bytem – očekáváme chybu: "Cannot delete owner. They still own..."
begin
  db_owner.delete_owner(1);
exception
  when others then dbms_output.put_line('Očekávaná chyba: Cannot delete owner. They still own...');
end;
/

-- Přidání nového nájemníka
exec db_tenant.new_tenant('Test Tenant', 'test.tenant@example.com', '777123123');
select * from tenants;

-- Změna kontaktních údajů nájemníka
exec db_tenant.update_contact_info(1, 'new.tenant@example.com', '123321123');

-- Pokus o aktualizaci neexistujícího nájemníka – očekávaná chyba
begin
  db_tenant.update_contact_info(999, 'no@example.com', '999');
exception
  when others then dbms_output.put_line('Očekávaná chyba: Tenant with ID 999 not found.');
end;
/

-- Pokus o smazání nájemníka se smlouvou – očekávaná chyba
begin
  db_tenant.delete_tenant(1);
exception
  when others then dbms_output.put_line('Očekávaná chyba: Cannot delete tenant. They have ... contract(s).');
end;
/

-- Vložení nového bytu
exec db_flat.new_flat('Testovaci 1, Praha', 70, 3, 1);
select * from flats;

-- Pokus o přiřazení neexistujícího vlastníka – očekávaná chyba
begin
  db_flat.reassign_flat(1, 999);
exception
  when others then dbms_output.put_line('Očekávaná chyba: New owner with ID 999 does not exist.');
end;
/

-- Pokus o přiřazení neexistujícího bytu – očekávaná chyba
begin
  db_flat.reassign_flat(999, 1);
exception
  when others then dbms_output.put_line('Očekávaná chyba: Flat with ID 999 does not exist.');
end;
/

-- Vložení nové smlouvy
exec db_contract.new_contract(1, 1, DATE '2024-11-01', null, 15000);
select * from contracts;

-- Pokus o vložení smlouvy s neplatným rozsahem dat – očekávaná chyba
begin
  db_contract.new_contract(1, 1, DATE '2024-05-01', DATE '2024-04-01', 14000);
exception
  when others then dbms_output.put_line('Očekávaná chyba: Start date must be before or equal to end date.');
end;
/

-- Ukončení smlouvy
exec db_contract.terminate_contract(1, DATE '2024-06-30');

-- Pokus o ukončení neexistující smlouvy – očekávaná chyba
begin
  db_contract.terminate_contract(999, DATE '2024-06-30');
exception
  when others then dbms_output.put_line('Očekávaná chyba: No such contract.');
end;
/

-- Změna výše nájemného
exec db_contract.change_rent(1, 15500);

-- Neplatná změna nájemného – očekávaná chyba
begin
  db_contract.change_rent(1, -500);
exception
  when others then dbms_output.put_line('Očekávaná chyba: Rent must be positive.');
end;
/

-- Vložení nové platby
exec db_payment.new_payment(1, DATE '2024-01-01', 15500, 'PAID');

-- Pokus o vložení platby s nulovou částkou – očekávaná chyba
begin
  db_payment.new_payment(1, DATE '2024-01-01', 0, 'PAID');
exception
  when others then dbms_output.put_line('Očekávaná chyba: Payment amount must be greater than zero.');
end;
/

-- Neplatný status platby – očekávaná chyba
begin
  db_payment.new_payment(1, DATE '2024-01-01', 10000, 'FOO');
exception
  when others then dbms_output.put_line('Očekávaná chyba: Invalid payment status: FOO');
end;
/

-- Změna statusu platby
exec db_payment.update_payment_status(1, 'LATE');

-- Pokus o změnu statusu neexistující platby – očekávaná chyba
begin
  db_payment.update_payment_status(999, 'PAID');
exception
  when others then dbms_output.put_line('Očekávaná chyba: Payment with ID 999 does not exist.');
end;
/

-- Vložení nové žádosti
exec db_request.new_request(1, 1, 'Netopí radiátor.');

-- Změna statusu žádosti
exec db_request.update_request_status(1, 'IN_PROGRESS');

-- Neplatný status – očekávaná chyba
begin
  db_request.update_request_status(1, 'HOTOVO');
exception
  when others then dbms_output.put_line('Očekávaná chyba: Invalid request status: HOTOVO');
end;
/

-- Přidání zaměstnance a servisní firmy
exec db_employee.new_employee('Test Technic', 'technician@example.com', '777555666', 'Údržbář');
exec db_service_company.new_company('TestServ', 'kontakt@testserv.cz', '604404404');

-- Přiřazení servisní akce
exec db_request.assign_service(1, 1, 1, 'Oprava topení.');

-- Funkce: jméno vlastníka
select db_owner.get_owner_name(1) as jmeno_vlastnika from dual;

-- Funkce: adresa bytu
select db_flat.get_flat_address(1) as adresa_bytu from dual;

-- Funkce: aktuální nájemník
select db_flat.get_current_tenant_name(1) as najemnik from dual;

-- Funkce: celkově zaplaceno
select db_payment.get_total_paid(1) as celkem_zaplaceno from dual;

-- Funkce: počet aktivních smluv
select db_contract.get_active_contract_count(1) as aktivni_smlouvy from dual;

-- Funkce: dlužná částka
select db_payment.get_outstanding_balance(1) as dluzna_castka from dual;

-- Funkce: otevřené žádosti
select db_request.count_open_requests(1) as otevrene_zadosti from dual;

-- Funkce: počet servisních akcí
select db_service_action.get_action_count(1) as pocet_akci from dual;

-- Ověření pohledů
select * from active_contracts;
select * from unpaid_payments;
select * from open_requests;
select * from employee_actions;
select * from contract_payment_summary;

-- Více plateb ke smlouvě a ověření funkce
exec db_payment.new_payment(1, DATE '2024-05-01', 14500, 'PAID');
exec db_payment.new_payment(1, DATE '2024-06-01', 14500, 'PAID');
select db_payment.get_total_paid(1) as celkem_zaplaceno_pro_smlouvu_1 from dual;

-- Více žádostí k bytu
exec db_request.new_request(1, 1, 'Rozbité okno.');
exec db_request.new_request(1, 1, 'Netopí topení.');
select db_request.count_open_requests(1) as otevrene_zadosti_pro_byt_1 from dual;

-- Více servisních zásahů k žádosti
exec db_service_action.new_action(1, 1, 1, DATE '2024-04-10', 'První kontrola');
exec db_service_action.new_action(1, 1, 1, DATE '2024-04-15', 'Druhá kontrola');
select db_service_action.get_action_count(1) as akce_na_zadost_1 from dual;

-- Kompletní nájemní tok (nový nájemník, byt, smlouva, platby, servis)
exec db_tenant.new_tenant('Komplet Tok', 'komplet@example.com', '601800000');
exec db_flat.new_flat('Tokova 1, Praha', 60, 2, 1);
-- Vložení smlouvy
exec db_contract.new_contract(8, 8, DATE '2024-04-01', null, 16500);

-- Použití ID právě vložené smlouvy
declare
  v_contract_id contracts.contract_id%type;
begin
  v_contract_id := contract_id_seq.currval;
  db_payment.new_payment(v_contract_id, DATE '2024-04-05', 16500, 'PAID');
end;
/

select * from contract_payment_summary where contract_id = 8;

-- Založení nájemního vztahu se třemi po sobě jdoucími nájemníky
exec db_tenant.new_tenant('Sekvence 1', 's1@example.com', '601000111');
exec db_tenant.new_tenant('Sekvence 2', 's2@example.com', '601000112');
exec db_tenant.new_tenant('Sekvence 3', 's3@example.com', '601000113');
exec db_flat.new_flat('Sekvencni 7, Brno', 55, 2, 2);
exec db_contract.new_contract(9, 9, DATE '2024-01-01', DATE '2024-03-31', 12000);
exec db_contract.new_contract(9, 10, DATE '2024-04-01', DATE '2024-06-30', 13000);
exec db_contract.new_contract(9, 11, DATE '2024-07-01', null, 13500);
select * from contracts where flat_id = 9 order by start_date;

-- Business check: nejvíce aktivních žádostí
select
  r.tenant_id,
  db_tenant.get_tenant_name(r.tenant_id) as jmeno_najemnika,
  count(*) as pocet_otevrenych
from requests r
where r.status in ('NEW', 'IN_PROGRESS')
group by r.tenant_id
order by pocet_otevrenych desc;

-- Business check: nejvíce plateb za měsíc
declare
  c sys_refcursor;
  id number;
  addr varchar2(255);
  area number;
  rooms number;
begin
  c := db_flat.get_flats_by_owner(1);
  loop
    fetch c into id, addr, area, rooms;
    exit when c%notfound;
    dbms_output.put_line('Byt ID: ' || id || ', Adresa: ' || addr || ', Plocha: ' || area || ', Pokoje: ' || rooms);
  end loop;
  close c;
end;
/

-- zopakování funkcí s novými daty
exec db_contract.new_contract(1, 1, DATE '2024-02-01', null, 18000);
select db_payment.get_outstanding_balance(2) as dluh from dual;

exec db_payment.generate_monthly_payments;
select * from payments where to_char(payment_date, 'YYYY-MM') = to_char(sysdate, 'YYYY-MM');

exec db_request.new_request(1, 1, 'Testovací požadavek na opravu.');
exec db_request.assign_service(2, 1, 1, 'Zaslána technická jednotka');

select db_employee.get_employee_name(1) as jmeno_zamestnance from dual;

select db_service_company.get_company_name(1) as jmeno_spolecnosti from dual;

select db_service_action.get_action_count(2) as pocet_akci_na_zadost_2 from dual;
