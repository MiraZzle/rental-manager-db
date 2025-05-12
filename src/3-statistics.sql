-- Author: Matěj Foukal

-- Schema-level statistics
exec dbms_stats.gather_schema_stats(USER);

-- Table-level statistics with column details
exec dbms_stats.gather_table_stats(USER, 'OWNERS', cascade => TRUE);
select column_name, nullable, num_distinct, num_nulls, density, histogram from ALL_TAB_COLUMNS where table_name = 'OWNERS';

exec dbms_stats.gather_table_stats(USER, 'TENANTS', cascade => TRUE);
select column_name, nullable, num_distinct, num_nulls, density, histogram from ALL_TAB_COLUMNS where table_name = 'TENANTS';

exec dbms_stats.gather_table_stats(USER, 'FLATS', cascade => TRUE);
select column_name, nullable, num_distinct, num_nulls, density, histogram from ALL_TAB_COLUMNS where table_name = 'FLATS';

exec dbms_stats.gather_table_stats(USER, 'CONTRACTS', cascade => TRUE);
select column_name, nullable, num_distinct, num_nulls, density, histogram from ALL_TAB_COLUMNS where table_name = 'CONTRACTS';

exec dbms_stats.gather_table_stats(USER, 'PAYMENTS', cascade => TRUE);
select column_name, nullable, num_distinct, num_nulls, density, histogram from ALL_TAB_COLUMNS where table_name = 'PAYMENTS';

exec dbms_stats.gather_table_stats(USER, 'REQUESTS', cascade => TRUE);
select column_name, nullable, num_distinct, num_nulls, density, histogram from ALL_TAB_COLUMNS where table_name = 'REQUESTS';

exec dbms_stats.gather_table_stats(USER, 'EMPLOYEES', cascade => TRUE);
select column_name, nullable, num_distinct, num_nulls, density, histogram from ALL_TAB_COLUMNS where table_name = 'EMPLOYEES';

exec dbms_stats.gather_table_stats(USER, 'SERVICE_COMPANIES', cascade => TRUE);
select column_name, nullable, num_distinct, num_nulls, density, histogram from ALL_TAB_COLUMNS where table_name = 'SERVICE_COMPANIES';

exec dbms_stats.gather_table_stats(USER, 'SERVICE_ACTIONS', cascade => TRUE);
select column_name, nullable, num_distinct, num_nulls, density, histogram from ALL_TAB_COLUMNS where table_name = 'SERVICE_ACTIONS';
