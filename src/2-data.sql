-- Autor: Matěj Foukal

DECLARE
    -- majitele ids
    v_owner_novak_id       persons.person_id%TYPE;
    v_owner_svoboda_id     persons.person_id%TYPE;
    v_owner_kolarova_id    persons.person_id%TYPE;
    v_owner_malek_id       persons.person_id%TYPE;
    v_owner_hruba_id       persons.person_id%TYPE;
    v_owner_vlk_id         persons.person_id%TYPE;
    v_owner_dostalova_id   persons.person_id%TYPE;

    -- najemnici ids
    v_tenant_vesela_id     persons.person_id%TYPE;
    v_tenant_dvorak_id     persons.person_id%TYPE;
    v_tenant_marek_id      persons.person_id%TYPE;
    v_tenant_novy_id       persons.person_id%TYPE;
    v_tenant_paleckova_id  persons.person_id%TYPE;
    v_tenant_mnovak_id     persons.person_id%TYPE;
    v_tenant_smidova_id    persons.person_id%TYPE;

    -- byty ids
    v_flat1_id             flats.flat_id%TYPE;
    v_flat2_id             flats.flat_id%TYPE;
    v_flat3_id             flats.flat_id%TYPE;
    v_flat4_id             flats.flat_id%TYPE;
    v_flat5_id             flats.flat_id%TYPE;
    v_flat6_id             flats.flat_id%TYPE;
    v_flat7_id             flats.flat_id%TYPE;

    -- kontrakt ids
    v_contract1_id         contracts.contract_id%TYPE;
    v_contract2_id         contracts.contract_id%TYPE;
    v_contract3_id         contracts.contract_id%TYPE;
    v_contract4_id         contracts.contract_id%TYPE;
    v_contract5_id         contracts.contract_id%TYPE;
    v_contract6_id         contracts.contract_id%TYPE;
    v_contract7_id         contracts.contract_id%TYPE;

    -- requesty ids
    v_request1_id          requests.request_id%TYPE;
    v_request2_id          requests.request_id%TYPE;
    v_request3_id          requests.request_id%TYPE;
    v_request4_id          requests.request_id%TYPE;
    v_request5_id          requests.request_id%TYPE;
    v_request6_id          requests.request_id%TYPE;
    v_request7_id          requests.request_id%TYPE;

    -- zamestnanci ids
    v_emp_hruby_id         persons.person_id%TYPE;
    v_emp_janska_id        persons.person_id%TYPE;
    v_emp_novak_id         persons.person_id%TYPE;
    v_emp_mrazova_id       persons.person_id%TYPE;
    v_emp_adam_id          persons.person_id%TYPE;
    v_emp_vosmikova_id     persons.person_id%TYPE;
    v_emp_havel_id         persons.person_id%TYPE;

    -- firmy ids
    v_comp_fixit_id        service_companies.company_id%TYPE;
    v_comp_water_id        service_companies.company_id%TYPE;
    v_comp_clean_id        service_companies.company_id%TYPE;
    v_comp_power_id        service_companies.company_id%TYPE;
    v_comp_havaria_id      service_companies.company_id%TYPE;
    v_comp_domov_id        service_companies.company_id%TYPE;
    v_comp_building_id     service_companies.company_id%TYPE;

