from fastapi import FastAPI, Request, Form
from fastapi.templating import Jinja2Templates
from fastapi.staticfiles import StaticFiles
from fastapi.responses import RedirectResponse
from database import get_connection

app = FastAPI()

app.mount("/static", StaticFiles(directory="static"), name="static")

templates = Jinja2Templates(directory="templates")


# =========================================================
# DASHBOARD
# =========================================================

@app.get("/")
def home(request: Request):

    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    # -----------------------------------------------------
    # Fuel stock
    # -----------------------------------------------------

    cursor.execute("""
        SELECT
            f.fuel_name,
            COALESCE(SUM(t.current_stock), 0) AS stock
        FROM fuel_type f
        LEFT JOIN tank t
            ON f.fuel_id = t.fuel_id
        GROUP BY f.fuel_id, f.fuel_name
        ORDER BY f.fuel_id
    """)

    fuel_stock = cursor.fetchall()

    # -----------------------------------------------------
    # Total sales revenue
    # -----------------------------------------------------

    cursor.execute("""
        SELECT
            COALESCE(SUM(total_amount), 0) AS total_sales
        FROM sale
    """)

    total_sales = cursor.fetchone()["total_sales"]

    # -----------------------------------------------------
    # Total number of sales
    # -----------------------------------------------------

    cursor.execute("""
        SELECT
            COUNT(*) AS sales_count
        FROM sale
    """)

    sales_count = cursor.fetchone()["sales_count"]

    # -----------------------------------------------------
    # Total litres sold
    # -----------------------------------------------------

    cursor.execute("""
        SELECT
            COALESCE(SUM(quantity_litres), 0) AS litres_sold
        FROM sale
    """)

    litres_sold = cursor.fetchone()["litres_sold"]

    # -----------------------------------------------------
    # Total paid amount
    # -----------------------------------------------------

    cursor.execute("""
        SELECT
            COALESCE(SUM(paid_amount), 0) AS paid_amount
        FROM invoice
    """)

    paid_amount = cursor.fetchone()["paid_amount"]

    # -----------------------------------------------------
    # Outstanding amount
    # -----------------------------------------------------

    cursor.execute("""
        SELECT
            COALESCE(SUM(balance_amount), 0) AS outstanding
        FROM invoice
        WHERE balance_amount > 0
    """)

    outstanding = cursor.fetchone()["outstanding"]

    # -----------------------------------------------------
    # Supplier count
    # -----------------------------------------------------

    cursor.execute("""
        SELECT
            COUNT(*) AS total
        FROM supplier
    """)

    total_suppliers = cursor.fetchone()["total"]

    # -----------------------------------------------------
    # Attendant count
    # -----------------------------------------------------

    cursor.execute("""
        SELECT
            COUNT(*) AS total
        FROM attendant
    """)

    total_attendants = cursor.fetchone()["total"]

    # -----------------------------------------------------
    # Customer count
    # -----------------------------------------------------

    cursor.execute("""
        SELECT
            COUNT(*) AS total
        FROM credit_customer
    """)

    total_customers = cursor.fetchone()["total"]

    # -----------------------------------------------------
    # Total fuel stock
    # -----------------------------------------------------

    cursor.execute("""
        SELECT
            COALESCE(SUM(current_stock), 0) AS total_stock
        FROM tank
    """)

    total_fuel_stock = cursor.fetchone()["total_stock"]

    # -----------------------------------------------------
    # Fuel-wise sales analytics
    # -----------------------------------------------------

    cursor.execute("""
        SELECT
            f.fuel_name,
            COUNT(s.sale_id) AS total_sales,
            COALESCE(SUM(s.quantity_litres), 0) AS litres_sold,
            COALESCE(SUM(s.total_amount), 0) AS revenue
        FROM fuel_type f
        LEFT JOIN sale s
            ON f.fuel_id = s.fuel_id
        GROUP BY f.fuel_id, f.fuel_name
        ORDER BY revenue DESC
    """)

    fuel_sales = cursor.fetchall()

    # -----------------------------------------------------
    # Payment method analytics
    # -----------------------------------------------------

    cursor.execute("""
        SELECT
            payment_type,
            COUNT(*) AS transactions,
            COALESCE(SUM(total_amount), 0) AS amount
        FROM sale
        GROUP BY payment_type
        ORDER BY amount DESC
    """)

    payment_breakdown = cursor.fetchall()

    # -----------------------------------------------------
    # Recent 7-day sales trend
    # -----------------------------------------------------

    cursor.execute("""
        SELECT
            DATE(sale_time) AS sale_date,
            COUNT(*) AS transactions,
            COALESCE(SUM(quantity_litres), 0) AS litres_sold,
            COALESCE(SUM(total_amount), 0) AS revenue
        FROM sale
        WHERE sale_time >= CURDATE() - INTERVAL 6 DAY
        GROUP BY DATE(sale_time)
        ORDER BY sale_date
    """)

    daily_sales = cursor.fetchall()

    cursor.close()
    connection.close()

    return templates.TemplateResponse(
        request=request,
        name="index.html",
        context={
            "fuel_stock": fuel_stock,
            "total_sales": total_sales,
            "sales_count": sales_count,
            "litres_sold": litres_sold,
            "paid_amount": paid_amount,
            "outstanding": outstanding,
            "total_suppliers": total_suppliers,
            "total_attendants": total_attendants,
            "total_customers": total_customers,
            "total_fuel_stock": total_fuel_stock,
            "fuel_sales": fuel_sales,
            "payment_breakdown": payment_breakdown,
            "daily_sales": daily_sales
        }
    )


