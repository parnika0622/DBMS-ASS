-- ============================================================================
-- SPORTS CLUB MEMBERSHIP AND TOURNAMENT MANAGEMENT SYSTEM
-- Advanced SQL Statements: Joins, Aggregations, Nested Queries & Reports
-- ============================================================================

-- ============================================================================
-- SECTION 1: MULTI-TABLE JOINS (INNER, LEFT OUTER, MULTI-WAY)
-- ============================================================================

-- Query 1.1: Complete Member Profile with Active Plan, Assigned Teams & Loans
-- Demonstrates multi-way LEFT OUTER JOIN across 5 tables
SELECT 
    m.member_id,
    m.first_name || ' ' || m.last_name AS member_name,
    m.email,
    m.phone,
    COALESCE(mp.plan_name, 'No Active Plan') AS current_plan,
    COALESCE(t.team_name, 'Unassigned') AS team_name,
    tr.jersey_number,
    COUNT(DISTINCT el.loan_id) AS total_active_loans
FROM members m
LEFT JOIN member_subscriptions ms ON m.member_id = ms.member_id AND ms.status = 'ACTIVE'
LEFT JOIN membership_plans mp ON ms.plan_id = mp.plan_id
LEFT JOIN team_roster tr ON m.member_id = tr.member_id AND tr.is_active = 1
LEFT JOIN teams t ON tr.team_id = t.team_id
LEFT JOIN equipment_loans el ON m.member_id = el.member_id AND el.status = 'ISSUED'
GROUP BY m.member_id
ORDER BY m.member_id;

-- Query 1.2: Match Fixture Details with Venue, Tournament, and Competitors
-- Demonstrates 4-table INNER JOIN with dual-aliasing on tournament_participants
SELECT 
    f.fixture_id,
    t.tournament_name,
    s.sport_name,
    f.stage,
    p1.display_name AS competitor_1,
    p2.display_name AS competitor_2,
    fac.facility_name AS venue,
    f.fixture_date,
    f.start_time || ' - ' || f.end_time AS match_slot,
    f.status,
    COALESCE(mr.score_participant1 || ' - ' || mr.score_participant2, 'Pending') AS final_score,
    COALESCE(pw.display_name, 'TBD') AS match_winner
FROM fixtures f
JOIN tournaments t ON f.tournament_id = t.tournament_id
JOIN sports s ON t.sport_id = s.sport_id
JOIN tournament_participants p1 ON f.participant1_id = p1.participant_id
JOIN tournament_participants p2 ON f.participant2_id = p2.participant_id
JOIN facilities fac ON f.facility_id = fac.facility_id
LEFT JOIN match_results mr ON f.fixture_id = mr.fixture_id
LEFT JOIN tournament_participants pw ON mr.winner_participant_id = pw.participant_id
ORDER BY f.fixture_date, f.start_time;

-- ============================================================================
-- SECTION 2: AGGREGATE FUNCTIONS WITH GROUP BY & HAVING
-- ============================================================================

-- Query 2.1: Sport-wise Revenue, Active Memberships & Facility Count
-- Demonstrates aggregate functions SUM, COUNT, AVG with GROUP BY
SELECT 
    s.sport_name,
    s.category,
    COUNT(DISTINCT f.facility_id) AS total_facilities,
    COUNT(DISTINCT ts.session_id) AS scheduled_training_sessions,
    COUNT(DISTINCT t.tournament_id) AS tournaments_hosted,
    COALESCE(SUM(fb.total_fee), 0.0) AS booking_revenue
FROM sports s
LEFT JOIN facilities f ON s.sport_id = f.sport_id
LEFT JOIN facility_bookings fb ON f.facility_id = fb.facility_id AND fb.status = 'CONFIRMED'
LEFT JOIN training_sessions ts ON s.sport_id = ts.sport_id
LEFT JOIN tournaments t ON s.sport_id = t.sport_id
GROUP BY s.sport_id, s.sport_name, s.category
ORDER BY booking_revenue DESC;

-- Query 2.2: Facilities with High Demand (Booked more than 2 times or revenue > $50)
-- Demonstrates HAVING clause filtering aggregate values
SELECT 
    f.facility_name,
    s.sport_name,
    f.capacity,
    f.hourly_rate,
    COUNT(fb.booking_id) AS confirmed_bookings_count,
    SUM(fb.total_fee) AS total_revenue
FROM facilities f
JOIN sports s ON f.sport_id = s.sport_id
JOIN facility_bookings fb ON f.facility_id = fb.facility_id
WHERE fb.status = 'CONFIRMED'
GROUP BY f.facility_id, f.facility_name, s.sport_name, f.capacity, f.hourly_rate
HAVING COUNT(fb.booking_id) >= 1 AND SUM(fb.total_fee) >= 25.0
ORDER BY total_revenue DESC;

