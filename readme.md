# Rental Manager Database App

## About

This Oracle SQL-based database application manages residential rentals.
It was developed as part of the course [**Database Application Development (NDBI026)**](https://is.cuni.cz/studium/predmety/index.php?do=predmet&kod=NDBI026) at Charles University.

The system tracks:

- Flats and their owners
- Tenants and rental contracts
- Payments
- Service requests, actions, and responsible employees
- External service companies

The entity relationships should model the full lifecycle of a rental agreement and its operational management.

## Data Model

![alt](./docs/schema_r.svg)

## Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/MiraZzle/rental-manager-db.git
   ```

2. Open your Oracle SQL environment and run the SQL scripts from the `src` folder in the following order:

   ```bash
   1.0-create_schema-tabels.sql
   1.1-create_schema-procedures.sql
   1.2-create_schema-indeces.sql
   1.3-create_schema-triggers.sql
   1.4-create_schema-views.sql
   2-data.sql
   3-statistics.sql
   6-test_examples.sql
   ```

## Reset & Cleanup

To remove all schema objects and statistics:

```bash
4-drop_statistics.sql
5-drop_schema.sql
```
