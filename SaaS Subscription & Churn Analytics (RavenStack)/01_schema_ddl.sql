-- Drop existing tables if re-running
DROP TABLE IF EXISTS feature_usage;
DROP TABLE IF EXISTS support_tickets;
DROP TABLE IF EXISTS churn_events;
DROP TABLE IF EXISTS subscriptions;
DROP TABLE IF EXISTS accounts;

-- 1. Accounts Table (500 rows, 0 nulls)
CREATE TABLE accounts (
    account_id VARCHAR(20) PRIMARY KEY,
    account_name VARCHAR(100) NOT NULL,
    industry VARCHAR(50) NOT NULL,
    country CHAR(2) NOT NULL,
    signup_date DATE NOT NULL,
    referral_source VARCHAR(50) NOT NULL,
    plan_tier VARCHAR(30) NOT NULL,
    seats INT NOT NULL,
    is_trial BOOLEAN NOT NULL,       -- In MS SQL: BIT
    churn_flag BOOLEAN NOT NULL      -- In MS SQL: BIT
);

-- 2. Subscriptions Table (5,000 rows, 4,514 nulls in end_date)
CREATE TABLE subscriptions (
    subscription_id VARCHAR(20) PRIMARY KEY,
    account_id VARCHAR(20) NOT NULL REFERENCES accounts(account_id),
    start_date DATE NOT NULL,
    end_date DATE NULL,
    plan_tier VARCHAR(30) NOT NULL,
    seats INT NOT NULL,
    mrr_amount NUMERIC(12, 2) NOT NULL,
    arr_amount NUMERIC(12, 2) NOT NULL,
    is_trial BOOLEAN NOT NULL,
    upgrade_flag BOOLEAN NOT NULL,
    downgrade_flag BOOLEAN NOT NULL,
    churn_flag BOOLEAN NOT NULL,
    billing_frequency VARCHAR(20) NOT NULL,
    auto_renew_flag BOOLEAN NOT NULL
);

-- 3. Feature Usage Table (25,000 rows, 0 nulls)
CREATE TABLE feature_usage (
    usage_id VARCHAR(20) PRIMARY KEY,
    subscription_id VARCHAR(20) NOT NULL REFERENCES subscriptions(subscription_id),
    usage_date DATE NOT NULL,
    feature_name VARCHAR(50) NOT NULL,
    usage_count INT NOT NULL,
    usage_duration_secs INT NOT NULL,
    error_count INT NOT NULL,
    is_beta_feature BOOLEAN NOT NULL
);

-- 4. Support Tickets Table (2,000 rows, 825 nulls in satisfaction_score)
CREATE TABLE support_tickets (
    ticket_id VARCHAR(20) PRIMARY KEY,
    account_id VARCHAR(20) NOT NULL REFERENCES accounts(account_id),
    submitted_at TIMESTAMP NOT NULL,
    closed_at TIMESTAMP NOT NULL,
    resolution_time_hours NUMERIC(8, 2) NOT NULL,
    priority VARCHAR(20) NOT NULL,
    first_response_time_minutes INT NOT NULL,
    satisfaction_score NUMERIC(3, 1) NULL,
    escalation_flag BOOLEAN NOT NULL
);

-- 5. Churn Events Table (600 rows, 148 nulls in feedback_text)
CREATE TABLE churn_events (
    churn_event_id VARCHAR(20) PRIMARY KEY,
    account_id VARCHAR(20) NOT NULL REFERENCES accounts(account_id),
    churn_date DATE NOT NULL,
    reason_code VARCHAR(50) NOT NULL,
    refund_amount_usd NUMERIC(10, 2) NOT NULL,
    preceding_upgrade_flag BOOLEAN NOT NULL,
    preceding_downgrade_flag BOOLEAN NOT NULL,
    is_reactivation BOOLEAN NOT NULL,
    feedback_text TEXT NULL
);

-- Create Indexes for Foreign Keys & Date Filtering
CREATE INDEX idx_sub_account_dates ON subscriptions(account_id, start_date, end_date);
CREATE INDEX idx_usage_sub_date ON feature_usage(subscription_id, usage_date);
CREATE INDEX idx_tickets_account ON support_tickets(account_id, priority);
CREATE INDEX idx_churn_account_reason ON churn_events(account_id, reason_code);