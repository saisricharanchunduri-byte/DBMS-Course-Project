/* ============================================================
   SAMPLE DATA INSERTION
   Fuel Station Sales and Tank Inventory Management System
   First 5 Records for Each Table
   ============================================================ */

USE fuel_station_management;


/* ============================================================
   1. FUEL_TYPE
   First 5 fuel types added to the database.
   ============================================================ */

INSERT INTO fuel_type
(fuel_name, fuel_code, price_per_litre, status)
VALUES
('Petrol', 'PET', 105.50, 'ACTIVE'),
('Diesel', 'DSL', 92.80, 'ACTIVE'),
('Premium Petrol', 'PPR', 115.00, 'ACTIVE'),
('CNG', 'CNG', 88.00, 'ACTIVE'),
('Electric Charging', 'EV', 18.50, 'ACTIVE');


/* ============================================================
   2. TANK
   First 5 storage tanks with their fuel types and stock.
   fuel_id 1 = Petrol
   fuel_id 2 = Diesel
   fuel_id 3 = Premium Petrol
   fuel_id 4 = CNG
   fuel_id 5 = Electric Charging
   ============================================================ */

INSERT INTO tank
(tank_number, fuel_id, capacity_litres, current_stock, status)
VALUES
('TANK-01', 1, 20000.00, 16187.00, 'ACTIVE'),
('TANK-02', 2, 25000.00, 22693.00, 'ACTIVE'),
('TANK-03', 3, 15000.00, 12450.00, 'ACTIVE'),
('TANK-04', 4, 10000.00, 8189.00, 'ACTIVE'),
('TANK-05', 5, 8000.00, 5952.00, 'ACTIVE');


/* ============================================================
   3. SUPPLIER
   First 5 suppliers added to the system.
   ============================================================ */

INSERT INTO supplier
(supplier_name, phone, email, address)
VALUES
('Indian Oil Corporation', '9000000001',
 'ioc@fuel.com', 'Hyderabad'),

('Bharat Petroleum', '9000000002',
 'bpcl@fuel.com', 'Vijayawada'),

('Hindustan Petroleum', '9000000003',
 'hpcl@fuel.com', 'Visakhapatnam'),

('Reliance Fuel Supply', '9000000004',
 'reliance@fuel.com', 'Mumbai'),

('Nayara Energy', '9000000005',
 'nayara@fuel.com', 'Pune');


/* ============================================================
   4. DELIVERY
   First 5 fuel delivery records.
   supplier_id refers to SUPPLIER.
   tank_id refers to TANK.
   ============================================================ */

INSERT INTO delivery
(supplier_id, tank_id, delivery_date,
 quantity_litres, cost_per_litre, total_cost, invoice_number)
VALUES
(1, 1, '2026-09-01', 5000.00, 98.00, 490000.00, 'INV-1001'),

(2, 2, '2026-09-02', 7000.00, 86.00, 602000.00, 'INV-1002'),

(3, 3, '2026-09-03', 4000.00, 108.00, 432000.00, 'INV-1003'),

(4, 4, '2026-09-04', 3000.00, 80.00, 240000.00, 'INV-1004'),

(5, 5, '2026-09-05', 2000.00, 15.00, 30000.00, 'INV-1005');


/* ============================================================
   5. DISPENSER
   First 5 dispensers installed at the station.
   ============================================================ */

INSERT INTO dispenser
(dispenser_number, fuel_id, status)
VALUES
('DISP-01', 1, 'ACTIVE'),
('DISP-02', 1, 'ACTIVE'),
('DISP-03', 2, 'ACTIVE'),
('DISP-04', 2, 'ACTIVE'),
('DISP-05', 3, 'ACTIVE');


/* ============================================================
   6. ATTENDANT
   First 5 fuel station attendants.
   ============================================================ */

INSERT INTO attendant
(employee_code, attendant_name, phone, status)
VALUES
('EMP001', 'Rahul Kumar', '9100000001', 'ACTIVE'),
('EMP002', 'Arjun Reddy', '9100000002', 'ACTIVE'),
('EMP003', 'Suresh Kumar', '9100000003', 'ACTIVE'),
('EMP004', 'Vikram Singh', '9100000004', 'ACTIVE'),
('EMP005', 'Kiran Kumar', '9100000005', 'ACTIVE');


/* ============================================================
   7. SHIFT
   First 5 attendant shift records.
   attendant_id refers to ATTENDANT.
   ============================================================ */

INSERT INTO shift
(attendant_id, shift_date, start_time, end_time, status)
VALUES
(1, '2026-09-01', '06:00:00', '14:00:00', 'CLOSED'),
(2, '2026-09-01', '14:00:00', '22:00:00', 'CLOSED'),
(3, '2026-09-02', '06:00:00', '14:00:00', 'CLOSED'),
(4, '2026-09-02', '14:00:00', '22:00:00', 'CLOSED'),
(5, '2026-09-03', '06:00:00', '14:00:00', 'CLOSED');


/* ============================================================
   8. METER_READING
   First 5 dispenser meter reading records.
   dispenser_id refers to DISPENSER.
   shift_id refers to SHIFT.
   ============================================================ */

INSERT INTO meter_reading
(dispenser_id, shift_id, opening_meter, closing_meter)
VALUES
(1, 1, 10000.00, 10350.00),
(2, 2, 15000.00, 15320.00),
(3, 3, 20000.00, 20450.00),
(4, 4, 25000.00, 25400.00),
(5, 5, 12000.00, 12300.00);


/* ============================================================
   9. SALE
   First 5 fuel sales transactions.
   ============================================================ */

INSERT INTO sale
(shift_id, dispenser_id, fuel_id,
 quantity_litres, price_per_litre, total_amount, payment_type)
VALUES
(1, 1, 1, 20.00, 105.50, 2110.00, 'CASH'),

(2, 2, 1, 30.00, 105.50, 3165.00, 'CARD'),

(3, 3, 2, 25.00, 92.80, 2320.00, 'UPI'),

(4, 4, 2, 40.00, 92.80, 3712.00, 'CASH'),

(5, 5, 3, 30.00, 115.00, 3450.00, 'CREDIT');


/* ============================================================
   10. CREDIT_CUSTOMER
   First 5 customers registered for credit transactions.
   ============================================================ */

INSERT INTO credit_customer
(customer_name, phone, address, credit_limit, status)
VALUES
('ABC Transport', '6000000001', 'Hyderabad', 50000.00, 'ACTIVE'),

('Sri Sai Logistics', '6000000002', 'Vijayawada', 75000.00, 'ACTIVE'),

('City Travels', '6000000003', 'Visakhapatnam', 60000.00, 'ACTIVE'),

('Metro Transport', '6000000004', 'Bengaluru', 80000.00, 'ACTIVE'),

('Green Logistics', '6000000005', 'Chennai', 100000.00, 'ACTIVE');


/* ============================================================
   11. INVOICE
   First 5 invoices generated for credit sales.
   sale_id must refer to a CREDIT sale.
   ============================================================ */

INSERT INTO invoice
(customer_id, sale_id, invoice_date,
 total_amount, paid_amount, balance_amount, status)
VALUES
(1, 5, '2026-09-03', 3450.00, 1500.00, 1950.00, 'PARTIAL');


/*
   NOTE:
   Additional invoice records can be inserted after additional
   CREDIT sales are created.
*/


/* ============================================================
   12. PAYMENT
   First payment made against the invoice.
   ============================================================ */

INSERT INTO payment
(invoice_id, payment_date, amount, payment_mode, reference_number)
VALUES
(1, '2026-09-04', 1500.00, 'UPI', 'PAY-1001');
