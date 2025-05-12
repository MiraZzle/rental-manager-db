-- Author: Matěj Foukal

-- Owners
exec db_owner.new_owner('Anna Novak', 'anna.novak@example.com', '601123456');
exec db_owner.new_owner('Petr Svoboda', 'petr.svoboda@example.com', '777987654');
exec db_owner.new_owner('Irena Kolarova', 'irena.k@example.com', '605666777');
exec db_owner.new_owner('Jan Malek', 'jan.malek@example.com', '603222333');
exec db_owner.new_owner('Simona Hruba', 'simona.hruba@example.com', '608999888');
exec db_owner.new_owner('Tomas Vlk', 'tomas.vlk@example.com', '604123789');
exec db_owner.new_owner('Lucie Dostalova', 'lucie.dostalova@example.com', '606456123');

-- Tenants
exec db_tenant.new_tenant('Jana Vesela', 'jana.vesela@example.com', '608765432');
exec db_tenant.new_tenant('Lukas Dvorak', 'lukas.dvorak@example.com', '602111222');
exec db_tenant.new_tenant('Veronika Marek', 'vero.marek@example.com', '607777777');
exec db_tenant.new_tenant('David Novy', 'david.novy@example.com', '601888111');
exec db_tenant.new_tenant('Martina Paleckova', 'martina.p@example.com', '602654321');
exec db_tenant.new_tenant('Marek Novak', 'marek.novak@example.com', '603789456');
exec db_tenant.new_tenant('Tereza Smidova', 'tereza.s@example.com', '607111222');

-- Flats
exec db_flat.new_flat('Masarykova 12, Praha', 75, 3, 1);
exec db_flat.new_flat('Zelena 8, Brno', 65, 2, 2);
exec db_flat.new_flat('Nerudova 33, Plzen', 90, 4, 3);
exec db_flat.new_flat('Havlickova 5, Olomouc', 55, 2, 4);
exec db_flat.new_flat('Krizikova 20, Praha', 82, 3, 5);
exec db_flat.new_flat('Trnkova 77, Brno', 60, 2, 6);
exec db_flat.new_flat('Husova 101, Liberec', 100, 4, 7);

-- Contracts
exec db_contract.new_contract(1, 1, DATE '2024-01-01', null, 18000);
exec db_contract.new_contract(2, 2, DATE '2023-10-01', DATE '2024-12-31', 15000);
exec db_contract.new_contract(3, 3, DATE '2024-03-01', null, 22000);
exec db_contract.new_contract(4, 4, DATE '2024-01-15', null, 14000);
exec db_contract.new_contract(5, 5, DATE '2023-09-01', DATE '2024-08-31', 16000);
exec db_contract.new_contract(6, 6, DATE '2024-02-01', null, 17000);
exec db_contract.new_contract(7, 7, DATE '2023-07-01', DATE '2024-06-30', 19000);

-- Payments
exec db_payment.new_payment(1, DATE '2024-02-01', 18000, 'PAID');
exec db_payment.new_payment(1, DATE '2024-03-01', 18000, 'DUE');
exec db_payment.new_payment(2, DATE '2024-03-01', 15000, 'LATE');
exec db_payment.new_payment(3, DATE '2024-03-01', 22000, 'PAID');
exec db_payment.new_payment(4, DATE '2024-03-01', 14000, 'PAID');
exec db_payment.new_payment(5, DATE '2024-03-01', 16000, 'DUE');
exec db_payment.new_payment(6, DATE '2024-03-01', 17000, 'PAID');

-- Requests
exec db_request.new_request(1, 1, 'Radiator not heating.', 'NEW');
exec db_request.new_request(2, 2, 'Leaking sink.', 'IN_PROGRESS');
exec db_request.new_request(3, 3, 'Window won’t close.', 'RESOLVED');
exec db_request.new_request(4, 4, 'Mold in bathroom.', 'NEW');
exec db_request.new_request(5, 5, 'Washing machine not working.', 'IN_PROGRESS');
exec db_request.new_request(6, 6, 'Noise from neighbors.', 'NEW');
exec db_request.new_request(7, 7, 'Broken light switch.', 'IN_PROGRESS');

-- Employees
exec db_employee.new_employee('Martin Hruby', 'Technician', 'martin.hruby@example.com');
exec db_employee.new_employee('Eva Janska', 'Plumber', 'eva.janska@example.com');
exec db_employee.new_employee('Tomas Novak', 'Electrician', 'tomas.novak@example.com');
exec db_employee.new_employee('Klara Mrazova', 'Cleaner', 'klara.mrazova@example.com');
exec db_employee.new_employee('Filip Adam', 'Supervisor', 'filip.adam@example.com');
exec db_employee.new_employee('Jana Vosmikova', 'Caretaker', 'jana.vosmikova@example.com');
exec db_employee.new_employee('Ondrej Havel', 'HVAC', 'ondrej.havel@example.com');

-- Service Companies
exec db_service_company.new_company('FixIt s.r.o.', 'kontakt@fixit.cz', '603998877');
exec db_service_company.new_company('WaterWorks', 'info@waterworks.cz', '604556677');
exec db_service_company.new_company('CleanSpace', 'contact@cleanspace.cz', '605334455');
exec db_service_company.new_company('PowerGuys', 'el@powerguys.cz', '606667788');
exec db_service_company.new_company('Havaria CZ', 'info@havaria.cz', '607112233');
exec db_service_company.new_company('DomovServis', 'help@domov.cz', '608445566');
exec db_service_company.new_company('BuildingFix', 'info@buildingfix.cz', '602889900');

-- Service Actions
exec db_service_action.new_action(1, 1, 1, DATE '2024-03-05', 'Checked and replaced valve');
exec db_service_action.new_action(2, 2, 2, DATE '2024-03-07', 'Ordered new faucet');
exec db_service_action.new_action(3, 3, 3, DATE '2024-03-08', 'Adjusted window hinges');
exec db_service_action.new_action(4, 4, 4, DATE '2024-03-09', 'Removed mold');
exec db_service_action.new_action(5, 5, 5, DATE '2024-03-10', 'Machine replaced');
exec db_service_action.new_action(6, 6, 6, DATE '2024-03-11', 'Spoke with tenants');
exec db_service_action.new_action(7, 7, 7, DATE '2024-03-12', 'Switch rewired');
