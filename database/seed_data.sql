-- ============================================================================
-- SPORTS CLUB MEMBERSHIP AND TOURNAMENT MANAGEMENT SYSTEM
-- Realistic Sample Seed Data
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. SPORTS
-- ----------------------------------------------------------------------------
INSERT INTO sports (sport_id, sport_name, category, max_team_size, description) VALUES
(1, 'Badminton', 'INDOOR', 2, 'Racquet sport played with shuttlecocks on indoor courts.'),
(2, 'Football', 'OUTDOOR', 11, 'Association football played on standard outdoor turf.'),
(3, 'Tennis', 'OUTDOOR', 2, 'Racket sport played individually or in doubles on clay/hard courts.'),
(4, 'Basketball', 'INDOOR', 5, 'Fast-paced indoor team sport with hoop scoring.'),
(5, 'Table Tennis', 'INDOOR', 2, 'Fast table racquet game with celluloid/plastic balls.');

-- ----------------------------------------------------------------------------
-- 2. MEMBERSHIP PLANS
-- ----------------------------------------------------------------------------
INSERT INTO membership_plans (plan_id, plan_name, duration_months, fee_amount, description, is_active) VALUES
(1, 'Annual All-Access VIP', 12, 750.00, 'Full unrestricted access to all facilities, priority booking, and tournaments.', 1),
(2, 'Semi-Annual Pro Athlete', 6, 420.00, 'Six months multi-sport access and tournament discounts.', 1),
(3, 'Quarterly Fitness & Play', 3, 230.00, 'Three months standard access to selected indoor and outdoor facilities.', 1),
(4, 'Monthly Casual Flex', 1, 85.00, 'Single month recurring subscription for recreational play.', 1);

-- ----------------------------------------------------------------------------
-- 3. MEMBERS
-- ----------------------------------------------------------------------------
INSERT INTO members (member_id, first_name, last_name, email, phone, dob, gender, address, emergency_contact, joined_date, status) VALUES
(1, 'Aarav', 'Sharma', 'aarav.sharma@example.com', '+91-9876543210', '1998-04-15', 'MALE', '12 Greenfield Ave, Sector 14', '+91-9876543219', '2025-01-10', 'ACTIVE'),
(2, 'Diya', 'Patel', 'diya.patel@example.com', '+91-9876543211', '2001-08-22', 'FEMALE', '45 Lake View Residency', '+91-9876543218', '2025-02-01', 'ACTIVE'),
(3, 'Rohan', 'Verma', 'rohan.verma@example.com', '+91-9876543212', '1995-11-03', 'MALE', '88 Hill Road, Apartment 3B', '+91-9876543217', '2025-01-15', 'ACTIVE'),
(4, 'Ananya', 'Iyer', 'ananya.iyer@example.com', '+91-9876543213', '2000-01-19', 'FEMALE', '7 Palm Grove enclave', '+91-9876543216', '2025-03-05', 'ACTIVE'),
(5, 'Kabir', 'Mehta', 'kabir.mehta@example.com', '+91-9876543214', '1997-06-30', 'MALE', '21 Sunrise Blvd', '+91-9876543215', '2025-01-20', 'ACTIVE'),
(6, 'Pooja', 'Nair', 'pooja.nair@example.com', '+91-9876543220', '1999-09-14', 'FEMALE', '104 Orchid Towers', '+91-9876543229', '2025-04-12', 'ACTIVE'),
(7, 'Vikram', 'Singh', 'vikram.singh@example.com', '+91-9876543221', '1994-12-05', 'MALE', '54 Civil Lines', '+91-9876543228', '2025-02-18', 'ACTIVE'),
(8, 'Sneha', 'Reddy', 'sneha.reddy@example.com', '+91-9876543222', '2002-03-27', 'FEMALE', '16 Jubilee Hills', '+91-9876543227', '2025-05-01', 'ACTIVE'),
(9, 'Arjun', 'Kapoor', 'arjun.kapoor@example.com', '+91-9876543223', '1996-07-11', 'MALE', '73 Bandra West, flat 12', '+91-9876543226', '2024-06-15', 'EXPIRED'),
(10, 'Meera', 'Deshmukh', 'meera.deshmukh@example.com', '+91-9876543224', '1998-10-09', 'FEMALE', '29 Koregaon Park', '+91-9876543225', '2025-06-10', 'ACTIVE'),
(11, 'Kunal', 'Bose', 'kunal.bose@example.com', '+91-9876543230', '2000-05-18', 'MALE', '8 Salt Lake City, Block AB', '+91-9876543239', '2025-03-01', 'ACTIVE'),
(12, 'Tanvi', 'Chopra', 'tanvi.chopra@example.com', '+91-9876543231', '2003-02-14', 'FEMALE', '33 Defense Colony', '+91-9876543238', '2025-07-01', 'ACTIVE'),
(13, 'Aditya', 'Joshi', 'aditya.joshi@example.com', '+91-9876543232', '1993-08-08', 'MALE', '19 Shivajinagar', '+91-9876543237', '2024-01-10', 'EXPIRED'),
(14, 'Rhea', 'Menon', 'rhea.menon@example.com', '+91-9876543233', '2001-11-23', 'FEMALE', '62 Marine Drive', '+91-9876543236', '2025-08-15', 'ACTIVE'),
(15, 'Siddharth', 'Malhotra', 'sid.malhotra@example.com', '+91-9876543234', '1997-01-31', 'MALE', '9 Indiranagar 100ft Rd', '+91-9876543235', '2025-09-01', 'ACTIVE');

