import datetime
from database.db_manager import get_db, query_db


def get_all_equipment():
    return query_db("""
        SELECT e.*, s.sport_name,
               (e.total_quantity - e.available_quantity) AS on_loan_quantity
        FROM equipment e
        JOIN sports s ON e.sport_id = s.sport_id
        ORDER BY e.equipment_id ASC;
    """)


def get_equipment_loans(status=None):
    sql = """
        SELECT el.*, e.equipment_name, e.brand, s.sport_name,
               m.first_name || ' ' || m.last_name AS member_name, m.email, m.phone,
               CASE 
                   WHEN el.status = 'ISSUED' AND el.due_date < CURRENT_DATE THEN 1 
                   ELSE 0 
               END AS is_overdue
        FROM equipment_loans el
        JOIN equipment e ON el.equipment_id = e.equipment_id
        JOIN sports s ON e.sport_id = s.sport_id
        JOIN members m ON el.member_id = m.member_id
        WHERE 1=1
    """
    params = []
    if status:
        sql += " AND el.status = ?"
        params.append(status)
    sql += " ORDER BY el.due_date ASC, el.loan_id DESC;"
    return query_db(sql, params)


def issue_equipment(equipment_id, member_id, quantity, due_date):
    quantity = int(quantity)
    if quantity <= 0:
        raise ValueError("Quantity must be greater than zero.")

    with get_db() as conn:
        cur = conn.cursor()
        # Verify member is ACTIVE
        cur.execute("SELECT status FROM members WHERE member_id = ?;", (member_id,))
        m = cur.fetchone()
        if not m or m["status"] != 'ACTIVE':
            raise ValueError("Only members with ACTIVE status can borrow equipment.")

        # Trigger validates sufficient stock & auto-decrements available_quantity
        cur.execute("""
            INSERT INTO equipment_loans 
            (equipment_id, member_id, quantity, issue_date, due_date, status, condition_on_issue, fine_amount)
            VALUES (?, ?, ?, CURRENT_DATE, ?, 'ISSUED', 'GOOD', 0.0);
        """, (equipment_id, member_id, quantity, due_date))
        return cur.lastrowid


def return_equipment(loan_id, condition_on_return='GOOD', fine_amount=0.0):
    fine_amount = float(fine_amount or 0.0)
    with get_db() as conn:
        cur = conn.cursor()
        new_status = 'DAMAGED_RETURNED' if condition_on_return in ('DAMAGED', 'LOST') else 'RETURNED'
        
        # Trigger trg_increment_equipment_stock will auto-restore stock
        cur.execute("""
            UPDATE equipment_loans
            SET return_date = CURRENT_DATE,
                status = ?,
                condition_on_return = ?,
                fine_amount = ?
            WHERE loan_id = ?;
        """, (new_status, condition_on_return, fine_amount, loan_id))
        return cur.rowcount


def add_equipment(sport_id, equipment_name, brand, model_code, quantity):
    quantity = int(quantity)
    with get_db() as conn:
        cur = conn.cursor()
        cur.execute("""
            INSERT INTO equipment (sport_id, equipment_name, brand, model_code, total_quantity, available_quantity, condition_status)
            VALUES (?, ?, ?, ?, ?, ?, 'GOOD');
        """, (sport_id, equipment_name, brand, model_code, quantity, quantity))
        return cur.lastrowid
