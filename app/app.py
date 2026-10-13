import os
import sys
from flask import Flask, render_template, request, redirect, url_for, flash, jsonify

# Add parent directory to sys.path so database package can be imported
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from database.db_manager import init_database
from app.services import (
    member_service,
    facility_service,
    team_service,
    training_service,
    tournament_service,
    equipment_service,
    reports_service
)

app = Flask(__name__)
app.secret_key = "sports_club_dbms_super_secret_academic_key"

# Ensure database is initialized on start
init_database(seed=True)


# -----------------------------------------------------------------------------
# DASHBOARD
# -----------------------------------------------------------------------------
@app.route("/")
def index():
    stats = reports_service.get_dashboard_stats()
    return render_template("index.html", stats=stats)


# -----------------------------------------------------------------------------
# MEMBERSHIP MANAGEMENT
# -----------------------------------------------------------------------------
@app.route("/members")
def members():
    search = request.args.get("search", "").strip()
    status_filter = request.args.get("status", "").strip()
    members_list = member_service.get_all_members(search or None, status_filter or None)
    plans = member_service.get_membership_plans()
    return render_template("members.html", members=members_list, plans=plans, search=search, status_filter=status_filter)


@app.route("/members/register", methods=["POST"])
def register_member():
    try:
        first_name = request.form["first_name"].strip()
        last_name = request.form["last_name"].strip()
        email = request.form["email"].strip()
        phone = request.form["phone"].strip()
        dob = request.form["dob"]
        gender = request.form["gender"]
        address = request.form.get("address", "").strip()
        emergency_contact = request.form.get("emergency_contact", "").strip()

        member_id = member_service.register_member(
            first_name, last_name, email, phone, dob, gender, address, emergency_contact
        )

        # If a plan was selected during registration, subscribe them immediately
        plan_id = request.form.get("plan_id")
        payment_method = request.form.get("payment_method", "CASH")
        if plan_id:
            member_service.subscribe_member(member_id, int(plan_id), payment_method)

        flash(f"Member '{first_name} {last_name}' registered successfully! (ID: {member_id})", "success")
    except Exception as e:
        flash(f"Error registering member: {str(e)}", "danger")
    return redirect(url_for("members"))


@app.route("/members/subscribe", methods=["POST"])
def subscribe_member():
    try:
        member_id = int(request.form["member_id"])
        plan_id = int(request.form["plan_id"])
        payment_method = request.form["payment_method"]

        member_service.subscribe_member(member_id, plan_id, payment_method)
        flash("Membership plan assigned and payment recorded successfully!", "success")
    except Exception as e:
        flash(f"Error subscribing member: {str(e)}", "danger")
    return redirect(url_for("members"))


# -----------------------------------------------------------------------------
# TEAMS & ROSTER
# -----------------------------------------------------------------------------
@app.route("/teams")
def teams():
    teams_list = team_service.get_all_teams()
    sports = team_service.get_all_sports()
    coaches = team_service.get_all_coaches()
    active_members = member_service.get_all_members(status_filter="ACTIVE")
    selected_team_id = request.args.get("team_id")
    roster = []
    selected_team = None
    if selected_team_id:
        roster = team_service.get_team_roster(int(selected_team_id))
        for t in teams_list:
            if t["team_id"] == int(selected_team_id):
                selected_team = t
                break

    return render_template(
        "teams.html",
        teams=teams_list,
        sports=sports,
        coaches=coaches,
        members=active_members,
        roster=roster,
        selected_team=selected_team
    )


@app.route("/teams/create", methods=["POST"])
def create_team():
    try:
        team_name = request.form["team_name"].strip()
        sport_id = int(request.form["sport_id"])
        coach_id = int(request.form["coach_id"]) if request.form.get("coach_id") else None
        captain_id = int(request.form["captain_id"]) if request.form.get("captain_id") else None

        team_id = team_service.create_team(team_name, sport_id, coach_id, captain_id)
        flash(f"Team '{team_name}' formed successfully! (ID: {team_id})", "success")
    except Exception as e:
        flash(f"Error forming team: {str(e)}", "danger")
    return redirect(url_for("teams"))