-- ----------------------------------------------------------------------------
-- 4. MEMBER SUBSCRIPTIONS
-- ----------------------------------------------------------------------------
INSERT INTO member_subscriptions (subscription_id, member_id, plan_id, start_date, end_date, status, payment_status) VALUES
(1, 1, 1, '2026-01-01', '2026-12-31', 'ACTIVE', 'PAID'),
(2, 2, 2, '2026-02-01', '2026-08-01', 'ACTIVE', 'PAID'),
(3, 3, 1, '2026-01-15', '2027-01-14', 'ACTIVE', 'PAID'),
(4, 4, 3, '2026-03-01', '2026-06-01', 'ACTIVE', 'PAID'),
(5, 5, 2, '2026-01-20', '2026-07-20', 'ACTIVE', 'PAID'),
(6, 6, 4, '2026-04-01', '2026-05-01', 'ACTIVE', 'PAID'),
(7, 7, 1, '2026-02-15', '2027-02-14', 'ACTIVE', 'PAID'),
(8, 8, 3, '2026-05-01', '2026-08-01', 'ACTIVE', 'PAID'),
(9, 9, 4, '2025-06-01', '2025-07-01', 'EXPIRED', 'PAID'),
(10, 10, 2, '2026-06-01', '2026-12-01', 'ACTIVE', 'PENDING'),
(11, 11, 3, '2026-03-15', '2026-06-15', 'ACTIVE', 'PAID'),
(12, 12, 4, '2026-07-01', '2026-08-01', 'ACTIVE', 'PAID'),
(13, 13, 4, '2024-05-01', '2024-06-01', 'EXPIRED', 'OVERDUE'),
(14, 14, 1, '2026-08-01', '2027-07-31', 'ACTIVE', 'PAID'),
(15, 15, 2, '2026-09-01', '2027-03-01', 'ACTIVE', 'PAID');

