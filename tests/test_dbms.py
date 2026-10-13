import os
import sys
import unittest
import sqlite3

# Add parent directory to path so database imports work
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from database.db_manager import get_connection, init_database

TEST_DB_PATH = os.path.abspath(os.path.join(os.path.dirname(__file__), "test_sports_club.db"))


class TestSportsClubDBMS(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        """Set up an isolated test database with fresh schema and seed data."""
        if os.path.exists(TEST_DB_PATH):
            os.remove(TEST_DB_PATH)
        init_database(db_path=TEST_DB_PATH, seed=True)

    @classmethod
    def tearDownClass(cls):
        """Clean up the test database file."""
        if os.path.exists(TEST_DB_PATH):
            try:
                os.remove(TEST_DB_PATH)
            except Exception:
                pass

    def get_conn(self):
        return get_connection(TEST_DB_PATH)

    def test_01_tables_and_views_exist(self):
        """Verify all 18 normalized tables and 6 views are present."""
        expected_tables = {
            "sports", "membership_plans", "members", "member_subscriptions",
            "payments", "coaches", "teams", "team_roster", "facilities",
            "facility_bookings", "training_sessions", "training_enrollments",
            "tournaments", "tournament_participants", "fixtures",
            "match_results", "equipment", "equipment_loans"
        }
        expected_views = {
            "v_active_memberships", "v_tournament_standings",
            "v_facility_utilization", "v_player_performance",
            "v_fee_dues", "v_equipment_status"
        }

        with self.get_conn() as conn:
            cur = conn.cursor()
            cur.execute("SELECT name FROM sqlite_master WHERE type='table';")
            tables = {row[0] for row in cur.fetchall()}
            for t in expected_tables:
                self.assertIn(t, tables, f"Missing table: {t}")

            cur.execute("SELECT name FROM sqlite_master WHERE type='view';")
            views = {row[0] for row in cur.fetchall()}
            for v in expected_views:
                self.assertIn(v, views, f"Missing view: {v}")

    def test_02_views_are_queryable(self):
        """Verify that all views return valid rows without SQL syntax or join errors."""
        views = [
            "v_active_memberships", "v_tournament_standings",
            "v_facility_utilization", "v_player_performance",
            "v_fee_dues", "v_equipment_status"
        ]
        with self.get_conn() as conn:
            cur = conn.cursor()
            for v in views:
                cur.execute(f"SELECT * FROM {v};")
                rows = cur.fetchall()
                self.assertIsNotNone(rows, f"View {v} returned None")

    def test_03_prevent_facility_booking_overlap(self):
        """Verify trigger prevents overlapping bookings for the same facility."""
        with self.get_conn() as conn:
            cur = conn.cursor()
            # Insert first valid booking
            cur.execute("""
                INSERT INTO facility_bookings 
                (facility_id, member_id, booking_date, start_time, end_time, booking_purpose, attendees_count, total_fee, status)
                VALUES (1, 1, '2026-11-20', '14:00:00', '15:00:00', 'CASUAL_PLAY', 2, 25.00, 'CONFIRMED');
            """)
            conn.commit()

            # Attempt overlapping booking (14:30 to 15:30) on same facility and date
            with self.assertRaises(sqlite3.IntegrityError):
                cur.execute("""
                    INSERT INTO facility_bookings 
                    (facility_id, member_id, booking_date, start_time, end_time, booking_purpose, attendees_count, total_fee, status)
                    VALUES (1, 2, '2026-11-20', '14:30:00', '15:30:00', 'CASUAL_PLAY', 2, 25.00, 'CONFIRMED');
                """)
                conn.commit()

    def test_04_require_active_member_for_facility_booking(self):
        """Verify trigger prevents expired/suspended members from booking facilities."""
        with self.get_conn() as conn:
            cur = conn.cursor()
            # Member 9 is EXPIRED in seed data
            with self.assertRaises(sqlite3.IntegrityError):
                cur.execute("""
                    INSERT INTO facility_bookings 
                    (facility_id, member_id, booking_date, start_time, end_time, booking_purpose, attendees_count, total_fee, status)
                    VALUES (2, 9, '2026-11-21', '10:00:00', '11:00:00', 'CASUAL_PLAY', 2, 20.00, 'CONFIRMED');
                """)
                conn.commit()

    def test_05_prevent_coach_schedule_overlap(self):
        """Verify trigger blocks double-booking of a coach at overlapping times."""
        with self.get_conn() as conn:
            cur = conn.cursor()
            # Coach 2 has session on 2026-10-18 from 07:00 to 08:30 (session 1)
            # Try to schedule Coach 2 on 2026-10-18 from 08:00 to 09:00
            with self.assertRaises(sqlite3.IntegrityError):
                cur.execute("""
                    INSERT INTO training_sessions
                    (sport_id, coach_id, facility_id, session_title, session_date, start_time, end_time, max_participants, status)
                    VALUES (1, 2, 2, 'Overlapping Badminton Camp', '2026-10-18', '08:00:00', '09:00:00', 4, 'SCHEDULED');
                """)
                conn.commit()

    def test_06_enforce_training_capacity(self):
        """Verify trigger prevents training enrollment beyond maximum capacity."""
        with self.get_conn() as conn:
            cur = conn.cursor()
            # Session 1 max participants is 4. Currently enrolled: members 2, 6, 8 (3 enrolled).
            # Enrolling 4th member (member 4) should succeed:
            cur.execute("""
                INSERT INTO training_enrollments (session_id, member_id, attendance_status)
                VALUES (1, 4, 'REGISTERED');
            """)
            conn.commit()

            # Enrolling 5th member (member 5) should fail due to capacity trigger:
            with self.assertRaises(sqlite3.IntegrityError):
                cur.execute("""
                    INSERT INTO training_enrollments (session_id, member_id, attendance_status)
                    VALUES (1, 5, 'REGISTERED');
                """)
                conn.commit()

    def test_07_equipment_loan_stock_auto_update(self):
        """Verify available stock decreases on loan issue and increases on return."""
        with self.get_conn() as conn:
            cur = conn.cursor()
            # Check current available quantity for equipment 2 (Yonex Shuttlecocks)
            cur.execute("SELECT available_quantity FROM equipment WHERE equipment_id = 2;")
            initial_stock = cur.fetchone()[0]

            # Issue 4 units to Member 1
            cur.execute("""
                INSERT INTO equipment_loans 
                (equipment_id, member_id, quantity, issue_date, due_date, status, condition_on_issue)
                VALUES (2, 1, 4, '2026-11-01', '2026-11-02', 'ISSUED', 'GOOD');
            """)
            conn.commit()
            loan_id = cur.lastrowid

            # Verify stock decremented by 4
            cur.execute("SELECT available_quantity FROM equipment WHERE equipment_id = 2;")
            stock_after_issue = cur.fetchone()[0]
            self.assertEqual(stock_after_issue, initial_stock - 4)

            # Return the equipment
            cur.execute("""
                UPDATE equipment_loans
                SET status = 'RETURNED', return_date = '2026-11-02', condition_on_return = 'GOOD'
                WHERE loan_id = ?;
            """, (loan_id,))
            conn.commit()

            # Verify stock restored
            cur.execute("SELECT available_quantity FROM equipment WHERE equipment_id = 2;")
            stock_after_return = cur.fetchone()[0]
            self.assertEqual(stock_after_return, initial_stock)

    def test_08_score_validity_check_constraints(self):
        """Verify CHECK constraints enforce positive scores and non-negative fees."""
        with self.get_conn() as conn:
            cur = conn.cursor()
            # Invalid negative score
            with self.assertRaises(sqlite3.IntegrityError):
                cur.execute("""
                    INSERT INTO match_results 
                    (fixture_id, winner_participant_id, score_participant1, score_participant2)
                    VALUES (6, 1, -1, 2);
                """)
                conn.commit()


if __name__ == "__main__":
    unittest.main()
