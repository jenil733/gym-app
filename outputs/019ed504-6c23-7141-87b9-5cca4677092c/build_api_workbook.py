from __future__ import annotations

import html
import os
import zipfile
from datetime import datetime, timezone
from pathlib import Path
from xml.etree import ElementTree as ET


OUTPUT_DIR = Path(__file__).resolve().parent
OUTPUT_FILE = OUTPUT_DIR / "gym_api_list.xlsx"


api_rows = [
    ("Splash Screen", "Get App Bootstrap Config - /app/bootstrap", "GET", "app_version, platform"),
    ("Onboarding", "Save Onboarding Status - /users/onboarding", "PATCH", "user_id or device_id, onboarding_completed"),
    ("Login", "Send Login OTP - /auth/send-otp", "POST", "phone, purpose=login"),
    ("Sign Up", "Register User - /auth/register", "POST", "name, phone, gender, place, dob"),
    ("Sign Up", "Send Signup OTP - /auth/send-otp", "POST", "phone, purpose=signup"),
    ("OTP Verification", "Verify OTP - /auth/verify-otp", "POST", "phone, otp, purpose, device_id, fcm_token"),
    ("OTP Verification", "Resend OTP - /auth/resend-otp", "POST", "phone, purpose"),
    ("Main Navigation", "Get Session Summary - /users/me/summary", "GET", "user_id"),
    ("Home", "Get Dashboard Summary - /dashboard", "GET", "user_id, date"),
    ("Home", "Get Activity Stats History - /stats/history", "GET", "user_id, metric, date_range"),
    ("Home", "Get Body Metric History - /body-metrics/history", "GET", "user_id, metric, date_range"),
    ("Notifications", "Get Notifications - /notifications", "GET", "user_id, page, limit"),
    ("Notifications", "Mark Notification Read - /notifications/{notification_id}/read", "PATCH", "user_id, notification_id"),
    ("Workout", "Get Workout Categories - /workouts/categories", "GET", "user_id, level, search"),
    ("Workout", "Get Today Workout Plan - /workouts/today", "GET", "user_id, date"),
    ("Workout Category", "Get Workout Category Detail - /workouts/categories/{category_id}", "GET", "category_id"),
    ("Workout Category", "Add Workout To Today Plan - /workouts/today", "POST", "user_id, category_id, date"),
    ("Workout Category", "Remove Workout From Today Plan - /workouts/today/{category_id}", "DELETE", "user_id, category_id, date"),
    ("Choose Workout", "Get Exercises By Category - /workouts/categories/{category_id}/exercises", "GET", "category_id"),
    ("Choose Workout", "Start Workout Session - /workout-sessions", "POST", "user_id, category_id, exercise_id optional, started_at"),
    ("Workout Timer", "Update Workout Session Timer - /workout-sessions/{session_id}", "PATCH", "session_id, elapsed_seconds, status"),
    ("Workout Timer", "Finish Workout Session - /workout-sessions/{session_id}/finish", "PATCH", "session_id, ended_at, duration_seconds, calories, completed_exercise_ids"),
    ("Diet Plan", "Get Diet Plans - /diet-plans", "GET", "user_id, goal"),
    ("Diet Plan", "Select Diet Plan - /diet-plans/select", "POST", "user_id, diet_plan_id, effective_date"),
    ("Meal Detail", "Get Meal Detail - /diet-plans/meals/{meal_id}", "GET", "meal_id"),
    ("Meal Detail", "Mark Meal Complete - /diet-logs", "POST", "user_id, meal_id, date, status"),
    ("Progress", "Get Progress Summary - /progress/summary", "GET", "user_id, date_range"),
    ("Progress - Water Level", "Log Water Intake - /water/logs", "POST", "user_id, date, amount_liters"),
    ("Progress - Water Level", "Set Daily Water Level - /water/daily-level", "PUT", "user_id, date, drank_liters"),
    ("Progress - Water Level", "Update Water Goal And Reminder - /water/settings", "PATCH", "user_id, daily_goal_liters, reminder_enabled"),
    ("Progress - Weight", "Log Weight - /weight/logs", "POST", "user_id, date, weight_kg"),
    ("Profile", "Get Profile - /users/me", "GET", "user_id"),
    ("Personal Information", "Update Personal Information - /users/me", "PATCH", "user_id, name, gender, height_cm, location, profile_image_id"),
    ("Personal Information", "Upload Profile Photo - /users/me/profile-photo", "POST", "user_id, image_file or profile_image_id"),
    ("Fitness Goal", "Get Fitness Goal - /users/me/fitness-goal", "GET", "user_id"),
    ("Fitness Goal", "Update Fitness Goal - /users/me/fitness-goal", "PATCH", "user_id, fitness_goal, weekly_workout_target, target_weight_kg, daily_water_target_liters, level"),
    ("Settings", "Get Settings - /settings", "GET", "user_id"),
    ("Settings", "Update Settings - /settings", "PATCH", "user_id, push_notifications, water_reminder, workout_reminder"),
    ("Choose Plan", "Get Membership Plans - /membership/plans", "GET", "user_id"),
    ("Choose Plan", "Create Payment Order - /payments/orders", "POST", "user_id, plan_id, payment_method, coupon_code optional, reward_token_id optional"),
    ("Choose Plan", "Verify Payment - /payments/verify", "POST", "order_id, payment_id, signature, user_id"),
    ("Achievement", "Get Achievements And Rewards - /rewards", "GET", "user_id"),
    ("Achievement", "Update Task Completion - /rewards/tasks/{task_id}", "PATCH", "user_id, task_id, completed"),
    ("Achievement", "Redeem Offer - /rewards/redeem", "POST", "user_id, offer_id, token_amount"),
    ("Trainer Booking", "Get Trainers - /trainers", "GET", "specialty, date, location"),
    ("Trainer Booking", "Book Trainer - /trainer-bookings", "POST", "user_id, trainer_id, slot_id, payment_method"),
    ("Profile", "Logout - /auth/logout", "POST", "user_id, refresh_token or device_id"),
]


