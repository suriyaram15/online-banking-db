# 🏦 Online Banking Database Project

This project contains a complete SQL script for setting up an **Online Banking System** backend database. It is designed to support banking operations such as managing customers, accounts, transactions, loans, and more.

---

## 📂 Project Contents

- `Online Banking DB.sql`: SQL file to create and initialize all necessary tables for the banking database.

---

## 🚀 Getting Started

Follow the steps below to set up and run the database locally using MySQL.

---

### ✅ Prerequisites

- [MySQL Server](https://dev.mysql.com/downloads/mysql/)
- [MySQL Workbench](https://dev.mysql.com/downloads/workbench/) or MySQL CLI
- Git (for cloning the repo)

---

### 📥 Clone the Repository

```bash
git clone https://github.com/suriyaram15/online-banking-db.git
cd online-banking-db
```

> Replace `your-username` with your GitHub username.

---

### 🛠️ Set Up the Database

#### Method 1: Using MySQL Workbench

1. Open **MySQL Workbench**.
2. Connect to your MySQL server.
3. Open the `Online Banking DB.sql` file.
4. Click **Run** (⚡) to execute the script.
5. The database and all tables will be created.

#### Method 2: Using MySQL Command Line

```bash
mysql -u your_username -p
```

After entering your password:

```sql
SOURCE path/to/Online\ Banking\ DB.sql;
```

> Make sure to provide the full path to the SQL file.

---

## 🧱 Database Schema Overview

The SQL script creates multiple interrelated tables supporting core banking operations.

### 🔹 `customer`
Stores information about customers.
| Column           | Type        | Description                    |
|------------------|-------------|--------------------------------|
| `customer_id`    | INT (PK)    | Unique ID                      |
| `customer_name`  | VARCHAR     | Full name                      |
| `customer_dob`   | DATE        | Date of birth                  |
| `customer_address` | TEXT      | Address                        |
| `customer_phone` | VARCHAR     | Contact number                 |
| `customer_email` | VARCHAR     | Email ID                       |

---

### 🔹 `account`
Holds banking account details.
| Column           | Type        | Description                    |
|------------------|-------------|--------------------------------|
| `account_number` | INT (PK)    | Unique account number          |
| `account_type`   | VARCHAR     | Savings, Current, etc.         |
| `branch_code`    | INT (FK)    | Linked to `branch`             |
| `customer_id`    | INT (FK)    | Linked to `customer`           |
| `open_date`      | DATE        | Date of account creation       |
| `balance`        | DECIMAL     | Current balance                |

---

### 🔹 `transaction`
Logs transactions like deposit, withdrawal, or transfer.
| Column             | Type        | Description                  |
|--------------------|-------------|------------------------------|
| `transaction_id`   | INT (PK)    | Unique transaction ID        |
| `account_number`   | INT (FK)    | Linked to `account`          |
| `transaction_date` | DATE        | Date of transaction          |
| `transaction_type` | VARCHAR     | Deposit, Withdrawal, etc.    |
| `amount`           | DECIMAL     | Amount involved              |

---

### 🔹 `branch`
Details of all bank branches.
| Column           | Type        | Description                  |
|------------------|-------------|------------------------------|
| `branch_code`    | INT (PK)    | Branch identifier            |
| `branch_name`    | VARCHAR     | Branch name                  |
| `branch_city`    | VARCHAR     | City                         |
| `branch_address` | TEXT        | Full address                 |
| `branch_phone`   | VARCHAR     | Contact number               |

---

### 🔹 `employee`
Bank employee information.
| Column        | Type        | Description                  |
|---------------|-------------|------------------------------|
| `emp_id`      | INT (PK)    | Employee ID                  |
| `emp_name`    | VARCHAR     | Full name                    |
| `designation` | VARCHAR     | Job role                     |
| `branch_code` | INT (FK)    | Works at which branch        |

---

### 🔹 `loan`
Loan records for customers.
| Column        | Type        | Description                  |
|---------------|-------------|------------------------------|
| `loan_id`     | INT (PK)    | Unique loan ID               |
| `customer_id` | INT (FK)    | Loan taken by which customer |
| `loan_amount` | DECIMAL     | Amount of loan               |
| `loan_date`   | DATE        | Date of sanction             |
| `loan_type`   | VARCHAR     | Type of loan                 |

---

### 🔹 `card`
Details of cards issued to customers.
| Column        | Type        | Description                  |
|---------------|-------------|------------------------------|
| `card_id`     | INT (PK)    | Unique card ID               |
| `customer_id` | INT (FK)    | Card owner                   |
| `card_type`   | VARCHAR     | Debit, Credit, etc.          |
| `card_number` | VARCHAR     | Card number                  |
| `expiry_date` | DATE        | Expiry date                  |

---

### 🔹 `login`
Stores login credentials (for demo only).
| Column      | Type        | Description                  |
|-------------|-------------|------------------------------|
| `login_id`  | INT (PK)    | Login identifier             |
| `username`  | VARCHAR     | Username                     |
| `password`  | VARCHAR     | Password                     |
| `customer_id` | INT (FK)  | Linked to `customer`         |

---

## 🔐 Security Note

> ⚠️ Do **not** use this setup for production or real-world deployments. The `login` table does not follow secure password storage practices like hashing and salting. This project is strictly for **educational purposes**.

---

## 🧪 Sample Queries (Optional)

```sql
-- Fetch all customer accounts
SELECT * FROM account WHERE customer_id = 1001;

-- View all transactions of a specific account
SELECT * FROM transaction WHERE account_number = 1234567890;

-- Get all loans taken in 2023
SELECT * FROM loan WHERE YEAR(loan_date) = 2023;
```

---

