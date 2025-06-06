-- Autor: Matěj Foukal

create or replace trigger contracts_insert
before insert on contracts
for each row
begin
  if (:new.end_date is not null and :new.start_date > :new.end_date) then
    raise_application_error(-20101, 'Start date must be before or equal to end date.');
  end if;
end;
/

create or replace trigger payments_insert
before insert on payments
for each row
begin
  if (:new.amount <= 0) then
    raise_application_error(-20102, 'Payment amount must be greater than 0.');
  end if;

  if (:new.status not in ('PAID', 'DUE', 'LATE')) then
    raise_application_error(-20103, 'Invalid payment status.');
  end if;
end;
/

create or replace trigger requests_insert
before insert on requests
for each row
begin
  if (:new.status not in ('NEW', 'IN_PROGRESS', 'RESOLVED')) then
    raise_application_error(-20104, 'Invalid request status.');
  end if;
end;
/
