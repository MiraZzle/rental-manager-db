-- Autor: Matěj Foukal

-- ==============================================
-- SEKVENCE
-- ==============================================
create sequence flat_id_seq start with 1 increment by 1;
create sequence contract_id_seq start with 1 increment by 1;
create sequence payment_id_seq start with 1 increment by 1;
create sequence request_id_seq start with 1 increment by 1;
create sequence company_id_seq start with 1 increment by 1;
create sequence action_id_seq start with 1 increment by 1;
create sequence person_id_seq start with 1 increment by 1;

-- ==============================================
-- PERSONS
-- ==============================================
CREATE OR REPLACE PACKAGE db_person IS
  -- Vloží nebo najde osobu podle unikátního emailu
  FUNCTION get_or_create_person(
    p_name  IN persons.name%TYPE,
    p_email IN persons.email%TYPE,
    p_phone IN persons.phone%TYPE
  ) RETURN persons.person_id%TYPE;

  FUNCTION get_person_id_by_email(
    p_email IN persons.email%TYPE
  ) RETURN persons.person_id%TYPE;
END db_person;
/

CREATE OR REPLACE PACKAGE BODY db_person IS
  FUNCTION get_or_create_person(
    p_name  IN persons.name%TYPE,
    p_email IN persons.email%TYPE,
    p_phone IN persons.phone%TYPE
  ) RETURN persons.person_id%TYPE IS
    v_person_id persons.person_id%TYPE;
  BEGIN
    -- pouzijeme MERGE aka UPSERT
    MERGE INTO persons p
    USING (SELECT p_email AS email FROM dual) src
    ON (p.email = src.email)
    WHEN NOT MATCHED THEN
      -- Pokud nenajdeme osobu podle mailu, vytvorime ji
      INSERT (person_id, name, email, phone)
      VALUES (person_id_seq.nextval, p_name, p_email, p_phone);

    SELECT person_id INTO v_person_id FROM persons WHERE email = p_email;

    RETURN v_person_id;

  END get_or_create_person;

  FUNCTION get_person_id_by_email(
    p_email IN persons.email%TYPE
  ) RETURN persons.person_id%TYPE IS
    v_person_id persons.person_id%TYPE;
  BEGIN
    SELECT person_id
    INTO v_person_id
    FROM persons
    WHERE email = p_email;

    RETURN v_person_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END get_person_id_by_email;
END db_person;
/

-- ==============================================
-- OWNERS
-- ==============================================
CREATE OR REPLACE PACKAGE db_owner IS
  -- Vloží nového vlastníka. Používá db_person pro mapovani osob
  PROCEDURE new_owner(
    p_name         IN persons.name%TYPE,
    p_email        IN persons.email%TYPE,
    p_phone        IN persons.phone%TYPE,
    p_bank_account IN owners.bank_account%TYPE
  );

  -- Aktualizuje kontaktní údaje vlastníka v tabulce persons
  PROCEDURE update_contact_info(
    p_owner_id  IN owners.owner_id%TYPE,
    p_new_email IN persons.email%TYPE,
    p_new_phone IN persons.phone%TYPE
  );

  -- Smaže roli vlastníka (ale ne osobu), pouze pokud nevlastní žádné byty
  PROCEDURE delete_owner(p_owner_id IN owners.owner_id%TYPE);

  -- Vrátí jméno vlastníka podle ID v persons
  FUNCTION get_owner_name(p_owner_id IN owners.owner_id%TYPE) RETURN persons.name%TYPE;

END db_owner;
/