-- ----------------------------------------------------------------------------
-- 5. PAYMENTS
-- ----------------------------------------------------------------------------
INSERT INTO payments (payment_id, member_id, subscription_id, amount, payment_date, payment_method, transaction_ref, status, notes) VALUES
(1, 1, 1, 750.00, '2026-01-01 10:15:00', 'CREDIT_CARD', 'TXN-20260101-001', 'COMPLETED', 'Annual VIP subscription fee'),
(2, 2, 2, 420.00, '2026-02-01 11:30:00', 'UPI', 'TXN-20260201-002', 'COMPLETED', 'Semi-Annual fee via GooglePay'),
(3, 3, 1, 750.00, '2026-01-15 16:45:00', 'BANK_TRANSFER', 'TXN-20260115-003', 'COMPLETED', 'NEFT Bank transfer clearance'),
(4, 4, 3, 230.00, '2026-03-01 09:20:00', 'DEBIT_CARD', 'TXN-20260301-004', 'COMPLETED', 'Quarterly fee payment'),
(5, 5, 2, 420.00, '2026-01-20 14:10:00', 'UPI', 'TXN-20260120-005', 'COMPLETED', 'UPI transaction reference 49201'),
(6, 6, 4, 85.00, '2026-04-01 12:00:00', 'CASH', 'TXN-20260401-006', 'COMPLETED', 'Front desk cash collection'),
(7, 7, 1, 750.00, '2026-02-15 15:30:00', 'CREDIT_CARD', 'TXN-20260215-007', 'COMPLETED', 'Visa card payment'),
(8, 8, 3, 230.00, '2026-05-01 18:25:00', 'UPI', 'TXN-20260501-008', 'COMPLETED', 'Quarterly plan payment'),
(9, 11, 11, 230.00, '2026-03-15 10:05:00', 'CREDIT_CARD', 'TXN-20260315-009', 'COMPLETED', 'Mastercard payment'),
(10, 12, 12, 85.00, '2026-07-01 17:40:00', 'UPI', 'TXN-20260701-010', 'COMPLETED', 'Monthly fee renewal');

-- ----------------------------------------------------------------------------
-- 6. COACHES
-- ----------------------------------------------------------------------------
INSERT INTO coaches (coach_id, first_name, last_name, email, phone, specialization_sport_id, qualification, hourly_rate, hire_date, status) VALUES
(1, 'Marcus', 'Fernandes', 'marcus.f@sportsclub.org', '+91-9123456780', 2, 'UEFA Pro Licence & AFC Elite Coach', 65.00, '2023-04-01', 'ACTIVE'),
(2, 'Lin', 'Dan-Raj', 'lin.raj@sportsclub.org', '+91-9123456781', 1, 'BWF Level 3 High Performance Coach', 55.00, '2023-06-15', 'ACTIVE'),
(3, 'Samantha', 'Williams', 'sam.williams@sportsclub.org', '+91-9123456782', 3, 'ITF Level 2 Certified Coach', 60.00, '2024-01-10', 'ACTIVE'),
(4, 'David', 'Kerr', 'david.kerr@sportsclub.org', '+91-9123456783', 4, 'FIBA Certified Youth & Pro Coach', 50.00, '2024-03-20', 'ACTIVE'),
(5, 'Zhang', 'Wei', 'zhang.wei@sportsclub.org', '+91-9123456784', 5, 'ITTF Advanced High Performance Diploma', 45.00, '2024-08-01', 'ACTIVE');

-- ----------------------------------------------------------------------------
-- 7. TEAMS
-- ----------------------------------------------------------------------------
INSERT INTO teams (team_id, team_name, sport_id, coach_id, captain_id, created_date) VALUES
(1, 'Thunderbolts FC', 2, 1, 1, '2025-02-01'),
(2, 'Vanguard Strikers', 2, 1, 5, '2025-02-15'),
(3, 'Apex Smashers', 1, 2, 2, '2025-03-01'),
(4, 'Red Hawks Basketball', 4, 4, 3, '2025-03-10'),
(5, 'Royal Court Tennis Club', 3, 3, 4, '2025-04-01');

-- ----------------------------------------------------------------------------
-- 8. TEAM ROSTER
-- ----------------------------------------------------------------------------
INSERT INTO team_roster (roster_id, team_id, member_id, jersey_number, position, joined_date, is_active) VALUES
-- Thunderbolts FC (Football)
(1, 1, 1, 10, 'Attacking Midfielder', '2025-02-01', 1),
(2, 1, 3, 9, 'Striker', '2025-02-01', 1),
(3, 1, 7, 4, 'Center Back', '2025-02-05', 1),
(4, 1, 11, 1, 'Goalkeeper', '2025-03-15', 1),
-- Vanguard Strikers (Football)
(5, 2, 5, 7, 'Winger', '2025-02-15', 1),
(6, 2, 15, 8, 'Central Midfielder', '2025-09-01', 1),
-- Apex Smashers (Badminton Doubles)
(7, 3, 2, 1, 'Front Court Specialist', '2025-03-01', 1),
(8, 3, 6, 2, 'Power Smasher', '2025-04-12', 1),
-- Red Hawks (Basketball)
(9, 4, 3, 23, 'Point Guard', '2025-03-10', 1),
(10, 4, 5, 33, 'Center', '2025-03-12', 1),
(11, 4, 7, 11, 'Small Forward', '2025-03-15', 1);

