import uuid
import random
import datetime

# Configuration
NUM_OFFICERS = 50
NUM_SUSPECTS = 200
NUM_CASES = 500
NUM_EVIDENCE = 1000

# Data Pools
FIRST_NAMES = ["James", "Mary", "John", "Patricia", "Robert", "Jennifer", "Michael", "Linda", "William", "Elizabeth", "David", "Barbara", "Richard", "Susan", "Joseph", "Jessica", "Thomas", "Sarah", "Charles", "Karen"]
LAST_NAMES = ["Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis", "Rodriguez", "Martinez", "Hernandez", "Lopez", "Gonzalez", "Wilson", "Anderson", "Thomas", "Taylor", "Moore", "Jackson", "Martin"]
RANKS = ["OFFICER", "DETECTIVE", "SERGEANT", "LIEUTENANT", "CAPTAIN"]
UNITS = ["PATROL", "HOMICIDE", "NARCOTICS", "CYBER", "VICE", "TRAFFIC"]
CRIME_TYPES = ["Burglary", "Assault", "Robbery", "Fraud", "Homicide", "Cyberstalking", "Grand Theft Auto", "Vandalism"]
LOCATIONS = ["123 Main St", "456 Oak Ave", "789 Pine Ln", "Central Park", "Downtown Metro", "Suburbia Mall", "Industrial District", "Harbor Warehouse"]
STATUSES = ["OPEN", "IN_PROGRESS", "CLOSED", "COLD"]
EVIDENCE_TYPES = ["WEAPON", "DOCUMENT", "DIGITAL", "BIOLOGICAL", "TRACE"]

def gen_uuid():
    return str(uuid.uuid4())

def random_date(start_year=2020, end_year=2023):
    start = datetime.date(start_year, 1, 1)
    end = datetime.date(end_year, 12, 31)
    return start + (end - start) * random.random()

def escape_sql(text):
    return text.replace("'", "''")

def main():
    print("-- GENERATED SEED DATA")
    print("BEGIN;") # Transaction start for speed

    officer_ids = []
    suspect_ids = []
    case_ids = []

    # 1. Generate Officers
    print("\n-- OFFICERS")
    for i in range(NUM_OFFICERS):
        oid = gen_uuid()
        officer_ids.append(oid)
        badge = f"BADGE-{1000+i}"
        fname = random.choice(FIRST_NAMES)
        lname = random.choice(LAST_NAMES)
        rank = random.choice(RANKS)
        unit = random.choice(UNITS)
        print(f"INSERT INTO officers (officer_id, badge_number, first_name, last_name, rank, unit) VALUES ('{oid}', '{badge}', '{fname}', '{lname}', '{rank}', '{unit}');")

    # 2. Generate Suspects
    print("\n-- SUSPECTS")
    for i in range(NUM_SUSPECTS):
        sid = gen_uuid()
        suspect_ids.append(sid)
        fname = random.choice(FIRST_NAMES)
        lname = random.choice(LAST_NAMES)
        dob = random_date(1970, 2005)
        risk = random.choice(["LOW", "MEDIUM", "HIGH", "CRITICAL"])
        print(f"INSERT INTO suspects (suspect_id, first_name, last_name, date_of_birth, risk_level) VALUES ('{sid}', '{fname}', '{lname}', '{dob}', '{risk}');")

    # 3. Generate Cases
    print("\n-- CASES")
    for i in range(NUM_CASES):
        cid = gen_uuid()
        case_ids.append(cid)
        cnum = f"CASE-{2023}-{i:07d}"
        title = f"{random.choice(CRIME_TYPES)} at {random.choice(LOCATIONS)}"
        desc = f"Investigation into {title.lower()}. Suspects fled scene."
        status = random.choice(STATUSES)
        priority = random.choice(["LOW", "NORMAL", "HIGH"])
        lead = random.choice(officer_ids)
        inc_date = random_date(2023, 2023)
        print(f"INSERT INTO cases (case_id, case_number, title, description, status, priority, lead_officer_id, incident_date) VALUES ('{cid}', '{cnum}', '{escape_sql(title)}', '{escape_sql(desc)}', '{status}', '{priority}', '{lead}', '{inc_date} 12:00:00');")

    # 4. Generate Evidence
    print("\n-- EVIDENCE")
    for i in range(NUM_EVIDENCE):
        eid = gen_uuid()
        case_id = random.choice(case_ids)
        etype = random.choice(EVIDENCE_TYPES)
        desc = f"Found {etype.lower()} at scene."
        loc = "Evidence Locker A"
        col_by = random.choice(officer_ids)
        print(f"INSERT INTO evidence (evidence_id, case_id, item_type, description, storage_location, collected_by) VALUES ('{eid}', '{case_id}', '{etype}', '{desc}', '{loc}', '{col_by}');")

    # 5. Generate Case Suspects
    print("\n-- CASE SUSPECTS")
    for cid in case_ids:
        if random.random() > 0.3: # 70% chance a case has a suspect
            sid = random.choice(suspect_ids)
            print(f"INSERT INTO case_suspects (case_id, suspect_id, role) VALUES ('{cid}', '{sid}', 'PRIMARY_SUSPECT');")

    # 6. Generate Case Notes (New)
    print("\n-- CASE NOTES")
    for cid in case_ids:
        for _ in range(random.randint(1, 5)):
            nid = gen_uuid()
            oid = random.choice(officer_ids)
            note = f"Investigator note: {random.choice(['Interviewed witness', 'Checked surveillance', 'Received lab report', 'Canvassed area'])}."
            print(f"INSERT INTO case_notes (note_id, case_id, officer_id, note_text) VALUES ('{nid}', '{cid}', '{oid}', '{note}');")

    # 7. Generate Victims (New)
    print("\n-- VICTIMS")
    for cid in case_ids:
        if random.random() > 0.5:
            vid = gen_uuid()
            fname = random.choice(FIRST_NAMES)
            lname = random.choice(LAST_NAMES)
            print(f"INSERT INTO victims (victim_id, case_id, first_name, last_name) VALUES ('{vid}', '{cid}', '{fname}', '{lname}');")

    # 8. Generate Warrants (New)
    print("\n-- WARRANTS")
    for cid in case_ids:
        if random.random() > 0.8: # 20% chance of warrant
            wid = gen_uuid()
            wtype = random.choice(["SEARCH", "ARREST"])
            judge = "Hon. Judge Dredd"
            print(f"INSERT INTO warrants (warrant_id, case_id, warrant_type, issued_by_judge, description) VALUES ('{wid}', '{cid}', '{wtype}', '{judge}', 'Warrant issued for investigation');")


    print("COMMIT;")

if __name__ == "__main__":
    main()
