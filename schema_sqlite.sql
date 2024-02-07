CREATE TABLE meetings (
	meeting_id INTEGER PRIMARY KEY,
	meeting_name TEXT NOT NULL,
	meeting_object TEXT NOT NULL,
	meeting_begin INTEGER NOT NULL,
	meeting_duration INTEGER NOT NULL,
	meeting_end INTEGER NOT NULL
);

CREATE TABLE attendees (
	attendee_id INTEGER PRIMARY KEY AUTOINCREMENT,
	attendee_meeting_id INTEGER,
	attendee_meeting_hash TEXT,
	attendee_role TEXT NOT NULL,
	attendee_email NOT NULL,
	attendee_count INTEGER
);

CREATE TABLE mail_reminder (
	mail_reminder_id INTEGER PRIMARY KEY AUTOINCREMENT,
	mail_reminder_meeting_id INTEGER NOT NULL,
	mail_reminder_date INTEGER NOT NULL,
	mail_reminder_done BOOLEAN
);

CREATE TABLE xmpp_reminder (
	xmpp_reminder_id INTEGER PRIMARY KEY AUTOINCREMENT,
	xmpp_reminder_meeting_id INTEGER NOT NULL,
	xmpp_reminder_date INTEGER NOT NULL,
	xmpp_reminder_done BOOLEAN
);

CREATE TABLE ical (
	ical_id INTEGER PRIMARY KEY AUTOINCREMENT,
	ical_owner TEXT NOT NULL,
	ical_hash TEXT NOT NULL
);

CREATE TRIGGER delete_meeting AFTER DELETE ON meetings
BEGIN
	DELETE FROM attendees WHERE attendee_meeting_id = old.meeting_id;
	DELETE FROM mail_reminder WHERE mail_reminder_meeting_id = old.meeting_id;
	DELETE FROM xmpp_reminder WHERE xmpp_reminder_meeting_id = old.meeting_id;
END;
