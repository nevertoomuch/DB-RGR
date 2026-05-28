SELECT client_id, full_name, phone_number, balance
FROM clients
ORDER BY full_name;

SELECT tariff_id, name, monthly_fee, description
FROM tariff_plans;

SELECT service_id, name, service_type, unit
FROM services;


SELECT full_name, phone_number, balance
FROM clients
WHERE balance > 500;

SELECT s.name, s.service_type, ts.limit_value
FROM tariff_services ts
JOIN services s ON s.service_id = ts.service_id
JOIN tariff_plans tp ON tp.tariff_id = ts.tariff_id
WHERE tp.name = 'Оптимальный';


SELECT c.full_name, tp.name AS tariff_name
FROM clients c
JOIN subscriptions sub ON sub.client_id = c.client_id
JOIN tariff_plans tp ON tp.tariff_id = sub.tariff_id
WHERE sub.status = 'active';


SELECT tp.name, COUNT(sub.client_id) AS client_count
FROM tariff_plans tp
JOIN subscriptions sub ON sub.tariff_id = tp.tariff_id
WHERE sub.status = 'active'
GROUP BY tp.name
HAVING COUNT(sub.client_id) > 1;


SELECT c.full_name, SUM(cb.total_points) AS total_points
FROM clients c
JOIN client_bonuses cb ON cb.client_id = c.client_id
GROUP BY c.client_id, c.full_name
ORDER BY total_points DESC
LIMIT 3;


WITH transactions_2026 AS (
    SELECT client_bonus_id, points, transaction_date
    FROM bonus_transactions
    WHERE EXTRACT(YEAR FROM transaction_date) = 2026
)
SELECT t.client_bonus_id, t.points, t.transaction_date
FROM transactions_2026 t
ORDER BY t.transaction_date;

SELECT full_name, phone_number
FROM clients
WHERE client_id NOT IN (
    SELECT DISTINCT client_id FROM client_bonuses
);

SELECT client_id, full_name, phone_number, email
FROM clients;

SELECT name, service_type, unit
FROM services;

SELECT name, monthly_fee, description
FROM tariff_plans;

SELECT full_name, balance, registration_date
FROM clients
WHERE balance > 750;

SELECT name, monthly_fee, is_active
FROM tariff_plans
WHERE is_active = TRUE;

SELECT c.full_name, tp.name AS tariff_name
FROM clients c
JOIN subscriptions s ON c.client_id = s.client_id
JOIN tariff_plans tp ON s.tariff_id = tp.tariff_id;

SELECT tp.name, s.name AS service_name, ts.limit_value
FROM tariff_plans tp
JOIN tariff_services ts ON tp.tariff_id = ts.tariff_id
JOIN services s ON ts.service_id = s.service_id;

SELECT tp.name, COUNT(s.client_id) AS client_count
FROM tariff_plans tp
JOIN subscriptions s ON tp.tariff_id = s.tariff_id
GROUP BY tp.tariff_id, tp.name
HAVING COUNT(s.client_id) > 1;

WITH active_clients AS (
    SELECT client_id, full_name
    FROM clients
    WHERE is_active = TRUE
)
SELECT ac.full_name, cb.total_points
FROM active_clients ac
JOIN client_bonuses cb ON ac.client_id = cb.client_id;

SELECT c.full_name, c.balance
FROM clients c
JOIN subscriptions s ON c.client_id = s.client_id
GROUP BY c.client_id, c.full_name
ORDER BY c.balance DESC
LIMIT 5;