BEGIN
    db_owner.new_owner('Anna Novak', 'anna.novak@example.com', '601123456', '111222333/0800');
    db_owner.new_owner('Petr Svoboda', 'petr.svoboda@example.com', '777987654', '222333444/0100');
    db_owner.new_owner('Irena Kolarova', 'irena.k@example.com', '605666777', '333444555/0300');
    db_owner.new_owner('Jan Malek', 'jan.malek@example.com', '603222333', '444555666/0600');
    db_owner.new_owner('Simona Hruba', 'simona.hruba@example.com', '608999888', '555666777/2700');
    db_owner.new_owner('Tomas Vlk', 'tomas.vlk@example.com', '604123789', '666777888/5500');
    db_owner.new_owner('Lucie Dostalova', 'lucie.dostalova@example.com', '606456123', '777888999/0710');

    v_owner_novak_id     := db_person.get_person_id_by_email('anna.novak@example.com');
    v_owner_svoboda_id   := db_person.get_person_id_by_email('petr.svoboda@example.com');
    v_owner_kolarova_id  := db_person.get_person_id_by_email('irena.k@example.com');
    v_owner_malek_id     := db_person.get_person_id_by_email('jan.malek@example.com');
    v_owner_hruba_id     := db_person.get_person_id_by_email('simona.hruba@example.com');
    v_owner_vlk_id       := db_person.get_person_id_by_email('tomas.vlk@example.com');
    v_owner_dostalova_id := db_person.get_person_id_by_email('lucie.dostalova@example.com');

    db_tenant.new_tenant('Jana Vesela', 'jana.vesela@example.com', '608765432', p_notes => 'Prefers communication via email.');
    db_tenant.new_tenant('Lukas Dvorak', 'lukas.dvorak@example.com', '602111222');
    db_tenant.new_tenant('Veronika Marek', 'vero.marek@example.com', '607777777');
    db_tenant.new_tenant('David Novy', 'david.novy@example.com', '601888111');
    db_tenant.new_tenant('Martina Paleckova', 'martina.p@example.com', '602654321');
    db_tenant.new_tenant('Marek Novak', 'marek.novak@example.com', '603789456');
    db_tenant.new_tenant('Tereza Smidova', 'tereza.s@example.com', '607111222');

    v_tenant_vesela_id    := db_person.get_person_id_by_email('jana.vesela@example.com');
    v_tenant_dvorak_id    := db_person.get_person_id_by_email('lukas.dvorak@example.com');
    v_tenant_marek_id     := db_person.get_person_id_by_email('vero.marek@example.com');
    v_tenant_novy_id      := db_person.get_person_id_by_email('david.novy@example.com');
    v_tenant_paleckova_id := db_person.get_person_id_by_email('martina.p@example.com');
    v_tenant_mnovak_id    := db_person.get_person_id_by_email('marek.novak@example.com');
    v_tenant_smidova_id   := db_person.get_person_id_by_email('tereza.s@example.com');

    db_flat.new_flat('Masarykova 12, Praha', 101, 75, 3, v_owner_novak_id);
    db_flat.new_flat('Zelena 8, Brno', 2, 65, 2, v_owner_svoboda_id);
    db_flat.new_flat('Nerudova 33, Plzen', 33, 90, 4, v_owner_kolarova_id);
    db_flat.new_flat('Havlickova 5, Olomouc', 1, 55, 2, v_owner_malek_id);
    db_flat.new_flat('Krizikova 20, Praha', 205, 82, 3, v_owner_hruba_id);
    db_flat.new_flat('Trnkova 77, Brno', 7, 60, 2, v_owner_vlk_id);
    db_flat.new_flat('Husova 101, Liberec', 1, 100, 4, v_owner_dostalova_id);

    v_flat1_id := db_flat.get_flat_id_by_address('Masarykova 12, Praha', 101);
    v_flat2_id := db_flat.get_flat_id_by_address('Zelena 8, Brno', 2);
    v_flat3_id := db_flat.get_flat_id_by_address('Nerudova 33, Plzen', 33);
    v_flat4_id := db_flat.get_flat_id_by_address('Havlickova 5, Olomouc', 1);
    v_flat5_id := db_flat.get_flat_id_by_address('Krizikova 20, Praha', 205);
    v_flat6_id := db_flat.get_flat_id_by_address('Trnkova 77, Brno', 7);
    v_flat7_id := db_flat.get_flat_id_by_address('Husova 101, Liberec', 1);

    db_contract.new_contract(v_flat1_id, v_tenant_vesela_id, DATE '2024-01-01', null, 18000);
    db_contract.new_contract(v_flat2_id, v_tenant_dvorak_id, DATE '2023-10-01', DATE '2024-12-31', 15000);
    db_contract.new_contract(v_flat3_id, v_tenant_marek_id, DATE '2024-03-01', null, 22000);
    db_contract.new_contract(v_flat4_id, v_tenant_novy_id, DATE '2024-01-15', null, 14000);
    db_contract.new_contract(v_flat5_id, v_tenant_paleckova_id, DATE '2023-09-01', DATE '2024-08-31', 16000);
    db_contract.new_contract(v_flat6_id, v_tenant_mnovak_id, DATE '2024-02-01', null, 17000);
    db_contract.new_contract(v_flat7_id, v_tenant_smidova_id, DATE '2023-07-01', DATE '2024-06-30', 19000);

    v_contract1_id := db_contract.get_contract_id(v_flat1_id, v_tenant_vesela_id, DATE '2024-01-01');
    v_contract2_id := db_contract.get_contract_id(v_flat2_id, v_tenant_dvorak_id, DATE '2023-10-01');
    v_contract3_id := db_contract.get_contract_id(v_flat3_id, v_tenant_marek_id, DATE '2024-03-01');
    v_contract4_id := db_contract.get_contract_id(v_flat4_id, v_tenant_novy_id, DATE '2024-01-15');
    v_contract5_id := db_contract.get_contract_id(v_flat5_id, v_tenant_paleckova_id, DATE '2023-09-01');
    v_contract6_id := db_contract.get_contract_id(v_flat6_id, v_tenant_mnovak_id, DATE '2024-02-01');
    v_contract7_id := db_contract.get_contract_id(v_flat7_id, v_tenant_smidova_id, DATE '2023-07-01');

    db_payment.new_payment(v_contract1_id, DATE '2024-02-01', 18000, 'PAID');
    db_payment.new_payment(v_contract1_id, DATE '2024-03-01', 18000, 'DUE');
    db_payment.new_payment(v_contract2_id, DATE '2024-03-01', 15000, 'LATE');
    db_payment.new_payment(v_contract3_id, DATE '2024-03-01', 22000, 'PAID');
    db_payment.new_payment(v_contract4_id, DATE '2024-03-01', 14000, 'PAID');
    db_payment.new_payment(v_contract5_id, DATE '2024-03-01', 16000, 'DUE');
    db_payment.new_payment(v_contract6_id, DATE '2024-03-01', 17000, 'PAID');


    db_request.new_request(v_flat1_id, v_tenant_vesela_id, 'Radiator not heating.');
    SELECT request_id INTO v_request1_id FROM requests WHERE flat_id = v_flat1_id AND tenant_id = v_tenant_vesela_id AND description = 'Radiator not heating.' AND ROWNUM = 1 ORDER BY request_date DESC;

    db_request.new_request(v_flat2_id, v_tenant_dvorak_id, 'Leaking sink.');
    SELECT request_id INTO v_request2_id FROM requests WHERE flat_id = v_flat2_id AND tenant_id = v_tenant_dvorak_id AND description = 'Leaking sink.' AND ROWNUM = 1 ORDER BY request_date DESC;

    db_request.new_request(v_flat3_id, v_tenant_marek_id, 'Window won’t close.');
    SELECT request_id INTO v_request3_id FROM requests WHERE flat_id = v_flat3_id AND tenant_id = v_tenant_marek_id AND description = 'Window won’t close.' AND ROWNUM = 1 ORDER BY request_date DESC;

    db_request.new_request(v_flat4_id, v_tenant_novy_id, 'Mold in bathroom.');
    SELECT request_id INTO v_request4_id FROM requests WHERE flat_id = v_flat4_id AND tenant_id = v_tenant_novy_id AND description = 'Mold in bathroom.' AND ROWNUM = 1 ORDER BY request_date DESC;

    db_request.new_request(v_flat5_id, v_tenant_paleckova_id, 'Washing machine not working.');
    SELECT request_id INTO v_request5_id FROM requests WHERE flat_id = v_flat5_id AND tenant_id = v_tenant_paleckova_id AND description = 'Washing machine not working.' AND ROWNUM = 1 ORDER BY request_date DESC;

    db_request.new_request(v_flat6_id, v_tenant_mnovak_id, 'Noise from neighbors.');
    SELECT request_id INTO v_request6_id FROM requests WHERE flat_id = v_flat6_id AND tenant_id = v_tenant_mnovak_id AND description = 'Noise from neighbors.' AND ROWNUM = 1 ORDER BY request_date DESC;

    db_request.new_request(v_flat7_id, v_tenant_smidova_id, 'Broken light switch.');
    SELECT request_id INTO v_request7_id FROM requests WHERE flat_id = v_flat7_id AND tenant_id = v_tenant_smidova_id AND description = 'Broken light switch.' AND ROWNUM = 1 ORDER BY request_date DESC;

    db_employee.new_employee('Martin Hruby', 'martin.hruby@example.com', '777000001', 'Technician');
    db_employee.new_employee('Eva Janska', 'eva.janska@example.com', '777000002', 'Plumber');
    db_employee.new_employee('Tomas Novak', 'tomas.novak@example.com', '777000003', 'Electrician');
    db_employee.new_employee('Klara Mrazova', 'klara.mrazova@example.com', '777000004', 'Cleaner');
    db_employee.new_employee('Filip Adam', 'filip.adam@example.com', '777000005', 'Supervisor');
    db_employee.new_employee('Jana Vosmikova', 'jana.vosmikova@example.com', '777000006', 'Caretaker');
    db_employee.new_employee('Ondrej Havel', 'ondrej.havel@example.com', '777000007', 'HVAC');

    v_emp_hruby_id      := db_person.get_person_id_by_email('martin.hruby@example.com');
    v_emp_janska_id     := db_person.get_person_id_by_email('eva.janska@example.com');
    v_emp_novak_id      := db_person.get_person_id_by_email('tomas.novak@example.com');
    v_emp_mrazova_id    := db_person.get_person_id_by_email('klara.mrazova@example.com');
    v_emp_adam_id       := db_person.get_person_id_by_email('filip.adam@example.com');
    v_emp_vosmikova_id  := db_person.get_person_id_by_email('jana.vosmikova@example.com');
    v_emp_havel_id      := db_person.get_person_id_by_email('ondrej.havel@example.com');

    db_service_company.new_company('FixIt s.r.o.', 'kontakt@fixit.cz', '603998877');
    db_service_company.new_company('WaterWorks', 'info@waterworks.cz', '604556677');
    db_service_company.new_company('CleanSpace', 'contact@cleanspace.cz', '605334455');
    db_service_company.new_company('PowerGuys', 'el@powerguys.cz', '606667788');
    db_service_company.new_company('Havaria CZ', 'info@havaria.cz', '607112233');
    db_service_company.new_company('DomovServis', 'help@domov.cz', '608445566');
    db_service_company.new_company('BuildingFix', 'info@buildingfix.cz', '602889900');

    v_comp_fixit_id    := db_service_company.get_company_id_by_name('FixIt s.r.o.');
    v_comp_water_id    := db_service_company.get_company_id_by_name('WaterWorks');
    v_comp_clean_id    := db_service_company.get_company_id_by_name('CleanSpace');
    v_comp_power_id    := db_service_company.get_company_id_by_name('PowerGuys');
    v_comp_havaria_id  := db_service_company.get_company_id_by_name('Havaria CZ');
    v_comp_domov_id    := db_service_company.get_company_id_by_name('DomovServis');
    v_comp_building_id := db_service_company.get_company_id_by_name('BuildingFix');

    db_service_action.new_action(v_request1_id, v_emp_hruby_id, v_comp_fixit_id, DATE '2024-03-05', 'Checked and replaced valve');
    db_service_action.new_action(v_request2_id, v_emp_janska_id, v_comp_water_id, DATE '2024-03-07', 'Ordered new faucet');
    db_service_action.new_action(v_request3_id, null, v_comp_building_id, DATE '2024-03-08', 'Adjusted window hinges');
    db_service_action.new_action(v_request4_id, v_emp_mrazova_id, null, DATE '2024-03-09', 'Removed mold');
    db_service_action.new_action(v_request5_id, v_emp_adam_id, v_comp_havaria_id, DATE '2024-03-10', 'Machine replaced');
    db_service_action.new_action(v_request6_id, v_emp_vosmikova_id, v_comp_domov_id, DATE '2024-03-11', 'Spoke with tenants');
    db_service_action.new_action(v_request7_id, v_emp_havel_id, v_comp_power_id, DATE '2024-03-12', 'Switch rewired');

    db_request.update_request_status(v_request1_id, 'RESOLVED');
    db_request.update_request_status(v_request2_id, 'IN_PROGRESS');
    db_request.update_request_status(v_request3_id, 'RESOLVED');
    db_request.update_request_status(v_request4_id, 'RESOLVED');
    db_request.update_request_status(v_request5_id, 'RESOLVED');
    db_request.update_request_status(v_request6_id, 'RESOLVED');
    db_request.update_request_status(v_request7_id, 'RESOLVED');

END;
/

COMMIT;