-- ----------------------------------------------------------------------------
-- 9. FACILITIES
-- ----------------------------------------------------------------------------
INSERT INTO facilities (facility_id, facility_name, sport_id, facility_type, capacity, hourly_rate, is_operational) VALUES
(1, 'Badminton Court 1 (Olympic Wood)', 1, 'COURT', 4, 25.00, 1),
(2, 'Badminton Court 2 (Synthetic Mat)', 1, 'COURT', 4, 20.00, 1),
(3, 'Main Football Stadium Turf', 2, 'TURF', 30, 80.00, 1),
(4, 'Championship Tennis Clay Court', 3, 'COURT', 4, 35.00, 1),
(5, 'Indoor Hardwood Basketball Arena', 4, 'ARENA', 25, 45.00, 1),
(6, 'Table Tennis Studio Arena', 5, 'COURT', 8, 15.00, 1);

-- ----------------------------------------------------------------------------
-- 10. FACILITY BOOKINGS
-- ----------------------------------------------------------------------------
INSERT INTO facility_bookings (booking_id, facility_id, member_id, team_id, booking_date, start_time, end_time, booking_purpose, attendees_count, total_fee, status) VALUES
(1, 1, 2, NULL, '2026-10-15', '07:00:00', '08:00:00', 'CASUAL_PLAY', 2, 25.00, 'CONFIRMED'),
(2, 1, 6, NULL, '2026-10-15', '08:30:00', '09:30:00', 'CASUAL_PLAY', 4, 25.00, 'CONFIRMED'),
(3, 3, NULL, 1, '2026-10-15', '16:00:00', '18:00:00', 'TRAINING', 16, 160.00, 'CONFIRMED'),
(4, 4, 4, NULL, '2026-10-16', '09:00:00', '10:30:00', 'CASUAL_PLAY', 2, 52.50, 'CONFIRMED'),
(5, 5, NULL, 4, '2026-10-16', '17:00:00', '19:00:00', 'TRAINING', 12, 90.00, 'CONFIRMED'),
(6, 2, 8, NULL, '2026-10-17', '10:00:00', '11:00:00', 'CASUAL_PLAY', 2, 20.00, 'CONFIRMED');

-- ----------------------------------------------------------------------------
-- 11. TRAINING SESSIONS
-- ----------------------------------------------------------------------------
INSERT INTO training_sessions (session_id, sport_id, coach_id, facility_id, session_title, session_date, start_time, end_time, max_participants, status) VALUES
(1, 1, 2, 1, 'Advanced Smash & Footwork Mastery', '2026-10-18', '07:00:00', '08:30:00', 4, 'SCHEDULED'),
(2, 2, 1, 3, 'Tactical Passing & Defensive Formations', '2026-10-18', '16:00:00', '18:00:00', 18, 'SCHEDULED'),
(3, 3, 3, 4, 'Topspin Serve & Baseline Drill', '2026-10-19', '08:00:00', '09:30:00', 4, 'SCHEDULED'),
(4, 4, 4, 5, 'Pick and Roll Strategy & Free Throws', '2026-10-19', '17:00:00', '18:30:00', 12, 'SCHEDULED'),
(5, 5, 5, 6, 'Spin Serve & Fast Counter Loop', '2026-10-20', '15:00:00', '16:30:00', 6, 'SCHEDULED');

