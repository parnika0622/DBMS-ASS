# Sports Club Membership and Tournament Management System (DBMS)

A complete, production-ready Relational Database Management System (RDBMS) course project and interactive web application for managing sports club memberships, teams, coaches, facility bookings, training drills, tournaments, match fixtures, fee collection, and equipment inventories.

Normalized up to **Third Normal Form (3NF) / Boyce-Codd Normal Form (BCNF)** with database-level integrity constraints, reactive triggers, advanced analytical queries, and an interactive Python/Flask web dashboard.

---

## 🌟 Key Features

1. **Member & Subscription Management:**
   - Multi-tier membership plans (Annual VIP, Semi-Annual Pro, Quarterly, Monthly Flex).
   - Atomic ACID transactions for member registration, plan subscription, and payment receipting.
   - Live tracking of membership expiration and overdue renewal dues.

2. **Teams & Player Rosters:**
   - Team formation across indoor and outdoor sports.
   - Assignment of licensed coaches and team captains.
   - Player roster management with jersey numbers (1–99) and positions.

3. **Facility Booking with Conflict Prevention:**
   - Courts, turfs, and arenas with capacity limits and hourly rates.
   - **Database Trigger `trg_prevent_facility_booking_overlap`:** Prevents double-booking overlapping time slots.
   - **Database Trigger `trg_require_active_member_for_booking`:** Restricts facility bookings to active members.

4. **Training Sessions & Coaching:**
   - Training drill scheduling with assigned coaches and facilities.
   - **Database Trigger `trg_prevent_coach_schedule_overlap`:** Prevents scheduling a coach for overlapping sessions.
   - **Database Trigger `trg_check_training_capacity`:** Blocks batch enrollments beyond maximum participant limits.

5. **Tournaments, Fixtures & Standings:**
   - Knockout, Round-Robin, and League tournament formats.
   - Match fixture scheduling with venue allocations.
   - Match score recording with set details and match notes.
   - Automated tournament standings computation (Played, Won, Drawn, Lost, Score For, Score Against, Score Diff, Points).

6. **Equipment Inventory & Loan Tracking:**
   - Sports gear inventory tracking (total vs. available stock).
   - **Database Trigger `trg_decrement_equipment_stock`:** Automatically decrements stock on checkout.
   - **Database Trigger `trg_increment_equipment_stock`:** Automatically restores stock on return and flags damaged gear for maintenance.
   - Overdue loan tracking with fine calculation.

7. **Analytical Reports & Stored Views:**
   - `v_active_memberships`: Real-time subscription status and days to renewal.
   - `v_tournament_standings`: Dynamic league standings table.
   - `v_facility_utilization`: Hours booked and revenue generated per facility.
   - `v_player_performance`: Match counts, wins, and win percentages.
   - `v_fee_dues`: Defaulters and overdue payment aging.
   - `v_equipment_status`: Current stock levels and overdue loans.

8. **Interactive SQL Console & Evaluator:**
   - Web console to test custom SELECT queries or run pre-set complex queries (multi-table joins, aggregations with `HAVING`, correlated subqueries, window functions).

---

## 📁 Project Directory Structure

```
sports_club_dbms/
├── database/
│   ├── schema.sql                 # SQLite DDL with CHECK constraints, triggers, and views
│   ├── schema_oracle_mysql.sql    # Standard ANSI / Oracle 21c / MySQL 8.0 DDL script
│   ├── seed_data.sql              # Realistic seed data populating all 18 tables
│   ├── queries_reports.sql        # Advanced SQL statements (joins, subqueries, CTEs, reports)
│   ├── db_manager.py              # SQLite connection manager & transactional helper
│   └── sports_club.db             # Generated SQLite database file
├── app/
│   ├── app.py                     # Main Flask application and routing controller
│   ├── services/                  # Business logic & transaction service layer
│   │   ├── member_service.py
│   │   ├── facility_service.py
│   │   ├── team_service.py
│   │   ├── training_service.py
│   │   ├── tournament_service.py
│   │   ├── equipment_service.py
│   │   └── reports_service.py
│   ├── templates/                 # Responsive Bootstrap 5 HTML templates
│   │   ├── base.html
│   │   ├── index.html             # Dashboard with KPI cards & recent activities
│   │   ├── members.html           # Member directory & modals
│   │   ├── teams.html             # Teams, coaches & rosters
│   │   ├── facilities.html        # Facilities & booking conflict checker
│   │   ├── training.html          # Training sessions & capacity manager
│   │   ├── tournaments.html       # Tournaments, fixtures & score recorder
│   │   ├── equipment.html         # Equipment inventory & loan tracker
│   │   ├── reports.html           # Analytical reports tabbed dashboard
│   │   └── sql_console.html       # Interactive SQL query evaluator
│   └── static/
│       ├── css/custom.css         # Custom UI stylesheet
│       └── js/app.js              # Client-side helper scripts
├── tests/
│   ├── test_dbms.py               # Unit & trigger integrity test suite
│   └── test_app_routes.py         # Route and integration test suite
├── docs/
│   └── PROJECT_REPORT.md          # Comprehensive academic project report with ER diagram & 3NF proof
├── run.py                         # One-click application launcher
└── README.md                      # Project documentation and guide
```

