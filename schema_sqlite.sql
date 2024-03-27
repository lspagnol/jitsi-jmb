CREATE TABLE meetings (
	meeting_id INTEGER PRIMARY KEY,
	meeting_name TEXT NOT NULL,
	meeting_object TEXT NOT NULL,
	meeting_begin INTEGER NOT NULL,
	meeting_duration INTEGER NOT NULL,
	meeting_end INTEGER NOT NULL,
	meeting_create INTEGER NOT NULL
);
CREATE INDEX idx_meeting_name ON meetings(meeting_name);
CREATE INDEX idx_meeting_begin ON meetings(meeting_begin);
CREATE INDEX idx_meeting_end ON meetings(meeting_end);


CREATE TABLE attendees (
	attendee_id INTEGER PRIMARY KEY AUTOINCREMENT,
	attendee_meeting_id INTEGER,
	attendee_meeting_hash TEXT,
	attendee_role TEXT NOT NULL,
	attendee_email TEXT NOT NULL,
	attendee_count INTEGER DEFAULT 0,
	attendee_partstat INTEGER DEFAULT 0
);
CREATE INDEX idx_attendee_meeting_id ON attendees(attendee_meeting_id);
CREATE INDEX idx_attendee_meeting_hash ON attendees(attendee_meeting_hash);
CREATE INDEX idx_attendee_role ON attendees(attendee_role);
CREATE INDEX idx_attendee_email ON attendees(attendee_email);
CREATE INDEX idx_attendee_partstat ON attendees(attendee_partstat);


CREATE TABLE mail_reminder (
	mail_reminder_id INTEGER PRIMARY KEY AUTOINCREMENT,
	mail_reminder_meeting_id INTEGER NOT NULL,
	mail_reminder_date INTEGER NOT NULL,
	mail_reminder_done BOOLEAN
);
CREATE INDEX idx_mail_reminder_meeting_id ON mail_reminder(mail_reminder_meeting_id);
CREATE INDEX idx_mail_reminder_date ON mail_reminder(mail_reminder_date);
CREATE INDEX idx_mail_reminder_done ON mail_reminder(mail_reminder_done);


CREATE TABLE xmpp_reminder (
	xmpp_reminder_id INTEGER PRIMARY KEY AUTOINCREMENT,
	xmpp_reminder_meeting_id INTEGER NOT NULL,
	xmpp_reminder_date INTEGER NOT NULL,
	xmpp_reminder_done BOOLEAN
);
CREATE INDEX idx_xmpp_reminder_meeting_id ON xmpp_reminder(xmpp_reminder_meeting_id);
CREATE INDEX idx_xmpp_reminder_date ON xmpp_reminder(xmpp_reminder_date);
CREATE INDEX idx_xmpp_reminder_done ON xmpp_reminder(xmpp_reminder_done);


CREATE TABLE ical (
	ical_id INTEGER PRIMARY KEY AUTOINCREMENT,
	ical_owner TEXT NOT NULL,
	ical_hash TEXT NOT NULL
);
CREATE INDEX idx_ical_owner ON ical(ical_owner);
CREATE INDEX idx_ical_hash ON ical(ical_hash);


CREATE TABLE private (
	private_id INTEGER PRIMARY KEY AUTOINCREMENT,
	private_room TEXT NOT NULL,
	private_date INTEGER NOT NULL,
	private_count INTEGER DEFAULT 0
);
CREATE INDEX idx_private_room ON private(private_room);


CREATE TRIGGER delete_meeting AFTER DELETE ON meetings
BEGIN
	DELETE FROM attendees WHERE attendee_meeting_id = old.meeting_id;
	DELETE FROM mail_reminder WHERE mail_reminder_meeting_id = old.meeting_id;
	DELETE FROM xmpp_reminder WHERE xmpp_reminder_meeting_id = old.meeting_id;
END;
