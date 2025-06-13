-- Autor: Matěj Foukal

SET SERVEROUTPUT ON;

DECLARE
  v_owner_id_1    persons.person_id%TYPE;
  v_tenant_id_1   persons.person_id%TYPE;
  v_flat_id_1     flats.flat_id%TYPE;
  v_contract_id_1 contracts.contract_id%TYPE;
  v_request_id_1  requests.request_id%TYPE;
BEGIN
  -- globalne pouzivane idcka
  v_owner_id_1    := db_person.get_person_id_by_email('anna.novak@example.com');
  v_tenant_id_1   := db_person.get_person_id_by_email('jana.vesela@example.com');
  v_flat_id_1     := db_flat.get_flat_id_by_address('Masarykova 12, Praha', 101);
  v_contract_id_1 := db_contract.get_contract_id(v_flat_id_1, v_tenant_id_1, DATE '2024-01-01');
  SELECT request_id INTO v_request_id_1 FROM requests WHERE flat_id = v_flat_id_1 
  AND tenant_id = v_tenant_id_1 AND description = 'Radiator not heating.' AND ROWNUM = 1;

  DECLARE
    v_owner_id_test persons.person_id%TYPE;
  BEGIN
    -- Přidání nového vlastníka
    db_owner.new_owner('Test Owner', 'test.owner@example.com', '601000001', '999888777/0800');
  END;

  -- Změna kontaktních údajů
  db_owner.update_contact_info(v_owner_id_1, 'updated@example.com', '123456789');

  -- Ověření chyby při aktualizaci neexistujícího vlastníka - `Person record for Owner ID 999 not found.`
  BEGIN
    db_owner.update_contact_info(999, 'fail@example.com', '000000000');
  EXCEPTION WHEN OTHERS THEN
    dbms_output.put_line('Očekávaná chyba: ' || SQLERRM);
  END;

  -- Pokus o smazání vlastníka s bytem – očekáváme chybu `Cannot delete owner. They still own one or more flats.`
  BEGIN
    db_owner.delete_owner(v_owner_id_1);
  EXCEPTION WHEN OTHERS THEN
    dbms_output.put_line('Očekávaná chyba: ' || SQLERRM);
  END;

  DECLARE
    v_tenant_id_test persons.person_id%TYPE;
    v_flat_id_test   flats.flat_id%TYPE;
  BEGIN
    -- Přidání nového nájemníka
    db_tenant.new_tenant('Test Tenant', 'test.tenant@example.com', '777123123');
    v_tenant_id_test := db_person.get_person_id_by_email('test.tenant@example.com');

    -- Vložení nového bytu
    db_flat.new_flat('Testovaci 1, Praha', 99, 70, 3, v_owner_id_1);
    v_flat_id_test := db_flat.get_flat_id_by_address('Testovaci 1, Praha', 99);
  END;

  -- Změna kontaktních údajů nájemníka
  db_tenant.update_contact_info(v_tenant_id_1, 'new.tenant@example.com', '123321123');

  -- Cely ziovtni cyklus
  DECLARE
      v_tenant_id_seq   persons.person_id%TYPE;
      v_flat_id_seq     flats.flat_id%TYPE;
      v_contract_id_seq contracts.contract_id%TYPE;
      v_payment_id_seq  payments.payment_id%TYPE;
      v_request_id_seq  requests.request_id%TYPE;
      v_employee_id_seq persons.person_id%TYPE;
      v_company_id_seq  service_companies.company_id%TYPE;
  BEGIN
      db_tenant.new_tenant('Sequential Tenant', 'seq.tenant@example.com', '777123456');
      v_tenant_id_seq := db_person.get_person_id_by_email('seq.tenant@example.com');

      db_flat.new_flat('Sekvencni Byt 1, Praha', 101, 50, 2, v_owner_id_1);
      v_flat_id_seq := db_flat.get_flat_id_by_address('Sekvencni Byt 1, Praha', 101);

      -- Vložení nové smlouvy
      db_contract.new_contract(v_flat_id_seq, v_tenant_id_seq, DATE '2025-01-01', null, 15000);
      v_contract_id_seq := db_contract.get_contract_id(v_flat_id_seq, v_tenant_id_seq, DATE '2025-01-01');

      -- Ukončení smlouvy
      db_contract.terminate_contract(v_contract_id_seq, DATE '2025-12-31');

      -- Vložení nové platby
      db_payment.new_payment(v_contract_id_seq, DATE '2025-02-01', 15000, 'PAID');
      v_payment_id_seq := db_payment.get_payment_id(v_contract_id_seq, DATE '2025-02-01');

      -- Změna statusu platby
      db_payment.update_payment_status(v_payment_id_seq, 'LATE');

      -- Vložení nové žádosti
      db_request.new_request(v_flat_id_seq, v_tenant_id_seq, 'Testovací požadavek na opravu.');
      SELECT request_id INTO v_request_id_seq FROM requests WHERE flat_id=v_flat_id_seq AND tenant_id=v_tenant_id_seq AND ROWNUM=1;

      -- Změna statusu žádosti
      db_request.update_request_status(v_request_id_seq, 'IN_PROGRESS');

      -- Přidání zaměstnance a servisní firmy
      db_employee.new_employee('Test Technic', 'technician@example.com', '777555666', 'Údržbář');
      v_employee_id_seq := db_person.get_person_id_by_email('technician@example.com');

      db_service_company.new_company('TestServ', 'kontakt@testserv.cz', '604404404');
      v_company_id_seq := db_service_company.get_company_id_by_name('TestServ');

      -- Přiřazení servisní akce
      db_request.assign_service(v_request_id_seq, v_employee_id_seq, v_company_id_seq, 'Oprava topení.');
  END;

  -- Kompletní nájemní tok
  DECLARE
    v_contract_id_tok contracts.contract_id%TYPE;
    v_flat_id_tok     flats.flat_id%TYPE;
    v_tenant_id_tok   persons.person_id%TYPE;
  BEGIN
    db_tenant.new_tenant('Komplet Tok', 'komplet@example.com', '601800000');
    v_tenant_id_tok := db_person.get_person_id_by_email('komplet@example.com');

    db_flat.new_flat('Tokova 1, Praha', 1, 60, 2, v_owner_id_1);
    v_flat_id_tok := db_flat.get_flat_id_by_address('Tokova 1, Praha', 1);

    db_contract.new_contract(v_flat_id_tok, v_tenant_id_tok, DATE '2024-04-01', null, 16500);
    v_contract_id_tok := db_contract.get_contract_id(v_flat_id_tok, v_tenant_id_tok, DATE '2024-04-01');

    db_payment.new_payment(v_contract_id_tok, DATE '2024-04-05', 16500, 'PAID');
    DBMS_OUTPUT.PUT_LINE('Test najemni tok hotovo');
  END;

  -- Založení nájemního vztahu se třemi po sobě jdoucími nájemníky
  DECLARE
    v_owner_id_s2     persons.person_id%TYPE;
    v_flat_id_seq     flats.flat_id%TYPE;
    v_tenant_id_s1    persons.person_id%TYPE;
    v_tenant_id_s2    persons.person_id%TYPE;
    v_tenant_id_s3    persons.person_id%TYPE;
  BEGIN
    v_owner_id_s2 := db_person.get_person_id_by_email('petr.svoboda@example.com');

    db_tenant.new_tenant('Sekvence 1', 's1@example.com', '601000111');
    v_tenant_id_s1 := db_person.get_person_id_by_email('s1@example.com');

    db_tenant.new_tenant('Sekvence 2', 's2@example.com', '601000112');
    v_tenant_id_s2 := db_person.get_person_id_by_email('s2@example.com');

    db_tenant.new_tenant('Sekvence 3', 's3@example.com', '601000113');
    v_tenant_id_s3 := db_person.get_person_id_by_email('s3@example.com');

    db_flat.new_flat('Sekvencni 7, Brno', 1, 55, 2, v_owner_id_s2);
    v_flat_id_seq := db_flat.get_flat_id_by_address('Sekvencni 7, Brno', 1);

    db_contract.new_contract(v_flat_id_seq, v_tenant_id_s1, DATE '2024-01-01', DATE '2024-03-31', 12000);
    db_contract.new_contract(v_flat_id_seq, v_tenant_id_s2, DATE '2024-04-01', DATE '2024-06-30', 13000);
    db_contract.new_contract(v_flat_id_seq, v_tenant_id_s3, DATE '2024-07-01', null, 13500);
    DBMS_OUTPUT.PUT_LINE('Test 3 nájemníci hotovo');
  END;

  -- Generování plateb
  db_payment.generate_monthly_payments;