summary_rows = [
    ("Network packages", "No http, dio, Firebase, Supabase, GraphQL, sqflite, hive, or similar network/data package is present in pubspec.yaml."),
    ("Active network calls", "No active Uri.parse, Dio, http client, REST annotation, GraphQL, Firebase, or MethodChannel API call was found under lib/."),
    ("Current data source", "The app currently uses hardcoded/static data in GetX controllers and local widget state."),
    ("Commented repository", "lib/scr/data/repository/interest_repository.dart contains only commented sample Future.delayed methods; it is not active app API code."),
    ("Workbook interpretation", "The API List sheet is a suggested backend API list inferred from existing screens and user flows, not a list of implemented network calls."),
]


def column_name(index: int) -> str:
    name = ""
    while index:
        index, remainder = divmod(index - 1, 26)
        name = chr(65 + remainder) + name
    return name


def cell(ref: str, value: str, style: int) -> str:
    escaped = html.escape(value, quote=False)
    return f'<c r="{ref}" s="{style}" t="inlineStr"><is><t>{escaped}</t></is></c>'


def row_xml(row_index: int, values: list[str], style: int, height: int | None = None) -> str:
    attrs = f' r="{row_index}"'
    if height is not None:
        attrs += f' ht="{height}" customHeight="1"'
    cells = "".join(
        cell(f"{column_name(col_index)}{row_index}", value, style)
        for col_index, value in enumerate(values, start=1)
    )
    return f"<row{attrs}>{cells}</row>"