CREATE OR REPLACE PACKAGE BODY db_owner IS
  PROCEDURE new_owner(
    p_name         IN persons.name%TYPE,
    p_email        IN persons.email%TYPE,
    p_phone        IN persons.phone%TYPE,
    p_bank_account IN owners.bank_account%TYPE
  ) IS
    v_person_id   persons.person_id%TYPE;
    v_role_exists NUMBER;
  BEGIN
    -- Najdeme nebo vytvoříme id osoby v persons tablu
    v_person_id := db_person.get_or_create_person(p_name, p_email, p_phone);

    SELECT COUNT(*)
    INTO v_role_exists
    FROM owners
    WHERE owner_id = v_person_id;

    -- Kontrola, jestli osoba již není vlastníkem
    IF v_role_exists > 0 THEN
      RAISE_APPLICATION_ERROR(-20015, 'This person is already registered as an owner.');
    ELSE
      INSERT INTO owners(owner_id, bank_account)
      VALUES (v_person_id, p_bank_account);
    END IF;

  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      RAISE_APPLICATION_ERROR(-20016, 'The bank account "' || p_bank_account || '" is already in use.');
  END new_owner;

  PROCEDURE update_contact_info(
    p_owner_id  IN owners.owner_id%TYPE,
    p_new_email IN persons.email%TYPE,
    p_new_phone IN persons.phone%TYPE
  ) IS
  BEGIN
    UPDATE persons
    SET
      email = p_new_email,
      phone = p_new_phone
    WHERE person_id = p_owner_id;

    IF SQL%NOTFOUND THEN
        RAISE_APPLICATION_ERROR(-20200, 'Person record for Owner ID ' || p_owner_id || ' not found.');
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20201, 'Owner with ID ' || p_owner_id || ' not found.');
    WHEN DUP_VAL_ON_INDEX THEN
      RAISE_APPLICATION_ERROR(-20011, 'This email or phone is already in use by another person.');
  END update_contact_info;

  PROCEDURE delete_owner(p_owner_id IN owners.owner_id%TYPE) IS
    e_child_records_found EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_child_records_found, -2292);
  BEGIN
    DELETE FROM owners WHERE owner_id = p_owner_id;

  EXCEPTION
    WHEN e_child_records_found THEN
      RAISE_APPLICATION_ERROR(-20202, 'Cannot delete owner. They still own one or more flats.');
  END delete_owner;

  FUNCTION get_owner_name(p_owner_id IN owners.owner_id%TYPE) RETURN persons.name%TYPE IS
    v_name persons.name%TYPE;
  BEGIN
    SELECT p.name
    INTO v_name
    FROM owners o
    JOIN persons p ON o.owner_id = p.person_id
    WHERE o.owner_id = p_owner_id;

    RETURN v_name;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END get_owner_name;

END db_owner;
/

-- ==============================================
-- TENANTS
-- ==============================================
CREATE OR REPLACE PACKAGE db_tenant IS
  -- Vloží nového nájemníka. Používá db_person k nalezení nebo vytvoření osoby
  PROCEDURE new_tenant(
    p_name  IN persons.name%TYPE,
    p_email IN persons.email%TYPE,
    p_phone IN persons.phone%TYPE,
    p_notes IN tenants.notes%TYPE DEFAULT NULL
  );

  -- Aktualizuje kontaktní údaje nájemníka v persons
  PROCEDURE update_contact_info(
    p_tenant_id IN tenants.tenant_id%TYPE,
    p_new_email IN persons.email%TYPE,
    p_new_phone IN persons.phone%TYPE
  );

  -- Smaže roli nájemníka (ale ne osobu), pouze pokud nemá žádné aktivní smlouvy
  PROCEDURE delete_tenant(p_tenant_id IN tenants.tenant_id%TYPE);

  -- Vrátí jméno nájemníka podle ID spojením s tabulkou persons.
  FUNCTION get_tenant_name(p_tenant_id IN tenants.tenant_id%TYPE) RETURN persons.name%TYPE;

END db_tenant;
/