# =========================================================
# FUEL INVENTORY
# =========================================================

@app.get("/inventory")
def inventory(request: Request):

    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    cursor.execute("""
        SELECT
            f.fuel_id,
            f.fuel_name,
            f.fuel_code,
            f.price_per_litre,
            t.tank_number,
            t.capacity_litres,
            t.current_stock,
            t.status
        FROM fuel_type f
        JOIN tank t
            ON f.fuel_id = t.fuel_id
        ORDER BY f.fuel_id
    """)

    inventory_data = cursor.fetchall()

    cursor.close()
    connection.close()

    return templates.TemplateResponse(
        request=request,
        name="inventory.html",
        context={
            "inventory": inventory_data
        }
    )


# =========================================================
# SUPPLIERS - VIEW
# =========================================================

@app.get("/suppliers")
def suppliers(request: Request):

    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    cursor.execute("""
        SELECT
            supplier_id,
            supplier_name,
            phone,
            email,
            address
        FROM supplier
        ORDER BY supplier_id DESC
    """)

    suppliers_data = cursor.fetchall()

    cursor.close()
    connection.close()

    return templates.TemplateResponse(
        request=request,
        name="suppliers.html",
        context={
            "suppliers": suppliers_data,
            "message": request.query_params.get("message")
        }
    )


# =========================================================
# SUPPLIERS - INSERT
# =========================================================

@app.post("/suppliers/add")
def add_supplier(
    name: str = Form(...),
    phone: str = Form(...),
    email: str = Form(""),
    address: str = Form(...)
):

    connection = get_connection()
    cursor = connection.cursor()

    try:

        cursor.execute("""
            INSERT INTO supplier
            (
                supplier_name,
                phone,
                email,
                address
            )
            VALUES
            (
                %s,
                %s,
                %s,
                %s
            )
        """, (
            name,
            phone,
            email if email else None,
            address
        ))

        connection.commit()

        message = "Supplier added successfully!"

    except Exception as e:

        connection.rollback()

        message = "Error: " + str(e)

    cursor.close()
    connection.close()

    return RedirectResponse(
        url="/suppliers?message=" + message,
        status_code=303
    )


# =========================================================
# SUPPLIERS - DELETE
# =========================================================

@app.post("/suppliers/delete/{supplier_id}")
def delete_supplier(supplier_id: int):

    connection = get_connection()
    cursor = connection.cursor()

    try:

        cursor.execute("""
            DELETE FROM supplier
            WHERE supplier_id = %s
        """, (supplier_id,))

        connection.commit()

        message = "Supplier deleted successfully!"

    except Exception:

        connection.rollback()

        message = "Cannot delete: supplier is used by another record."

    cursor.close()
    connection.close()

    return RedirectResponse(
        url="/suppliers?message=" + message,
        status_code=303
    )


