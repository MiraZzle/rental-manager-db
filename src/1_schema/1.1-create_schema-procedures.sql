-- Autor: Matěj Foukal

-- ==============================================
-- SEKVENCE
-- ==============================================
create sequence flat_id_seq start with 1 increment by 1;
create sequence owner_id_seq start with 1 increment by 1;
create sequence tenant_id_seq start with 1 increment by 1;
create sequence contract_id_seq start with 1 increment by 1;
create sequence payment_id_seq start with 1 increment by 1;
create sequence request_id_seq start with 1 increment by 1;
create sequence employee_id_seq start with 1 increment by 1;
create sequence company_id_seq start with 1 increment by 1;
create sequence action_id_seq start with 1 increment by 1;

-- ==============================================
-- OWNERS
-- ==============================================
CREATE OR REPLACE PACKAGE db_owner IS
  -- Vloží nového vlastníka
  PROCEDURE new_owner(
    p_name  IN owners.owner_name%TYPE,
    p_email IN owners.email%TYPE,
    p_phone IN owners.phone%TYPE);

  -- Aktualizuje kontaktní údaje vlastníka
  PROCEDURE update_contact_info(
    p_owner_id  IN owners.owner_id%TYPE,
    p_new_email IN owners.email%TYPE,
    p_new_phone IN owners.phone%TYPE);

  -- Smaže vlastníka (pouze pokud nevlastní žádné byty)
  PROCEDURE delete_owner(p_owner_id IN owners.owner_id%TYPE);

  -- Vrátí jméno vlastníka podle ID
  FUNCTION get_owner_name(p_owner_id IN owners.owner_id%TYPE) RETURN owners.owner_name%TYPE;
END db_owner;
/

CREATE OR REPLACE PACKAGE BODY db_owner IS
  PROCEDURE new_owner(p_name IN owners.owner_name%TYPE, p_email IN owners.email%TYPE, p_phone IN owners.phone%TYPE) IS
  BEGIN
    INSERT INTO owners(owner_id, owner_name, email, phone)
    VALUES (owner_id_seq.nextval, p_name, p_email, p_phone);
  END new_owner;

  PROCEDURE update_contact_info(p_owner_id IN owners.owner_id%TYPE, p_new_email IN owners.email%TYPE, p_new_phone IN owners.phone%TYPE) IS
  BEGIN
    UPDATE owners
    SET
      email = p_new_email,
      phone = p_new_phone
    WHERE owner_id = p_owner_id;

    IF SQL%NOTFOUND THEN
        RAISE_APPLICATION_ERROR(-20200, 'Owner with ID ' || p_owner_id || ' not found.');
    END IF;
  END update_contact_info;

  PROCEDURE delete_owner(p_owner_id IN owners.owner_id%TYPE) IS
    v_flat_count NUMBER;
  BEGIN
    SELECT COUNT(*) INTO v_flat_count FROM flats WHERE owner_id = p_owner_id;

    IF v_flat_count > 0 THEN
      RAISE_APPLICATION_ERROR(-20201, 'Cannot delete owner. They still own ' || v_flat_count || ' flat(s).');
    ELSE
      DELETE FROM owners WHERE owner_id = p_owner_id;
    END IF;
  END delete_owner;

  FUNCTION get_owner_name(p_owner_id IN owners.owner_id%TYPE) RETURN owners.owner_name%TYPE IS
    v_name owners.owner_name%TYPE;
  BEGIN
    SELECT owner_name INTO v_name FROM owners WHERE owner_id = p_owner_id;
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
  -- Vloží nového nájemníka
  PROCEDURE new_tenant(
    p_name  IN tenants.tenant_name%TYPE,
    p_email IN tenants.email%TYPE,
    p_phone IN tenants.phone%TYPE);

  -- Aktualizuje kontaktní údaje nájemníka
  PROCEDURE update_contact_info(
    p_tenant_id IN tenants.tenant_id%TYPE,
    p_new_email IN tenants.email%TYPE,
    p_new_phone IN tenants.phone%TYPE);

  -- Smaže nájemníka (pouze pokud nemá žádné smlouvy)
  PROCEDURE delete_tenant(p_tenant_id IN tenants.tenant_id%TYPE);

  -- Vrátí jméno nájemníka podle ID
  FUNCTION get_tenant_name(p_tenant_id IN tenants.tenant_id%TYPE) RETURN tenants.tenant_name%TYPE;
END db_tenant;
/