CREATE OR REPLACE PACKAGE BODY db_tenant IS
  PROCEDURE new_tenant(
    p_name  IN persons.name%TYPE,
    p_email IN persons.email%TYPE,
    p_phone IN persons.phone%TYPE,
    p_notes IN tenants.notes%TYPE DEFAULT NULL
  ) IS
    v_person_id   persons.person_id%TYPE;
    v_role_exists NUMBER;
  BEGIN
    -- Najdeme nebo vytvoříme id osoby v persons tablu
    v_person_id := db_person.get_or_create_person(p_name, p_email, p_phone);

    -- Kontrola, zda osoba již není nájemníkem
    SELECT COUNT(*)
    INTO v_role_exists
    FROM tenants
    WHERE tenant_id = v_person_id;

    IF v_role_exists > 0 THEN
      RAISE_APPLICATION_ERROR(-20025, 'This person is already registered as a tenant.');
    ELSE
      INSERT INTO tenants(tenant_id, notes)
      VALUES (v_person_id, p_notes);
    END IF;

  END new_tenant;

  PROCEDURE update_contact_info(
    p_tenant_id IN tenants.tenant_id%TYPE,
    p_new_email IN persons.email%TYPE,
    p_new_phone IN persons.phone%TYPE
  ) IS
  BEGIN
    UPDATE persons
    SET
      email = p_new_email,
      phone = p_new_phone
    WHERE person_id = p_tenant_id;

    IF SQL%NOTFOUND THEN
        RAISE_APPLICATION_ERROR(-20210, 'Person record for Tenant ID ' || p_tenant_id || ' not found.');
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20211, 'Tenant with ID ' || p_tenant_id || ' not found.');
    WHEN DUP_VAL_ON_INDEX THEN
      RAISE_APPLICATION_ERROR(-20011, 'This email or phone is already in use by another person.');
  END update_contact_info;

  PROCEDURE delete_tenant(p_tenant_id IN tenants.tenant_id%TYPE) IS
    e_child_records_found EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_child_records_found, -2292);
  BEGIN
    DELETE FROM tenants WHERE tenant_id = p_tenant_id;
  EXCEPTION
    WHEN e_child_records_found THEN
      RAISE_APPLICATION_ERROR(-20212, 'Cannot delete tenant. They still have one or more contracts.');
  END delete_tenant;

  FUNCTION get_tenant_name(p_tenant_id IN tenants.tenant_id%TYPE) RETURN persons.name%TYPE IS
    v_name persons.name%TYPE;
  BEGIN
    SELECT p.name
    INTO v_name
    FROM tenants t
    JOIN persons p ON t.tenant_id = p.person_id
    WHERE t.tenant_id = p_tenant_id;

    RETURN v_name;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END get_tenant_name;

END db_tenant;
/

-- ==============================================
-- EMPLOYEES
-- ==============================================
CREATE OR REPLACE PACKAGE db_employee IS
  -- Vloží nového zaměstnance. Používá db_person k nalezení nebo vytvoření osoby.
  PROCEDURE new_employee(
    p_name  IN persons.name%TYPE,
    p_email IN persons.email%TYPE,
    p_phone IN persons.phone%TYPE,
    p_role  IN employees.role%TYPE
  );

  -- Smaže roli zaměstnance (ale ne osobu), pouze pokud nemá žádné přiřazené servisní akce.
  PROCEDURE delete_employee(p_employee_id IN employees.employee_id%TYPE);

  -- Vrátí jméno zaměstnance podle ID spojením s tabulkou persons.
  FUNCTION get_employee_name(p_employee_id IN employees.employee_id%TYPE) RETURN persons.name%TYPE;

END db_employee;
/

CREATE OR REPLACE PACKAGE BODY db_employee IS
  PROCEDURE new_employee(
    p_name  IN persons.name%TYPE,
    p_email IN persons.email%TYPE,
    p_phone IN persons.phone%TYPE,
    p_role  IN employees.role%TYPE
  ) IS
    v_person_id   persons.person_id%TYPE;
    v_role_exists NUMBER;
  BEGIN
    v_person_id := db_person.get_or_create_person(p_name, p_email, p_phone);

    SELECT COUNT(*)
    INTO v_role_exists
    FROM employees
    WHERE employee_id = v_person_id;

    IF v_role_exists > 0 THEN
      RAISE_APPLICATION_ERROR(-20035, 'This person is already registered as an employee.');
    ELSE
      -- Step 3: Insert the employee-specific information.
      INSERT INTO employees(employee_id, role)
      VALUES (v_person_id, p_role);
    END IF;

  END new_employee;

  PROCEDURE delete_employee(p_employee_id IN employees.employee_id%TYPE) IS
    e_child_records_found EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_child_records_found, -2292);
  BEGIN
    DELETE FROM employees WHERE employee_id = p_employee_id;
  EXCEPTION
    WHEN e_child_records_found THEN
      RAISE_APPLICATION_ERROR(-20036, 'Cannot delete employee. They are assigned to one or more service actions.');
  END delete_employee;

  FUNCTION get_employee_name(p_employee_id IN employees.employee_id%TYPE) RETURN persons.name%TYPE IS
    v_name persons.name%TYPE;
  BEGIN
    SELECT p.name
    INTO v_name
    FROM employees e
    JOIN persons p ON e.employee_id = p.person_id
    WHERE e.employee_id = p_employee_id;

    RETURN v_name;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END get_employee_name;

END db_employee;
/