# =========================================================
# CUSTOMERS - VIEW
# =========================================================

@app.get("/customers")
def customers(request: Request):

    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    cursor.execute("""
        SELECT
            customer_id,
            customer_name,
            phone,
            address,
            credit_limit,
            status
        FROM credit_customer
        ORDER BY customer_id DESC
    """)

    customers_data = cursor.fetchall()

    cursor.close()
    connection.close()

    return templates.TemplateResponse(
        request=request,
        name="customers.html",
        context={
            "customers": customers_data,
            "message": request.query_params.get("message")
        }
    )


# =========================================================
# CUSTOMERS - INSERT
# =========================================================

@app.post("/customers/add")
def add_customer(
    name: str = Form(...),
    phone: str = Form(...),
    address: str = Form(...),
    credit_limit: float = Form(...)
):

    connection = get_connection()
    cursor = connection.cursor()

    try:

        cursor.execute("""
            INSERT INTO credit_customer
            (
                customer_name,
                phone,
                address,
                credit_limit
            )
            VALUES
            (
                %s,
                %s,
                %s,
                %s
            )
        """, (
            name,
            phone,
            address,
            credit_limit
        ))

        connection.commit()

        message = "Customer added successfully!"

    except Exception as e:

        connection.rollback()

        message = "Error: " + str(e)

    cursor.close()
    connection.close()

    return RedirectResponse(
        url="/customers?message=" + message,
        status_code=303
    )


# =========================================================
# CUSTOMERS - DELETE
# =========================================================

@app.post("/customers/delete/{customer_id}")
def delete_customer(customer_id: int):

    connection = get_connection()
    cursor = connection.cursor()

    try:

        cursor.execute("""
            DELETE FROM credit_customer
            WHERE customer_id = %s
        """, (customer_id,))

        connection.commit()

        message = "Customer deleted successfully!"

    except Exception:

        connection.rollback()

        message = "Cannot delete: customer is used by another record."

    cursor.close()
    connection.close()

    return RedirectResponse(
        url="/customers?message=" + message,
        status_code=303
    )


# =========================================================
# SALES - VIEW
# =========================================================

@app.get("/sales")
def sales(request: Request):

    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    cursor.execute("""
        SELECT
            s.sale_id,
            f.fuel_name,
            s.quantity_litres,
            s.price_per_litre,
            s.total_amount,
            s.payment_type,
            s.sale_time,
            d.dispenser_number
        FROM sale s
        JOIN fuel_type f
            ON s.fuel_id = f.fuel_id
        JOIN dispenser d
            ON s.dispenser_id = d.dispenser_id
        ORDER BY s.sale_id DESC
    """)

    sales_data = cursor.fetchall()

    cursor.close()
    connection.close()

    return templates.TemplateResponse(
        request=request,
        name="sales.html",
        context={
            "sales": sales_data
        }
    )


# =========================================================
# DELIVERIES - VIEW
# =========================================================

@app.get("/deliveries")
def deliveries(request: Request):

    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    cursor.execute("""
        SELECT
            d.delivery_id,
            s.supplier_name,
            t.tank_number,
            f.fuel_name,
            d.delivery_date,
            d.quantity_litres,
            d.cost_per_litre,
            d.total_cost,
            d.invoice_number
        FROM delivery d
        JOIN supplier s
            ON d.supplier_id = s.supplier_id
        JOIN tank t
            ON d.tank_id = t.tank_id
        JOIN fuel_type f
            ON t.fuel_id = f.fuel_id
        ORDER BY d.delivery_id DESC
    """)

    deliveries_data = cursor.fetchall()

    cursor.close()
    connection.close()

    return templates.TemplateResponse(
        request=request,
        name="deliveries.html",
        context={
            "deliveries": deliveries_data
        }
    )


# =========================================================
# INVOICES - VIEW
# =========================================================

