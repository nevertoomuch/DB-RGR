CREATE TABLE clients (
    client_id SERIAL PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    phone_number VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(100) UNIQUE,
    registration_date DATE NOT NULL DEFAULT CURRENT_DATE,
    balance NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT chk_balance_credit_limit CHECK (balance >= -5000.00)
);

CREATE TABLE tariff_plans (
    tariff_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    monthly_fee NUMERIC(10, 2) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT chk_monthly_fee_positive CHECK (monthly_fee >= 0)
);

CREATE TABLE services (
    service_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    service_type VARCHAR(30) NOT NULL,
    unit VARCHAR(20) NOT NULL,
    CONSTRAINT chk_service_type CHECK (
        service_type IN ('Звонки', 'SMS', 'Интернет', 'Роуминг', 'Прочее')
    )
);

CREATE TABLE tariff_services (
    tariff_service_id SERIAL PRIMARY KEY,
    tariff_id INT NOT NULL REFERENCES tariff_plans(tariff_id) ON DELETE CASCADE,
    service_id INT NOT NULL REFERENCES services(service_id) ON DELETE CASCADE,
    limit_value NUMERIC(12, 2),
    is_unlimited BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT uq_tariff_service UNIQUE (tariff_id, service_id),
    CONSTRAINT chk_limit_logic CHECK (
        (is_unlimited = TRUE) OR (limit_value IS NOT NULL AND limit_value >= 0)
    )
);

CREATE TABLE subscriptions (
    subscription_id SERIAL PRIMARY KEY,
    client_id INT NOT NULL REFERENCES clients(client_id) ON DELETE CASCADE,
    tariff_id INT NOT NULL REFERENCES tariff_plans(tariff_id) ON DELETE RESTRICT,
    start_date DATE NOT NULL DEFAULT CURRENT_DATE,
    end_date DATE,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    CONSTRAINT chk_status CHECK (status IN ('active', 'suspended', 'terminated')),
    CONSTRAINT chk_dates CHECK (end_date IS NULL OR end_date > start_date)
);

CREATE TABLE bonus_programs (
    program_id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL UNIQUE,
    description TEXT,
    points_per_ruble NUMERIC(6, 4) NOT NULL,
    min_balance NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT chk_points_positive CHECK (points_per_ruble > 0),
    CONSTRAINT chk_min_balance CHECK (min_balance >= 0)
);

CREATE TABLE client_bonuses (
    client_bonus_id SERIAL PRIMARY KEY,
    client_id INT NOT NULL REFERENCES clients(client_id) ON DELETE CASCADE,
    program_id INT NOT NULL REFERENCES bonus_programs(program_id) ON DELETE RESTRICT,
    total_points INT NOT NULL DEFAULT 0,
    enrollment_date DATE NOT NULL DEFAULT CURRENT_DATE,
    CONSTRAINT uq_client_program UNIQUE (client_id, program_id),
    CONSTRAINT chk_points_non_neg CHECK (total_points >= 0)
);

CREATE TABLE bonus_transactions (
    transaction_id SERIAL PRIMARY KEY,
    client_bonus_id INT NOT NULL REFERENCES client_bonuses(client_bonus_id) ON DELETE CASCADE,
    points INT NOT NULL,
    transaction_type VARCHAR(10) NOT NULL,
    transaction_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    description TEXT,
    CONSTRAINT chk_points_not_zero CHECK (points <> 0),
    CONSTRAINT chk_tx_type CHECK (transaction_type IN ('credit', 'debit'))
);

CREATE INDEX idx_clients_phone ON clients(phone_number);
CREATE INDEX idx_subscriptions_client ON subscriptions(client_id, status);
CREATE INDEX idx_bonus_tx_date ON bonus_transactions(transaction_date);
CREATE INDEX idx_subscriptions_tariff ON subscriptions(tariff_id);