package com.VMS.model;

/** Represents one event row as seen from a specific volunteer's perspective. */
public class VolunteerEventEntry {
    private String eventId;
    private String title;
    private String location;
    private String startsAt;        // formatted display string
    private String endsAt;          // formatted display string
    private String eventStatus;     // "opened" | "closed"
    private String volunteerStatus; // "pending" | "accepted" | "declined"
    private String joinedAt;        // formatted display string

    public VolunteerEventEntry() {}

    public String getEventId()          { return eventId; }
    public void   setEventId(String v)          { this.eventId = v; }

    public String getTitle()            { return title; }
    public void   setTitle(String v)            { this.title = v; }

    public String getLocation()         { return location; }
    public void   setLocation(String v)         { this.location = v; }

    public String getStartsAt()         { return startsAt; }
    public void   setStartsAt(String v)         { this.startsAt = v; }

    public String getEndsAt()           { return endsAt; }
    public void   setEndsAt(String v)           { this.endsAt = v; }

    public String getEventStatus()      { return eventStatus; }
    public void   setEventStatus(String v)      { this.eventStatus = v; }

    public String getVolunteerStatus()  { return volunteerStatus; }
    public void   setVolunteerStatus(String v)  { this.volunteerStatus = v; }

    public String getJoinedAt()         { return joinedAt; }
    public void   setJoinedAt(String v)         { this.joinedAt = v; }
}