@app.get("/invoices")
def invoices(request: Request):

    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    cursor.execute("""
        SELECT
            i.invoice_id,
            c.customer_name,
            i.sale_id,
            i.invoice_date,
            i.total_amount,
            i.paid_amount,
            i.balance_amount,
            i.status
        FROM invoice i
        JOIN credit_customer c
            ON i.customer_id = c.customer_id
        ORDER BY i.invoice_id DESC
    """)

    invoices_data = cursor.fetchall()

    cursor.close()
    connection.close()

    return templates.TemplateResponse(
        request=request,
        name="invoices.html",
        context={
            "invoices": invoices_data
        }
    )


# =========================================================
# PAYMENTS - VIEW
# =========================================================

@app.get("/payments")
def payments(request: Request):

    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    cursor.execute("""
        SELECT
            p.payment_id,
            p.invoice_id,
            c.customer_name,
            p.payment_date,
            p.amount,
            p.payment_mode,
            p.reference_number
        FROM payment p
        JOIN invoice i
            ON p.invoice_id = i.invoice_id
        JOIN credit_customer c
            ON i.customer_id = c.customer_id
        ORDER BY p.payment_id DESC
    """)

    payments_data = cursor.fetchall()

    cursor.execute("""
        SELECT
            invoice_id,
            balance_amount
        FROM invoice
        WHERE balance_amount > 0
        ORDER BY invoice_id
    """)

    unpaid_invoices = cursor.fetchall()

    cursor.close()
    connection.close()

    return templates.TemplateResponse(
        request=request,
        name="payments.html",
        context={
            "payments": payments_data,
            "unpaid_invoices": unpaid_invoices,
            "message": request.query_params.get("message")
        }
    )


# =========================================================
# PAYMENTS - INSERT
# =========================================================

@app.post("/payments/add")
def add_payment(
    invoice_id: int = Form(...),
    amount: float = Form(...),
    payment_mode: str = Form(...),
    reference_number: str = Form("")
):

    connection = get_connection()
    cursor = connection.cursor()

    try:

        cursor.execute("""
            INSERT INTO payment
            (
                invoice_id,
                payment_date,
                amount,
                payment_mode,
                reference_number
            )
            VALUES
            (
                %s,
                CURDATE(),
                %s,
                %s,
                %s
            )
        """, (
            invoice_id,
            amount,
            payment_mode,
            reference_number if reference_number else None
        ))

        connection.commit()

        message = "Payment added successfully!"

    except Exception as e:

        connection.rollback()

        message = "Error: " + str(e)

    cursor.close()
    connection.close()

    return RedirectResponse(
        url="/payments?message=" + message,
        status_code=303
    )


# =========================================================
# REPORTS
# =========================================================

@app.get("/reports")
def reports(request: Request):

    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    # -----------------------------------------------------
    # Fuel sales report
    # -----------------------------------------------------

    cursor.execute("""
        SELECT
            f.fuel_name,
            COALESCE(SUM(s.quantity_litres), 0) AS litres_sold,
            COALESCE(SUM(s.total_amount), 0) AS revenue
        FROM fuel_type f
        LEFT JOIN sale s
            ON f.fuel_id = s.fuel_id
        GROUP BY
            f.fuel_id,
            f.fuel_name
        ORDER BY revenue DESC
    """)

    fuel_report = cursor.fetchall()

    # -----------------------------------------------------
    # Stock report
    # -----------------------------------------------------

    cursor.execute("""
        SELECT
            f.fuel_name,
            COALESCE(SUM(t.current_stock), 0) AS current_stock,
            COALESCE(SUM(t.capacity_litres), 0) AS capacity
        FROM fuel_type f
        LEFT JOIN tank t
            ON f.fuel_id = t.fuel_id
        GROUP BY
            f.fuel_id,
            f.fuel_name
        ORDER BY f.fuel_id
    """)

    stock_report = cursor.fetchall()

    # -----------------------------------------------------
    # Payment report
    # -----------------------------------------------------

    cursor.execute("""
        SELECT
            payment_type,
            COUNT(*) AS transactions,
            COALESCE(SUM(total_amount), 0) AS amount
        FROM sale
        GROUP BY payment_type
        ORDER BY amount DESC
    """)

    payment_report = cursor.fetchall()

    cursor.close()
    connection.close()

    return templates.TemplateResponse(
        request=request,
        name="reports.html",
        context={
            "fuel_report": fuel_report,
            "stock_report": stock_report,
            "payment_report": payment_report
        }
    )