def worksheet_xml(title: str, subtitle: str, headers: list[str], data: list[tuple[str, ...]], widths: list[int]) -> str:
    sheet_rows = [
        row_xml(1, [title], 1, 26),
        row_xml(2, [subtitle], 4, 40),
        row_xml(4, headers, 2, 24),
    ]

    for offset, row in enumerate(data, start=5):
        sheet_rows.append(row_xml(offset, list(row), 3, 42))

    last_row = len(data) + 4
    cols = "".join(
        f'<col min="{idx}" max="{idx}" width="{width}" customWidth="1"/>'
        for idx, width in enumerate(widths, start=1)
    )
    sheet_data = "".join(sheet_rows)
    return f'''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
  <sheetViews>
    <sheetView workbookViewId="0">
      <pane ySplit="4" topLeftCell="A5" activePane="bottomLeft" state="frozen"/>
      <selection pane="bottomLeft" activeCell="A5" sqref="A5"/>
    </sheetView>
  </sheetViews>
  <sheetFormatPr defaultRowHeight="15"/>
  <cols>{cols}</cols>
  <sheetData>{sheet_data}</sheetData>
  <autoFilter ref="A4:{column_name(len(headers))}{last_row}"/>
  <mergeCells count="2">
    <mergeCell ref="A1:{column_name(len(headers))}1"/>
    <mergeCell ref="A2:{column_name(len(headers))}2"/>
  </mergeCells>
  <pageMargins left="0.7" right="0.7" top="0.75" bottom="0.75" header="0.3" footer="0.3"/>
</worksheet>'''


def write_file(zf: zipfile.ZipFile, name: str, content: str) -> None:
    zf.writestr(name, content.encode("utf-8"))


