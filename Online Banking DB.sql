-- Online Banking Management System
-- MySQL Database Schema
-- Version 1.0

-- Database creation
DROP DATABASE IF EXISTS online_banking_system;
CREATE DATABASE online_banking_system;
USE online_banking_system;

-- Enable strict mode for better data integrity
SET SQL_MODE = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION';

-- Table structure for 'banks'
CREATE TABLE banks (
    bank_id INT AUTO_INCREMENT PRIMARY KEY,
    bank_name VARCHAR(100) NOT NULL,
    bank_code VARCHAR(20) NOT NULL UNIQUE,
    headquarters_address VARCHAR(255) NOT NULL,
    contact_number VARCHAR(20) NOT NULL,
    email VARCHAR(100) NOT NULL,
    established_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Table structure for 'branches'
CREATE TABLE branches (
    branch_id INT AUTO_INCREMENT PRIMARY KEY,
    bank_id INT NOT NULL,
    branch_name VARCHAR(100) NOT NULL,
    branch_code VARCHAR(20) NOT NULL,
    address VARCHAR(255) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(50) NOT NULL DEFAULT 'United States',
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100),
    manager_id INT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (bank_id) REFERENCES banks(bank_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Table structure for 'employees'
CREATE TABLE employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    branch_id INT NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender ENUM('Male', 'Female', 'Other') NOT NULL,
    ssn VARCHAR(11) NOT NULL UNIQUE,
    address VARCHAR(255) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(50) NOT NULL DEFAULT 'United States',
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    position VARCHAR(50) NOT NULL,
    salary DECIMAL(12, 2) NOT NULL,
    hire_date DATE NOT NULL,
    termination_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Add foreign key constraint for branch manager after employees table is created
ALTER TABLE branches
ADD CONSTRAINT fk_branch_manager
FOREIGN KEY (manager_id) REFERENCES employees(employee_id) ON DELETE SET NULL;

-- Table structure for 'customers'
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender ENUM('Male', 'Female', 'Other') NOT NULL,
    ssn VARCHAR(11) NOT NULL UNIQUE,
    address VARCHAR(255) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(50) NOT NULL DEFAULT 'United States',
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    occupation VARCHAR(100),
    annual_income DECIMAL(12, 2),
    credit_score INT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Table structure for 'users' (for login credentials)
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    employee_id INT,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    role ENUM('customer', 'teller', 'manager', 'admin') NOT NULL,
    last_login DATETIME,
    is_locked BOOLEAN DEFAULT FALSE,
    failed_login_attempts INT DEFAULT 0,
    password_changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    must_change_password BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE,
    CONSTRAINT chk_user_type CHECK (
        (customer_id IS NOT NULL AND employee_id IS NULL) OR
        (customer_id IS NULL AND employee_id IS NOT NULL)
    )
) ENGINE=InnoDB;

-- Table structure for 'account_types'
CREATE TABLE account_types (
    account_type_id INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    minimum_balance DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    interest_rate DECIMAL(5, 2) NOT NULL DEFAULT 0.00,
    monthly_fee DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    overdraft_fee DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    withdrawal_limit INT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Table structure for 'accounts'
CREATE TABLE accounts (
    account_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    branch_id INT NOT NULL,
    account_type_id INT NOT NULL,
    account_number VARCHAR(20) NOT NULL UNIQUE,
    routing_number VARCHAR(20) NOT NULL,
    current_balance DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    available_balance DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    date_opened DATE NOT NULL,
    date_closed DATE,
    status ENUM('Active', 'Dormant', 'Closed', 'Frozen') NOT NULL DEFAULT 'Active',
    overdraft_protection BOOLEAN DEFAULT FALSE,
    last_activity_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id) ON DELETE CASCADE,
    FOREIGN KEY (account_type_id) REFERENCES account_types(account_type_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Table structure for 'transactions'
CREATE TABLE transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    account_id INT NOT NULL,
    transaction_type ENUM('Deposit', 'Withdrawal', 'Transfer', 'Payment', 'Fee', 'Interest') NOT NULL,
    amount DECIMAL(12, 2) NOT NULL,
    running_balance DECIMAL(12, 2) NOT NULL,
    description VARCHAR(255),
    reference_number VARCHAR(50) UNIQUE,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Pending', 'Completed', 'Failed', 'Reversed') NOT NULL DEFAULT 'Completed',
    initiated_by INT,
    related_transaction_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id) ON DELETE CASCADE,
    FOREIGN KEY (initiated_by) REFERENCES users(user_id) ON DELETE SET NULL,
    FOREIGN KEY (related_transaction_id) REFERENCES transactions(transaction_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Table structure for 'transfers'
CREATE TABLE transfers (
    transfer_id INT AUTO_INCREMENT PRIMARY KEY,
    source_transaction_id INT NOT NULL,
    destination_transaction_id INT NOT NULL,
    transfer_amount DECIMAL(12, 2) NOT NULL,
    transfer_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Pending', 'Completed', 'Failed', 'Reversed') NOT NULL DEFAULT 'Completed',
    description VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (source_transaction_id) REFERENCES transactions(transaction_id) ON DELETE CASCADE,
    FOREIGN KEY (destination_transaction_id) REFERENCES transactions(transaction_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Table structure for 'loans'
CREATE TABLE loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    account_id INT NOT NULL,
    loan_type ENUM('Personal', 'Mortgage', 'Auto', 'Student', 'Business') NOT NULL,
    loan_amount DECIMAL(12, 2) NOT NULL,
    interest_rate DECIMAL(5, 2) NOT NULL,
    term_months INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    monthly_payment DECIMAL(10, 2) NOT NULL,
    remaining_balance DECIMAL(12, 2) NOT NULL,
    status ENUM('Active', 'Paid', 'Defaulted', 'Foreclosed') NOT NULL DEFAULT 'Active',
    purpose VARCHAR(255),
    approved_by INT,
    approved_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id) ON DELETE CASCADE,
    FOREIGN KEY (approved_by) REFERENCES employees(employee_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Table structure for 'loan_payments'
CREATE TABLE loan_payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    loan_id INT NOT NULL,
    payment_amount DECIMAL(10, 2) NOT NULL,
    principal_amount DECIMAL(10, 2) NOT NULL,
    interest_amount DECIMAL(10, 2) NOT NULL,
    payment_date DATE NOT NULL,
    due_date DATE NOT NULL,
    status ENUM('Pending', 'Paid', 'Late', 'Partial') NOT NULL DEFAULT 'Paid',
    transaction_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id) ON DELETE CASCADE,
    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Table structure for 'cards'
CREATE TABLE cards (
    card_id INT AUTO_INCREMENT PRIMARY KEY,
    account_id INT NOT NULL,
    customer_id INT NOT NULL,
    card_number VARCHAR(16) NOT NULL UNIQUE,
    card_type ENUM('Debit', 'Credit', 'ATM') NOT NULL,
    expiry_date DATE NOT NULL,
    cvv VARCHAR(4) NOT NULL,
    pin_hash VARCHAR(255) NOT NULL,
    daily_withdrawal_limit DECIMAL(10, 2) NOT NULL DEFAULT 500.00,
    daily_purchase_limit DECIMAL(10, 2) NOT NULL DEFAULT 1000.00,
    status ENUM('Active', 'Inactive', 'Lost', 'Stolen', 'Expired') NOT NULL DEFAULT 'Active',
    issue_date DATE NOT NULL,
    activated_date DATE,
    deactivated_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Table structure for 'card_transactions'
CREATE TABLE card_transactions (
    card_transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    card_id INT NOT NULL,
    transaction_id INT NOT NULL,
    merchant_name VARCHAR(100) NOT NULL,
    merchant_category VARCHAR(50),
    transaction_amount DECIMAL(10, 2) NOT NULL,
    transaction_date TIMESTAMP NOT NULL,
    transaction_type ENUM('Purchase', 'Withdrawal', 'Refund', 'Chargeback') NOT NULL,
    location VARCHAR(100),
    is_online BOOLEAN DEFAULT FALSE,
    is_international BOOLEAN DEFAULT FALSE,
    status ENUM('Pending', 'Completed', 'Declined', 'Refunded') NOT NULL DEFAULT 'Completed',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (card_id) REFERENCES cards(card_id) ON DELETE CASCADE,
    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Table structure for 'beneficiaries'
CREATE TABLE beneficiaries (
    beneficiary_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    account_id INT,
    nickname VARCHAR(50) NOT NULL,
    bank_name VARCHAR(100) NOT NULL,
    bank_code VARCHAR(20),
    account_number VARCHAR(20) NOT NULL,
    account_holder_name VARCHAR(100) NOT NULL,
    routing_number VARCHAR(20),
    is_internal BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Table structure for 'scheduled_payments'
CREATE TABLE scheduled_payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    account_id INT NOT NULL,
    beneficiary_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    description VARCHAR(255),
    frequency ENUM('One-time', 'Daily', 'Weekly', 'Monthly', 'Quarterly', 'Yearly') NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    next_payment_date DATE NOT NULL,
    status ENUM('Active', 'Paused', 'Completed', 'Cancelled') NOT NULL DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id) ON DELETE CASCADE,
    FOREIGN KEY (beneficiary_id) REFERENCES beneficiaries(beneficiary_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Table structure for 'audit_logs'
CREATE TABLE audit_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    action VARCHAR(50) NOT NULL,
    table_name VARCHAR(50) NOT NULL,
    record_id INT,
    old_values JSON,
    new_values JSON,
    ip_address VARCHAR(45),
    user_agent VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Table structure for 'notifications'
CREATE TABLE notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    message TEXT NOT NULL,
    notification_type ENUM('Transaction', 'Account', 'Security', 'System', 'Promotion') NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Table structure for 'security_questions'
CREATE TABLE security_questions (
    question_id INT AUTO_INCREMENT PRIMARY KEY,
    question_text VARCHAR(255) NOT NULL UNIQUE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Table structure for 'user_security_questions'
CREATE TABLE user_security_questions (
    user_question_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    question_id INT NOT NULL,
    answer_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES security_questions(question_id) ON DELETE CASCADE,
    UNIQUE KEY (user_id, question_id)
) ENGINE=InnoDB;

-- Table structure for 'password_reset_tokens'
CREATE TABLE password_reset_tokens (
    token_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    token VARCHAR(64) NOT NULL UNIQUE,
    expires_at TIMESTAMP NOT NULL,
    is_used BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Table structure for 'login_history'
CREATE TABLE login_history (
    login_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    ip_address VARCHAR(45) NOT NULL,
    device_info VARCHAR(255),
    login_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    logout_time TIMESTAMP NULL,
    status ENUM('Success', 'Failed', 'Locked') NOT NULL,
    failure_reason VARCHAR(255),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Table structure for 'exchange_rates'
CREATE TABLE exchange_rates (
    rate_id INT AUTO_INCREMENT PRIMARY KEY,
    base_currency CHAR(3) NOT NULL,
    target_currency CHAR(3) NOT NULL,
    rate DECIMAL(12, 6) NOT NULL,
    effective_date DATE NOT NULL,
    expiry_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY (base_currency, target_currency, effective_date)
) ENGINE=InnoDB;

-- Table structure for 'currency_accounts'
CREATE TABLE currency_accounts (
    currency_account_id INT AUTO_INCREMENT PRIMARY KEY,
    account_id INT NOT NULL,
    currency CHAR(3) NOT NULL,
    balance DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id) ON DELETE CASCADE,
    UNIQUE KEY (account_id, currency)
) ENGINE=InnoDB;

-- Table structure for 'foreign_transactions'
CREATE TABLE foreign_transactions (
    foreign_transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_id INT NOT NULL,
    original_amount DECIMAL(12, 2) NOT NULL,
    original_currency CHAR(3) NOT NULL,
    exchange_rate DECIMAL(12, 6) NOT NULL,
    fee_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    description VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Insert sample data into 'banks'
INSERT INTO banks (bank_name, bank_code, headquarters_address, contact_number, email, established_date)
VALUES 
('National Trust Bank', 'NTB001', '123 Financial District, New York, NY 10001', '18005551000', 'info@ntbank.com', '1985-06-15'),
('First Capital Bank', 'FCB002', '456 Commerce Street, Chicago, IL 60601', '18005552000', 'contact@fcbank.com', '1978-11-22');

-- Insert sample data into 'branches'
INSERT INTO branches (bank_id, branch_name, branch_code, address, city, state, postal_code, phone, email)
VALUES 
(1, 'New York Downtown', 'NYD001', '123 Financial District, New York, NY 10001', 'New York', 'NY', '10001', '2125551000', 'nydowntown@ntbank.com'),
(1, 'Chicago Main', 'CHM001', '456 Commerce Street, Chicago, IL 60601', 'Chicago', 'IL', '60601', '3125552000', 'chmain@ntbank.com'),
(2, 'Los Angeles West', 'LAW001', '789 Sunset Blvd, Los Angeles, CA 90001', 'Los Angeles', 'CA', '90001', '2135553000', 'lawest@fcbank.com');

-- Insert sample data into 'employees'
INSERT INTO employees (branch_id, first_name, last_name, date_of_birth, gender, ssn, address, city, state, postal_code, phone, email, position, salary, hire_date)
VALUES 
(1, 'John', 'Smith', '1980-05-15', 'Male', '123-45-6789', '100 Park Ave, New York, NY 10001', 'New York', 'NY', '10001', '2125551111', 'john.smith@ntbank.com', 'Branch Manager', 85000.00, '2010-03-15'),
(1, 'Sarah', 'Johnson', '1985-08-22', 'Female', '234-56-7890', '200 Broadway, New York, NY 10002', 'New York', 'NY', '10002', '2125552222', 'sarah.johnson@ntbank.com', 'Loan Officer', 65000.00, '2015-06-10'),
(2, 'Michael', 'Williams', '1978-11-30', 'Male', '345-67-8901', '300 Michigan Ave, Chicago, IL 60602', 'Chicago', 'IL', '60602', '3125553333', 'michael.williams@ntbank.com', 'Branch Manager', 82000.00, '2008-09-20'),
(3, 'Emily', 'Brown', '1990-04-18', 'Female', '456-78-9012', '400 Hollywood Blvd, Los Angeles, CA 90002', 'Los Angeles', 'CA', '90002', '2135554444', 'emily.brown@fcbank.com', 'Customer Service', 55000.00, '2018-02-05');

-- Update branches with manager IDs
UPDATE branches SET manager_id = 1 WHERE branch_id = 1;
UPDATE branches SET manager_id = 3 WHERE branch_id = 2;
UPDATE branches SET manager_id = 4 WHERE branch_id = 3;

-- Insert sample data into 'customers'
INSERT INTO customers (first_name, last_name, date_of_birth, gender, ssn, address, city, state, postal_code, phone, email, occupation, annual_income, credit_score)
VALUES 
('Robert', 'Johnson', '1975-02-10', 'Male', '111-22-3333', '500 5th Ave, New York, NY 10010', 'New York', 'NY', '10010', '2125551234', 'robert.johnson@email.com', 'Software Engineer', 120000.00, 780),
('Jennifer', 'Davis', '1982-07-25', 'Female', '222-33-4444', '600 Lake Shore Dr, Chicago, IL 60611', 'Chicago', 'IL', '60611', '3125552345', 'jennifer.davis@email.com', 'Marketing Manager', 95000.00, 810),
('David', 'Wilson', '1990-11-15', 'Male', '333-44-5555', '700 Rodeo Dr, Beverly Hills, CA 90210', 'Beverly Hills', 'CA', '90210', '3105553456', 'david.wilson@email.com', 'Financial Analyst', 110000.00, 750),
('Jessica', 'Martinez', '1988-03-30', 'Female', '444-55-6666', '800 Ocean Ave, Santa Monica, CA 90401', 'Santa Monica', 'CA', '90401', '3105554567', 'jessica.martinez@email.com', 'Teacher', 65000.00, 720);

-- Insert sample data into 'users'
INSERT INTO users (customer_id, username, password_hash, email, role)
VALUES 
(1, 'rjohnson', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'robert.johnson@email.com', 'customer'),
(2, 'jdavis', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'jennifer.davis@email.com', 'customer'),
(3, 'dwilson', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'david.wilson@email.com', 'customer'),
(4, 'jmartinez', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'jessica.martinez@email.com', 'customer');

-- Insert employee users
INSERT INTO users (employee_id, username, password_hash, email, role)
VALUES 
(1, 'jsmith', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'john.smith@ntbank.com', 'manager'),
(2, 'sjohnson', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'sarah.johnson@ntbank.com', 'teller'),
(3, 'mwilliams', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'michael.williams@ntbank.com', 'manager'),
(4, 'ebrown', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'emily.brown@fcbank.com', 'teller');

-- Insert sample data into 'account_types'
INSERT INTO account_types (type_name, description, minimum_balance, interest_rate, monthly_fee, overdraft_fee, withdrawal_limit)
VALUES 
('Checking', 'Basic checking account with no interest', 25.00, 0.00, 5.00, 35.00, NULL),
('Savings', 'Basic savings account with interest', 100.00, 0.05, 0.00, 0.00, 6),
('Premium Checking', 'Premium checking account with interest', 1000.00, 0.01, 0.00, 25.00, NULL),
('Money Market', 'High-yield money market account', 2500.00, 0.15, 0.00, 0.00, 3),
('Student Checking', 'Checking account for students', 0.00, 0.00, 0.00, 25.00, NULL);

-- Insert sample data into 'accounts'
INSERT INTO accounts (customer_id, branch_id, account_type_id, account_number, routing_number, current_balance, available_balance, date_opened, status)
VALUES 
(1, 1, 1, '100000001', '123456789', 5000.00, 5000.00, '2020-01-15', 'Active'),
(1, 1, 2, '100000002', '123456789', 15000.00, 15000.00, '2020-01-15', 'Active'),
(2, 2, 1, '200000001', '987654321', 3500.00, 3500.00, '2019-05-20', 'Active'),
(2, 2, 3, '200000002', '987654321', 25000.00, 25000.00, '2021-02-10', 'Active'),
(3, 3, 1, '300000001', '456789123', 12000.00, 12000.00, '2018-11-05', 'Active'),
(3, 3, 4, '300000002', '456789123', 50000.00, 50000.00, '2022-01-30', 'Active'),
(4, 1, 5, '400000001', '123456789', 800.00, 800.00, '2022-03-15', 'Active');

-- Insert sample data into 'transactions'
-- For customer 1
INSERT INTO transactions (account_id, transaction_type, amount, running_balance, description, reference_number, status, initiated_by)
VALUES 
(1, 'Deposit', 5000.00, 5000.00, 'Initial deposit', 'INIT1001', 'Completed', 1),
(1, 'Withdrawal', 200.00, 4800.00, 'ATM withdrawal', 'ATM20220101', 'Completed', 1),
(1, 'Payment', 150.00, 4650.00, 'Utility bill payment', 'BILL20220105', 'Completed', 1),
(2, 'Deposit', 15000.00, 15000.00, 'Initial deposit', 'INIT1002', 'Completed', 1),
(2, 'Transfer', 1000.00, 14000.00, 'Transfer to checking', 'XFER20220110', 'Completed', 1);

-- For customer 2
INSERT INTO transactions (account_id, transaction_type, amount, running_balance, description, reference_number, status, initiated_by)
VALUES 
(3, 'Deposit', 3500.00, 3500.00, 'Initial deposit', 'INIT2001', 'Completed', 2),
(3, 'Withdrawal', 500.00, 3000.00, 'ATM withdrawal', 'ATM20220102', 'Completed', 2),
(4, 'Deposit', 25000.00, 25000.00, 'Initial deposit', 'INIT2002', 'Completed', 2),
(4, 'Payment', 1200.00, 23800.00, 'Mortgage payment', 'BILL20220115', 'Completed', 2);

-- For customer 3
INSERT INTO transactions (account_id, transaction_type, amount, running_balance, description, reference_number, status, initiated_by)
VALUES 
(5, 'Deposit', 12000.00, 12000.00, 'Initial deposit', 'INIT3001', 'Completed', 3),
(5, 'Withdrawal', 1000.00, 11000.00, 'ATM withdrawal', 'ATM20220103', 'Completed', 3),
(6, 'Deposit', 50000.00, 50000.00, 'Initial deposit', 'INIT3002', 'Completed', 3),
(6, 'Transfer', 5000.00, 45000.00, 'Transfer to checking', 'XFER20220120', 'Completed', 3);

-- For customer 4
INSERT INTO transactions (account_id, transaction_type, amount, running_balance, description, reference_number, status, initiated_by)
VALUES 
(7, 'Deposit', 800.00, 800.00, 'Initial deposit', 'INIT4001', 'Completed', 4),
(7, 'Withdrawal', 100.00, 700.00, 'ATM withdrawal', 'ATM20220104', 'Completed', 4);

-- Insert sample data into 'transfers'
INSERT INTO transfers (source_transaction_id, destination_transaction_id, transfer_amount, description)
VALUES 
(5, 1, 1000.00, 'Transfer from savings to checking'),
(13, 9, 5000.00, 'Transfer from money market to checking');

-- Insert sample data into 'loans'
INSERT INTO loans (customer_id, account_id, loan_type, loan_amount, interest_rate, term_months, start_date, end_date, monthly_payment, remaining_balance, status, purpose, approved_by, approved_date)
VALUES 
(1, 1, 'Personal', 10000.00, 7.50, 36, '2022-01-10', '2025-01-10', 311.06, 8500.00, 'Active', 'Home renovation', 1, '2022-01-05'),
(2, 3, 'Auto', 25000.00, 5.25, 60, '2021-06-15', '2026-06-15', 474.64, 20000.00, 'Active', 'Car purchase', 3, '2021-06-10'),
(3, 5, 'Mortgage', 300000.00, 3.75, 360, '2020-03-01', '2050-03-01', 1389.35, 290000.00, 'Active', 'Home purchase', 1, '2020-02-20');

-- Insert sample data into 'loan_payments'
INSERT INTO loan_payments (loan_id, payment_amount, principal_amount, interest_amount, payment_date, due_date, status, transaction_id)
VALUES 
(1, 311.06, 250.00, 61.06, '2022-02-10', '2022-02-10', 'Paid', NULL),
(1, 311.06, 253.56, 57.50, '2022-03-10', '2022-03-10', 'Paid', NULL),
(2, 474.64, 375.00, 99.64, '2021-07-15', '2021-07-15', 'Paid', NULL),
(2, 474.64, 378.64, 96.00, '2021-08-15', '2021-08-15', 'Paid', NULL),
(3, 1389.35, 750.00, 639.35, '2020-04-01', '2020-04-01', 'Paid', NULL),
(3, 1389.35, 752.34, 637.01, '2020-05-01', '2020-05-01', 'Paid', NULL);

-- Insert sample data into 'cards'
INSERT INTO cards (account_id, customer_id, card_number, card_type, expiry_date, cvv, pin_hash, status, issue_date, activated_date)
VALUES 
(1, 1, '4111111111111111', 'Debit', '2025-12-31', '123', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Active', '2020-01-20', '2020-01-25'),
(3, 2, '5555555555554444', 'Debit', '2024-10-31', '456', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Active', '2019-05-25', '2019-05-30'),
(5, 3, '378282246310005', 'Debit', '2026-06-30', '789', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Active', '2018-11-10', '2018-11-15'),
(7, 4, '6011111111111117', 'Debit', '2023-09-30', '321', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Active', '2022-03-20', '2022-03-25');

-- Insert sample data into 'card_transactions'
INSERT INTO card_transactions (card_id, transaction_id, merchant_name, merchant_category,transaction_amount, transaction_date, transaction_type, location, is_online, status)
VALUES 
(1, 2, 'ATM Downtown', 'ATM', 200.00, '2022-01-02 14:30:00', 'Withdrawal', 'New York, NY', FALSE, 'Completed'),
(1, 3, 'ConEdison', 'Utilities', 150.00, '2022-01-05 09:15:00', 'Purchase', 'Online', TRUE, 'Completed'),
(2, 7, 'ATM Lakeview', 'ATM', 500.00, '2022-01-03 16:45:00', 'Withdrawal', 'Chicago, IL', FALSE, 'Completed'),
(3, 10, 'ATM Hollywood', 'ATM', 1000.00, '2022-01-04 11:20:00', 'Withdrawal', 'Los Angeles, CA', FALSE, 'Completed'),
(4, 15, 'ATM Times Square', 'ATM', 100.00, '2022-01-05 13:10:00', 'Withdrawal', 'New York, NY', FALSE, 'Completed'),
(1, NULL, 'Amazon', 'Retail', 89.99, '2022-01-15 19:30:00', 'Purchase', 'Online', TRUE, 'Completed'),
(2, NULL, 'Shell', 'Gas Station', 45.75, '2022-01-16 07:45:00', 'Purchase', 'Chicago, IL', FALSE, 'Completed');

-- Insert sample data into 'beneficiaries'
INSERT INTO beneficiaries (customer_id, account_id, nickname, bank_name, account_number, account_holder_name, is_internal)
VALUES 
(1, 3, 'Jennifer Checking', 'National Trust Bank', '200000001', 'Jennifer Davis', TRUE),
(2, 1, 'Robert Checking', 'National Trust Bank', '100000001', 'Robert Johnson', TRUE),
(3, 7, 'Jessica Student', 'National Trust Bank', '400000001', 'Jessica Martinez', TRUE),
(4, 5, 'David Checking', 'First Capital Bank', '300000001', 'David Wilson', TRUE);

-- Insert sample data into 'scheduled_payments'
INSERT INTO scheduled_payments (customer_id, account_id, beneficiary_id, amount, description, frequency, start_date, next_payment_date, status)
VALUES 
(1, 1, 1, 500.00, 'Rent payment', 'Monthly', '2022-01-01', '2022-02-01', 'Active'),
(2, 3, 2, 200.00, 'Loan repayment', 'Monthly', '2022-01-05', '2022-02-05', 'Active'),
(3, 5, 3, 100.00, 'Tuition payment', 'Monthly', '2022-01-10', '2022-02-10', 'Active');

-- Insert sample data into 'audit_logs'
INSERT INTO audit_logs (user_id, action, table_name, record_id, ip_address, user_agent)
VALUES 
(1, 'LOGIN', 'users', 1, '192.168.1.1', 'Mozilla/5.0 (Windows NT 10.0)'),
(2, 'ACCOUNT_UPDATE', 'accounts', 3, '192.168.1.2', 'Mozilla/5.0 (Macintosh)'),
(3, 'TRANSACTION_CREATE', 'transactions', 10, '192.168.1.3', 'Mozilla/5.0 (iPhone)'),
(4, 'PASSWORD_CHANGE', 'users', 4, '192.168.1.4', 'Mozilla/5.0 (Android)');

-- Insert sample data into 'notifications'
INSERT INTO notifications (user_id, title, message, notification_type)
VALUES 
(1, 'Deposit Received', 'Your account has been credited with $5000.00', 'Transaction'),
(2, 'Withdrawal Alert', '$500.00 has been withdrawn from your account', 'Transaction'),
(3, 'Account Opened', 'Your new account has been successfully opened', 'Account'),
(4, 'Low Balance', 'Your account balance is below $100', 'Account');

-- Insert sample data into 'security_questions'
INSERT INTO security_questions (question_text)
VALUES 
('What was your first pet''s name?'),
('In what city were you born?'),
('What is your mother''s maiden name?'),
('What was the name of your first school?'),
('What was your first car''s model?');

-- Insert sample data into 'user_security_questions'
INSERT INTO user_security_questions (user_id, question_id, answer_hash)
VALUES 
(1, 1, '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
(2, 2, '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
(3, 3, '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
(4, 4, '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi');

-- Insert sample data into 'password_reset_tokens'
INSERT INTO password_reset_tokens (user_id, token, expires_at)
VALUES 
(1, 'abc123xyz456', DATE_ADD(NOW(), INTERVAL 1 HOUR)),
(2, 'def456uvw789', DATE_ADD(NOW(), INTERVAL 1 HOUR)),
(3, 'ghi789rst012', DATE_ADD(NOW(), INTERVAL 1 HOUR));

-- Insert sample data into 'login_history'
INSERT INTO login_history (user_id, ip_address, device_info, status)
VALUES 
(1, '192.168.1.1', 'Windows 10 Chrome', 'Success'),
(2, '192.168.1.2', 'MacOS Safari', 'Success'),
(3, '192.168.1.3', 'iPhone iOS', 'Success'),
(4, '192.168.1.4', 'Android Chrome', 'Success'),
(1, '10.0.0.1', 'Windows 10 Firefox', 'Failed'),
(2, '10.0.0.2', 'Linux Firefox', 'Failed');

-- Insert sample data into 'exchange_rates'
INSERT INTO exchange_rates (base_currency, target_currency, rate, effective_date, expiry_date)
VALUES 
('USD', 'EUR', 0.85, '2022-01-01', '2022-01-31'),
('USD', 'GBP', 0.75, '2022-01-01', '2022-01-31'),
('USD', 'JPY', 115.50, '2022-01-01', '2022-01-31'),
('EUR', 'USD', 1.18, '2022-01-01', '2022-01-31'),
('GBP', 'USD', 1.33, '2022-01-01', '2022-01-31');

-- Insert sample data into 'currency_accounts'
INSERT INTO currency_accounts (account_id, currency, balance)
VALUES 
(1, 'USD', 5000.00),
(1, 'EUR', 4250.00),
(3, 'USD', 3500.00),
(5, 'USD', 12000.00),
(5, 'GBP', 9000.00),
(6, 'USD', 50000.00);

-- Insert sample data into 'foreign_transactions'
INSERT INTO foreign_transactions (transaction_id, original_amount, original_currency, exchange_rate, fee_amount, description)
VALUES 
(1, 4250.00, 'EUR', 0.85, 10.00, 'Initial deposit in Euros'),
(9, 9000.00, 'GBP', 0.75, 15.00, 'Initial deposit in Pounds');

-- Create indexes for better performance
CREATE INDEX idx_accounts_customer ON accounts(customer_id);
CREATE INDEX idx_accounts_branch ON accounts(branch_id);
CREATE INDEX idx_transactions_account ON transactions(account_id);
CREATE INDEX idx_transactions_date ON transactions(transaction_date);
CREATE INDEX idx_loans_customer ON loans(customer_id);
CREATE INDEX idx_cards_account ON cards(account_id);
CREATE INDEX idx_cards_customer ON cards(customer_id);
CREATE INDEX idx_users_customer ON users(customer_id);
CREATE INDEX idx_users_employee ON users(employee_id);

-- Create views for common queries

-- Customer account summary view
CREATE VIEW customer_account_summary AS
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(a.account_id) AS number_of_accounts,
    SUM(a.current_balance) AS total_balance,
    MAX(a.last_activity_date) AS last_activity
FROM 
    customers c
LEFT JOIN 
    accounts a ON c.customer_id = a.customer_id
GROUP BY 
    c.customer_id, customer_name;

-- Transaction history view
CREATE VIEW transaction_history AS
SELECT 
    t.transaction_id,
    a.account_id,
    a.account_number,
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    t.transaction_type,
    t.amount,
    t.running_balance,
    t.description,
    t.transaction_date,
    t.status
FROM 
    transactions t
JOIN 
    accounts a ON t.account_id = a.account_id
JOIN 
    customers c ON a.customer_id = c.customer_id;

-- Daily balances view
CREATE VIEW daily_balances AS
SELECT 
    a.account_id,
    a.account_number,
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    DATE(t.transaction_date) AS balance_date,
    LAST_VALUE(t.running_balance) OVER (
        PARTITION BY a.account_id, DATE(t.transaction_date)
        ORDER BY t.transaction_date
        RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS closing_balance
FROM 
    accounts a
JOIN 
    transactions t ON a.account_id = t.account_id
JOIN 
    customers c ON a.customer_id = c.customer_id
GROUP BY 
    a.account_id, a.account_number, c.customer_id, customer_name, balance_date;

-- Stored procedures

-- Procedure to create a new customer account
DELIMITER //
CREATE PROCEDURE create_customer_account(
    IN p_first_name VARCHAR(50),
    IN p_last_name VARCHAR(50),
    IN p_dob DATE,
    IN p_gender ENUM('Male', 'Female', 'Other'),
    IN p_ssn VARCHAR(11),
    IN p_address VARCHAR(255),
    IN p_city VARCHAR(50),
    IN p_state VARCHAR(50),
    IN p_postal_code VARCHAR(20),
    IN p_phone VARCHAR(20),
    IN p_email VARCHAR(100),
    IN p_occupation VARCHAR(100),
    IN p_annual_income DECIMAL(12, 2),
    IN p_credit_score INT,
    IN p_account_type_id INT,
    IN p_branch_id INT,
    IN p_initial_deposit DECIMAL(12, 2),
    OUT p_customer_id INT,
    OUT p_account_id INT,
    OUT p_account_number VARCHAR(20)
)
BEGIN
    DECLARE v_routing_number VARCHAR(20);
    DECLARE v_new_account_number VARCHAR(20);
    
    -- Insert customer
    INSERT INTO customers (
        first_name, last_name, date_of_birth, gender, ssn, address, 
        city, state, postal_code, phone, email, occupation, annual_income, credit_score
    ) VALUES (
        p_first_name, p_last_name, p_dob, p_gender, p_ssn, p_address, 
        p_city, p_state, p_postal_code, p_phone, p_email, p_occupation, p_annual_income, p_credit_score
    );
    
    SET p_customer_id = LAST_INSERT_ID();
    
    -- Get branch routing number
    SELECT routing_number INTO v_routing_number 
    FROM branches 
    WHERE branch_id = p_branch_id 
    LIMIT 1;
    
    -- Generate account number (simplified for example)
    SELECT CONCAT(FLOOR(RAND() * 900000000) + 100000000 INTO v_new_account_number;
    
    -- Insert account
    INSERT INTO accounts (
        customer_id, branch_id, account_type_id, account_number, routing_number, 
        current_balance, available_balance, date_opened
    ) VALUES (
        p_customer_id, p_branch_id, p_account_type_id, v_new_account_number, v_routing_number, 
        p_initial_deposit, p_initial_deposit, CURDATE()
    );
    
    SET p_account_id = LAST_INSERT_ID();
    SET p_account_number = v_new_account_number;
    
    -- Insert initial deposit transaction
    INSERT INTO transactions (
        account_id, transaction_type, amount, running_balance, 
        description, reference_number, status
    ) VALUES (
        p_account_id, 'Deposit', p_initial_deposit, p_initial_deposit, 
        'Initial deposit', CONCAT('INIT', p_account_id), 'Completed'
    );
END //
DELIMITER ;

-- Procedure to transfer funds between accounts
DELIMITER //
CREATE PROCEDURE transfer_funds(
    IN p_source_account_id INT,
    IN p_destination_account_id INT,
    IN p_amount DECIMAL(12, 2),
    IN p_description VARCHAR(255),
    IN p_initiated_by INT,
    OUT p_transfer_id INT,
    OUT p_status VARCHAR(20)
)
BEGIN
    DECLARE v_source_balance DECIMAL(12, 2);
    DECLARE v_destination_balance DECIMAL(12, 2);
    DECLARE v_source_transaction_id INT;
    DECLARE v_destination_transaction_id INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_status = 'Failed';
    END;
    
    START TRANSACTION;
    
    -- Check if source account has sufficient funds
    SELECT available_balance INTO v_source_balance
    FROM accounts
    WHERE account_id = p_source_account_id
    FOR UPDATE;
    
    IF v_source_balance < p_amount THEN
        SET p_status = 'Insufficient funds';
        ROLLBACK;
        LEAVE transfer_funds;
    END IF;
    
    -- Get destination account balance
    SELECT current_balance INTO v_destination_balance
    FROM accounts
    WHERE account_id = p_destination_account_id
    FOR UPDATE;
    
    -- Create withdrawal transaction for source account
    INSERT INTO transactions (
        account_id, transaction_type, amount, running_balance, 
        description, reference_number, status, initiated_by
    ) VALUES (
        p_source_account_id, 'Transfer', -p_amount, v_source_balance - p_amount,
        CONCAT('Transfer to account ', p_destination_account_id, ': ', p_description),
        CONCAT('XFER', UNIX_TIMESTAMP()), 'Completed', p_initiated_by
    );
    
    SET v_source_transaction_id = LAST_INSERT_ID();
    
    -- Create deposit transaction for destination account
    INSERT INTO transactions (
        account_id, transaction_type, amount, running_balance, 
        description, reference_number, status, initiated_by
    ) VALUES (
        p_destination_account_id, 'Transfer', p_amount, v_destination_balance + p_amount,
        CONCAT('Transfer from account ', p_source_account_id, ': ', p_description),
        CONCAT('XFER', UNIX_TIMESTAMP()), 'Completed', p_initiated_by
    );
    
    SET v_destination_transaction_id = LAST_INSERT_ID();
    
    -- Update account balances
    UPDATE accounts 
    SET current_balance = current_balance - p_amount,
        available_balance = available_balance - p_amount,
        last_activity_date = CURDATE()
    WHERE account_id = p_source_account_id;
    
    UPDATE accounts 
    SET current_balance = current_balance + p_amount,
        available_balance = available_balance + p_amount,
        last_activity_date = CURDATE()
    WHERE account_id = p_destination_account_id;
    
    -- Create transfer record
    INSERT INTO transfers (
        source_transaction_id, destination_transaction_id, 
        transfer_amount, description
    ) VALUES (
        v_source_transaction_id, v_destination_transaction_id,
        p_amount, p_description
    );
    
    SET p_transfer_id = LAST_INSERT_ID();
    SET p_status = 'Completed';
    
    COMMIT;
END //
DELIMITER ;

-- Procedure to apply monthly interest
DELIMITER //
CREATE PROCEDURE apply_monthly_interest()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_account_id INT;
    DECLARE v_balance DECIMAL(12, 2);
    DECLARE v_interest_rate DECIMAL(5, 2);
    DECLARE v_interest_amount DECIMAL(12, 2);
    DECLARE v_transaction_id INT;
    
    DECLARE account_cursor CURSOR FOR
        SELECT a.account_id, a.current_balance, at.interest_rate
        FROM accounts a
        JOIN account_types at ON a.account_type_id = at.account_type_id
        WHERE at.interest_rate > 0 AND a.status = 'Active';
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN account_cursor;
    
    interest_loop: LOOP
        FETCH account_cursor INTO v_account_id, v_balance, v_interest_rate;
        IF done THEN
            LEAVE interest_loop;
        END IF;
        
        -- Calculate monthly interest
        SET v_interest_amount = ROUND(v_balance * (v_interest_rate / 100 / 12), 2);
        
        IF v_interest_amount > 0 THEN
            START TRANSACTION;
            
            -- Update account balance
            UPDATE accounts 
            SET current_balance = current_balance + v_interest_amount,
                available_balance = available_balance + v_interest_amount,
                last_activity_date = CURDATE()
            WHERE account_id = v_account_id;
            
            -- Create interest transaction
            INSERT INTO transactions (
                account_id, transaction_type, amount, running_balance, 
                description, reference_number, status
            ) VALUES (
                v_account_id, 'Interest', v_interest_amount, v_balance + v_interest_amount,
                'Monthly interest', CONCAT('INT', DATE_FORMAT(CURDATE(), '%Y%m')), 'Completed'
            );
            
            COMMIT;
        END IF;
    END LOOP;
    
    CLOSE account_cursor;
END //
DELIMITER ;

-- Procedure to process loan payments
DELIMITER //
CREATE PROCEDURE process_loan_payment(
    IN p_loan_id INT,
    IN p_payment_amount DECIMAL(10, 2),
    IN p_payment_date DATE,
    OUT p_payment_id INT,
    OUT p_status VARCHAR(20)
BEGIN
    DECLARE v_remaining_balance DECIMAL(12, 2);
    DECLARE v_monthly_payment DECIMAL(10, 2);
    DECLARE v_interest_rate DECIMAL(5, 2);
    DECLARE v_interest_amount DECIMAL(10, 2);
    DECLARE v_principal_amount DECIMAL(10, 2);
    DECLARE v_account_id INT;
    DECLARE v_transaction_id INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_status = 'Failed';
    END;
    
    START TRANSACTION;
    
    -- Get loan details
    SELECT remaining_balance, monthly_payment, interest_rate, account_id
    INTO v_remaining_balance, v_monthly_payment, v_interest_rate, v_account_id
    FROM loans
    WHERE loan_id = p_loan_id
    FOR UPDATE;
    
    -- Calculate interest and principal amounts
    SET v_interest_amount = ROUND(v_remaining_balance * (v_interest_rate / 100 / 12), 2);
    
    IF p_payment_amount >= v_monthly_payment THEN
        -- Full payment
        SET v_principal_amount = v_monthly_payment - v_interest_amount;
        SET p_payment_amount = v_monthly_payment;
    ELSE
        -- Partial payment (apply to interest first)
        IF p_payment_amount > v_interest_amount THEN
            SET v_principal_amount = p_payment_amount - v_interest_amount;
        ELSE
            SET v_principal_amount = 0;
            SET v_interest_amount = p_payment_amount;
        END IF;
    END IF;
    
    -- Update loan balance
    UPDATE loans
    SET remaining_balance = remaining_balance - v_principal_amount
    WHERE loan_id = p_loan_id;
    
    -- Create payment record
    INSERT INTO loan_payments (
        loan_id, payment_amount, principal_amount, 
        interest_amount, payment_date, due_date, status
    ) VALUES (
        p_loan_id, p_payment_amount, v_principal_amount,
        v_interest_amount, p_payment_date, p_payment_date, 'Paid'
    );
    
    SET p_payment_id = LAST_INSERT_ID();
    
    -- Create transaction if payment is from an account
    IF v_account_id IS NOT NULL THEN
        INSERT INTO transactions (
            account_id, transaction_type, amount, running_balance, 
            description, reference_number, status
        ) VALUES (
            v_account_id, 'Payment', -p_payment_amount, 
            (SELECT current_balance FROM accounts WHERE account_id = v_account_id) - p_payment_amount,
            CONCAT('Loan payment #', p_loan_id), CONCAT('LOAN', p_loan_id, '-', p_payment_id), 'Completed'
        );
        
        SET v_transaction_id = LAST_INSERT_ID();
        
        -- Update account balance
        UPDATE accounts 
        SET current_balance = current_balance - p_payment_amount,
            available_balance = available_balance - p_payment_amount,
            last_activity_date = CURDATE()
        WHERE account_id = v_account_id;
        
        -- Update payment with transaction ID
        UPDATE loan_payments
        SET transaction_id = v_transaction_id
        WHERE payment_id = p_payment_id;
    END IF;
    
    -- Update loan status if paid off
    UPDATE loans
    SET status = CASE 
                    WHEN remaining_balance <= 0 THEN 'Paid'
                    ELSE status
                 END
    WHERE loan_id = p_loan_id;
    
    SET p_status = 'Completed';
    
    COMMIT;
END //
DELIMITER ;

-- Triggers

-- Trigger to update account last_activity_date on transaction
DELIMITER //
CREATE TRIGGER after_transaction_insert
AFTER INSERT ON transactions
FOR EACH ROW
BEGIN
    UPDATE accounts 
    SET last_activity_date = DATE(NEW.transaction_date)
    WHERE account_id = NEW.account_id;
END //
DELIMITER ;

-- Trigger to log account balance changes
DELIMITER //
CREATE TRIGGER before_account_update
BEFORE UPDATE ON accounts
FOR EACH ROW
BEGIN
    IF OLD.current_balance != NEW.current_balance THEN
        INSERT INTO audit_logs (
            table_name, record_id, action,
            old_values, new_values
        ) VALUES (
            'accounts', OLD.account_id, 'BALANCE_CHANGE',
            JSON_OBJECT('current_balance', OLD.current_balance),
            JSON_OBJECT('current_balance', NEW.current_balance)
        );
    END IF;
END //
DELIMITER ;

-- Trigger to prevent overdraft without protection
DELIMITER //
CREATE TRIGGER before_transaction_insert
BEFORE INSERT ON transactions
FOR EACH ROW
BEGIN
    DECLARE v_current_balance DECIMAL(12, 2);
    DECLARE v_overdraft_protection BOOLEAN;
    DECLARE v_account_type VARCHAR(50);
    
    IF NEW.transaction_type IN ('Withdrawal', 'Payment', 'Transfer') AND NEW.amount > 0 THEN
        -- Get current balance and overdraft protection status
        SELECT a.current_balance, a.overdraft_protection, at.type_name
        INTO v_current_balance, v_overdraft_protection, v_account_type
        FROM accounts a
        JOIN account_types at ON a.account_type_id = at.account_type_id
        WHERE a.account_id = NEW.account_id;
        
        -- Check if transaction would cause overdraft
        IF (v_current_balance - NEW.amount) < 0 THEN
            IF v_overdraft_protection = FALSE THEN
                SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Transaction would cause overdraft and account does not have overdraft protection';
            ELSE
                -- Apply overdraft fee
                INSERT INTO transactions (
                    account_id, transaction_type, amount, running_balance,
                    description, reference_number, status
                ) VALUES (
                    NEW.account_id, 'Fee', 
                    (SELECT overdraft_fee FROM account_types at JOIN accounts a ON at.account_type_id = a.account_type_id WHERE a.account_id = NEW.account_id),
                    v_current_balance - NEW.amount - (SELECT overdraft_fee FROM account_types at JOIN accounts a ON at.account_type_id = a.account_type_id WHERE a.account_id = NEW.account_id),
                    'Overdraft fee', CONCAT('OD', UNIX_TIMESTAMP()), 'Completed'
                );
            END IF;
        END IF;
    END IF;
END //
DELIMITER ;

-- Trigger to create notification for large transactions
DELIMITER //
CREATE TRIGGER after_large_transaction
AFTER INSERT ON transactions
FOR EACH ROW
BEGIN
    DECLARE v_customer_id INT;
    DECLARE v_user_id INT;
    
    IF NEW.amount > 10000 THEN
        -- Get customer ID
        SELECT customer_id INTO v_customer_id
        FROM accounts
        WHERE account_id = NEW.account_id;
        
        -- Get user ID
        SELECT user_id INTO v_user_id
        FROM users
        WHERE customer_id = v_customer_id;
        
        -- Create notification
        INSERT INTO notifications (
            user_id, title, message, notification_type
        ) VALUES (
            v_user_id, 'Large Transaction', 
            CONCAT('A large transaction of $', NEW.amount, ' has been processed on your account.'),
            'Transaction'
        );
    END IF;
END //
DELIMITER ;

-- Trigger to update card status when expired
DELIMITER //
CREATE TRIGGER before_card_usage
BEFORE INSERT ON card_transactions
FOR EACH ROW
BEGIN
    DECLARE v_card_status ENUM('Active', 'Inactive', 'Lost', 'Stolen', 'Expired');
    DECLARE v_expiry_date DATE;
    
    -- Get card status and expiry date
    SELECT status, expiry_date INTO v_card_status, v_expiry_date
    FROM cards
    WHERE card_id = NEW.card_id;
    
    -- Check if card is active and not expired
    IF v_card_status != 'Active' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot process transaction with inactive card';
    ELSEIF v_expiry_date < CURDATE() THEN
        -- Update card status to expired
        UPDATE cards
        SET status = 'Expired',
            deactivated_date = CURDATE()
        WHERE card_id = NEW.card_id;
        
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Card has expired';
    END IF;
END //
DELIMITER ;

-- Event scheduler for monthly processes
DELIMITER //
CREATE EVENT monthly_maintenance
ON SCHEDULE EVERY 1 MONTH
STARTS TIMESTAMP(DATE_FORMAT(DATE_ADD(CURDATE(), INTERVAL 1 MONTH), '%Y-%m-01 02:00:00'))
DO
BEGIN
    -- Apply monthly interest
    CALL apply_monthly_interest();
    
    -- Charge monthly fees
    INSERT INTO transactions (account_id, transaction_type, amount, running_balance, description, reference_number, status)
    SELECT 
        a.account_id, 
        'Fee', 
        at.monthly_fee, 
        a.current_balance - at.monthly_fee,
        'Monthly account fee',
        CONCAT('FEE', DATE_FORMAT(CURDATE(), '%Y%m')),
        'Completed'
    FROM accounts a
    JOIN account_types at ON a.account_type_id = at.account_type_id
    WHERE at.monthly_fee > 0 
    AND a.status = 'Active'
    AND (a.current_balance - at.monthly_fee) >= at.minimum_balance;
    
    -- Update account balances for fees
    UPDATE accounts a
    JOIN account_types at ON a.account_type_id = at.account_type_id
    SET 
        a.current_balance = a.current_balance - at.monthly_fee,
        a.available_balance = a.available_balance - at.monthly_fee,
        a.last_activity_date = CURDATE()
    WHERE at.monthly_fee > 0 
    AND a.status = 'Active'
    AND (a.current_balance - at.monthly_fee) >= at.minimum_balance;
    
    -- Process scheduled payments
    INSERT INTO transactions (account_id, transaction_type, amount, running_balance, description, reference_number, status)
    SELECT 
        sp.account_id,
        'Payment',
        -sp.amount,
        a.current_balance - sp.amount,
        CONCAT('Scheduled payment to ', b.nickname),
        CONCAT('SCH', DATE_FORMAT(CURDATE(), '%Y%m%d')),
        'Completed'
    FROM scheduled_payments sp
    JOIN beneficiaries b ON sp.beneficiary_id = b.beneficiary_id
    JOIN accounts a ON sp.account_id = a.account_id
    WHERE sp.next_payment_date = CURDATE()
    AND sp.status = 'Active'
    AND a.current_balance >= sp.amount;
    
    -- Update account balances for scheduled payments
    UPDATE accounts a
    JOIN scheduled_payments sp ON a.account_id = sp.account_id
    SET 
        a.current_balance = a.current_balance - sp.amount,
        a.available_balance = a.available_balance - sp.amount,
        a.last_activity_date = CURDATE()
    WHERE sp.next_payment_date = CURDATE()
    AND sp.status = 'Active'
    AND a.current_balance >= sp.amount;
    
    -- Update next payment date for recurring payments
    UPDATE scheduled_payments
    SET next_payment_date = CASE 
        WHEN frequency = 'Monthly' THEN DATE_ADD(next_payment_date, INTERVAL 1 MONTH)
        WHEN frequency = 'Weekly' THEN DATE_ADD(next_payment_date, INTERVAL 1 WEEK)
        WHEN frequency = 'Quarterly' THEN DATE_ADD(next_payment_date, INTERVAL 3 MONTH)
        WHEN frequency = 'Yearly' THEN DATE_ADD(next_payment_date, INTERVAL 1 YEAR)
        ELSE NULL
    END
    WHERE frequency != 'One-time'
    AND next_payment_date = CURDATE()
    AND status = 'Active';
    
    -- Complete one-time payments
    UPDATE scheduled_payments
    SET status = 'Completed'
    WHERE frequency = 'One-time'
    AND next_payment_date = CURDATE();
END //
DELIMITER ;

-- Enable event scheduler
SET GLOBAL event_scheduler = ON;

-- Create function to calculate age from date of birth
DELIMITER //
CREATE FUNCTION calculate_age(dob DATE) 
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE age INT;
    SET age = TIMESTAMPDIFF(YEAR, dob, CURDATE());
    IF DATE_ADD(dob, INTERVAL age YEAR) > CURDATE() THEN
        SET age = age - 1;
    END IF;
    RETURN age;
END //
DELIMITER ;

-- Create function to mask sensitive data
DELIMITER //
CREATE FUNCTION mask_string(input VARCHAR(255), show_first INT, show_last INT, mask_char CHAR(1))
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
    DECLARE input_len INT;
    DECLARE masked_len INT;
    DECLARE masked_part VARCHAR(255);
    
    SET input_len = LENGTH(input);
    
    IF input_len <= (show_first + show_last) THEN
        RETURN input;
    END IF;
    
    SET masked_len = input_len - show_first - show_last;
    SET masked_part = REPEAT(mask_char, masked_len);
    
    RETURN CONCAT(
        LEFT(input, show_first),
        masked_part,
        RIGHT(input, show_last)
    );
END //
DELIMITER ;

-- Create function to check if business day
DELIMITER //
CREATE FUNCTION is_business_day(check_date DATE) 
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE day_of_week INT;
    SET day_of_week = DAYOFWEEK(check_date);
    -- Return TRUE if not Saturday (7) or Sunday (1)
    RETURN (day_of_week != 1 AND day_of_week != 7);
END //
DELIMITER ;

-- Create function to calculate loan payment
DELIMITER //
CREATE FUNCTION calculate_loan_payment(
    principal DECIMAL(12, 2),
    annual_rate DECIMAL(5, 2),
    term_months INT
) 
RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
    DECLARE monthly_rate DECIMAL(10, 6);
    DECLARE payment DECIMAL(10, 2);
    
    SET monthly_rate = annual_rate / 100 / 12;
    
    IF monthly_rate = 0 THEN
        SET payment = principal / term_months;
    ELSE
        SET payment = principal * monthly_rate * POWER(1 + monthly_rate, term_months) / 
                      (POWER(1 + monthly_rate, term_months) - 1);
    END IF;
    
    RETURN ROUND(payment, 2);
END //
DELIMITER ;

-- Create function to generate random account number
DELIMITER //
CREATE FUNCTION generate_account_number() 
RETURNS VARCHAR(20)
NOT DETERMINISTIC
BEGIN
    DECLARE account_num VARCHAR(20);
    SET account_num = CONCAT(
        FLOOR(RAND() * 9) + 1,
        LPAD(FLOOR(RAND() * 1000000000), 9, '0')
    );
    
    -- Check if number already exists (very unlikely but possible)
    WHILE EXISTS (SELECT 1 FROM accounts WHERE account_number = account_num) DO
        SET account_num = CONCAT(
            FLOOR(RAND() * 9) + 1,
            LPAD(FLOOR(RAND() * 1000000000), 9, '0')
        );
    END WHILE;
    
    RETURN account_num;
END //
DELIMITER ;

-- Create function to validate email format
DELIMITER //
CREATE FUNCTION is_valid_email(email VARCHAR(100)) 
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE pattern VARCHAR(255);
    SET pattern = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$';
    RETURN email REGEXP pattern;
END //
DELIMITER ;