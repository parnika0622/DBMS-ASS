from database.db_manager import get_connection, query_db


def get_dashboard_stats():
    conn = get_connection()
    try:
        cur = conn.cursor()
        cur.execute("SELECT COUNT(*) FROM members WHERE status = 'ACTIVE';")
        active_members = cur.fetchone()[0]

        cur.execute("SELECT COUNT(*) FROM tournaments WHERE status IN ('ONGOING', 'UPCOMING');")
        active_tournaments = cur.fetchone()[0]

        cur.execute("SELECT COUNT(*) FROM facility_bookings WHERE status = 'CONFIRMED' AND booking_date >= CURRENT_DATE;")
        upcoming_bookings = cur.fetchone()[0]

        cur.execute("SELECT COALESCE(SUM(amount), 0.0) FROM payments WHERE status = 'COMPLETED';")
        total_revenue = cur.fetchone()[0]

        cur.execute("SELECT COUNT(*) FROM equipment_loans WHERE status = 'ISSUED';")
        active_loans = cur.fetchone()[0]

        cur.execute("SELECT COUNT(*), COALESCE(SUM(amount_due), 0.0) FROM v_fee_dues;")
        fee_row = cur.fetchone()
        fee_defaulters_count = fee_row[0]
        fee_defaulters_amount = fee_row[1]

        # Recent 5 bookings
        cur.execute("""
            SELECT fb.*, f.facility_name, 
                   COALESCE(m.first_name || ' ' || m.last_name, t.team_name) AS booked_for
            FROM facility_bookings fb
            JOIN facilities f ON fb.facility_id = f.facility_id
            LEFT JOIN members m ON fb.member_id = m.member_id
            LEFT JOIN teams t ON fb.team_id = t.team_id
            ORDER BY fb.booking_date DESC, fb.start_time ASC
            LIMIT 5;
        """)
        recent_bookings = [dict(r) for r in cur.fetchall()]

        # Recent 5 payments
        cur.execute("""
            SELECT p.*, m.first_name || ' ' || m.last_name AS member_name
            FROM payments p
            JOIN members m ON p.member_id = m.member_id
            ORDER BY p.payment_date DESC
            LIMIT 5;
        """)
        recent_payments = [dict(r) for r in cur.fetchall()]

        return {
            "active_members": active_members,
            "active_tournaments": active_tournaments,
            "upcoming_bookings": upcoming_bookings,
            "total_revenue": total_revenue,
            "active_loans": active_loans,
            "fee_defaulters_count": fee_defaulters_count,
            "fee_defaulters_amount": fee_defaulters_amount,
            "recent_bookings": recent_bookings,
            "recent_payments": recent_payments
        }
    finally:
        conn.close()


def get_report_data(report_name):
    view_map = {
        "memberships": "SELECT * FROM v_active_memberships ORDER BY days_remaining ASC;",
        "standings": "SELECT * FROM v_tournament_standings;",
        "facilities": "SELECT * FROM v_facility_utilization ORDER BY total_revenue_generated DESC;",
        "players": "SELECT * FROM v_player_performance ORDER BY win_percentage DESC;",
        "dues": "SELECT * FROM v_fee_dues ORDER BY days_since_start DESC;",
        "equipment": "SELECT * FROM v_equipment_status ORDER BY overdue_loans_count DESC;"
    }
    sql = view_map.get(report_name, view_map["memberships"])
    return query_db(sql)


def run_custom_query(sql_query):
    """Executes an interactive SQL query and returns column names and row values."""
    cleaned = sql_query.strip()
    if not cleaned:
        return {"columns": [], "rows": [], "error": "Query cannot be empty."}

    # Restrict to SELECT queries for safety
    if not cleaned.lower().startswith("select"):
        return {"columns": [], "rows": [], "error": "Only SELECT statements are permitted in the SQL Console."}

    conn = get_connection()
    try:
        cur = conn.cursor()
        cur.execute(cleaned)
        columns = [desc[0] for desc in cur.description] if cur.description else []
        rows = [list(r) for r in cur.fetchall()]
        return {"columns": columns, "rows": rows, "error": None, "count": len(rows)}
    except Exception as e:
        return {"columns": [], "rows": [], "error": str(e)}
    finally:
        conn.close()