-- ----------------------------------------------------------------------------
-- 12. TRAINING ENROLLMENTS
-- ----------------------------------------------------------------------------
INSERT INTO training_enrollments (enrollment_id, session_id, member_id, enrolled_at, attendance_status) VALUES
(1, 1, 2, '2026-10-10 11:00:00', 'REGISTERED'),
(2, 1, 6, '2026-10-10 11:30:00', 'REGISTERED'),
(3, 1, 8, '2026-10-11 09:15:00', 'REGISTERED'),
(4, 2, 1, '2026-10-09 14:00:00', 'REGISTERED'),
(5, 2, 3, '2026-10-09 14:05:00', 'REGISTERED'),
(6, 2, 5, '2026-10-09 15:20:00', 'REGISTERED'),
(7, 2, 7, '2026-10-10 16:00:00', 'REGISTERED'),
(8, 3, 4, '2026-10-11 10:45:00', 'REGISTERED'),
(9, 4, 3, '2026-10-11 12:00:00', 'REGISTERED');

-- ----------------------------------------------------------------------------
-- 13. TOURNAMENTS
-- ----------------------------------------------------------------------------
INSERT INTO tournaments (tournament_id, tournament_name, sport_id, start_date, end_date, format, entry_fee, prize_pool, status) VALUES
(1, 'All-Club Badminton Singles Championship 2026', 1, '2026-10-22', '2026-10-25', 'KNOCKOUT', 30.00, 500.00, 'ONGOING'),
(2, 'Inter-Club Autumn Football Derby 2026', 2, '2026-10-26', '2026-11-05', 'ROUND_ROBIN', 100.00, 1500.00, 'UPCOMING'),
(3, 'Club Open Tennis Classic', 3, '2026-09-01', '2026-09-05', 'KNOCKOUT', 40.00, 800.00, 'COMPLETED');

-- ----------------------------------------------------------------------------
-- 14. TOURNAMENT PARTICIPANTS
-- ----------------------------------------------------------------------------
INSERT INTO tournament_participants (participant_id, tournament_id, team_id, member_id, display_name, registration_date, seed_number, payment_status, status) VALUES
-- Tournament 1: Badminton Championship (Singles)
(1, 1, NULL, 1, 'Aarav Sharma', '2026-10-05', 1, 'PAID', 'ACTIVE'),
(2, 1, NULL, 2, 'Diya Patel', '2026-10-06', 2, 'PAID', 'ACTIVE'),
(3, 1, NULL, 6, 'Pooja Nair', '2026-10-07', 3, 'PAID', 'ACTIVE'),
(4, 1, NULL, 8, 'Sneha Reddy', '2026-10-08', 4, 'PAID', 'ACTIVE'),
-- Tournament 2: Football Derby (Teams)
(5, 2, 1, NULL, 'Thunderbolts FC', '2026-10-02', 1, 'PAID', 'REGISTERED'),
(6, 2, 2, NULL, 'Vanguard Strikers', '2026-10-03', 2, 'PAID', 'REGISTERED'),
-- Tournament 3: Tennis Classic (Completed)
(7, 3, NULL, 3, 'Rohan Verma', '2026-08-20', 1, 'PAID', 'WINNER'),
(8, 3, NULL, 4, 'Ananya Iyer', '2026-08-21', 2, 'PAID', 'RUNNER_UP'),
(9, 3, NULL, 7, 'Vikram Singh', '2026-08-22', 3, 'PAID', 'ELIMINATED'),
(10, 3, NULL, 5, 'Kabir Mehta', '2026-08-22', 4, 'PAID', 'ELIMINATED');

