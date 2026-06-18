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

---

## Repository Structure

```
├── README.md
├── sqli.sql             # Patient & claims schema with seed data
├── rentals.sql          # Rental plans, customers & movie rentals schema
└── Q1.sql               # Atomic transaction: rental plan fee adjustment
```

---

## Source Files

### `sqli.sql` — Healthcare Schema & Seed Data

```sql
CREATE TABLE patient (
    pid integer NOT NULL,
    fname character varying(30),
    lname character varying(20),
    age integer
);

insert into patient values (1,'Lilly','Yu',52);
insert into patient values (2,'Olivia','Fletcher',100);
insert into patient values (3,'Anthony','Farrell',29);
insert into patient values (4,'Christopher','Potts',21);
insert into patient values (5,'John','Kidd',82);
insert into patient values (6,'Elizabeth','Dennis',100);
insert into patient values (7,'Ned','Bridges',7);
insert into patient values (8,'Benjamin','Crawford',87);
insert into patient values (9,'Jacob','Palmer',4);
insert into patient values (10,'Sophie','Bowen',51);
insert into patient values (11,'Emily','Lawson',91);
insert into patient values (12,'Ethan','Dodson',32);
insert into patient values (13,'Jacob','Bush',56);
insert into patient values (14,'Michael','Odom',71);
insert into patient values (15,'Jorge','Gentry',26);
insert into patient values (16,'Sophia','Calhoun',30);
insert into patient values (17,'Ava','Koch',99);
insert into patient values (18,'Andrew','Yang',55);
insert into patient values (19,'Heather','Armstrong',13);
insert into patient values (20,'Madison','Cortez',25);


CREATE TABLE claims (
    claim_id int primary key,
    claim_date DATE,
    doc VARCHAR(25),
    patient varchar(25)
);

insert into claims values (1,  '2023-06-26', 'Snaddin',       'Carnaman');
insert into claims values (2,  '2023-09-01', 'Jouhan',        'Bessom');
insert into claims values (3,  '2022-12-08', 'Node',          'Heitz');
insert into claims values (4,  '2022-11-11', 'McOwan',        'Guy');
insert into claims values (5,  '2023-05-08', 'Stuehmeyer',    'Nattrass');
insert into claims values (6,  '2023-02-02', 'Winterborne',   'Gaenor');
insert into claims values (7,  '2023-04-19', 'Caldicott',     'Scrivner');
insert into claims values (8,  '2023-01-16', 'Speenden',      'Coulbeck');
insert into claims values (9,  '2023-04-28', 'Rowaszkiewicz', 'Laverack');
insert into claims values (10, '2023-05-01', 'Pierpoint',     'Karolyi');
insert into claims values (11, '2023-02-01', 'McComiskie',    'Le Marquand');
insert into claims values (12, '2023-05-13', 'Leftly',        'Farington');
insert into claims values (13, '2023-08-17', 'Algy',          'Gouldstone');
insert into claims values (14, '2023-10-15', 'Seivwright',    'Niesegen');
insert into claims values (15, '2023-08-19', 'Girvin',        'Cordero');
insert into claims values (16, '2022-12-22', 'Catteroll',     'Vlies');
insert into claims values (17, '2023-08-28', 'Macari',        'Schwartz');
insert into claims values (18, '2022-12-02', 'Braganza',      'Parkin');
insert into claims values (19, '2022-12-07', 'Randerson',     'Stienton');
insert into claims values (20, '2022-11-04', 'Trythall',      'Somerton');
```

---

### `rentals.sql` — Movie Rental Schema & Seed Data

```sql
CREATE TABLE RentalPlans(
  pid integer PRIMARY KEY,
  name VARCHAR(50) UNIQUE NOT NULL,
  max_movies int NOT NULL,
  fee numeric(6,2) NOT NULL
);

CREATE TABLE Customers(
  cid integer PRIMARY KEY,
  login VARCHAR(50) UNIQUE,
  password VARCHAR(50),
  fname VARCHAR(50),
  lname VARCHAR(50),
  pid integer REFERENCES RentalPlans (pid)
);

CREATE TABLE MovieRentals(
  mid integer NOT NULL,
  cid integer REFERENCES Customers(cid),
  status VARCHAR(10) CHECK (status = 'open' or status = 'closed')
);

INSERT INTO RentalPlans VALUES (1, 'basic',        1,  1.99);
INSERT INTO RentalPlans VALUES (2, 'rental plus',  3,  2.99);
INSERT INTO RentalPlans VALUES (3, 'super access', 5,  3.99);
INSERT INTO RentalPlans VALUES (4, 'prime',        10, 4.99);

INSERT INTO Customers VALUES (1, 'george', '123',    'George', 'Ford',    1);
INSERT INTO Customers VALUES (2, 'tim',    'secret', 'Tim',    'Johnson', 1);

INSERT INTO MovieRentals VALUES (200741, 1, 'open');
INSERT INTO MovieRentals VALUES (516259, 1, 'closed');
```

