# PostgreSQL Claims & Rental Management System

A relational database project built with PostgreSQL demonstrating secure query design, transaction management, and concurrency control across two real-world domains: healthcare claims processing and a movie rental service.

---

## Highlights

- 🔒 **SQL injection-proof** — all queries use parameterized statements via `psycopg2`
- ⚙️ **Concurrency-safe inserts** — serializable transaction isolation prevents duplicate claims under concurrent load
- 🎬 **Two production-style schemas** — healthcare claims and a tiered movie rental service
- 🐍 **Python-backed CLI** — interactive terminal app for querying and writing to the database

---

## Tech Stack

| Layer | Technology |
|---|---|
| Database | PostgreSQL |
| Backend | Python 3, psycopg2 |
| Query Design | Parameterized SQL (prepared statements) |
| Concurrency | SERIALIZABLE isolation level |

---

## Schemas

### Healthcare Claims

```
patient
├── pid        INTEGER  (PK)
├── fname      VARCHAR(30)
├── lname      VARCHAR(20)
└── age        INTEGER

claims
├── claim_id   INTEGER  (PK)
├── claim_date DATE
├── doc        VARCHAR(25)
└── patient    VARCHAR(25)
```

### Movie Rental Service

```
RentalPlans
├── pid         INTEGER  (PK)
├── name        VARCHAR(50) UNIQUE
├── max_movies  INTEGER
└── fee         NUMERIC(6,2)

Customers
├── cid         INTEGER  (PK)
├── login       VARCHAR(50) UNIQUE
├── fname / lname VARCHAR(50)
└── pid         INTEGER  (FK → RentalPlans)

MovieRentals
├── mid         INTEGER
├── cid         INTEGER  (FK → Customers)
└── status      VARCHAR(10)  CHECK('open' | 'closed')
```

Rental tiers: `basic` ($1.99) · `rental plus` ($2.99) · `super access` ($3.99) · `prime` ($4.99)

---

## Setup

### Prerequisites

- PostgreSQL installed and running
- Python 3.x
- psycopg2: `pip install psycopg2`

### Load the schemas

```bash
psql -U postgres -c "CREATE DATABASE your_db_name;"
psql -U postgres -d your_db_name -f sqli.sql
psql -U postgres -d your_db_name -f rentals.sql
```

---

## Security: SQL Injection Prevention

A core focus of this project was building queries that are safe against injection attacks. Every user-supplied value is passed as a parameter — never interpolated into the query string.

```python
# ❌ Vulnerable approach — never do this:
query = "SELECT * FROM claims WHERE patient= '" + patient + "';"

# ✅ Safe parameterized statement:
query = "SELECT * FROM claims WHERE patient = %s;"
cursor.execute(query, (patient,))
```

Input like `' OR '1'='1` is treated as a literal string, not executable SQL.

---

## Concurrency Control: Preventing Duplicate Claims

The claim insertion logic handles a classic **write-skew race condition**: two sessions checking simultaneously could both see zero existing claims and both proceed to insert. This is solved with `SERIALIZABLE` isolation, which forces transactions to behave as if they ran sequentially.

```python
conn.set_isolation_level(extensions.ISOLATION_LEVEL_SERIALIZABLE)

# 1. Check for existing claim
cursor.execute("SELECT COUNT(*) FROM claims WHERE patient = %s;", (patient,))
if cursor.fetchone()[0] > 0:
    print("Patient already has a claim.")
    return

# 2. Get next ID and insert
cursor.execute("SELECT MAX(claim_id) FROM claims;")
max_id = cursor.fetchone()[0]

cursor.execute(
    "INSERT INTO claims (claim_id, claim_date, doc, patient) VALUES (%s, %s, %s, %s);",
    (max_id + 1, claim_date, doc, patient)
)
conn.commit()
```

If two sessions race, PostgreSQL serializes them — one succeeds, one is safely rolled back.

---

## Atomic Transactions

`Q1.sql` demonstrates an atomic fee adjustment across rental plan tiers. Both updates commit together or not at all, ensuring no intermediate state is ever visible to other sessions.

```sql
START TRANSACTION;
UPDATE RentalPlans SET fee = fee - 1 WHERE name = 'basic';
UPDATE RentalPlans SET fee = fee + 1 WHERE name = 'prime';
COMMIT;
```
```
