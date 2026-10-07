-- =====================================================================
-- Project: SQL Queries and Views for Reporting
-- =====================================================================

-- Select the Fuel Station Management database
USE fuel_station_management;


-- =====================================================================
-- QUERY 1: FUEL-WISE TOTAL SALES
-- Find the total quantity of fuel sold and total revenue generated
-- for each fuel type.
-- =====================================================================

SELECT
    f.fuel_name,
    SUM(s.quantity_litres) AS total_litres_sold,
    SUM(s.total_amount) AS total_revenue
FROM sale s
JOIN fuel_type f
    ON s.fuel_id = f.fuel_id
GROUP BY f.fuel_id, f.fuel_name;


-- =====================================================================
-- QUERY 2: CURRENT STOCK OF EACH FUEL
-- Display the current stock, tank capacity and stock percentage
-- for each fuel tank.
-- =====================================================================

SELECT
    f.fuel_name,
    t.tank_number,
    t.capacity_litres,
    t.current_stock,
    ROUND(
        (t.current_stock / t.capacity_litres) * 100,
        2
    ) AS stock_percentage
FROM tank t
JOIN fuel_type f
    ON t.fuel_id = f.fuel_id
ORDER BY stock_percentage DESC;


-- =====================================================================
-- QUERY 3: SALES ABOVE AVERAGE SALE AMOUNT
-- Find sales whose total amount is greater than the average
-- sale amount.
-- =====================================================================

SELECT
    sale_id,
    fuel_id,
    quantity_litres,
    total_amount,
    payment_type
FROM sale
WHERE total_amount > (
    SELECT AVG(total_amount)
    FROM sale
)
ORDER BY total_amount DESC;


-- =====================================================================
-- QUERY 4: SUPPLIER-WISE DELIVERY SUMMARY
-- Find the total number of deliveries, total quantity delivered
-- and total delivery cost for each supplier.
-- =====================================================================

SELECT
    s.supplier_name,
    COUNT(d.delivery_id) AS total_deliveries,
    SUM(d.quantity_litres) AS total_quantity_delivered,
    SUM(d.total_cost) AS total_delivery_cost
FROM supplier s
JOIN delivery d
    ON s.supplier_id = d.supplier_id
GROUP BY s.supplier_id, s.supplier_name
ORDER BY total_quantity_delivered DESC;


-- =====================================================================
-- QUERY 5: PAYMENT METHOD ANALYSIS
-- Find the number of sales and total revenue generated through
-- each payment method.
-- =====================================================================

SELECT
    payment_type,
    COUNT(*) AS number_of_sales,
    SUM(total_amount) AS total_revenue
FROM sale
GROUP BY payment_type
ORDER BY total_revenue DESC;


-- =====================================================================
-- QUERY 6: OUTSTANDING INVOICES
-- Display customers who have outstanding invoice balances.
-- =====================================================================

SELECT
    c.customer_name,
    i.invoice_id,
    i.total_amount,
    i.paid_amount,
    i.balance_amount,
    i.status
FROM credit_customer c
JOIN invoice i
    ON c.customer_id = i.customer_id
WHERE i.balance_amount > 0
ORDER BY i.balance_amount DESC;


-- =====================================================================
-- QUERY 7: ATTENDANT-WISE SALES
-- Find the total number of sales and total revenue handled
-- by each attendant.
-- =====================================================================

SELECT
    a.attendant_name,
    COUNT(s.sale_id) AS total_sales,
    SUM(s.total_amount) AS total_revenue
FROM attendant a
JOIN shift sh
    ON a.attendant_id = sh.attendant_id
JOIN sale s
    ON sh.shift_id = s.shift_id
GROUP BY a.attendant_id, a.attendant_name
ORDER BY total_revenue DESC;


-- =====================================================================
-- QUERY 8: FUEL TYPES WITH STOCK BELOW 50%
-- Identify tanks where the current stock is below 50% of
-- their total capacity.
-- =====================================================================

SELECT
    f.fuel_name,
    t.tank_number,
    t.current_stock,
    t.capacity_litres
FROM tank t
JOIN fuel_type f
    ON t.fuel_id = f.fuel_id
WHERE t.current_stock < (t.capacity_litres * 0.50);


-- =====================================================================
-- QUERY 9: TOP 5 HIGHEST-VALUE SALES
-- Find the five sales having the highest total transaction value.
-- =====================================================================

SELECT
    s.sale_id,
    f.fuel_name,
    s.quantity_litres,
    s.price_per_litre,
    s.total_amount,
    s.payment_type
FROM sale s
JOIN fuel_type f
    ON s.fuel_id = f.fuel_id
ORDER BY s.total_amount DESC
LIMIT 5;


-- =====================================================================
-- QUERY 10: TOTAL OUTSTANDING PAYMENT
-- Calculate the total amount that is still outstanding
-- across all invoices.
-- =====================================================================

SELECT
    SUM(balance_amount) AS total_outstanding_amount
