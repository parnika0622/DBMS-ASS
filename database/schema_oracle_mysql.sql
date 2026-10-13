-- ============================================================================
-- SPORTS CLUB MEMBERSHIP AND TOURNAMENT MANAGEMENT SYSTEM
-- Relational DDL Script for Oracle Database 21c / MySQL 8.0 / PostgreSQL
-- Normalized to 3NF / BCNF with full integrity constraints
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. SPORTS TABLE
-- ----------------------------------------------------------------------------
CREATE TABLE sports (
    sport_id INT AUTO_INCREMENT PRIMARY KEY,
    sport_name VARCHAR(60) NOT NULL UNIQUE,
    category VARCHAR(20) NOT NULL CHECK (category IN ('INDOOR', 'OUTDOOR')),
    max_team_size INT NOT NULL CHECK (max_team_size >= 1),
    description VARCHAR(255)
);

-- ----------------------------------------------------------------------------
-- 2. MEMBERSHIP PLANS TABLE
-- ----------------------------------------------------------------------------
CREATE TABLE membership_plans (
    plan_id INT AUTO_INCREMENT PRIMARY KEY,
    plan_name VARCHAR(60) NOT NULL UNIQUE,
    duration_months INT NOT NULL CHECK (duration_months > 0),
    fee_amount DECIMAL(10, 2) NOT NULL CHECK (fee_amount >= 0.0),
    description VARCHAR(255),
    is_active SMALLINT DEFAULT 1 CHECK (is_active IN (0, 1))
);

-- ----------------------------------------------------------------------------
-- 3. MEMBERS TABLE
-- ----------------------------------------------------------------------------
CREATE TABLE members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL UNIQUE,
    dob DATE NOT NULL,
    gender VARCHAR(10) NOT NULL CHECK (gender IN ('MALE', 'FEMALE', 'OTHER')),
    address VARCHAR(200),
    emergency_contact VARCHAR(20),
    joined_date DATE DEFAULT (CURRENT_DATE),
    status VARCHAR(20) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'EXPIRED', 'SUSPENDED'))
);

-- ----------------------------------------------------------------------------
-- 4. MEMBER SUBSCRIPTIONS TABLE
-- ----------------------------------------------------------------------------
CREATE TABLE member_subscriptions (
    subscription_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    plan_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'EXPIRED', 'CANCELLED')),
    payment_status VARCHAR(20) DEFAULT 'PENDING' CHECK (payment_status IN ('PAID', 'PENDING', 'OVERDUE')),
    CONSTRAINT chk_sub_dates CHECK (end_date >= start_date),
    CONSTRAINT fk_sub_member FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE,
    CONSTRAINT fk_sub_plan FOREIGN KEY (plan_id) REFERENCES membership_plans(plan_id) ON DELETE RESTRICT
);

-- ----------------------------------------------------------------------------
-- 5. PAYMENTS TABLE
-- ----------------------------------------------------------------------------
CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    subscription_id INT,
    amount DECIMAL(10, 2) NOT NULL CHECK (amount > 0.0),
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_method VARCHAR(30) NOT NULL CHECK (payment_method IN ('CASH', 'CREDIT_CARD', 'DEBIT_CARD', 'UPI', 'BANK_TRANSFER')),
    transaction_ref VARCHAR(80) NOT NULL UNIQUE,
    status VARCHAR(20) DEFAULT 'COMPLETED' CHECK (status IN ('COMPLETED', 'PENDING', 'REFUNDED')),
    notes VARCHAR(255),
    CONSTRAINT fk_pay_member FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE,
    CONSTRAINT fk_pay_sub FOREIGN KEY (subscription_id) REFERENCES member_subscriptions(subscription_id) ON DELETE SET NULL
);

-- ----------------------------------------------------------------------------
-- 6. COACHES TABLE
-- ----------------------------------------------------------------------------
CREATE TABLE coaches (
    coach_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL UNIQUE,
    specialization_sport_id INT NOT NULL,
    qualification VARCHAR(100),
    hourly_rate DECIMAL(10, 2) DEFAULT 0.0 CHECK (hourly_rate >= 0.0),
    hire_date DATE DEFAULT (CURRENT_DATE),
    status VARCHAR(20) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'INACTIVE')),
    CONSTRAINT fk_coach_sport FOREIGN KEY (specialization_sport_id) REFERENCES sports(sport_id) ON DELETE RESTRICT
);