---

## 🚀 Quick Start Guide

### 1. Requirements
- Python 3.10+ (Tested on Python 3.13)
- Flask (`py -m pip install Flask` if not already installed)

### 2. Run the Web Application
Open PowerShell or your terminal in the project directory:
```powershell
py run.py
```
Open your browser and navigate to:
```
http://127.0.0.1:5000
```

### 3. Run Systematic Tests
Execute the database integrity test suite (validates triggers, constraints, capacity limits, and overlap prevention):
```powershell
py tests\test_dbms.py
```
Execute the web route integration test suite:
```powershell
py tests\test_app_routes.py
```

---

## 🗄️ Relational Schema (18 Tables)

| # | Table Name | Description | Key Constraints |
| :--- | :--- | :--- | :--- |
| 1 | `sports` | Indoor and outdoor sport types | `sport_id` (PK), `sport_name` (UQ) |
| 2 | `membership_plans` | Pricing and duration tiers | `plan_id` (PK), `plan_name` (UQ) |
| 3 | `members` | Member personal records & status | `member_id` (PK), `email` (UQ), `phone` (UQ) |
| 4 | `member_subscriptions` | Active & historical subscriptions | `subscription_id` (PK), FKs to member, plan |
| 5 | `payments` | Monetary transactions & invoices | `payment_id` (PK), `transaction_ref` (UQ) |
| 6 | `coaches` | Certified trainers & hourly rates | `coach_id` (PK), `email` (UQ), FK to sport |
| 7 | `teams` | Club teams by sport | `team_id` (PK), `team_name` (UQ), FKs |
| 8 | `team_roster` | Team player assignments | `roster_id` (PK), UQ(team, member), UQ(team, jersey) |
| 9 | `facilities` | Courts, pitches, and venues | `facility_id` (PK), `facility_name` (UQ) |
| 10 | `facility_bookings` | Court reservations & fees | `booking_id` (PK), Overlap Trigger Checked |
| 11 | `training_sessions` | Coaching clinics & drills | `session_id` (PK), Coach Overlap Trigger Checked |
| 12 | `training_enrollments` | Member drill attendances | `enrollment_id` (PK), Capacity Trigger Checked |
| 13 | `tournaments` | Competitions and prize pools | `tournament_id` (PK), format checks |
| 14 | `tournament_participants` | Enrolled players/teams & seeds | `participant_id` (PK), FKs to tournament |
| 15 | `fixtures` | Match schedules & rounds | `fixture_id` (PK), FKs to participants |
| 16 | `match_results` | Match scores & winner records | `result_id` (PK), `fixture_id` (UQ), score checks |
| 17 | `equipment` | Sports gear inventory | `equipment_id` (PK), quantity checks |
| 18 | `equipment_loans` | Member equipment checkouts | `loan_id` (PK), Auto Stock Update Triggers |

---

## 💡 SQL DDL for Oracle Database 21c / MySQL
For submissions requiring Oracle Database 21c, MySQL, or PostgreSQL, refer to [`database/schema_oracle_mysql.sql`](database/schema_oracle_mysql.sql). It is formatted with standard `AUTO_INCREMENT`/`NUMBER`, `DECIMAL`, and constraint syntax.
"# DBMS-ASS" 