CREATE OR REPLACE PACKAGE BODY db_tenant IS
  PROCEDURE new_tenant(p_name IN tenants.tenant_name%TYPE, p_email IN tenants.email%TYPE, p_phone IN tenants.phone%TYPE) IS
  BEGIN
    INSERT INTO tenants(tenant_id, tenant_name, email, phone)
    VALUES (tenant_id_seq.nextval, p_name, p_email, p_phone);
  END new_tenant;

  PROCEDURE update_contact_info(p_tenant_id IN tenants.tenant_id%TYPE, p_new_email IN tenants.email%TYPE, p_new_phone IN tenants.phone%TYPE) IS
  BEGIN
    UPDATE tenants
    SET
      email = p_new_email,
      phone = p_new_phone
    WHERE tenant_id = p_tenant_id;

    IF SQL%NOTFOUND THEN
        RAISE_APPLICATION_ERROR(-20210, 'Tenant with ID ' || p_tenant_id || ' not found.');
    END IF;
  END update_contact_info;

  PROCEDURE delete_tenant(p_tenant_id IN tenants.tenant_id%TYPE) IS
    v_contract_count NUMBER;
  BEGIN
    SELECT COUNT(*) INTO v_contract_count FROM contracts WHERE tenant_id = p_tenant_id;

    IF v_contract_count > 0 THEN
      RAISE_APPLICATION_ERROR(-20211, 'Cannot delete tenant. They have ' || v_contract_count || ' contract(s).');
    ELSE
      DELETE FROM tenants WHERE tenant_id = p_tenant_id;
    END IF;
  END delete_tenant;

  FUNCTION get_tenant_name(p_tenant_id IN tenants.tenant_id%TYPE) RETURN tenants.tenant_name%TYPE IS
    v_name tenants.tenant_name%TYPE;
  BEGIN
    SELECT tenant_name INTO v_name FROM tenants WHERE tenant_id = p_tenant_id;
    RETURN v_name;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END get_tenant_name;
END db_tenant;
/

-- ==============================================
-- FLATS
-- ==============================================
CREATE OR REPLACE PACKAGE db_flat IS
  -- Vloží nový byt
  PROCEDURE new_flat(
    p_address  IN flats.address%TYPE,
    p_area     IN flats.area%TYPE,
    p_rooms    IN flats.rooms%TYPE,
    p_owner_id IN flats.owner_id%TYPE);

  -- Přeřadí byt na nového vlastníka
  PROCEDURE reassign_flat(p_flat_id IN flats.flat_id%TYPE, p_new_owner_id IN owners.owner_id%TYPE);

  -- Vrátí adresu bytu podle ID
  FUNCTION get_flat_address(p_flat_id IN flats.flat_id%TYPE) RETURN flats.address%TYPE;

  -- Vrátí seznam bytů pro daného vlastníka
  FUNCTION get_flats_by_owner(p_owner_id IN owners.owner_id%TYPE) RETURN SYS_REFCURSOR;

  -- Vrátí jméno aktuálního nájemníka bytu
  FUNCTION get_current_tenant_name(p_flat_id IN flats.flat_id%TYPE) RETURN tenants.tenant_name%TYPE;
END db_flat;
/

CREATE OR REPLACE PACKAGE BODY db_flat IS
  PROCEDURE new_flat(p_address flats.address%TYPE, p_area flats.area%TYPE, p_rooms flats.rooms%TYPE, p_owner_id flats.owner_id%TYPE) IS
  BEGIN
    INSERT INTO flats(flat_id, address, area, rooms, owner_id)
    VALUES (flat_id_seq.nextval, p_address, p_area, p_rooms, p_owner_id);
  END new_flat;

  PROCEDURE reassign_flat(p_flat_id IN flats.flat_id%TYPE, p_new_owner_id IN owners.owner_id%TYPE) IS
    v_check NUMBER;
  BEGIN
    -- First, verify the new owner actually exists to prevent foreign key errors
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

  FUNCTION get_current_tenant_name(p_flat_id IN flats.flat_id%TYPE) RETURN tenants.tenant_name%TYPE IS
    v_tenant_name tenants.tenant_name%TYPE;
  BEGIN
    SELECT t.tenant_name INTO v_tenant_name
    FROM contracts c
    JOIN tenants t ON c.tenant_id = t.tenant_id
    WHERE c.flat_id = p_flat_id
      AND c.start_date <= SYSDATE
      AND (c.end_date IS NULL OR c.end_date >= SYSDATE)
      AND ROWNUM = 1; -- Pouze jeden zaznam je vracen, pokud jich je vice

    RETURN v_tenant_name;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 'Unoccupied';
  END get_current_tenant_name;

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
END db_request;
/

-- ==============================================
-- EMPLOYEES
-- ==============================================
CREATE OR REPLACE PACKAGE db_employee IS
  -- Vloží nového zaměstnance
  PROCEDURE new_employee(
    p_name  IN employees.employee_name%TYPE,
    p_role  IN employees.role%TYPE,
    p_email IN employees.email%TYPE);

  -- Vrátí jméno zaměstnance podle ID
  FUNCTION get_employee_name(p_employee_id IN employees.employee_id%TYPE) RETURN employees.employee_name%TYPE;
END db_employee;
/

CREATE OR REPLACE PACKAGE BODY db_employee IS
  PROCEDURE new_employee(p_name employees.employee_name%TYPE, p_role employees.role%TYPE, p_email employees.email%TYPE) IS
  BEGIN
    INSERT INTO employees(employee_id, employee_name, "ROLE", email)
    VALUES (employee_id_seq.nextval, p_name, p_role, p_email);
  END new_employee;

  FUNCTION get_employee_name(p_employee_id employees.employee_id%TYPE) RETURN employees.employee_name%TYPE IS
    v_name employees.employee_name%TYPE;
  BEGIN
    SELECT employee_name INTO v_name FROM employees WHERE employee_id = p_employee_id;
    RETURN v_name;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END get_employee_name;
END db_employee;
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