def build_xlsx() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    now = datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")

    api_sheet = worksheet_xml(
        "GYM App Suggested API List",
        "Based on the current Flutter screens. Code scan found no implemented network calls, so these are backend APIs to build/connect.",
        ["Screen Name", "API Name", "Method", "Parameter"],
        api_rows,
        [24, 52, 14, 64],
    )

    summary_sheet = worksheet_xml(
        "Code Scan Summary",
        "Evidence from scanning pubspec.yaml, lib/, controllers, routes, and repository files.",
        ["Check", "Finding"],
        summary_rows,
        [28, 110],
    )

    with zipfile.ZipFile(OUTPUT_FILE, "w", compression=zipfile.ZIP_DEFLATED) as zf:
        write_file(
            zf,
            "[Content_Types].xml",
            '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/docProps/app.xml" ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"/>
  <Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>
  <Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>
  <Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>
  <Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>
  <Override PartName="/xl/worksheets/sheet2.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>
</Types>''',
        )
        write_file(
            zf,
            "_rels/.rels",
            '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>
  <Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties" Target="docProps/app.xml"/>
</Relationships>''',
        )
        write_file(
            zf,
            "docProps/core.xml",
            f'''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:dcmitype="http://purl.org/dc/dcmitype/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <dc:title>GYM App API List</dc:title>
  <dc:creator>Codex</dc:creator>
  <cp:lastModifiedBy>Codex</cp:lastModifiedBy>
  <dcterms:created xsi:type="dcterms:W3CDTF">{now}</dcterms:created>
  <dcterms:modified xsi:type="dcterms:W3CDTF">{now}</dcterms:modified>
</cp:coreProperties>''',
        )
        write_file(
            zf,
            "docProps/app.xml",
            '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties" xmlns:vt="http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes">
  <Application>Codex</Application>
  <DocSecurity>0</DocSecurity>
  <ScaleCrop>false</ScaleCrop>
  <HeadingPairs><vt:vector size="2" baseType="variant"><vt:variant><vt:lpstr>Worksheets</vt:lpstr></vt:variant><vt:variant><vt:i4>2</vt:i4></vt:variant></vt:vector></HeadingPairs>
  <TitlesOfParts><vt:vector size="2" baseType="lpstr"><vt:lpstr>API List</vt:lpstr><vt:lpstr>Code Scan Summary</vt:lpstr></vt:vector></TitlesOfParts>
  <Company/>
  <LinksUpToDate>false</LinksUpToDate>
  <SharedDoc>false</SharedDoc>
  <HyperlinksChanged>false</HyperlinksChanged>
  <AppVersion>16.0300</AppVersion>
</Properties>''',
        )
        write_file(
            zf,
            "xl/workbook.xml",
            '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
  <bookViews><workbookView xWindow="0" yWindow="0" windowWidth="24000" windowHeight="15000"/></bookViews>
  <sheets>
    <sheet name="API List" sheetId="1" r:id="rId1"/>
    <sheet name="Code Scan Summary" sheetId="2" r:id="rId2"/>
  </sheets>
</workbook>''',
        )
        write_file(
            zf,
            "xl/_rels/workbook.xml.rels",
            '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet2.xml"/>
  <Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
</Relationships>''',
        )
        write_file(
            zf,
            "xl/styles.xml",
            '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
  <fonts count="3">
    <font><sz val="11"/><color theme="1"/><name val="Calibri"/><family val="2"/></font>
    <font><b/><sz val="16"/><color rgb="FFFFFFFF"/><name val="Calibri"/><family val="2"/></font>
    <font><b/><sz val="11"/><color rgb="FFFFFFFF"/><name val="Calibri"/><family val="2"/></font>
  </fonts>
  <fills count="5">
    <fill><patternFill patternType="none"/></fill>
    <fill><patternFill patternType="gray125"/></fill>
    <fill><patternFill patternType="solid"><fgColor rgb="FF18332F"/><bgColor indexed="64"/></patternFill></fill>
    <fill><patternFill patternType="solid"><fgColor rgb="FF0F766E"/><bgColor indexed="64"/></patternFill></fill>
    <fill><patternFill patternType="solid"><fgColor rgb="FFEFF7F4"/><bgColor indexed="64"/></patternFill></fill>
  </fills>
  <borders count="2">
    <border><left/><right/><top/><bottom/><diagonal/></border>
    <border>
      <left style="thin"><color rgb="FFD9E2E0"/></left>
      <right style="thin"><color rgb="FFD9E2E0"/></right>
      <top style="thin"><color rgb="FFD9E2E0"/></top>
      <bottom style="thin"><color rgb="FFD9E2E0"/></bottom>
      <diagonal/>
    </border>
  </borders>
  <cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs>
  <cellXfs count="5">
    <xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/>
    <xf numFmtId="0" fontId="1" fillId="2" borderId="0" xfId="0" applyFont="1" applyFill="1" applyAlignment="1"><alignment horizontal="center" vertical="center"/></xf>
    <xf numFmtId="0" fontId="2" fillId="3" borderId="1" xfId="0" applyFont="1" applyFill="1" applyBorder="1" applyAlignment="1"><alignment horizontal="center" vertical="center" wrapText="1"/></xf>
    <xf numFmtId="0" fontId="0" fillId="0" borderId="1" xfId="0" applyBorder="1" applyAlignment="1"><alignment vertical="top" wrapText="1"/></xf>
    <xf numFmtId="0" fontId="0" fillId="4" borderId="1" xfId="0" applyFill="1" applyBorder="1" applyAlignment="1"><alignment vertical="top" wrapText="1"/></xf>
  </cellXfs>
  <cellStyles count="1"><cellStyle name="Normal" xfId="0" builtinId="0"/></cellStyles>
  <dxfs count="0"/>
  <tableStyles count="0" defaultTableStyle="TableStyleMedium2" defaultPivotStyle="PivotStyleLight16"/>
</styleSheet>''',
        )
        write_file(zf, "xl/worksheets/sheet1.xml", api_sheet)
        write_file(zf, "xl/worksheets/sheet2.xml", summary_sheet)


def validate_xlsx() -> None:
    required = {
        "[Content_Types].xml",
        "_rels/.rels",
        "xl/workbook.xml",
        "xl/_rels/workbook.xml.rels",
        "xl/styles.xml",
        "xl/worksheets/sheet1.xml",
        "xl/worksheets/sheet2.xml",
    }
    with zipfile.ZipFile(OUTPUT_FILE, "r") as zf:
        names = set(zf.namelist())
        missing = sorted(required - names)
        if missing:
            raise RuntimeError(f"Missing xlsx parts: {missing}")
        for name in required:
            ET.fromstring(zf.read(name))

    size = os.path.getsize(OUTPUT_FILE)
    if size < 4000:
        raise RuntimeError(f"Workbook looks too small: {size} bytes")


if __name__ == "__main__":
    build_xlsx()
    validate_xlsx()
    print(OUTPUT_FILE)
