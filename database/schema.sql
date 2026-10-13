-- ============================================================================
-- SPORTS CLUB MEMBERSHIP AND TOURNAMENT MANAGEMENT SYSTEM
-- Relational Database Schema (SQLite 3 compatible with full constraints & triggers)
-- Conforms to Third Normal Form (3NF) / Boyce-Codd Normal Form (BCNF)
-- ============================================================================

PRAGMA foreign_keys = ON;

-- ----------------------------------------------------------------------------
-- 1. SPORTS
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sports (
    sport_id INTEGER PRIMARY KEY AUTOINCREMENT,
    sport_name TEXT NOT NULL UNIQUE COLLATE NOCASE,
    category TEXT NOT NULL CHECK (category IN ('INDOOR', 'OUTDOOR')),
    max_team_size INTEGER NOT NULL CHECK (max_team_size >= 1),
    description TEXT
);

-- ----------------------------------------------------------------------------
-- 2. MEMBERSHIP PLANS
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS membership_plans (
    plan_id INTEGER PRIMARY KEY AUTOINCREMENT,
    plan_name TEXT NOT NULL UNIQUE COLLATE NOCASE,
    duration_months INTEGER NOT NULL CHECK (duration_months > 0),
    fee_amount REAL NOT NULL CHECK (fee_amount >= 0.0),
    description TEXT,
    is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1))
);

-- ----------------------------------------------------------------------------
-- 3. MEMBERS
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS members (
    member_id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE COLLATE NOCASE,
    phone TEXT NOT NULL UNIQUE,
    dob DATE NOT NULL,
    gender TEXT NOT NULL CHECK (gender IN ('MALE', 'FEMALE', 'OTHER')),
    address TEXT,
    emergency_contact TEXT,
    joined_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    status TEXT NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'EXPIRED', 'SUSPENDED'))
);

-- ----------------------------------------------------------------------------
-- 4. MEMBER SUBSCRIPTIONS
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS member_subscriptions (
    subscription_id INTEGER PRIMARY KEY AUTOINCREMENT,
    member_id INTEGER NOT NULL,
    plan_id INTEGER NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status TEXT NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'EXPIRED', 'CANCELLED')),
    payment_status TEXT NOT NULL DEFAULT 'PENDING' CHECK (payment_status IN ('PAID', 'PENDING', 'OVERDUE')),
    CHECK (end_date >= start_date),
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE,
    FOREIGN KEY (plan_id) REFERENCES membership_plans(plan_id) ON DELETE RESTRICT
);

-- ----------------------------------------------------------------------------
-- 5. PAYMENTS
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS payments (
    payment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    member_id INTEGER NOT NULL,
    subscription_id INTEGER,
    amount REAL NOT NULL CHECK (amount > 0.0),
    payment_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_method TEXT NOT NULL CHECK (payment_method IN ('CASH', 'CREDIT_CARD', 'DEBIT_CARD', 'UPI', 'BANK_TRANSFER')),
    transaction_ref TEXT NOT NULL UNIQUE,
    status TEXT NOT NULL DEFAULT 'COMPLETED' CHECK (status IN ('COMPLETED', 'PENDING', 'REFUNDED')),
    notes TEXT,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE,
    FOREIGN KEY (subscription_id) REFERENCES member_subscriptions(subscription_id) ON DELETE SET NULL
);

-- ----------------------------------------------------------------------------
-- 6. COACHES
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS coaches (
    coach_id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE COLLATE NOCASE,
    phone TEXT NOT NULL UNIQUE,
    specialization_sport_id INTEGER NOT NULL,
    qualification TEXT,
    hourly_rate REAL NOT NULL DEFAULT 0.0 CHECK (hourly_rate >= 0.0),
    hire_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    status TEXT NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'INACTIVE')),
    FOREIGN KEY (specialization_sport_id) REFERENCES sports(sport_id) ON DELETE RESTRICT
);