-- ==============================================
-- FLATS
-- ==============================================
CREATE OR REPLACE PACKAGE db_flat IS
  -- Vloží nový byt
  PROCEDURE new_flat(
    p_address     IN flats.address%TYPE,
    p_unit_number IN flats.unit_number%TYPE,
    p_area        IN flats.area%TYPE,
    p_rooms       IN flats.rooms%TYPE,
    p_owner_id    IN flats.owner_id%TYPE);

  -- Přeřadí byt na nového vlastníka
  PROCEDURE reassign_flat(p_flat_id IN flats.flat_id%TYPE, p_new_owner_id IN owners.owner_id%TYPE);

  -- Vrátí adresu bytu podle ID
  FUNCTION get_flat_address(p_flat_id IN flats.flat_id%TYPE) RETURN flats.address%TYPE;

  -- Vrátí seznam bytů pro daného vlastníka
  FUNCTION get_flats_by_owner(p_owner_id IN owners.owner_id%TYPE) RETURN SYS_REFCURSOR;

  -- Vrátí jméno aktuálního nájemníka bytu
  FUNCTION get_current_tenant_name(p_flat_id IN flats.flat_id%TYPE) RETURN persons.name%TYPE;

  -- Vrátí ID bytu podle adresy a čísla jednotky
  FUNCTION get_flat_id_by_address(p_address IN flats.address%TYPE, p_unit_number IN flats.unit_number%TYPE
  ) RETURN flats.flat_id%TYPE;
END db_flat;
/

CREATE OR REPLACE PACKAGE BODY db_flat IS
  PROCEDURE new_flat(p_address     IN flats.address%TYPE,
    p_unit_number IN flats.unit_number%TYPE,
    p_area        IN flats.area%TYPE,
    p_rooms       IN flats.rooms%TYPE,
    p_owner_id    IN flats.owner_id%TYPE) IS
  BEGIN
    INSERT INTO flats(flat_id, address, unit_number, area, rooms, owner_id)
    VALUES (flat_id_seq.nextval, p_address, p_unit_number, p_area, p_rooms, p_owner_id);
  END new_flat;

  PROCEDURE reassign_flat(p_flat_id IN flats.flat_id%TYPE, p_new_owner_id IN owners.owner_id%TYPE) IS
    v_check NUMBER;
  BEGIN
    SELECT count(*) INTO v_check FROM owners WHERE owner_id = p_new_owner_id;
    IF v_check = 0 THEN
        RAISE_APPLICATION_ERROR(-20301, 'New owner with ID ' || p_new_owner_id || ' does not exist.');
    END IF;

    UPDATE flats SET owner_id = p_new_owner_id WHERE flat_id = p_flat_id;

    IF SQL%NOTFOUND THEN
        RAISE_APPLICATION_ERROR(-20302, 'Flat with ID ' || p_flat_id || ' does not exist.');
    END IF;
  END reassign_flat;

  FUNCTION get_flat_address(p_flat_id flats.flat_id%TYPE) RETURN flats.address%TYPE IS
    v_address flats.address%TYPE;
  BEGIN
    SELECT address INTO v_address FROM flats WHERE flat_id = p_flat_id;
    RETURN v_address;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END get_flat_address;

  FUNCTION get_flats_by_owner(p_owner_id IN owners.owner_id%TYPE) RETURN sys_refcursor IS
    v_cursor sys_refcursor;
  BEGIN
    OPEN v_cursor FOR
      SELECT flat_id, address, area, rooms
      FROM flats
      WHERE owner_id = p_owner_id;
    RETURN v_cursor;
  END get_flats_by_owner;

  FUNCTION get_current_tenant_name(p_flat_id IN flats.flat_id%TYPE) RETURN persons.name%TYPE IS
    v_tenant_name persons.name%TYPE;
  BEGIN
    SELECT p.name INTO v_tenant_name
    FROM contracts c
    JOIN tenants t ON c.tenant_id = t.tenant_id
    JOIN persons p ON t.tenant_id = p.person_id
    WHERE c.flat_id = p_flat_id
      AND c.start_date <= SYSDATE
      AND (c.end_date IS NULL OR c.end_date >= SYSDATE)
      AND ROWNUM = 1;

    RETURN v_tenant_name;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 'Unoccupied';
  END get_current_tenant_name;

  FUNCTION get_flat_id_by_address(p_address IN flats.address%TYPE, p_unit_number IN flats.unit_number%TYPE
   ) RETURN flats.flat_id%TYPE IS
    v_flat_id flats.flat_id%TYPE;
  BEGIN
    SELECT flat_id
    INTO v_flat_id
    FROM flats
    WHERE address = p_address
      AND unit_number = p_unit_number;

    RETURN v_flat_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END get_flat_id_by_address;