---

### `Q1.sql` — Atomic Fee Adjustment Transaction

```sql
START TRANSACTION;
UPDATE RentalPlans SET fee = fee - 1 WHERE name = 'basic';
UPDATE RentalPlans SET fee = fee + 1 WHERE name = 'prime';
COMMIT;
```

---

### `DBConnector.py` — Database Interface

```python
import psycopg2
from psycopg2 import extensions
import time


class DBConnector:

    def __init__(self):
        self.conn = None
        self.cursor = None

    def connect_to_db(self):
        self.conn = psycopg2.connect(
            dbname=os.getenv("DB_NAME"),
            user=os.getenv("DB_USER"),
            password=os.getenv("DB_PASSWORD"),
            host=os.getenv("DB_HOST", "localhost"),
            port=os.getenv("DB_PORT", "5432")
        )

    def get_claim(self, doc, patient):
        query = "SELECT * FROM claims WHERE doc = %s AND patient = %s;"
        result = []
        try:
            self.cursor = self.conn.cursor()
            self.cursor.execute(query, (doc, patient))
            result.append(self.cursor.fetchall())
        except psycopg2.Error as e:
            result.append(('Your search did not succeed, try again.', ' '))
        return result

    def get_patient_record(self, fname, lname):
        query = "SELECT * FROM patient WHERE fname = %s AND lname = %s;"
        result = []
        try:
            self.cursor = self.conn.cursor()
            self.cursor.execute(query, (fname, lname))
            result.append(self.cursor.fetchall())
        except psycopg2.Error as e:
            result.append(('Your search did not succeed, try again.', ' '))
        return result

    def add_claim(self, claim_date, doc, patient):
        try:
            self.conn.set_isolation_level(extensions.ISOLATION_LEVEL_SERIALIZABLE)

            query = "SELECT COUNT(*) FROM claims WHERE patient = %s;"
            self.cursor = self.conn.cursor()
            self.cursor.execute(query, (patient,))
            num_claims = self.cursor.fetchone()[0]

            if num_claims > 0:
                print("Cannot add claim. The patient already has one claim.\n")
                return
            else:
                time.sleep(3)

            self.cursor.execute("SELECT MAX(claim_id) FROM claims;")
            max_claim_id = self.cursor.fetchone()[0]

            query = "INSERT INTO claims (patient, doc, claim_date, claim_id) VALUES (%s, %s, %s, %s);"
            self.cursor.execute(query, (patient, doc, claim_date, max_claim_id + 1))
            self.conn.commit()
            print("Claim added successfully.\n")

        except psycopg2.Error as e:
            print('Error while adding claim, try again.\n' + str(e))

    def close_db(self):
        self.conn.close()
```

---

### `console.py` — CLI Application

```python
from DBConnector import DBConnector

dbconn = DBConnector()
dbconn.connect_to_db()

def print_result(result):
    res_list = result[0]
    if len(res_list) == 0:
        print('no matches found')
    for i in range(len(res_list)):
        print(res_list[i])

print("Welcome! Enter a number to run a query:")

while True:
    print("1- Find claims for a specific doctor and patient.\n"
          "2- Find a patient's record using first and last name.\n"
          "3- Add a claim for a patient.\n"
          "X- Quit.")
    choice = input()
    if choice in ('X', 'x'):
        break
    elif choice == '1':
        doc = input("Doctor's name: ")
        patient = input("Patient's name: ")
        print_result(dbconn.get_claim(doc, patient))
    elif choice == '2':
        fname = input("First name: ")
        lname = input("Last name: ")
        print_result(dbconn.get_patient_record(fname, lname))
    elif choice == '3':
        claim_date = input("Claim date: ")
        doc = input("Doctor's name: ")
        patient = input("Patient's name: ")
        dbconn.add_claim(claim_date, doc, patient)

dbconn.close_db()
```
