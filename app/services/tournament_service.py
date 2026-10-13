from database.db_manager import get_db, query_db


def get_tournaments():
    return query_db("""
        SELECT t.*, s.sport_name,
               COUNT(DISTINCT tp.participant_id) AS total_participants,
               COUNT(DISTINCT f.fixture_id) AS total_fixtures
        FROM tournaments t
        JOIN sports s ON t.sport_id = s.sport_id
        LEFT JOIN tournament_participants tp ON t.tournament_id = tp.tournament_id
        LEFT JOIN fixtures f ON t.tournament_id = f.tournament_id
        GROUP BY t.tournament_id
        ORDER BY t.start_date DESC;
    """)


def get_tournament_details(tournament_id):
    return query_db("SELECT t.*, s.sport_name FROM tournaments t JOIN sports s ON t.sport_id = s.sport_id WHERE t.tournament_id = ?;", (tournament_id,), one=True)


def create_tournament(tournament_name, sport_id, start_date, end_date, format_type, entry_fee, prize_pool):
    with get_db() as conn:
        cur = conn.cursor()
        cur.execute("""
            INSERT INTO tournaments (tournament_name, sport_id, start_date, end_date, format, entry_fee, prize_pool, status)
            VALUES (?, ?, ?, ?, ?, ?, ?, 'UPCOMING');
        """, (tournament_name, sport_id, start_date, end_date, format_type, entry_fee, prize_pool))
        return cur.lastrowid


def get_tournament_participants(tournament_id):
    return query_db("""
        SELECT tp.*, 
               COALESCE(m.email, 'team') AS contact_info
        FROM tournament_participants tp
        LEFT JOIN members m ON tp.member_id = m.member_id
        WHERE tp.tournament_id = ?
        ORDER BY tp.seed_number ASC, tp.participant_id ASC;
    """, (tournament_id,))


def add_participant(tournament_id, team_id, member_id, display_name, seed_number=None):
    with get_db() as conn:
        cur = conn.cursor()
        cur.execute("""
            INSERT INTO tournament_participants (tournament_id, team_id, member_id, display_name, registration_date, seed_number, payment_status, status)
            VALUES (?, ?, ?, ?, CURRENT_DATE, ?, 'PAID', 'ACTIVE');
        """, (tournament_id, team_id or None, member_id or None, display_name, seed_number or None))
        return cur.lastrowid


def get_tournament_fixtures(tournament_id):
    return query_db("""
        SELECT f.*, 
               p1.display_name AS p1_name,
               p2.display_name AS p2_name,
               fac.facility_name,
               mr.result_id, mr.score_participant1, mr.score_participant2, mr.set_scores_details,
               pw.display_name AS winner_name
        FROM fixtures f
        JOIN tournament_participants p1 ON f.participant1_id = p1.participant_id
        JOIN tournament_participants p2 ON f.participant2_id = p2.participant_id
        JOIN facilities fac ON f.facility_id = fac.facility_id
        LEFT JOIN match_results mr ON f.fixture_id = mr.fixture_id
        LEFT JOIN tournament_participants pw ON mr.winner_participant_id = pw.participant_id
        WHERE f.tournament_id = ?
        ORDER BY f.fixture_date ASC, f.start_time ASC;
    """, (tournament_id,))


def create_fixture(tournament_id, stage, p1_id, p2_id, facility_id, fixture_date, start_time, end_time):
    if p1_id == p2_id:
        raise ValueError("Participant 1 and Participant 2 cannot be the same entity.")

    with get_db() as conn:
        cur = conn.cursor()
        cur.execute("""
            INSERT INTO fixtures (tournament_id, stage, participant1_id, participant2_id, facility_id, fixture_date, start_time, end_time, status)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'SCHEDULED');
        """, (tournament_id, stage, p1_id, p2_id, facility_id, fixture_date, start_time, end_time))
        return cur.lastrowid


def record_match_result(fixture_id, score_p1, score_p2, set_scores=None, notes=None):
    score_p1 = int(score_p1)
    score_p2 = int(score_p2)
    if score_p1 < 0 or score_p2 < 0:
        raise ValueError("Scores must be non-negative integers.")

    with get_db() as conn:
        cur = conn.cursor()
        # Find fixture and participants
        cur.execute("SELECT * FROM fixtures WHERE fixture_id = ?;", (fixture_id,))
        fix = cur.fetchone()
        if not fix:
            raise ValueError("Fixture not found.")

        p1_id = fix["participant1_id"]
        p2_id = fix["participant2_id"]

        winner_id = None
        if score_p1 > score_p2:
            winner_id = p1_id
        elif score_p2 > score_p1:
            winner_id = p2_id

        # Insert or replace match result
        cur.execute("""
            INSERT OR REPLACE INTO match_results 
            (fixture_id, winner_participant_id, score_participant1, score_participant2, set_scores_details, match_notes, recorded_at)
            VALUES (?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP);
        """, (fixture_id, winner_id, score_p1, score_p2, set_scores or '', notes or ''))

        # Update fixture status
        cur.execute("UPDATE fixtures SET status = 'COMPLETED' WHERE fixture_id = ?;", (fixture_id,))
        return cur.lastrowid