-- ----------------------------------------------------------------------------
-- 7. TEAMS
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS teams (
    team_id INTEGER PRIMARY KEY AUTOINCREMENT,
    team_name TEXT NOT NULL UNIQUE COLLATE NOCASE,
    sport_id INTEGER NOT NULL,
    coach_id INTEGER,
    captain_id INTEGER,
    created_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    FOREIGN KEY (sport_id) REFERENCES sports(sport_id) ON DELETE RESTRICT,
    FOREIGN KEY (coach_id) REFERENCES coaches(coach_id) ON DELETE SET NULL,
    FOREIGN KEY (captain_id) REFERENCES members(member_id) ON DELETE SET NULL
);

-- ----------------------------------------------------------------------------
-- 8. TEAM ROSTER
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS team_roster (
    roster_id INTEGER PRIMARY KEY AUTOINCREMENT,
    team_id INTEGER NOT NULL,
    member_id INTEGER NOT NULL,
    jersey_number INTEGER CHECK (jersey_number BETWEEN 1 AND 99),
    position TEXT,
    joined_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
    UNIQUE (team_id, member_id),
    UNIQUE (team_id, jersey_number),
    FOREIGN KEY (team_id) REFERENCES teams(team_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE
);

-- ----------------------------------------------------------------------------
-- 9. FACILITIES
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS facilities (
    facility_id INTEGER PRIMARY KEY AUTOINCREMENT,
    facility_name TEXT NOT NULL UNIQUE COLLATE NOCASE,
    sport_id INTEGER NOT NULL,
    facility_type TEXT NOT NULL CHECK (facility_type IN ('COURT', 'TURF', 'ARENA', 'POOL', 'GYM', 'TRACK')),
    capacity INTEGER NOT NULL CHECK (capacity > 0),
    hourly_rate REAL NOT NULL DEFAULT 0.0 CHECK (hourly_rate >= 0.0),
    is_operational INTEGER NOT NULL DEFAULT 1 CHECK (is_operational IN (0, 1)),
    FOREIGN KEY (sport_id) REFERENCES sports(sport_id) ON DELETE RESTRICT
);

-- ----------------------------------------------------------------------------
-- 10. FACILITY BOOKINGS
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS facility_bookings (
    booking_id INTEGER PRIMARY KEY AUTOINCREMENT,
    facility_id INTEGER NOT NULL,
    member_id INTEGER,
    team_id INTEGER,
    booking_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    booking_purpose TEXT NOT NULL DEFAULT 'CASUAL_PLAY' CHECK (booking_purpose IN ('CASUAL_PLAY', 'TRAINING', 'TOURNAMENT_MATCH', 'MAINTENANCE')),
    attendees_count INTEGER NOT NULL DEFAULT 1 CHECK (attendees_count > 0),
    total_fee REAL NOT NULL DEFAULT 0.0 CHECK (total_fee >= 0.0),
    status TEXT NOT NULL DEFAULT 'CONFIRMED' CHECK (status IN ('CONFIRMED', 'CANCELLED', 'COMPLETED')),
    CHECK (end_time > start_time),
    CHECK (member_id IS NOT NULL OR team_id IS NOT NULL),
    FOREIGN KEY (facility_id) REFERENCES facilities(facility_id) ON DELETE RESTRICT,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE SET NULL,
    FOREIGN KEY (team_id) REFERENCES teams(team_id) ON DELETE SET NULL
);

-- ----------------------------------------------------------------------------
-- 11. TRAINING SESSIONS
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS training_sessions (
    session_id INTEGER PRIMARY KEY AUTOINCREMENT,
    sport_id INTEGER NOT NULL,
    coach_id INTEGER NOT NULL,
    facility_id INTEGER NOT NULL,
    session_title TEXT NOT NULL,
    session_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    max_participants INTEGER NOT NULL CHECK (max_participants > 0),
    status TEXT NOT NULL DEFAULT 'SCHEDULED' CHECK (status IN ('SCHEDULED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED')),
    CHECK (end_time > start_time),
    FOREIGN KEY (sport_id) REFERENCES sports(sport_id) ON DELETE RESTRICT,
    FOREIGN KEY (coach_id) REFERENCES coaches(coach_id) ON DELETE RESTRICT,
    FOREIGN KEY (facility_id) REFERENCES facilities(facility_id) ON DELETE RESTRICT
);

-- ----------------------------------------------------------------------------
-- 12. TRAINING ENROLLMENTS
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS training_enrollments (
    enrollment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id INTEGER NOT NULL,
    member_id INTEGER NOT NULL,
    enrolled_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    attendance_status TEXT NOT NULL DEFAULT 'REGISTERED' CHECK (attendance_status IN ('REGISTERED', 'ATTENDED', 'ABSENT')),
    UNIQUE (session_id, member_id),
    FOREIGN KEY (session_id) REFERENCES training_sessions(session_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE
);

-- ----------------------------------------------------------------------------
-- 13. TOURNAMENTS
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tournaments (
    tournament_id INTEGER PRIMARY KEY AUTOINCREMENT,
    tournament_name TEXT NOT NULL,
    sport_id INTEGER NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    format TEXT NOT NULL DEFAULT 'ROUND_ROBIN' CHECK (format IN ('KNOCKOUT', 'ROUND_ROBIN', 'LEAGUE')),
    entry_fee REAL NOT NULL DEFAULT 0.0 CHECK (entry_fee >= 0.0),
    prize_pool REAL NOT NULL DEFAULT 0.0 CHECK (prize_pool >= 0.0),
    status TEXT NOT NULL DEFAULT 'UPCOMING' CHECK (status IN ('UPCOMING', 'ONGOING', 'COMPLETED', 'CANCELLED')),
    CHECK (end_date >= start_date),
    FOREIGN KEY (sport_id) REFERENCES sports(sport_id) ON DELETE RESTRICT
);

-- ----------------------------------------------------------------------------
-- 14. TOURNAMENT PARTICIPANTS
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tournament_participants (
    participant_id INTEGER PRIMARY KEY AUTOINCREMENT,
    tournament_id INTEGER NOT NULL,
    team_id INTEGER,
    member_id INTEGER,
    display_name TEXT NOT NULL,
    registration_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    seed_number INTEGER CHECK (seed_number > 0),
    payment_status TEXT NOT NULL DEFAULT 'PAID' CHECK (payment_status IN ('PAID', 'PENDING')),
    status TEXT NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('REGISTERED', 'ACTIVE', 'ELIMINATED', 'WINNER', 'RUNNER_UP')),
    CHECK (team_id IS NOT NULL OR member_id IS NOT NULL),
    UNIQUE (tournament_id, team_id),
    UNIQUE (tournament_id, member_id),
    FOREIGN KEY (tournament_id) REFERENCES tournaments(tournament_id) ON DELETE CASCADE,
    FOREIGN KEY (team_id) REFERENCES teams(team_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE
);

-- ----------------------------------------------------------------------------
-- 15. FIXTURES
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS fixtures (
    fixture_id INTEGER PRIMARY KEY AUTOINCREMENT,
    tournament_id INTEGER NOT NULL,
    stage TEXT NOT NULL CHECK (stage IN ('ROUND_OF_16', 'QUARTER_FINAL', 'SEMI_FINAL', 'FINAL', 'GROUP_STAGE', 'LEAGUE')),
    participant1_id INTEGER NOT NULL,
    participant2_id INTEGER NOT NULL,
    facility_id INTEGER NOT NULL,
    fixture_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    status TEXT NOT NULL DEFAULT 'SCHEDULED' CHECK (status IN ('SCHEDULED', 'IN_PROGRESS', 'COMPLETED', 'POSTPONED', 'CANCELLED')),
    CHECK (participant1_id <> participant2_id),
    CHECK (end_time > start_time),
    FOREIGN KEY (tournament_id) REFERENCES tournaments(tournament_id) ON DELETE CASCADE,
    FOREIGN KEY (participant1_id) REFERENCES tournament_participants(participant_id) ON DELETE RESTRICT,
    FOREIGN KEY (participant2_id) REFERENCES tournament_participants(participant_id) ON DELETE RESTRICT,
    FOREIGN KEY (facility_id) REFERENCES facilities(facility_id) ON DELETE RESTRICT
);

-- ----------------------------------------------------------------------------
-- 16. MATCH RESULTS
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS match_results (
    result_id INTEGER PRIMARY KEY AUTOINCREMENT,
    fixture_id INTEGER NOT NULL UNIQUE,
    winner_participant_id INTEGER,
    score_participant1 INTEGER NOT NULL CHECK (score_participant1 >= 0),
    score_participant2 INTEGER NOT NULL CHECK (score_participant2 >= 0),
    set_scores_details TEXT,
    match_notes TEXT,
    recorded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (fixture_id) REFERENCES fixtures(fixture_id) ON DELETE CASCADE,
    FOREIGN KEY (winner_participant_id) REFERENCES tournament_participants(participant_id) ON DELETE SET NULL
);

-- ----------------------------------------------------------------------------
-- 17. EQUIPMENT
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS equipment (
    equipment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    sport_id INTEGER NOT NULL,
    equipment_name TEXT NOT NULL COLLATE NOCASE,
    brand TEXT,
    model_code TEXT,
    total_quantity INTEGER NOT NULL CHECK (total_quantity >= 0),
    available_quantity INTEGER NOT NULL CHECK (available_quantity >= 0),
    condition_status TEXT NOT NULL DEFAULT 'GOOD' CHECK (condition_status IN ('GOOD', 'FAIR', 'MAINTENANCE_REQUIRED')),
    CHECK (available_quantity <= total_quantity),
    FOREIGN KEY (sport_id) REFERENCES sports(sport_id) ON DELETE RESTRICT
);

-- ----------------------------------------------------------------------------
-- 18. EQUIPMENT LOANS
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS equipment_loans (
    loan_id INTEGER PRIMARY KEY AUTOINCREMENT,
    equipment_id INTEGER NOT NULL,
    member_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
    issue_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    due_date DATE NOT NULL,
    return_date DATE,
    status TEXT NOT NULL DEFAULT 'ISSUED' CHECK (status IN ('ISSUED', 'RETURNED', 'OVERDUE', 'DAMAGED_RETURNED')),
    condition_on_issue TEXT NOT NULL DEFAULT 'GOOD' CHECK (condition_on_issue IN ('GOOD', 'FAIR')),
    condition_on_return TEXT CHECK (condition_on_return IN ('GOOD', 'FAIR', 'DAMAGED', 'LOST')),
    fine_amount REAL NOT NULL DEFAULT 0.0 CHECK (fine_amount >= 0.0),
    CHECK (due_date >= issue_date),
    FOREIGN KEY (equipment_id) REFERENCES equipment(equipment_id) ON DELETE RESTRICT,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE RESTRICT
);

-- ============================================================================
-- INDEXES FOR FREQUENTLY SEARCHED / JOINED COLUMNS
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_members_name ON members(last_name, first_name);
CREATE INDEX IF NOT EXISTS idx_members_status ON members(status);
CREATE INDEX IF NOT EXISTS idx_member_subscriptions_member ON member_subscriptions(member_id, status);
CREATE INDEX IF NOT EXISTS idx_payments_member ON payments(member_id, payment_date);
CREATE INDEX IF NOT EXISTS idx_facility_bookings_lookup ON facility_bookings(facility_id, booking_date, status);
CREATE INDEX IF NOT EXISTS idx_training_sessions_lookup ON training_sessions(facility_id, coach_id, session_date);
CREATE INDEX IF NOT EXISTS idx_fixtures_tournament ON fixtures(tournament_id, fixture_date, status);
CREATE INDEX IF NOT EXISTS idx_match_results_fixture ON match_results(fixture_id);
CREATE INDEX IF NOT EXISTS idx_equipment_sport ON equipment(sport_id);
CREATE INDEX IF NOT EXISTS idx_equipment_loans_status ON equipment_loans(member_id, status);

-- ============================================================================
-- BUSINESS RULE TRIGGERS
-- ============================================================================

-- Business Rule 1A: Prevent Overlapping Facility Bookings
CREATE TRIGGER IF NOT EXISTS trg_prevent_facility_booking_overlap_insert
BEFORE INSERT ON facility_bookings
FOR EACH ROW
WHEN NEW.status = 'CONFIRMED'
BEGIN
    SELECT CASE
        WHEN EXISTS (
            SELECT 1 FROM facility_bookings
            WHERE facility_id = NEW.facility_id
              AND booking_date = NEW.booking_date
              AND status = 'CONFIRMED'
              AND (
                  (NEW.start_time < end_time AND NEW.end_time > start_time)
              )
        )
        THEN RAISE(ABORT, 'Integrity Error: The selected facility is already booked during this time slot.')
    END;
END;

CREATE TRIGGER IF NOT EXISTS trg_prevent_facility_booking_overlap_update
BEFORE UPDATE OF facility_id, booking_date, start_time, end_time, status ON facility_bookings
FOR EACH ROW
WHEN NEW.status = 'CONFIRMED'
BEGIN
    SELECT CASE
        WHEN EXISTS (
            SELECT 1 FROM facility_bookings
            WHERE facility_id = NEW.facility_id
              AND booking_date = NEW.booking_date
              AND booking_id <> NEW.booking_id
              AND status = 'CONFIRMED'
              AND (
                  (NEW.start_time < end_time AND NEW.end_time > start_time)
              )
        )
        THEN RAISE(ABORT, 'Integrity Error: The selected facility is already booked during this time slot.')
    END;
END;

-- Business Rule 1B: Prevent Overlapping Coach Training Sessions
CREATE TRIGGER IF NOT EXISTS trg_prevent_coach_schedule_overlap
BEFORE INSERT ON training_sessions
FOR EACH ROW
WHEN NEW.status <> 'CANCELLED'
BEGIN
    SELECT CASE
        WHEN EXISTS (
            SELECT 1 FROM training_sessions
            WHERE coach_id = NEW.coach_id
              AND session_date = NEW.session_date
              AND status <> 'CANCELLED'
              AND (NEW.start_time < end_time AND NEW.end_time > start_time)
        )
        THEN RAISE(ABORT, 'Integrity Error: Coach has another overlapping training session at this time.')
    END;
END;

-- Business Rule 2: Active Membership Required for Individual Facility Booking
CREATE TRIGGER IF NOT EXISTS trg_require_active_member_for_booking
BEFORE INSERT ON facility_bookings
FOR EACH ROW
WHEN NEW.member_id IS NOT NULL
BEGIN
    SELECT CASE
        WHEN (
            SELECT status FROM members WHERE member_id = NEW.member_id
        ) <> 'ACTIVE'
        THEN RAISE(ABORT, 'Integrity Error: Only members with ACTIVE status can book club facilities.')
    END;
END;

-- Business Rule 3: Training Session Capacity Limit Enforcement
CREATE TRIGGER IF NOT EXISTS trg_check_training_capacity
BEFORE INSERT ON training_enrollments
FOR EACH ROW
BEGIN
    SELECT CASE
        WHEN (
            SELECT COUNT(*) FROM training_enrollments WHERE session_id = NEW.session_id
        ) >= (
            SELECT max_participants FROM training_sessions WHERE session_id = NEW.session_id
        )
        THEN RAISE(ABORT, 'Integrity Error: Training session capacity is fully booked.')
    END;
END;

-- Business Rule 4: Equipment Inventory Stock Check on Loan
CREATE TRIGGER IF NOT EXISTS trg_check_equipment_stock_before_loan
BEFORE INSERT ON equipment_loans
FOR EACH ROW
BEGIN
    SELECT CASE
        WHEN NEW.quantity > (
            SELECT available_quantity FROM equipment WHERE equipment_id = NEW.equipment_id
        )
        THEN RAISE(ABORT, 'Integrity Error: Insufficient available inventory for the requested equipment.')
    END;
END;

-- Business Rule 5: Auto-Decrement Equipment Stock on Loan
CREATE TRIGGER IF NOT EXISTS trg_decrement_equipment_stock
AFTER INSERT ON equipment_loans
FOR EACH ROW
BEGIN
    UPDATE equipment
    SET available_quantity = available_quantity - NEW.quantity
    WHERE equipment_id = NEW.equipment_id;
END;

-- Business Rule 6: Auto-Increment Equipment Stock on Return
CREATE TRIGGER IF NOT EXISTS trg_increment_equipment_stock
AFTER UPDATE OF status ON equipment_loans
FOR EACH ROW
WHEN NEW.status IN ('RETURNED', 'DAMAGED_RETURNED') AND OLD.status NOT IN ('RETURNED', 'DAMAGED_RETURNED')
BEGIN
    UPDATE equipment
    SET available_quantity = available_quantity + NEW.quantity,
        condition_status = CASE 
            WHEN NEW.status = 'DAMAGED_RETURNED' THEN 'MAINTENANCE_REQUIRED'
            ELSE condition_status 
        END
    WHERE equipment_id = NEW.equipment_id;
END;

-- Business Rule 7: Auto-Update Fixture Status to COMPLETED on Match Result Entry
CREATE TRIGGER IF NOT EXISTS trg_update_fixture_status_on_result
AFTER INSERT ON match_results
FOR EACH ROW
BEGIN
    UPDATE fixtures
    SET status = 'COMPLETED'
    WHERE fixture_id = NEW.fixture_id;
END;

-- ============================================================================
-- ANALYTICAL STORED VIEWS
-- ============================================================================

-- View 1: Active Memberships with Subscription details & Expiry Tracking
CREATE VIEW IF NOT EXISTS v_active_memberships AS
SELECT 
    m.member_id,
    m.first_name || ' ' || m.last_name AS full_name,
    m.email,
    m.phone,
    m.status AS member_status,
    p.plan_name,
    s.subscription_id,
    s.start_date,
    s.end_date,
    s.status AS subscription_status,
    s.payment_status,
    CAST((julianday(s.end_date) - julianday(CURRENT_DATE)) AS INTEGER) AS days_remaining
FROM members m
JOIN member_subscriptions s ON m.member_id = s.member_id
JOIN membership_plans p ON s.plan_id = p.plan_id
WHERE s.status = 'ACTIVE';

-- View 2: Tournament Standings (League / Group Stage Table)
CREATE VIEW IF NOT EXISTS v_tournament_standings AS
SELECT 
    t.tournament_id,
    t.tournament_name,
    tp.participant_id,
    tp.display_name,
    COUNT(f.fixture_id) AS matches_played,
    SUM(CASE WHEN mr.winner_participant_id = tp.participant_id THEN 1 ELSE 0 END) AS won,
    SUM(CASE WHEN mr.result_id IS NOT NULL AND mr.winner_participant_id IS NULL THEN 1 ELSE 0 END) AS drawn,
    SUM(CASE WHEN mr.result_id IS NOT NULL AND mr.winner_participant_id <> tp.participant_id AND mr.winner_participant_id IS NOT NULL THEN 1 ELSE 0 END) AS lost,
    SUM(CASE 
        WHEN tp.participant_id = f.participant1_id THEN mr.score_participant1
        WHEN tp.participant_id = f.participant2_id THEN mr.score_participant2
        ELSE 0 
    END) AS score_for,
    SUM(CASE 
        WHEN tp.participant_id = f.participant1_id THEN mr.score_participant2
        WHEN tp.participant_id = f.participant2_id THEN mr.score_participant1
        ELSE 0 
    END) AS score_against,
    (SUM(CASE 
        WHEN tp.participant_id = f.participant1_id THEN mr.score_participant1
        WHEN tp.participant_id = f.participant2_id THEN mr.score_participant2
        ELSE 0 
    END) - 
    SUM(CASE 
        WHEN tp.participant_id = f.participant1_id THEN mr.score_participant2
        WHEN tp.participant_id = f.participant2_id THEN mr.score_participant1
        ELSE 0 
    END)) AS score_diff,
    (SUM(CASE WHEN mr.winner_participant_id = tp.participant_id THEN 3 ELSE 0 END) +
     SUM(CASE WHEN mr.result_id IS NOT NULL AND mr.winner_participant_id IS NULL THEN 1 ELSE 0 END)) AS total_points
FROM tournaments t
JOIN tournament_participants tp ON t.tournament_id = tp.tournament_id
LEFT JOIN fixtures f ON t.tournament_id = f.tournament_id 
    AND (tp.participant_id = f.participant1_id OR tp.participant_id = f.participant2_id)
    AND f.status = 'COMPLETED'
LEFT JOIN match_results mr ON f.fixture_id = mr.fixture_id
GROUP BY t.tournament_id, tp.participant_id
ORDER BY t.tournament_id, total_points DESC, score_diff DESC;

-- View 3: Facility Utilization & Revenue Analysis
CREATE VIEW IF NOT EXISTS v_facility_utilization AS
SELECT 
    f.facility_id,
    f.facility_name,
    s.sport_name,
    f.facility_type,
    f.capacity,
    f.hourly_rate,
    COUNT(fb.booking_id) AS total_confirmed_bookings,
    COALESCE(SUM(fb.total_fee), 0.0) AS total_revenue_generated,
    COALESCE(SUM((strftime('%H', fb.end_time) - strftime('%H', fb.start_time))), 0) AS total_hours_booked
FROM facilities f
JOIN sports s ON f.sport_id = s.sport_id
LEFT JOIN facility_bookings fb ON f.facility_id = fb.facility_id AND fb.status = 'CONFIRMED'
GROUP BY f.facility_id;

-- View 4: Player / Team Performance Summary
CREATE VIEW IF NOT EXISTS v_player_performance AS
SELECT 
    tp.participant_id,
    tp.display_name,
    t.tournament_name,
    s.sport_name,
    COUNT(f.fixture_id) AS matches_played,
    SUM(CASE WHEN mr.winner_participant_id = tp.participant_id THEN 1 ELSE 0 END) AS wins,
    ROUND(
        (CAST(SUM(CASE WHEN mr.winner_participant_id = tp.participant_id THEN 1 ELSE 0 END) AS REAL) / 
         NULLIF(COUNT(f.fixture_id), 0)) * 100.0, 
        2
    ) AS win_percentage
FROM tournament_participants tp
JOIN tournaments t ON tp.tournament_id = t.tournament_id
JOIN sports s ON t.sport_id = s.sport_id
LEFT JOIN fixtures f ON (tp.participant_id = f.participant1_id OR tp.participant_id = f.participant2_id) AND f.status = 'COMPLETED'
LEFT JOIN match_results mr ON f.fixture_id = mr.fixture_id
GROUP BY tp.participant_id;

-- View 5: Outstanding Fee Dues and Subscriptions
CREATE VIEW IF NOT EXISTS v_fee_dues AS
SELECT 
    m.member_id,
    m.first_name || ' ' || m.last_name AS member_name,
    m.email,
    m.phone,
    p.plan_name,
    s.subscription_id,
    p.fee_amount AS amount_due,
    s.start_date,
    s.end_date,
    s.payment_status,
    CAST((julianday(CURRENT_DATE) - julianday(s.start_date)) AS INTEGER) AS days_since_start
FROM members m
JOIN member_subscriptions s ON m.member_id = s.member_id
JOIN membership_plans p ON s.plan_id = p.plan_id
WHERE s.payment_status IN ('PENDING', 'OVERDUE');

-- View 6: Equipment Inventory & Loan Status
CREATE VIEW IF NOT EXISTS v_equipment_status AS
SELECT 
    e.equipment_id,
    e.equipment_name,
    s.sport_name,
    e.brand,
    e.total_quantity,
    e.available_quantity,
    (e.total_quantity - e.available_quantity) AS currently_issued_quantity,
    e.condition_status,
    COUNT(CASE WHEN el.status = 'ISSUED' AND el.due_date < CURRENT_DATE THEN 1 END) AS overdue_loans_count
FROM equipment e
JOIN sports s ON e.sport_id = s.sport_id
LEFT JOIN equipment_loans el ON e.equipment_id = el.equipment_id
GROUP BY e.equipment_id;
