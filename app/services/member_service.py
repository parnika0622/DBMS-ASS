import datetime
from database.db_manager import get_db, query_db


def get_all_members(search=None, status_filter=None):
    sql = """
        SELECT m.*, 
               s.subscription_id, s.start_date, s.end_date, s.payment_status,
               p.plan_name,
               (SELECT COUNT(*) FROM equipment_loans el WHERE el.member_id = m.member_id AND el.status = 'ISSUED') AS active_loans_count
        FROM members m
        LEFT JOIN member_subscriptions s ON m.member_id = s.member_id AND s.status = 'ACTIVE'
        LEFT JOIN membership_plans p ON s.plan_id = p.plan_id
        WHERE 1=1
    """
    params = []
    if search:
        sql += " AND (m.first_name LIKE ? OR m.last_name LIKE ? OR m.email LIKE ? OR m.phone LIKE ?)"
        term = f"%{search}%"
        params.extend([term, term, term, term])
    if status_filter:
        sql += " AND m.status = ?"
        params.append(status_filter)
    sql += " ORDER BY m.member_id DESC;"
    return query_db(sql, params)


def get_member(member_id):
    return query_db("SELECT * FROM members WHERE member_id = ?;", (member_id,), one=True)


def get_membership_plans():
    return query_db("SELECT * FROM membership_plans WHERE is_active = 1 ORDER BY fee_amount ASC;")


def register_member(first_name, last_name, email, phone, dob, gender, address, emergency_contact):
    sql = """
        INSERT INTO members (first_name, last_name, email, phone, dob, gender, address, emergency_contact, joined_date, status)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, CURRENT_DATE, 'ACTIVE');
    """
    with get_db() as conn:
        cur = conn.cursor()
        cur.execute(sql, (first_name, last_name, email, phone, dob, gender, address, emergency_contact))
        return cur.lastrowid


def subscribe_member(member_id, plan_id, payment_method, duration_months=None):
    """
    ACID Transaction:
    1. Look up plan
    2. Insert active subscription
    3. Generate completed payment record
    4. Set member status to ACTIVE
    """
    with get_db() as conn:
        cur = conn.cursor()
        cur.execute("SELECT * FROM membership_plans WHERE plan_id = ?;", (plan_id,))
        plan = cur.fetchone()
        if not plan:
            raise ValueError("Invalid membership plan selected.")

        months = duration_months or plan["duration_months"]
        fee = plan["fee_amount"]

        start_date = datetime.date.today()
        # approximate month duration
        end_date = start_date + datetime.timedelta(days=int(months * 30.4375))

        # Close any previous active subscriptions
        cur.execute("""
            UPDATE member_subscriptions 
            SET status = 'EXPIRED' 
            WHERE member_id = ? AND status = 'ACTIVE';
        """, (member_id,))

        # Create new subscription
        cur.execute("""
            INSERT INTO member_subscriptions (member_id, plan_id, start_date, end_date, status, payment_status)
            VALUES (?, ?, ?, ?, 'ACTIVE', 'PAID');
        """, (member_id, plan_id, start_date.isoformat(), end_date.isoformat()))
        sub_id = cur.lastrowid

        # Record payment transaction
        txn_ref = f"TXN-{datetime.datetime.now().strftime('%Y%m%d%H%M%S')}-{member_id}"
        cur.execute("""
            INSERT INTO payments (member_id, subscription_id, amount, payment_date, payment_method, transaction_ref, status, notes)
            VALUES (?, ?, ?, CURRENT_TIMESTAMP, ?, ?, 'COMPLETED', ?);
        """, (member_id, sub_id, fee, payment_method, txn_ref, f"Payment for {plan['plan_name']}"))

        # Ensure member is ACTIVE
        cur.execute("UPDATE members SET status = 'ACTIVE' WHERE member_id = ?;", (member_id,))

        return sub_id