END db_flat;
/

-- ==============================================
-- CONTRACTS
-- ==============================================
CREATE OR REPLACE PACKAGE db_contract IS
  -- Vytvoří novou smlouvu
  PROCEDURE new_contract(
    p_flat_id   IN contracts.flat_id%TYPE,
    p_tenant_id IN contracts.tenant_id%TYPE,
    p_start     IN contracts.start_date%TYPE,
    p_end       IN contracts.end_date%TYPE,
    p_rent      IN contracts.rent_amount%TYPE);

  -- Ukončí smlouvu
  PROCEDURE terminate_contract(p_contract_id IN contracts.contract_id%TYPE, p_end_date IN contracts.end_date%TYPE);

  -- Prodlouží smlouvu
  PROCEDURE extend_contract(p_contract_id IN contracts.contract_id%TYPE, p_new_end IN contracts.end_date%TYPE);

  -- Změní výši nájmu
  PROCEDURE change_rent(p_contract_id IN contracts.contract_id%TYPE, p_new_rent IN contracts.rent_amount%TYPE);

  -- Vrátí počet aktivních smluv pro byt
  FUNCTION get_active_contract_count(p_flat_id IN flats.flat_id%TYPE) RETURN NUMBER;

  FUNCTION get_contract_id(p_flat_id IN contracts.flat_id%TYPE, p_tenant_id IN contracts.tenant_id%TYPE,
  p_start_date IN contracts.start_date%TYPE
  ) RETURN contracts.contract_id%TYPE;
END db_contract;
/

CREATE OR REPLACE PACKAGE BODY db_contract IS
  PROCEDURE new_contract(p_flat_id IN contracts.flat_id%TYPE, p_tenant_id IN contracts.tenant_id%TYPE, p_start IN contracts.start_date%TYPE, p_end IN contracts.end_date%TYPE, p_rent IN contracts.rent_amount%TYPE) IS
  BEGIN
    IF p_end IS NOT NULL AND p_start > p_end THEN
      raise_application_error(-20101, 'Start date must be before or equal to end date.');
    END IF;

    INSERT INTO contracts(contract_id, flat_id, tenant_id, start_date, end_date, rent_amount)
    VALUES (contract_id_seq.nextval, p_flat_id, p_tenant_id, p_start, p_end, p_rent);
  END new_contract;

  PROCEDURE terminate_contract(p_contract_id IN contracts.contract_id%TYPE, p_end_date IN contracts.end_date%TYPE) IS
  BEGIN
    UPDATE contracts SET end_date = p_end_date WHERE contract_id = p_contract_id;
    IF sql%rowcount = 0 THEN
      raise_application_error(-20102, 'No such contract.');
    END IF;
  END terminate_contract;

  PROCEDURE extend_contract(p_contract_id IN contracts.contract_id%TYPE, p_new_end IN contracts.end_date%TYPE) IS
    v_start_date contracts.start_date%TYPE;
  BEGIN
    SELECT start_date INTO v_start_date FROM contracts WHERE contract_id = p_contract_id;
    IF v_start_date > p_new_end THEN
      raise_application_error(-20103, 'New end date must be after start date.');
    END IF;
    UPDATE contracts SET end_date = p_new_end WHERE contract_id = p_contract_id;
  END extend_contract;

  PROCEDURE change_rent(p_contract_id IN contracts.contract_id%TYPE, p_new_rent IN contracts.rent_amount%TYPE) IS
  BEGIN
    IF p_new_rent <= 0 THEN
      raise_application_error(-20104, 'Rent must be positive.');
    END IF;
    UPDATE contracts SET rent_amount = p_new_rent WHERE contract_id = p_contract_id;
  END change_rent;

  FUNCTION get_active_contract_count(p_flat_id IN flats.flat_id%TYPE) RETURN NUMBER IS
    v_count NUMBER;
  BEGIN
    SELECT count(*) INTO v_count FROM contracts
    WHERE flat_id = p_flat_id AND (end_date IS NULL OR end_date > SYSDATE);
    RETURN v_count;
  END get_active_contract_count;

  FUNCTION get_contract_id(p_flat_id IN contracts.flat_id%TYPE, p_tenant_id IN contracts.tenant_id%TYPE,
  p_start_date IN contracts.start_date%TYPE
  ) RETURN contracts.contract_id%TYPE IS
    v_contract_id contracts.contract_id%TYPE;
  BEGIN
    SELECT contract_id
    INTO v_contract_id
    FROM contracts
    WHERE flat_id = p_flat_id
      AND tenant_id = p_tenant_id
      AND start_date = p_start_date;

    RETURN v_contract_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END get_contract_id;
