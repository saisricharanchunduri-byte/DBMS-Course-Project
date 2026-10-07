/* ============================================================
   FUEL STATION SALES AND TANK INVENTORY MANAGEMENT SYSTEM
   DDL COMMANDS
   ============================================================ */


/* ============================================================
   1. CREATE DATABASE
   Creates the database for the complete fuel station system.
   ============================================================ */

CREATE DATABASE IF NOT EXISTS fuel_station_management;


/* ============================================================
   2. SELECT DATABASE
   Selects the database in which all tables will be created.
   ============================================================ */

USE fuel_station_management;


/* ============================================================
   3. CREATE FUEL_TYPE TABLE
   Stores information about different types of fuel.
   ============================================================ */

CREATE TABLE fuel_type (
    fuel_id INT AUTO_INCREMENT PRIMARY KEY,
    fuel_name VARCHAR(50) NOT NULL UNIQUE,
    fuel_code VARCHAR(10) NOT NULL UNIQUE,
    price_per_litre DECIMAL(10,2) NOT NULL,
    status VARCHAR(10) NOT NULL DEFAULT 'ACTIVE',

    -- Selling price must be greater than zero
    CHECK (price_per_litre > 0)
);


/* ============================================================
   4. CREATE TANK TABLE
   Stores fuel storage tank details and current fuel stock.
   ============================================================ */

CREATE TABLE tank (
    tank_id INT AUTO_INCREMENT PRIMARY KEY,
    tank_number VARCHAR(20) NOT NULL UNIQUE,
    fuel_id INT NOT NULL,
    capacity_litres DECIMAL(10,2) NOT NULL,
    current_stock DECIMAL(10,2) NOT NULL DEFAULT 0,
    status VARCHAR(10) NOT NULL DEFAULT 'ACTIVE',

    -- Establishes relationship between TANK and FUEL_TYPE
    CONSTRAINT fk_tank_fuel
        FOREIGN KEY (fuel_id)
        REFERENCES fuel_type(fuel_id),

    -- Tank capacity must be greater than zero
    CHECK (capacity_litres > 0),

    -- Stock cannot be negative
    CHECK (current_stock >= 0),

    -- Stock cannot exceed tank capacity
    CHECK (current_stock <= capacity_litres)
);


/* ============================================================
   5. CREATE SUPPLIER TABLE
   Stores information about fuel suppliers.
   ============================================================ */

CREATE TABLE supplier (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL UNIQUE,
    email VARCHAR(100) UNIQUE,
    address VARCHAR(255) NOT NULL
);


/* ============================================================
   6. CREATE DELIVERY TABLE
   Records fuel deliveries received from suppliers.
   ============================================================ */

CREATE TABLE delivery (
    delivery_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_id INT NOT NULL,
    tank_id INT NOT NULL,
    delivery_date DATE NOT NULL,
    quantity_litres DECIMAL(10,2) NOT NULL,
    cost_per_litre DECIMAL(10,2) NOT NULL,
    total_cost DECIMAL(10,2) NOT NULL,
    invoice_number VARCHAR(50) NOT NULL UNIQUE,

    -- Relationship between DELIVERY and SUPPLIER
    CONSTRAINT fk_delivery_supplier
        FOREIGN KEY (supplier_id)
        REFERENCES supplier(supplier_id),

    -- Relationship between DELIVERY and TANK
    CONSTRAINT fk_delivery_tank
        FOREIGN KEY (tank_id)
        REFERENCES tank(tank_id),

    -- Delivery quantity must be positive
    CHECK (quantity_litres > 0),

    -- Purchase price must be positive
    CHECK (cost_per_litre > 0),

    -- Total delivery cost must be positive
    CHECK (total_cost > 0)
);


/* ============================================================
   7. CREATE DISPENSER TABLE
   Stores information about fuel dispensing units.
   ============================================================ */

CREATE TABLE dispenser (
    dispenser_id INT AUTO_INCREMENT PRIMARY KEY,
    dispenser_number VARCHAR(20) NOT NULL UNIQUE,
    fuel_id INT NOT NULL,
    status VARCHAR(10) NOT NULL DEFAULT 'ACTIVE',

    -- Relationship between DISPENSER and FUEL_TYPE
    CONSTRAINT fk_dispenser_fuel
        FOREIGN KEY (fuel_id)
        REFERENCES fuel_type(fuel_id)
);


/* ============================================================
   8. CREATE ATTENDANT TABLE
   Stores information about fuel station attendants.
   ============================================================ */

CREATE TABLE attendant (
    attendant_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_code VARCHAR(20) NOT NULL UNIQUE,
    attendant_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL UNIQUE,
    status VARCHAR(10) NOT NULL DEFAULT 'ACTIVE'
);


/* ============================================================
   9. CREATE SHIFT TABLE
   Stores the working shifts of fuel station attendants.
   ============================================================ */