-- ----------------------------------------------------------------------------
-- 15. FIXTURES
-- ----------------------------------------------------------------------------
INSERT INTO fixtures (fixture_id, tournament_id, stage, participant1_id, participant2_id, facility_id, fixture_date, start_time, end_time, status) VALUES
-- Completed Tennis Classic matches
(1, 3, 'SEMI_FINAL', 7, 9, 4, '2026-09-02', '14:00:00', '16:00:00', 'COMPLETED'),
(2, 3, 'SEMI_FINAL', 8, 10, 4, '2026-09-02', '16:30:00', '18:30:00', 'COMPLETED'),
(3, 3, 'FINAL', 7, 8, 4, '2026-09-04', '15:00:00', '17:30:00', 'COMPLETED'),
-- Ongoing Badminton Championship matches
(4, 1, 'SEMI_FINAL', 1, 3, 1, '2026-10-22', '10:00:00', '11:15:00', 'COMPLETED'),
(5, 1, 'SEMI_FINAL', 2, 4, 1, '2026-10-22', '11:30:00', '12:45:00', 'COMPLETED'),
(6, 1, 'FINAL', 1, 2, 1, '2026-10-24', '16:00:00', '17:30:00', 'SCHEDULED'),
-- Upcoming Football Derby
(7, 2, 'LEAGUE', 5, 6, 3, '2026-10-28', '17:00:00', '19:00:00', 'SCHEDULED');

-- ----------------------------------------------------------------------------
-- 16. MATCH RESULTS
-- ----------------------------------------------------------------------------
INSERT INTO match_results (result_id, fixture_id, winner_participant_id, score_participant1, score_participant2, set_scores_details, match_notes, recorded_at) VALUES
(1, 1, 7, 2, 0, '6-4, 6-3', 'Rohan dominated with first serves.', '2026-09-02 16:05:00'),
(2, 2, 8, 2, 1, '4-6, 7-5, 6-2', 'Comeback victory for Ananya.', '2026-09-02 18:35:00'),
(3, 3, 7, 2, 1, '7-6, 3-6, 6-4', 'Championship thriller; Rohan clinched title.', '2026-09-04 17:35:00'),
(4, 4, 1, 2, 0, '21-18, 21-14', 'Aarav advanced to finals.', '2026-10-22 11:20:00'),
(5, 5, 2, 2, 1, '21-19, 17-21, 21-15', 'Diya secured finals spot in three tight sets.', '2026-10-22 12:50:00');

-- ----------------------------------------------------------------------------
-- 17. EQUIPMENT
-- ----------------------------------------------------------------------------
INSERT INTO equipment (equipment_id, sport_id, equipment_name, brand, model_code, total_quantity, available_quantity, condition_status) VALUES
(1, 1, 'Yonex Astrox 88D Pro Badminton Racket', 'Yonex', 'AX88D-P', 15, 12, 'GOOD'),
(2, 1, 'Yonex Aerosensa 30 Feather Shuttlecocks (Tubes)', 'Yonex', 'AS-30', 30, 26, 'GOOD'),
(3, 2, 'Nike Flight Professional Match Football', 'Nike', 'NK-FLT-05', 20, 16, 'GOOD'),
(4, 3, 'Wilson Pro Staff 97 v14 Tennis Racket', 'Wilson', 'WR038411', 10, 8, 'GOOD'),
(5, 4, 'Spalding TF-1000 Legacy Basketball', 'Spalding', 'SP-TF1000', 12, 11, 'GOOD'),
(6, 5, 'Butterfly Timo Boll ALC Table Tennis Bat', 'Butterfly', 'TB-ALC-FL', 10, 9, 'GOOD');

-- ----------------------------------------------------------------------------
-- 18. EQUIPMENT LOANS
-- ----------------------------------------------------------------------------
INSERT INTO equipment_loans (loan_id, equipment_id, member_id, quantity, issue_date, due_date, return_date, status, condition_on_issue, condition_on_return, fine_amount) VALUES
(1, 1, 2, 2, '2026-10-10', '2026-10-10', '2026-10-10', 'RETURNED', 'GOOD', 'GOOD', 0.00),
(2, 3, 1, 2, '2026-10-11', '2026-10-11', '2026-10-11', 'RETURNED', 'GOOD', 'GOOD', 0.00),
(3, 1, 6, 1, '2026-10-12', '2026-10-13', NULL, 'ISSUED', 'GOOD', NULL, 0.00),
(4, 4, 4, 1, '2026-10-08', '2026-10-09', NULL, 'OVERDUE', 'GOOD', NULL, 15.00),
(5, 5, 3, 1, '2026-10-12', '2026-10-14', NULL, 'ISSUED', 'GOOD', NULL, 0.00);