-- Query 2.3: Coach Workload and Potential Hourly Earnings
SELECT 
    c.coach_id,
    c.first_name || ' ' || c.last_name AS coach_name,
    s.sport_name,
    c.hourly_rate,
    COUNT(ts.session_id) AS sessions_count,
    COALESCE(SUM(
        (strftime('%H', ts.end_time) - strftime('%H', ts.start_time)) + 
        (strftime('%M', ts.end_time) - strftime('%M', ts.start_time)) / 60.0
    ), 0.0) AS total_coaching_hours,
    ROUND(COALESCE(SUM(
        (strftime('%H', ts.end_time) - strftime('%H', ts.start_time)) + 
        (strftime('%M', ts.end_time) - strftime('%M', ts.start_time)) / 60.0
    ) * c.hourly_rate, 0.0), 2) AS estimated_payout
FROM coaches c
JOIN sports s ON c.specialization_sport_id = s.sport_id
LEFT JOIN training_sessions ts ON c.coach_id = ts.coach_id AND ts.status <> 'CANCELLED'
GROUP BY c.coach_id, coach_name, s.sport_name, c.hourly_rate;

-- ============================================================================
-- SECTION 3: NESTED QUERIES (SUBQUERIES, CORRELATED, EXISTS)
-- ============================================================================

-- Query 3.1: Non-Correlated Subquery: Members who have NEVER borrowed equipment
SELECT 
    member_id,
    first_name || ' ' || last_name AS member_name,
    email,
    phone,
    status
FROM members
WHERE member_id NOT IN (
    SELECT DISTINCT member_id 
    FROM equipment_loans
)
ORDER BY member_id;

-- Query 3.2: Correlated Subquery: Members whose total payments exceed the average payment
SELECT 
    m.member_id,
    m.first_name || ' ' || m.last_name AS member_name,
    p.amount AS transaction_amount,
    p.payment_method,
    p.transaction_ref
FROM members m
JOIN payments p ON m.member_id = p.member_id
WHERE p.amount > (
    SELECT AVG(amount) 
    FROM payments
)
ORDER BY p.amount DESC;

-- Query 3.3: EXISTS Subquery: Find facilities that have BOTH casual bookings AND training sessions
SELECT 
    f.facility_id,
    f.facility_name,
    f.facility_type
FROM facilities f
WHERE EXISTS (
    SELECT 1 
    FROM facility_bookings fb 
    WHERE fb.facility_id = f.facility_id AND fb.booking_purpose = 'CASUAL_PLAY'
)
AND EXISTS (
    SELECT 1 
    FROM training_sessions ts 
    WHERE ts.facility_id = f.facility_id
);

-- Query 3.4: Scalar Subquery in SELECT clause: Members with total fee spend and rank
SELECT 
    m.member_id,
    m.first_name || ' ' || m.last_name AS member_name,
    m.status,
    (SELECT COUNT(*) FROM facility_bookings fb WHERE fb.member_id = m.member_id) AS total_facility_bookings,
    (SELECT COALESCE(SUM(amount), 0.0) FROM payments p WHERE p.member_id = m.member_id) AS total_money_spent
FROM members m
ORDER BY total_money_spent DESC;

-- ============================================================================
-- SECTION 4: ADVANCED ANALYTICAL & WINDOW FUNCTIONS
-- ============================================================================

-- Query 4.1: Ranking Members by Total Payments using DENSE_RANK()
SELECT 
    m.member_id,
    m.first_name || ' ' || m.last_name AS member_name,
    SUM(p.amount) AS total_paid,
    DENSE_RANK() OVER (ORDER BY SUM(p.amount) DESC) AS payment_rank
FROM members m
JOIN payments p ON m.member_id = p.member_id
GROUP BY m.member_id
ORDER BY payment_rank;

-- Query 4.2: Running Total of Club Revenue over Time
SELECT 
    payment_id,
    payment_date,
    amount,
    payment_method,
    SUM(amount) OVER (ORDER BY payment_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_revenue
FROM payments
ORDER BY payment_date;

-- ============================================================================
-- SECTION 5: MEANINGFUL BUSINESS REPORTS (VIEW QUERIES)
-- ============================================================================

-- Report 1: Active Membership Registry & Days to Renewal
SELECT * FROM v_active_memberships ORDER BY days_remaining ASC;

-- Report 2: Live Tournament Standings
SELECT * FROM v_tournament_standings;

-- Report 3: Facility Utilization & Revenue Efficiency
SELECT * FROM v_facility_utilization ORDER BY total_revenue_generated DESC;

-- Report 4: Player Performance Roster
SELECT * FROM v_player_performance ORDER BY win_percentage DESC;

-- Report 5: Fee Defaulters & Delinquency Aging
SELECT * FROM v_fee_dues ORDER BY days_since_start DESC;

-- Report 6: Equipment Inventory & Loan Tracking
SELECT * FROM v_equipment_status ORDER BY overdue_loans_count DESC;