CREATE TABLE shift (
    shift_id INT AUTO_INCREMENT PRIMARY KEY,
    attendant_id INT NOT NULL,
    shift_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME,
    status VARCHAR(10) NOT NULL DEFAULT 'OPEN',

    -- Relationship between SHIFT and ATTENDANT
    CONSTRAINT fk_shift_attendant
        FOREIGN KEY (attendant_id)
        REFERENCES attendant(attendant_id),

    -- Shift status can only be OPEN or CLOSED
    CHECK (status IN ('OPEN', 'CLOSED')),

    -- End time cannot be earlier than start time
    CHECK (end_time IS NULL OR end_time >= start_time)
);


/* ============================================================
   10. CREATE METER_READING TABLE
   Stores opening and closing meter readings of dispensers.
   ============================================================ */

CREATE TABLE meter_reading (
    reading_id INT AUTO_INCREMENT PRIMARY KEY,
    dispenser_id INT NOT NULL,
    shift_id INT NOT NULL,
    opening_meter DECIMAL(12,2) NOT NULL,
    closing_meter DECIMAL(12,2) NOT NULL,
    reading_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Relationship between METER_READING and DISPENSER
    CONSTRAINT fk_meter_dispenser
        FOREIGN KEY (dispenser_id)
        REFERENCES dispenser(dispenser_id),

    -- Relationship between METER_READING and SHIFT
    CONSTRAINT fk_meter_shift
        FOREIGN KEY (shift_id)
        REFERENCES shift(shift_id),

    -- Meter readings cannot be negative
    CHECK (opening_meter >= 0),
    CHECK (closing_meter >= 0)
);


/* ============================================================
   11. CREATE SALE TABLE
   Stores all fuel sales transactions.
   ============================================================ */

CREATE TABLE sale (
    sale_id INT AUTO_INCREMENT PRIMARY KEY,
    shift_id INT NOT NULL,
    dispenser_id INT NOT NULL,
    fuel_id INT NOT NULL,
    quantity_litres DECIMAL(10,2) NOT NULL,
    price_per_litre DECIMAL(10,2) NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    payment_type VARCHAR(10) NOT NULL,
    sale_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Relationship between SALE and SHIFT
    CONSTRAINT fk_sale_shift
        FOREIGN KEY (shift_id)
        REFERENCES shift(shift_id),

    -- Relationship between SALE and DISPENSER
    CONSTRAINT fk_sale_dispenser
        FOREIGN KEY (dispenser_id)
        REFERENCES dispenser(dispenser_id),

    -- Relationship between SALE and FUEL_TYPE
    CONSTRAINT fk_sale_fuel
        FOREIGN KEY (fuel_id)
        REFERENCES fuel_type(fuel_id),

    -- Sale values must be positive
    CHECK (quantity_litres > 0),
    CHECK (price_per_litre > 0),
    CHECK (total_amount > 0),

    -- Valid payment methods
    CHECK (payment_type IN ('CASH', 'CARD', 'UPI', 'CREDIT'))
);


/* ============================================================
   12. CREATE CREDIT_CUSTOMER TABLE
   Stores customers who purchase fuel on credit.
   ============================================================ */

CREATE TABLE credit_customer (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL UNIQUE,
    address VARCHAR(255) NOT NULL,
    credit_limit DECIMAL(12,2) NOT NULL,
    status VARCHAR(10) NOT NULL DEFAULT 'ACTIVE',

    -- Credit limit cannot be negative
    CHECK (credit_limit >= 0),

    -- Valid customer status
    CHECK (status IN ('ACTIVE', 'INACTIVE'))
);


/* ============================================================
   13. CREATE INVOICE TABLE
   Stores invoices generated for credit sales.
   ============================================================ */

CREATE TABLE invoice (
    invoice_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    sale_id INT NOT NULL UNIQUE,
    invoice_date DATE NOT NULL,
    total_amount DECIMAL(12,2) NOT NULL,
    paid_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
    balance_amount DECIMAL(12,2) NOT NULL,
    status VARCHAR(10) NOT NULL DEFAULT 'PENDING',

    -- Relationship between INVOICE and CREDIT_CUSTOMER
    CONSTRAINT fk_invoice_customer
        FOREIGN KEY (customer_id)
        REFERENCES credit_customer(customer_id),

    -- Relationship between INVOICE and SALE
    CONSTRAINT fk_invoice_sale
        FOREIGN KEY (sale_id)
        REFERENCES sale(sale_id),

    -- Invoice amount must be positive
    CHECK (total_amount > 0),

    -- Paid amount cannot be negative
    CHECK (paid_amount >= 0),

    -- Outstanding balance cannot be negative
    CHECK (balance_amount >= 0),

    -- Valid invoice status
    CHECK (status IN ('PENDING', 'PARTIAL', 'PAID'))
);


/* ============================================================
   14. CREATE PAYMENT TABLE
   Stores payments made against credit invoices.
   ============================================================ */

CREATE TABLE payment (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    invoice_id INT NOT NULL,
    payment_date DATE NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    payment_mode VARCHAR(10) NOT NULL,
    reference_number VARCHAR(50) UNIQUE,

    -- Relationship between PAYMENT and INVOICE
    CONSTRAINT fk_payment_invoice
        FOREIGN KEY (invoice_id)
        REFERENCES invoice(invoice_id),

    -- Payment amount must be positive
    CHECK (amount > 0),

    -- Valid payment modes
    CHECK (payment_mode IN ('CASH', 'CARD', 'UPI'))
);