-- ----------------------------------------------------------------------------
-- 7. TEAMS TABLE
-- ----------------------------------------------------------------------------
CREATE TABLE teams (
    team_id INT AUTO_INCREMENT PRIMARY KEY,
    team_name VARCHAR(80) NOT NULL UNIQUE,
    sport_id INT NOT NULL,
    coach_id INT,
    captain_id INT,
    created_date DATE DEFAULT (CURRENT_DATE),
    CONSTRAINT fk_team_sport FOREIGN KEY (sport_id) REFERENCES sports(sport_id) ON DELETE RESTRICT,
    CONSTRAINT fk_team_coach FOREIGN KEY (coach_id) REFERENCES coaches(coach_id) ON DELETE SET NULL,
    CONSTRAINT fk_team_captain FOREIGN KEY (captain_id) REFERENCES members(member_id) ON DELETE SET NULL
);

-- ----------------------------------------------------------------------------
-- 8. TEAM ROSTER TABLE
-- ----------------------------------------------------------------------------
CREATE TABLE team_roster (
    roster_id INT AUTO_INCREMENT PRIMARY KEY,
    team_id INT NOT NULL,
    member_id INT NOT NULL,
    jersey_number INT CHECK (jersey_number BETWEEN 1 AND 99),
    position VARCHAR(40),
    joined_date DATE DEFAULT (CURRENT_DATE),
    is_active SMALLINT DEFAULT 1 CHECK (is_active IN (0, 1)),
    CONSTRAINT uq_team_member UNIQUE (team_id, member_id),
    CONSTRAINT uq_team_jersey UNIQUE (team_id, jersey_number),
    CONSTRAINT fk_roster_team FOREIGN KEY (team_id) REFERENCES teams(team_id) ON DELETE CASCADE,
    CONSTRAINT fk_roster_member FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE
);

-- ----------------------------------------------------------------------------
-- 9. FACILITIES TABLE
-- ----------------------------------------------------------------------------
CREATE TABLE facilities (
    facility_id INT AUTO_INCREMENT PRIMARY KEY,
    facility_name VARCHAR(80) NOT NULL UNIQUE,
    sport_id INT NOT NULL,
    facility_type VARCHAR(30) NOT NULL CHECK (facility_type IN ('COURT', 'TURF', 'ARENA', 'POOL', 'GYM', 'TRACK')),
    capacity INT NOT NULL CHECK (capacity > 0),
    hourly_rate DECIMAL(10, 2) DEFAULT 0.0 CHECK (hourly_rate >= 0.0),
    is_operational SMALLINT DEFAULT 1 CHECK (is_operational IN (0, 1)),
    CONSTRAINT fk_facility_sport FOREIGN KEY (sport_id) REFERENCES sports(sport_id) ON DELETE RESTRICT
);

-- ----------------------------------------------------------------------------
-- 10. FACILITY BOOKINGS TABLE
-- ----------------------------------------------------------------------------
CREATE TABLE facility_bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    facility_id INT NOT NULL,
    member_id INT,
    team_id INT,
    booking_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    booking_purpose VARCHAR(30) DEFAULT 'CASUAL_PLAY' CHECK (booking_purpose IN ('CASUAL_PLAY', 'TRAINING', 'TOURNAMENT_MATCH', 'MAINTENANCE')),
    attendees_count INT DEFAULT 1 CHECK (attendees_count > 0),
    total_fee DECIMAL(10, 2) DEFAULT 0.0 CHECK (total_fee >= 0.0),
    status VARCHAR(20) DEFAULT 'CONFIRMED' CHECK (status IN ('CONFIRMED', 'CANCELLED', 'COMPLETED')),
    CONSTRAINT chk_booking_time CHECK (end_time > start_time),
    CONSTRAINT chk_booking_entity CHECK (member_id IS NOT NULL OR team_id IS NOT NULL),
    CONSTRAINT fk_book_facility FOREIGN KEY (facility_id) REFERENCES facilities(facility_id) ON DELETE RESTRICT,
    CONSTRAINT fk_book_member FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE SET NULL,
    CONSTRAINT fk_book_team FOREIGN KEY (team_id) REFERENCES teams(team_id) ON DELETE SET NULL
);