END;
/

-- Ostatní custom funkce
-- jméno vlastníka
select db_owner.get_owner_name(1) as jmeno_vlastnika from dual;
-- adresa bytu
select db_flat.get_flat_address(1) as adresa_bytu from dual;
-- aktuální nájemník
select db_flat.get_current_tenant_name(1) as najemnik from dual;
-- celkově zaplaceno
select db_payment.get_total_paid(1) as celkem_zaplaceno from dual;
-- dlužná částka
select db_payment.get_outstanding_balance(2) as dluh from dual;
-- otevřené žádosti
select db_request.count_open_requests(1) as otevrene_zadosti from dual;
-- počet servisních akcí
select db_service_action.get_action_count(1) as pocet_akci from dual;

-- Pohledy
DBMS_OUTPUT.PUT_LINE('Aktivní smlouvy:');
select * from active_contracts;
DBMS_OUTPUT.PUT_LINE('Neuhrazené platby:');
select * from unpaid_payments;
DBMS_OUTPUT.PUT_LINE('Otevřené žádosti:');
select * from open_requests;
DBMS_OUTPUT.PUT_LINE('Akce:');
select * from employee_actions;
DBMS_OUTPUT.PUT_LINE('Souhrn plateb:');
select * from contract_payment_summary;

COMMIT;