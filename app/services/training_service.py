from database.db_manager import get_db, query_db


def get_training_sessions():
    return query_db("""
        SELECT ts.*, s.sport_name,
               c.first_name || ' ' || c.last_name AS coach_name,
               f.facility_name,
               COUNT(te.enrollment_id) AS enrolled_count
        FROM training_sessions ts
        JOIN sports s ON ts.sport_id = s.sport_id
        JOIN coaches c ON ts.coach_id = c.coach_id
        JOIN facilities f ON ts.facility_id = f.facility_id
        LEFT JOIN training_enrollments te ON ts.session_id = te.session_id
        GROUP BY ts.session_id
        ORDER BY ts.session_date DESC, ts.start_time ASC;
    """)


def get_session_enrollments(session_id):
    return query_db("""
        SELECT te.*, m.first_name || ' ' || m.last_name AS member_name, m.email, m.phone
        FROM training_enrollments te
        JOIN members m ON te.member_id = m.member_id
        WHERE te.session_id = ?
        ORDER BY te.enrolled_at ASC;
    """, (session_id,))


def create_training_session(sport_id, coach_id, facility_id, session_title, session_date, start_time, end_time, max_participants):
    with get_db() as conn:
        cur = conn.cursor()
        cur.execute("""
            INSERT INTO training_sessions
            (sport_id, coach_id, facility_id, session_title, session_date, start_time, end_time, max_participants, status)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'SCHEDULED');
        """, (sport_id, coach_id, facility_id, session_title, session_date, start_time, end_time, max_participants))
        return cur.lastrowid


def enroll_member(session_id, member_id):
    with get_db() as conn:
        cur = conn.cursor()
        # Verify active status
        cur.execute("SELECT status FROM members WHERE member_id = ?;", (member_id,))
        m = cur.fetchone()
        if not m or m["status"] != 'ACTIVE':
            raise ValueError("Only members with ACTIVE status can enroll in training sessions.")

        cur.execute("""
            INSERT INTO training_enrollments (session_id, member_id, enrolled_at, attendance_status)
            VALUES (?, ?, CURRENT_TIMESTAMP, 'REGISTERED');
        """, (session_id, member_id))
        return cur.lastrowid