-- ----------------------------------------------------------------------------
-- 11. TRAINING SESSIONS TABLE
-- ----------------------------------------------------------------------------
CREATE TABLE training_sessions (
    session_id INT AUTO_INCREMENT PRIMARY KEY,
    sport_id INT NOT NULL,
    coach_id INT NOT NULL,
    facility_id INT NOT NULL,
    session_title VARCHAR(100) NOT NULL,
    session_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    max_participants INT NOT NULL CHECK (max_participants > 0),
    status VARCHAR(20) DEFAULT 'SCHEDULED' CHECK (status IN ('SCHEDULED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED')),
    CONSTRAINT chk_session_time CHECK (end_time > start_time),
    CONSTRAINT fk_session_sport FOREIGN KEY (sport_id) REFERENCES sports(sport_id) ON DELETE RESTRICT,
    CONSTRAINT fk_session_coach FOREIGN KEY (coach_id) REFERENCES coaches(coach_id) ON DELETE RESTRICT,
    CONSTRAINT fk_session_facility FOREIGN KEY (facility_id) REFERENCES facilities(facility_id) ON DELETE RESTRICT
);

-- ----------------------------------------------------------------------------
-- 12. TRAINING ENROLLMENTS TABLE
-- ----------------------------------------------------------------------------
CREATE TABLE training_enrollments (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    session_id INT NOT NULL,
    member_id INT NOT NULL,
    enrolled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    attendance_status VARCHAR(20) DEFAULT 'REGISTERED' CHECK (attendance_status IN ('REGISTERED', 'ATTENDED', 'ABSENT')),
    CONSTRAINT uq_session_member UNIQUE (session_id, member_id),
    CONSTRAINT fk_enroll_session FOREIGN KEY (session_id) REFERENCES training_sessions(session_id) ON DELETE CASCADE,
    CONSTRAINT fk_enroll_member FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE
);

-- ----------------------------------------------------------------------------
-- 13. TOURNAMENTS TABLE
-- ----------------------------------------------------------------------------
CREATE TABLE tournaments (
    tournament_id INT AUTO_INCREMENT PRIMARY KEY,
    tournament_name VARCHAR(100) NOT NULL,
    sport_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    format VARCHAR(30) DEFAULT 'ROUND_ROBIN' CHECK (format IN ('KNOCKOUT', 'ROUND_ROBIN', 'LEAGUE')),
    entry_fee DECIMAL(10, 2) DEFAULT 0.0 CHECK (entry_fee >= 0.0),
    prize_pool DECIMAL(10, 2) DEFAULT 0.0 CHECK (prize_pool >= 0.0),
    status VARCHAR(20) DEFAULT 'UPCOMING' CHECK (status IN ('UPCOMING', 'ONGOING', 'COMPLETED', 'CANCELLED')),
    CONSTRAINT chk_tourn_dates CHECK (end_date >= start_date),
    CONSTRAINT fk_tourn_sport FOREIGN KEY (sport_id) REFERENCES sports(sport_id) ON DELETE RESTRICT
);

-- ----------------------------------------------------------------------------
-- 14. TOURNAMENT PARTICIPANTS TABLE
-- ----------------------------------------------------------------------------
CREATE TABLE tournament_participants (
    participant_id INT AUTO_INCREMENT PRIMARY KEY,
    tournament_id INT NOT NULL,
    team_id INT,
    member_id INT,
    display_name VARCHAR(100) NOT NULL,
    registration_date DATE DEFAULT (CURRENT_DATE),
    seed_number INT CHECK (seed_number > 0),
    payment_status VARCHAR(20) DEFAULT 'PAID' CHECK (payment_status IN ('PAID', 'PENDING')),
    status VARCHAR(20) DEFAULT 'ACTIVE' CHECK (status IN ('REGISTERED', 'ACTIVE', 'ELIMINATED', 'WINNER', 'RUNNER_UP')),
    CONSTRAINT chk_part_entity CHECK (team_id IS NOT NULL OR member_id IS NOT NULL),
    CONSTRAINT fk_part_tourn FOREIGN KEY (tournament_id) REFERENCES tournaments(tournament_id) ON DELETE CASCADE,
    CONSTRAINT fk_part_team FOREIGN KEY (team_id) REFERENCES teams(team_id) ON DELETE CASCADE,
    CONSTRAINT fk_part_member FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE
);

