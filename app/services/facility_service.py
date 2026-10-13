from database.db_manager import get_db, query_db


def get_all_facilities():
    return query_db("""
        SELECT f.*, s.sport_name 
        FROM facilities f 
        JOIN sports s ON f.sport_id = s.sport_id 
        ORDER BY f.facility_id ASC;
    """)


def get_facility_bookings(facility_id=None, booking_date=None):
    sql = """
        SELECT fb.*, f.facility_name, s.sport_name,
               COALESCE(m.first_name || ' ' || m.last_name, 'Team: ' || t.team_name) AS booked_by
        FROM facility_bookings fb
        JOIN facilities f ON fb.facility_id = f.facility_id
        JOIN sports s ON f.sport_id = s.sport_id
        LEFT JOIN members m ON fb.member_id = m.member_id
        LEFT JOIN teams t ON fb.team_id = t.team_id
        WHERE 1=1
    """
    params = []
    if facility_id:
        sql += " AND fb.facility_id = ?"
        params.append(facility_id)
    if booking_date:
        sql += " AND fb.booking_date = ?"
        params.append(booking_date)
    sql += " ORDER BY fb.booking_date DESC, fb.start_time ASC;"
    return query_db(sql, params)


def book_facility(facility_id, member_id, team_id, booking_date, start_time, end_time, purpose, attendees_count):
    with get_db() as conn:
        cur = conn.cursor()
        # Fetch facility info
        cur.execute("SELECT hourly_rate, capacity, is_operational FROM facilities WHERE facility_id = ?;", (facility_id,))
        fac = cur.fetchone()
        if not fac:
            raise ValueError("Facility not found.")
        if not fac["is_operational"]:
            raise ValueError("Selected facility is currently closed for maintenance.")

        # Capacity check
        if attendees_count > fac["capacity"]:
            raise ValueError(f"Attendees count ({attendees_count}) exceeds facility maximum capacity ({fac['capacity']}).")

        # Calculate fee
        # parse hours difference
        start_h, start_m = map(int, start_time.split(":")[:2])
        end_h, end_m = map(int, end_time.split(":")[:2])
        duration_hours = (end_h + end_m / 60.0) - (start_h + start_m / 60.0)
        if duration_hours <= 0:
            raise ValueError("End time must be after start time.")

        total_fee = round(duration_hours * fac["hourly_rate"], 2)

        # Trigger will check membership status & overlap
        cur.execute("""
            INSERT INTO facility_bookings 
            (facility_id, member_id, team_id, booking_date, start_time, end_time, booking_purpose, attendees_count, total_fee, status)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'CONFIRMED');
        """, (facility_id, member_id or None, team_id or None, booking_date, start_time, end_time, purpose, attendees_count, total_fee))
        return cur.lastrowid