@app.route("/teams/add-player", methods=["POST"])
def add_player_to_team():
    team_id = int(request.form["team_id"])
    try:
        member_id = int(request.form["member_id"])
        jersey_number = int(request.form["jersey_number"]) if request.form.get("jersey_number") else None
        position = request.form.get("position", "").strip()

        team_service.add_member_to_roster(team_id, member_id, jersey_number, position)
        flash("Player enrolled into team roster successfully!", "success")
    except Exception as e:
        flash(f"Error adding player to roster: {str(e)}", "danger")
    return redirect(url_for("teams", team_id=team_id))


# -----------------------------------------------------------------------------
# FACILITIES & BOOKINGS
# -----------------------------------------------------------------------------
@app.route("/facilities")
def facilities():
    facilities_list = facility_service.get_all_facilities()
    facility_filter = request.args.get("facility_id")
    date_filter = request.args.get("date")
    bookings = facility_service.get_facility_bookings(
        facility_id=int(facility_filter) if facility_filter else None,
        booking_date=date_filter or None
    )
    active_members = member_service.get_all_members(status_filter="ACTIVE")
    teams_list = team_service.get_all_teams()
    return render_template(
        "facilities.html",
        facilities=facilities_list,
        bookings=bookings,
        members=active_members,
        teams=teams_list,
        facility_filter=facility_filter,
        date_filter=date_filter
    )


@app.route("/facilities/book", methods=["POST"])
def book_facility():
    try:
        facility_id = int(request.form["facility_id"])
        book_type = request.form.get("book_type", "member")
        member_id = int(request.form["member_id"]) if book_type == "member" and request.form.get("member_id") else None
        team_id = int(request.form["team_id"]) if book_type == "team" and request.form.get("team_id") else None
        booking_date = request.form["booking_date"]
        start_time = request.form["start_time"]
        end_time = request.form["end_time"]
        purpose = request.form.get("purpose", "CASUAL_PLAY")
        attendees = int(request.form.get("attendees_count", 1))

        facility_service.book_facility(
            facility_id, member_id, team_id, booking_date, start_time, end_time, purpose, attendees
        )
        flash("Facility booked successfully! Slot confirmed.", "success")
    except Exception as e:
        flash(f"Booking Failed: {str(e)}", "danger")
    return redirect(url_for("facilities"))


# -----------------------------------------------------------------------------
# TRAINING SESSIONS
# -----------------------------------------------------------------------------
@app.route("/training")
def training():
    sessions = training_service.get_training_sessions()
    sports = team_service.get_all_sports()
    coaches = team_service.get_all_coaches()
    facilities_list = facility_service.get_all_facilities()
    active_members = member_service.get_all_members(status_filter="ACTIVE")
    selected_session_id = request.args.get("session_id")
    enrollments = []
    if selected_session_id:
        enrollments = training_service.get_session_enrollments(int(selected_session_id))

    return render_template(
        "training.html",
        sessions=sessions,
        sports=sports,
        coaches=coaches,
        facilities=facilities_list,
        members=active_members,
        enrollments=enrollments,
        selected_session_id=selected_session_id
    )


@app.route("/training/create", methods=["POST"])
def create_training():
    try:
        sport_id = int(request.form["sport_id"])
        coach_id = int(request.form["coach_id"])
        facility_id = int(request.form["facility_id"])
        session_title = request.form["session_title"].strip()
        session_date = request.form["session_date"]
        start_time = request.form["start_time"]
        end_time = request.form["end_time"]
        max_participants = int(request.form["max_participants"])

        training_service.create_training_session(
            sport_id, coach_id, facility_id, session_title, session_date, start_time, end_time, max_participants
        )
        flash(f"Training session '{session_title}' scheduled successfully!", "success")
    except Exception as e:
        flash(f"Failed to schedule training session: {str(e)}", "danger")
    return redirect(url_for("training"))