-- ----------------------------------------------------------------------------
-- 15. FIXTURES TABLE
-- ----------------------------------------------------------------------------
CREATE TABLE fixtures (
    fixture_id INT AUTO_INCREMENT PRIMARY KEY,
    tournament_id INT NOT NULL,
    stage VARCHAR(30) NOT NULL CHECK (stage IN ('ROUND_OF_16', 'QUARTER_FINAL', 'SEMI_FINAL', 'FINAL', 'GROUP_STAGE', 'LEAGUE')),
    participant1_id INT NOT NULL,
    participant2_id INT NOT NULL,
    facility_id INT NOT NULL,
    fixture_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    status VARCHAR(20) DEFAULT 'SCHEDULED' CHECK (status IN ('SCHEDULED', 'IN_PROGRESS', 'COMPLETED', 'POSTPONED', 'CANCELLED')),
    CONSTRAINT chk_fixture_teams CHECK (participant1_id <> participant2_id),
    CONSTRAINT chk_fixture_times CHECK (end_time > start_time),
    CONSTRAINT fk_fix_tourn FOREIGN KEY (tournament_id) REFERENCES tournaments(tournament_id) ON DELETE CASCADE,
    CONSTRAINT fk_fix_part1 FOREIGN KEY (participant1_id) REFERENCES tournament_participants(participant_id) ON DELETE RESTRICT,
    CONSTRAINT fk_fix_part2 FOREIGN KEY (participant2_id) REFERENCES tournament_participants(participant_id) ON DELETE RESTRICT,
    CONSTRAINT fk_fix_facility FOREIGN KEY (facility_id) REFERENCES facilities(facility_id) ON DELETE RESTRICT
);

-- ----------------------------------------------------------------------------
-- 16. MATCH RESULTS TABLE
-- ----------------------------------------------------------------------------
CREATE TABLE match_results (
    result_id INT AUTO_INCREMENT PRIMARY KEY,
    fixture_id INT NOT NULL UNIQUE,
    winner_participant_id INT,
    score_participant1 INT NOT NULL CHECK (score_participant1 >= 0),
    score_participant2 INT NOT NULL CHECK (score_participant2 >= 0),
    set_scores_details VARCHAR(255),
    match_notes VARCHAR(255),
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_res_fixture FOREIGN KEY (fixture_id) REFERENCES fixtures(fixture_id) ON DELETE CASCADE,
    CONSTRAINT fk_res_winner FOREIGN KEY (winner_participant_id) REFERENCES tournament_participants(participant_id) ON DELETE SET NULL
);

-- ----------------------------------------------------------------------------
-- 17. EQUIPMENT TABLE
-- ----------------------------------------------------------------------------
CREATE TABLE equipment (
    equipment_id INT AUTO_INCREMENT PRIMARY KEY,
    sport_id INT NOT NULL,
    equipment_name VARCHAR(100) NOT NULL,
    brand VARCHAR(60),
    model_code VARCHAR(40),
    total_quantity INT NOT NULL CHECK (total_quantity >= 0),
    available_quantity INT NOT NULL CHECK (available_quantity >= 0),
    condition_status VARCHAR(30) DEFAULT 'GOOD' CHECK (condition_status IN ('GOOD', 'FAIR', 'MAINTENANCE_REQUIRED')),
    CONSTRAINT chk_eq_quantity CHECK (available_quantity <= total_quantity),
    CONSTRAINT fk_eq_sport FOREIGN KEY (sport_id) REFERENCES sports(sport_id) ON DELETE RESTRICT
);

-- ----------------------------------------------------------------------------
-- 18. EQUIPMENT LOANS TABLE
-- ----------------------------------------------------------------------------
CREATE TABLE equipment_loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    equipment_id INT NOT NULL,
    member_id INT NOT NULL,
    quantity INT DEFAULT 1 CHECK (quantity > 0),
    issue_date DATE DEFAULT (CURRENT_DATE),
    due_date DATE NOT NULL,
    return_date DATE,
    status VARCHAR(30) DEFAULT 'ISSUED' CHECK (status IN ('ISSUED', 'RETURNED', 'OVERDUE', 'DAMAGED_RETURNED')),
    condition_on_issue VARCHAR(20) DEFAULT 'GOOD' CHECK (condition_on_issue IN ('GOOD', 'FAIR')),
    condition_on_return VARCHAR(20) CHECK (condition_on_return IN ('GOOD', 'FAIR', 'DAMAGED', 'LOST')),
    fine_amount DECIMAL(10, 2) DEFAULT 0.0 CHECK (fine_amount >= 0.0),
    CONSTRAINT chk_loan_due CHECK (due_date >= issue_date),
    CONSTRAINT fk_loan_eq FOREIGN KEY (equipment_id) REFERENCES equipment(equipment_id) ON DELETE RESTRICT,
    CONSTRAINT fk_loan_member FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE RESTRICT
);

-- Indexes for Query Optimization
CREATE INDEX idx_members_name ON members(last_name, first_name);
CREATE INDEX idx_facility_bookings_date ON facility_bookings(facility_id, booking_date);
CREATE INDEX idx_fixtures_date ON fixtures(tournament_id, fixture_date);
CREATE INDEX idx_equipment_loans_member ON equipment_loans(member_id, status);
