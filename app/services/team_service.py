from database.db_manager import get_db, query_db


def get_all_teams():
    return query_db("""
        SELECT t.*, s.sport_name, 
               COALESCE(c.first_name || ' ' || c.last_name, 'No Coach') AS coach_name,
               COALESCE(m.first_name || ' ' || m.last_name, 'No Captain') AS captain_name,
               COUNT(tr.roster_id) AS total_players
        FROM teams t
        JOIN sports s ON t.sport_id = s.sport_id
        LEFT JOIN coaches c ON t.coach_id = c.coach_id
        LEFT JOIN members m ON t.captain_id = m.member_id
        LEFT JOIN team_roster tr ON t.team_id = tr.team_id AND tr.is_active = 1
        GROUP BY t.team_id
        ORDER BY t.team_id DESC;
    """)


def get_team_roster(team_id):
    return query_db("""
        SELECT tr.*, m.first_name || ' ' || m.last_name AS member_name, m.email, m.phone, m.status AS member_status
        FROM team_roster tr
        JOIN members m ON tr.member_id = m.member_id
        WHERE tr.team_id = ?
        ORDER BY tr.jersey_number ASC;
    """, (team_id,))


def get_all_coaches():
    return query_db("""
        SELECT c.*, s.sport_name 
        FROM coaches c 
        JOIN sports s ON c.specialization_sport_id = s.sport_id 
        ORDER BY c.coach_id ASC;
    """)


def get_all_sports():
    return query_db("SELECT * FROM sports ORDER BY sport_id ASC;")


def create_team(team_name, sport_id, coach_id, captain_id):
    with get_db() as conn:
        cur = conn.cursor()
        cur.execute("""
            INSERT INTO teams (team_name, sport_id, coach_id, captain_id, created_date)
            VALUES (?, ?, ?, ?, CURRENT_DATE);
        """, (team_name, sport_id, coach_id or None, captain_id or None))
        team_id = cur.lastrowid

        # If captain is assigned, automatically add to roster as jersey 10 / Captain
        if captain_id:
            cur.execute("""
                INSERT OR IGNORE INTO team_roster (team_id, member_id, jersey_number, position, joined_date, is_active)
                VALUES (?, ?, 10, 'Captain', CURRENT_DATE, 1);
            """, (team_id, captain_id))
        return team_id


def add_member_to_roster(team_id, member_id, jersey_number, position):
    with get_db() as conn:
        cur = conn.cursor()
        cur.execute("""
            INSERT INTO team_roster (team_id, member_id, jersey_number, position, joined_date, is_active)
            VALUES (?, ?, ?, ?, CURRENT_DATE, 1);
        """, (team_id, member_id, jersey_number, position))
        return cur.lastrowid