@app.route("/training/enroll", methods=["POST"])
def enroll_training():
    session_id = int(request.form["session_id"])
    try:
        member_id = int(request.form["member_id"])
        training_service.enroll_member(session_id, member_id)
        flash("Member enrolled in training session successfully!", "success")
    except Exception as e:
        flash(f"Enrollment Error: {str(e)}", "danger")
    return redirect(url_for("training", session_id=session_id))


# -----------------------------------------------------------------------------
# TOURNAMENTS, FIXTURES & RESULTS
# -----------------------------------------------------------------------------
@app.route("/tournaments")
def tournaments():
    tournaments_list = tournament_service.get_tournaments()
    sports = team_service.get_all_sports()
    facilities_list = facility_service.get_all_facilities()
    active_members = member_service.get_all_members(status_filter="ACTIVE")
    teams_list = team_service.get_all_teams()

    selected_tourn_id = request.args.get("tournament_id")
    current_tournament = None
    participants = []
    fixtures = []

    if selected_tourn_id:
        current_tournament = tournament_service.get_tournament_details(int(selected_tourn_id))
        participants = tournament_service.get_tournament_participants(int(selected_tourn_id))
        fixtures = tournament_service.get_tournament_fixtures(int(selected_tourn_id))
    elif tournaments_list:
        # Default to first tournament
        current_tournament = tournaments_list[0]
        selected_tourn_id = current_tournament["tournament_id"]
        participants = tournament_service.get_tournament_participants(selected_tourn_id)
        fixtures = tournament_service.get_tournament_fixtures(selected_tourn_id)

    return render_template(
        "tournaments.html",
        tournaments=tournaments_list,
        current_tournament=current_tournament,
        participants=participants,
        fixtures=fixtures,
        sports=sports,
        facilities=facilities_list,
        members=active_members,
        teams=teams_list
    )


@app.route("/tournaments/create", methods=["POST"])
def create_tournament():
    try:
        tournament_name = request.form["tournament_name"].strip()
        sport_id = int(request.form["sport_id"])
        start_date = request.form["start_date"]
        end_date = request.form["end_date"]
        format_type = request.form.get("format", "ROUND_ROBIN")
        entry_fee = float(request.form.get("entry_fee", 0.0))
        prize_pool = float(request.form.get("prize_pool", 0.0))

        tourn_id = tournament_service.create_tournament(
            tournament_name, sport_id, start_date, end_date, format_type, entry_fee, prize_pool
        )
        flash(f"Tournament '{tournament_name}' created successfully!", "success")
        return redirect(url_for("tournaments", tournament_id=tourn_id))
    except Exception as e:
        flash(f"Error creating tournament: {str(e)}", "danger")
        return redirect(url_for("tournaments"))


@app.route("/tournaments/participants/add", methods=["POST"])
def add_tournament_participant():
    tournament_id = int(request.form["tournament_id"])
    try:
        part_type = request.form.get("participant_type", "member")
        member_id = int(request.form["member_id"]) if part_type == "member" and request.form.get("member_id") else None
        team_id = int(request.form["team_id"]) if part_type == "team" and request.form.get("team_id") else None
        display_name = request.form["display_name"].strip()
        seed_number = int(request.form["seed_number"]) if request.form.get("seed_number") else None

        tournament_service.add_participant(tournament_id, team_id, member_id, display_name, seed_number)
        flash(f"Participant '{display_name}' registered for tournament!", "success")
    except Exception as e:
        flash(f"Error adding participant: {str(e)}", "danger")
    return redirect(url_for("tournaments", tournament_id=tournament_id))


@app.route("/tournaments/fixtures/create", methods=["POST"])
def create_fixture():
    tournament_id = int(request.form["tournament_id"])
    try:
        stage = request.form["stage"]
        p1_id = int(request.form["participant1_id"])
        p2_id = int(request.form["participant2_id"])
        facility_id = int(request.form["facility_id"])
        fixture_date = request.form["fixture_date"]
        start_time = request.form["start_time"]
        end_time = request.form["end_time"]

        tournament_service.create_fixture(
            tournament_id, stage, p1_id, p2_id, facility_id, fixture_date, start_time, end_time
        )
        flash("Tournament fixture scheduled successfully!", "success")
    except Exception as e:
        flash(f"Error scheduling fixture: {str(e)}", "danger")
    return redirect(url_for("tournaments", tournament_id=tournament_id))