END db_contract;
/


-- ==============================================
-- PAYMENTS
-- ==============================================
CREATE OR REPLACE PACKAGE db_payment IS
  -- Vloží novou platbu
  PROCEDURE new_payment(
    p_contract_id IN payments.contract_id%TYPE,
    p_date        IN payments.payment_date%TYPE,
    p_amount      IN payments.amount%TYPE,
    p_status      IN payments.status%TYPE);

  -- Změní status platby
  PROCEDURE update_payment_status(
    p_payment_id IN payments.payment_id%TYPE,
    p_status     IN payments.status%TYPE);

  -- Vrátí celkovou zaplacenou částku
  FUNCTION get_total_paid(p_contract_id IN contracts.contract_id%TYPE) RETURN NUMBER;

  -- Vrátí dlužnou částku pro smlouvu
  FUNCTION get_outstanding_balance(p_contract_id IN contracts.contract_id%TYPE) RETURN NUMBER;

  -- Generuje měsíční platby pro aktivní smlouvy
  PROCEDURE generate_monthly_payments;

  FUNCTION get_payment_id(p_contract_id IN payments.contract_id%TYPE, p_payment_date IN payments.payment_date%TYPE)
    RETURN payments.payment_id%TYPE;
END db_payment;
/

CREATE OR REPLACE PACKAGE BODY db_payment IS
  PROCEDURE new_payment(p_contract_id IN payments.contract_id%TYPE, p_date IN payments.payment_date%TYPE, p_amount IN payments.amount%TYPE, p_status IN payments.status%TYPE) IS
  BEGIN
    IF p_amount <= 0 THEN
      raise_application_error(-20401, 'Payment amount must be greater than zero.');
    END IF;
    IF p_status NOT IN ('PAID', 'DUE', 'LATE') THEN
      raise_application_error(-20402, 'Invalid payment status: ' || p_status);
    END IF;
    INSERT INTO payments(payment_id, contract_id, payment_date, amount, status)
    VALUES (payment_id_seq.nextval, p_contract_id, p_date, p_amount, p_status);
  END new_payment;

  PROCEDURE update_payment_status(p_payment_id IN payments.payment_id%TYPE, p_status IN payments.status%TYPE) IS
  BEGIN
    IF p_status NOT IN ('PAID', 'DUE', 'LATE') THEN
        raise_application_error(-20402, 'Invalid payment status: ' || p_status);
    END IF;
    UPDATE payments
    SET status = p_status
    WHERE payment_id = p_payment_id;
    IF SQL%NOTFOUND THEN
        raise_application_error(-20403, 'Payment with ID ' || p_payment_id || ' does not exist.');
    END IF;
  END update_payment_status;

  FUNCTION get_total_paid(p_contract_id IN contracts.contract_id%TYPE) RETURN NUMBER IS
    v_total payments.amount%TYPE;
  BEGIN
    SELECT SUM(amount) INTO v_total
    FROM payments
    WHERE contract_id = p_contract_id AND status = 'PAID';
    RETURN NVL(v_total, 0);
  END get_total_paid;

  FUNCTION get_outstanding_balance(p_contract_id IN contracts.contract_id%TYPE) RETURN NUMBER IS
    v_total_due    NUMBER := 0;
    v_total_paid   NUMBER := 0;
    v_contract_rec contracts%ROWTYPE;
  BEGIN
    SELECT * INTO v_contract_rec
    FROM contracts
    WHERE contract_id = p_contract_id;

    v_total_due := FLOOR(months_between(LEAST(SYSDATE, NVL(v_contract_rec.end_date, SYSDATE)), v_contract_rec.start_date)) * v_contract_rec.rent_amount;
    v_total_paid := get_total_paid(p_contract_id);

    RETURN GREATEST(0, v_total_due - v_total_paid);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 0;
  END get_outstanding_balance;

  PROCEDURE generate_monthly_payments IS
    v_payment_date DATE;
  BEGIN
    FOR c IN (SELECT contract_id, rent_amount FROM contracts WHERE end_date IS NULL OR end_date >= TRUNC(SYSDATE, 'MM')) LOOP
        v_payment_date := TRUNC(SYSDATE, 'MM');
        DECLARE
            v_payment_exists NUMBER;
        BEGIN
            SELECT COUNT(*) INTO v_payment_exists
            FROM payments
            WHERE contract_id = c.contract_id
              AND TRUNC(payment_date, 'MM') = v_payment_date;

            IF v_payment_exists = 0 THEN
                INSERT INTO payments(payment_id, contract_id, payment_date, amount, status)
                VALUES (payment_id_seq.nextval, c.contract_id, v_payment_date, c.rent_amount, 'DUE');
            END IF;
        END;
    END LOOP;
  END generate_monthly_payments;

  FUNCTION get_payment_id(p_contract_id  IN payments.contract_id%TYPE, p_payment_date IN payments.payment_date%TYPE
  ) RETURN payments.payment_id%TYPE IS
    v_payment_id payments.payment_id%TYPE;
  BEGIN
    SELECT payment_id
    INTO v_payment_id
    FROM payments
    WHERE contract_id = p_contract_id
      AND payment_date = p_payment_date;

    RETURN v_payment_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END get_payment_id;