FROM invoice
WHERE balance_amount > 0;


-- =====================================================================
-- QUERY 11: TOTAL FUEL STOCK
-- Display the total current stock available for each fuel type.
-- =====================================================================

SELECT
    f.fuel_name,
    SUM(t.current_stock) AS total_stock_litres
FROM fuel_type f
JOIN tank t
    ON f.fuel_id = t.fuel_id
GROUP BY f.fuel_id, f.fuel_name
ORDER BY total_stock_litres DESC;


-- =====================================================================
-- QUERY 12: CREDIT CUSTOMER OUTSTANDING BALANCE
-- Display credit customers along with their total outstanding
-- invoice balance.
-- =====================================================================

SELECT
    c.customer_name,
    SUM(i.balance_amount) AS outstanding_balance
FROM credit_customer c
JOIN invoice i
    ON c.customer_id = i.customer_id
WHERE i.balance_amount > 0
GROUP BY c.customer_id, c.customer_name
ORDER BY outstanding_balance DESC;


-- =====================================================================
-- QUERY 13: SALES BY PAYMENT TYPE
-- Display the total number of transactions for each payment type.
-- =====================================================================

SELECT
    payment_type,
    COUNT(sale_id) AS total_transactions
FROM sale
GROUP BY payment_type
ORDER BY total_transactions DESC;


-- =====================================================================
-- QUERY 14: FUEL STOCK AND OUTSTANDING AMOUNT
-- Retrieve the current fuel stock available for each fuel type
-- and the total outstanding amount related to its sales.
-- =====================================================================

SELECT
    f.fuel_name AS Fuel_Name,
    COALESCE(t.fuel_left, 0) AS Fuel_Left_Litres,
    COALESCE(i.unpaid_amount, 0) AS Unpaid_Amount
FROM fuel_type f

LEFT JOIN (
    SELECT
        fuel_id,
        SUM(current_stock) AS fuel_left
    FROM tank
    GROUP BY fuel_id
) t
    ON f.fuel_id = t.fuel_id

LEFT JOIN (
    SELECT
        s.fuel_id,
        SUM(i.balance_amount) AS unpaid_amount
    FROM invoice i
    JOIN sale s
        ON i.sale_id = s.sale_id
    WHERE i.balance_amount > 0
    GROUP BY s.fuel_id
) i
    ON f.fuel_id = i.fuel_id;


-- =====================================================================
-- VIEWS FOR REPORTING
-- =====================================================================


-- =====================================================================
-- VIEW 1: FUEL STOCK VIEW
-- Creates a reusable view for monitoring current fuel inventory.
-- =====================================================================

CREATE OR REPLACE VIEW fuel_stock_view AS
SELECT
    f.fuel_name,
    t.tank_number,
    t.capacity_litres,
    t.current_stock,
    ROUND(
        (t.current_stock / t.capacity_litres) * 100,
        2
    ) AS stock_percentage
FROM fuel_type f
JOIN tank t
    ON f.fuel_id = t.fuel_id;


-- Display the fuel stock view
SELECT *
FROM fuel_stock_view;


-- =====================================================================
-- VIEW 2: SALES SUMMARY VIEW
-- Creates a reusable view showing fuel-wise sales performance.
-- =====================================================================

CREATE OR REPLACE VIEW sales_summary_view AS
SELECT
    f.fuel_name,
    SUM(s.quantity_litres) AS total_litres_sold,
    SUM(s.total_amount) AS total_revenue
FROM sale s
JOIN fuel_type f
    ON s.fuel_id = f.fuel_id
GROUP BY f.fuel_id, f.fuel_name;


-- Display the sales summary view
SELECT *
FROM sales_summary_view;


-- =====================================================================
-- VIEW 3: OUTSTANDING INVOICE VIEW
-- Creates a reusable view for monitoring unpaid invoice balances.
-- =====================================================================

CREATE OR REPLACE VIEW outstanding_invoice_view AS
SELECT
    c.customer_name,
    i.invoice_id,
    i.total_amount,
    i.paid_amount,
    i.balance_amount,
    i.status
FROM credit_customer c
JOIN invoice i
    ON c.customer_id = i.customer_id
WHERE i.balance_amount > 0;


-- Display outstanding invoices
SELECT *
FROM outstanding_invoice_view;


-- =====================================================================
-- VIEW 4: SUPPLIER DELIVERY VIEW
-- Creates a reusable view showing supplier-wise delivery details.
-- =====================================================================

CREATE OR REPLACE VIEW supplier_delivery_view AS
SELECT
    s.supplier_name,
    COUNT(d.delivery_id) AS total_deliveries,
    SUM(d.quantity_litres) AS total_quantity_delivered,
    SUM(d.total_cost) AS total_delivery_cost
FROM supplier s
JOIN delivery d
    ON s.supplier_id = d.supplier_id
GROUP BY s.supplier_id, s.supplier_name;


-- Display supplier delivery information
SELECT *
FROM supplier_delivery_view;
