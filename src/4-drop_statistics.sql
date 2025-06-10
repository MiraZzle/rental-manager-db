-- Autor: Matěj Foukal

exec dbms_stats.delete_table_stats(USER, 'PERSONS');
exec dbms_stats.delete_table_stats(USER, 'OWNERS');
exec dbms_stats.delete_table_stats(USER, 'TENANTS');
exec dbms_stats.delete_table_stats(USER, 'FLATS');
exec dbms_stats.delete_table_stats(USER, 'CONTRACTS');
exec dbms_stats.delete_table_stats(USER, 'PAYMENTS');
exec dbms_stats.delete_table_stats(USER, 'REQUESTS');
exec dbms_stats.delete_table_stats(USER, 'EMPLOYEES');
exec dbms_stats.delete_table_stats(USER, 'SERVICE_COMPANIES');
exec dbms_stats.delete_table_stats(USER, 'SERVICE_ACTIONS');