END db_payment;
/

-- ==============================================
-- REQUESTS
-- ==============================================
CREATE OR REPLACE PACKAGE db_request IS
  -- Vloží novou žádost
  PROCEDURE new_request(
    p_flat_id       IN requests.flat_id%TYPE,
    p_tenant_id     IN requests.tenant_id%TYPE,
    p_description   IN requests.description%TYPE);

  -- Aktualizuje status žádosti
  PROCEDURE update_request_status(
    p_request_id IN requests.request_id%TYPE,
    p_new_status IN requests.status%TYPE);

  -- Přiřadí servisní zásah k žádosti
  PROCEDURE assign_service(
    p_request_id  IN requests.request_id%TYPE,
    p_employee_id IN employees.employee_id%TYPE,
    p_company_id  IN service_companies.company_id%TYPE,
    p_note        IN service_actions.note%TYPE);

  -- Vrátí počet otevřených žádostí pro byt
  FUNCTION count_open_requests(p_flat_id IN flats.flat_id%TYPE) RETURN NUMBER;

  -- Vrátí ID žádosti podle flat_id, tenant_id, request_date a description
  FUNCTION get_request_id(
    p_flat_id      IN requests.flat_id%TYPE,
    p_tenant_id    IN requests.tenant_id%TYPE,
    p_request_date IN requests.request_date%TYPE,
    p_description  IN requests.description%TYPE
  ) RETURN requests.request_id%TYPE;
END db_request;
/

CREATE OR REPLACE PACKAGE BODY db_request IS
  PROCEDURE new_request(p_flat_id requests.flat_id%TYPE, p_tenant_id requests.tenant_id%TYPE, p_description requests.description%TYPE) IS
  BEGIN
    -- New requests always start with 'NEW' status
    INSERT INTO requests(request_id, flat_id, tenant_id, description, request_date, status)
    VALUES (request_id_seq.nextval, p_flat_id, p_tenant_id, p_description, SYSDATE, 'NEW');
  END new_request;

  PROCEDURE update_request_status(p_request_id IN requests.request_id%TYPE, p_new_status IN requests.status%TYPE) IS
  BEGIN
    IF p_new_status NOT IN ('NEW', 'IN_PROGRESS', 'RESOLVED') THEN
        raise_application_error(-20501, 'Invalid request status: ' || p_new_status);
    END IF;

    UPDATE requests SET status = p_new_status WHERE request_id = p_request_id;

    IF SQL%NOTFOUND THEN
      raise_application_error(-20502, 'Request with ID ' || p_request_id || ' not found.');
    END IF;
  END update_request_status;

  PROCEDURE assign_service(p_request_id IN requests.request_id%TYPE, p_employee_id IN employees.employee_id%TYPE, p_company_id IN service_companies.company_id%TYPE, p_note IN service_actions.note%TYPE) IS
  BEGIN
    -- Update the request status to 'IN_PROGRESS'
    update_request_status(p_request_id, 'IN_PROGRESS');

    -- Create a corresponding service_action record
    insert into service_actions(action_id, request_id, employee_id, company_id, action_date, note)
    values (action_id_seq.nextval, p_request_id, p_employee_id, p_company_id, sysdate, p_note);

  END assign_service;

  FUNCTION count_open_requests(p_flat_id flats.flat_id%TYPE) RETURN NUMBER IS
    v_count NUMBER;
  BEGIN
    SELECT COUNT(*) INTO v_count
    FROM requests
    WHERE flat_id = p_flat_id AND status != 'RESOLVED';
    RETURN v_count;
  END count_open_requests;

  FUNCTION get_request_id(
    p_flat_id      IN requests.flat_id%TYPE,
    p_tenant_id    IN requests.tenant_id%TYPE,
    p_request_date IN requests.request_date%TYPE,
    p_description  IN requests.description%TYPE
  ) RETURN requests.request_id%TYPE IS
    v_request_id requests.request_id%TYPE;
  BEGIN
    SELECT request_id
    INTO v_request_id
    FROM requests
    WHERE flat_id = p_flat_id
      AND tenant_id = p_tenant_id
      AND request_date = p_request_date
      AND description = p_description;

    RETURN v_request_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END get_request_id;