@app.route("/tournaments/fixtures/result", methods=["POST"])
def record_match_result():
    tournament_id = int(request.form["tournament_id"])
    try:
        fixture_id = int(request.form["fixture_id"])
        score_p1 = int(request.form["score_p1"])
        score_p2 = int(request.form["score_p2"])
        set_scores = request.form.get("set_scores", "").strip()
        notes = request.form.get("notes", "").strip()

        tournament_service.record_match_result(fixture_id, score_p1, score_p2, set_scores, notes)
        flash("Match result recorded! Standings updated automatically.", "success")
    except Exception as e:
        flash(f"Error recording match result: {str(e)}", "danger")
    return redirect(url_for("tournaments", tournament_id=tournament_id))


# -----------------------------------------------------------------------------
# EQUIPMENT INVENTORY & LOANS
# -----------------------------------------------------------------------------
@app.route("/equipment")
def equipment():
    equipment_list = equipment_service.get_all_equipment()
    loans = equipment_service.get_equipment_loans()
    sports = team_service.get_all_sports()
    active_members = member_service.get_all_members(status_filter="ACTIVE")
    return render_template(
        "equipment.html",
        equipment=equipment_list,
        loans=loans,
        sports=sports,
        members=active_members
    )


@app.route("/equipment/add", methods=["POST"])
def add_equipment():
    try:
        sport_id = int(request.form["sport_id"])
        equipment_name = request.form["equipment_name"].strip()
        brand = request.form.get("brand", "").strip()
        model_code = request.form.get("model_code", "").strip()
        quantity = int(request.form["quantity"])

        equipment_service.add_equipment(sport_id, equipment_name, brand, model_code, quantity)
        flash(f"Equipment item '{equipment_name}' added to inventory!", "success")
    except Exception as e:
        flash(f"Error adding equipment: {str(e)}", "danger")
    return redirect(url_for("equipment"))


@app.route("/equipment/issue", methods=["POST"])
def issue_equipment():
    try:
        equipment_id = int(request.form["equipment_id"])
        member_id = int(request.form["member_id"])
        quantity = int(request.form["quantity"])
        due_date = request.form["due_date"]

        equipment_service.issue_equipment(equipment_id, member_id, quantity, due_date)
        flash("Equipment checked out successfully! Inventory decremented.", "success")
    except Exception as e:
        flash(f"Checkout Failed: {str(e)}", "danger")
    return redirect(url_for("equipment"))


@app.route("/equipment/return", methods=["POST"])
def return_equipment():
    try:
        loan_id = int(request.form["loan_id"])
        condition = request.form.get("condition_on_return", "GOOD")
        fine = float(request.form.get("fine_amount", 0.0))

        equipment_service.return_equipment(loan_id, condition, fine)
        flash("Equipment marked as returned! Inventory restored.", "success")
    except Exception as e:
        flash(f"Error processing return: {str(e)}", "danger")
    return redirect(url_for("equipment"))


# -----------------------------------------------------------------------------
# REPORTS & ANALYTICS
# -----------------------------------------------------------------------------
@app.route("/reports")
def reports():
    tab = request.args.get("tab", "memberships")
    report_data = reports_service.get_report_data(tab)
    return render_template("reports.html", active_tab=tab, report_data=report_data)


# -----------------------------------------------------------------------------
# INTERACTIVE SQL CONSOLE
# -----------------------------------------------------------------------------
@app.route("/sql-console", methods=["GET", "POST"])
def sql_console():
    query_result = None
    default_query = "SELECT * FROM v_tournament_standings;"
    sql_input = default_query

    if request.method == "POST":
        sql_input = request.form.get("sql_query", "")
        query_result = reports_service.run_custom_query(sql_input)
    else:
        # Pre-run default view query
        query_result = reports_service.run_custom_query(default_query)

    return render_template("sql_console.html", sql_query=sql_input, result=query_result)


if __name__ == "__main__":
    app.run(debug=True, host="127.0.0.1", port=5000)
