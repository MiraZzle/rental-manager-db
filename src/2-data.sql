-- Autor: Matěj Foukal

BEGIN
    -- Owners
    db_owner.new_owner('Anna Novak', 'anna.novak@example.com', '601123456', '111222333/0800');
    db_owner.new_owner('Petr Svoboda', 'petr.svoboda@example.com', '777987654', '222333444/0100');
    db_owner.new_owner('Irena Kolarova', 'irena.k@example.com', '605666777', '333444555/0300');
    db_owner.new_owner('Jan Malek', 'jan.malek@example.com', '603222333', '444555666/0600');
    db_owner.new_owner('Simona Hruba', 'simona.hruba@example.com', '608999888', '555666777/2700');
    db_owner.new_owner('Tomas Vlk', 'tomas.vlk@example.com', '604123789', '666777888/5500');
    db_owner.new_owner('Lucie Dostalova', 'lucie.dostalova@example.com', '606456123', '777888999/0710');

    -- Tenants
    db_tenant.new_tenant('Jana Vesela', 'jana.vesela@example.com', '608765432', p_notes => 'Prefers communication via email.');
    db_tenant.new_tenant('Lukas Dvorak', 'lukas.dvorak@example.com', '602111222');
    db_tenant.new_tenant('Veronika Marek', 'vero.marek@example.com', '607777777');
    db_tenant.new_tenant('David Novy', 'david.novy@example.com', '601888111');
    db_tenant.new_tenant('Martina Paleckova', 'martina.p@example.com', '602654321');
    db_tenant.new_tenant('Marek Novak', 'marek.novak@example.com', '603789456');
    db_tenant.new_tenant('Tereza Smidova', 'tereza.s@example.com', '607111222');

    -- Flats
    db_flat.new_flat('Masarykova 12, Praha', 75, 3, 1);
    db_flat.new_flat('Zelena 8, Brno', 65, 2, 2);
    db_flat.new_flat('Nerudova 33, Plzen', 90, 4, 3);
    db_flat.new_flat('Havlickova 5, Olomouc', 55, 2, 4);
    db_flat.new_flat('Krizikova 20, Praha', 82, 3, 5);
    db_flat.new_flat('Trnkova 77, Brno', 60, 2, 6);
    db_flat.new_flat('Husova 101, Liberec', 100, 4, 7);

    -- Contracts
    db_contract.new_contract(1, 1, DATE '2024-01-01', null, 18000);
    db_contract.new_contract(2, 2, DATE '2023-10-01', DATE '2024-12-31', 15000);
    db_contract.new_contract(3, 3, DATE '2024-03-01', null, 22000);
    db_contract.new_contract(4, 4, DATE '2024-01-15', null, 14000);
    db_contract.new_contract(5, 5, DATE '2023-09-01', DATE '2024-08-31', 16000);
    db_contract.new_contract(6, 6, DATE '2024-02-01', null, 17000);
    db_contract.new_contract(7, 7, DATE '2023-07-01', DATE '2024-06-30', 19000);

    -- Payments
    db_payment.new_payment(1, DATE '2024-02-01', 18000, 'PAID');
    db_payment.new_payment(1, DATE '2024-03-01', 18000, 'DUE');
    db_payment.new_payment(2, DATE '2024-03-01', 15000, 'LATE');
    db_payment.new_payment(3, DATE '2024-03-01', 22000, 'PAID');
    db_payment.new_payment(4, DATE '2024-03-01', 14000, 'PAID');
    db_payment.new_payment(5, DATE '2024-03-01', 16000, 'DUE');
    db_payment.new_payment(6, DATE '2024-03-01', 17000, 'PAID');

    -- Requests
    db_request.new_request(1, 1, 'Radiator not heating.');
    db_request.new_request(2, 2, 'Leaking sink.');
    db_request.new_request(3, 3, 'Window won’t close.');
    db_request.new_request(4, 4, 'Mold in bathroom.');
    db_request.new_request(5, 5, 'Washing machine not working.');
    db_request.new_request(6, 6, 'Noise from neighbors.');
    db_request.new_request(7, 7, 'Broken light switch.');

    -- Employees
    db_employee.new_employee('Martin Hruby', 'martin.hruby@example.com', '777000001', 'Technician');
    db_employee.new_employee('Eva Janska', 'eva.janska@example.com', '777000002', 'Plumber');
    db_employee.new_employee('Tomas Novak', 'tomas.novak@example.com', '777000003', 'Electrician');
    db_employee.new_employee('Klara Mrazova', 'klara.mrazova@example.com', '777000004', 'Cleaner');
    db_employee.new_employee('Filip Adam', 'filip.adam@example.com', '777000005', 'Supervisor');
    db_employee.new_employee('Jana Vosmikova', 'jana.vosmikova@example.com', '777000006', 'Caretaker');
    db_employee.new_employee('Ondrej Havel', 'ondrej.havel@example.com', '777000007', 'HVAC');

    -- Service Companies
    db_service_company.new_company('FixIt s.r.o.', 'kontakt@fixit.cz', '603998877');
    db_service_company.new_company('WaterWorks', 'info@waterworks.cz', '604556677');
    db_service_company.new_company('CleanSpace', 'contact@cleanspace.cz', '605334455');
    db_service_company.new_company('PowerGuys', 'el@powerguys.cz', '606667788');
    db_service_company.new_company('Havaria CZ', 'info@havaria.cz', '607112233');
    db_service_company.new_company('DomovServis', 'help@domov.cz', '608445566');
    db_service_company.new_company('BuildingFix', 'info@buildingfix.cz', '602889900');

    -- Service Actions
    db_service_action.new_action(1, 1, 1, DATE '2024-03-05', 'Checked and replaced valve');
    db_service_action.new_action(2, 2, 2, DATE '2024-03-07', 'Ordered new faucet');
    db_service_action.new_action(3, null, 7, DATE '2024-03-08', 'Adjusted window hinges');
    db_service_action.new_action(4, 4, null, DATE '2024-03-09', 'Removed mold');
    db_service_action.new_action(5, 5, 5, DATE '2024-03-10', 'Machine replaced');
    db_service_action.new_action(6, 6, 6, DATE '2024-03-11', 'Spoke with tenants');
    db_service_action.new_action(7, 7, 7, DATE '2024-03-12', 'Switch rewired');

    -- Request Status Updates
    db_request.update_request_status(1, 'RESOLVED');
    db_request.update_request_status(2, 'IN_PROGRESS');
    db_request.update_request_status(3, 'RESOLVED');
    db_request.update_request_status(4, 'RESOLVED');
    db_request.update_request_status(5, 'RESOLVED');
    db_request.update_request_status(6, 'RESOLVED');
    db_request.update_request_status(7, 'RESOLVED');

END;
/

COMMIT;