END db_request;
/

-- ==============================================
-- SERVICE COMPANIES
-- ==============================================
CREATE OR REPLACE PACKAGE db_service_company IS
  -- Vloží novou servisní společnost
  PROCEDURE new_company(
    p_name  IN service_companies.company_name%TYPE,
    p_email IN service_companies.email%TYPE,
    p_phone IN service_companies.phone%TYPE);

  -- Vrátí název společnosti podle ID
  FUNCTION get_company_name(p_company_id IN service_companies.company_id%TYPE) RETURN service_companies.company_name%TYPE;

  FUNCTION get_company_id_by_name(p_company_name IN service_companies.company_name%TYPE) RETURN service_companies.company_id%TYPE;

END db_service_company;
/

CREATE OR REPLACE PACKAGE BODY db_service_company IS
  PROCEDURE new_company(p_name service_companies.company_name%TYPE, p_email service_companies.email%TYPE, p_phone service_companies.phone%TYPE) IS
  BEGIN
    INSERT INTO service_companies(company_id, company_name, email, phone)
    VALUES (company_id_seq.nextval, p_name, p_email, p_phone);
  END new_company;

  FUNCTION get_company_name(p_company_id IN service_companies.company_id%TYPE) RETURN service_companies.company_name%TYPE IS
    v_name service_companies.company_name%TYPE;
  BEGIN
    SELECT company_name INTO v_name FROM service_companies WHERE company_id = p_company_id;
    RETURN v_name;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END get_company_name;

FUNCTION get_company_id_by_name(p_company_name IN service_companies.company_name%TYPE) RETURN service_companies.company_id%TYPE IS
    v_company_id service_companies.company_id%TYPE;
  BEGIN
    SELECT company_id
    INTO v_company_id
    FROM service_companies
    WHERE company_name = p_company_name;

    RETURN v_company_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END get_company_id_by_name;
  end db_service_company;
/

-- ==============================================
-- SERVICE ACTIONS
-- ==============================================
CREATE OR REPLACE PACKAGE db_service_action IS
  -- Přidá novou servisní akci
  PROCEDURE new_action(
    p_request_id  IN service_actions.request_id%TYPE,
    p_employee_id IN service_actions.employee_id%TYPE,
    p_company_id  IN service_actions.company_id%TYPE,
    p_date        IN service_actions.action_date%TYPE,
    p_note        IN service_actions.note%TYPE);

  -- Vrátí počet servisních akcí k dané žádosti
  FUNCTION get_action_count(p_request_id IN requests.request_id%TYPE) RETURN NUMBER;
END db_service_action;
/

CREATE OR REPLACE PACKAGE BODY db_service_action IS
  PROCEDURE new_action(p_request_id  service_actions.request_id%TYPE, p_employee_id service_actions.employee_id%TYPE, p_company_id service_actions.company_id%TYPE, p_date service_actions.action_date%TYPE, p_note service_actions.note%TYPE) IS
  BEGIN
    INSERT INTO service_actions(action_id, request_id, employee_id, company_id, action_date, note)
    VALUES (action_id_seq.nextval, p_request_id, p_employee_id, p_company_id, p_date, p_note);
  END new_action;

  FUNCTION get_action_count(p_request_id IN requests.request_id%TYPE) RETURN NUMBER IS
    v_count NUMBER;
  BEGIN
    SELECT count(*) INTO v_count FROM service_actions WHERE request_id = p_request_id;
    RETURN v_count;
  END get_action_count;
END db_service_action;
/

