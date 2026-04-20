package com.VMS.model;

/** One accepted event as seen from a volunteer's perspective, with attendance data. */
public class VolunteerAssignmentEntry {

    private String  eventId;
    private String  title;
    private String  location;
    private String  startsAt;
    private String  endsAt;
    private String  eventStatus;   // opened | closed
    private String  joinedAt;
    private String  markedAt;
    private boolean attended;
    private boolean hasAssignment;
    private int     pointsEarned;
    private boolean past;          // endsAt < now

    public VolunteerAssignmentEntry() {}

    public String  getEventId()                    { return eventId; }
    public void    setEventId(String v)            { eventId = v; }

    public String  getTitle()                      { return title; }
    public void    setTitle(String v)              { title = v; }

    public String  getLocation()                   { return location; }
    public void    setLocation(String v)           { location = v; }

    public String  getStartsAt()                   { return startsAt; }
    public void    setStartsAt(String v)           { startsAt = v; }

    public String  getEndsAt()                     { return endsAt; }
    public void    setEndsAt(String v)             { endsAt = v; }

    public String  getEventStatus()                { return eventStatus; }
    public void    setEventStatus(String v)        { eventStatus = v; }

    public String  getJoinedAt()                   { return joinedAt; }
    public void    setJoinedAt(String v)           { joinedAt = v; }

    public String  getMarkedAt()                   { return markedAt; }
    public void    setMarkedAt(String v)           { markedAt = v; }

    public boolean isAttended()                    { return attended; }
    public void    setAttended(boolean v)          { attended = v; }

    public boolean isHasAssignment()               { return hasAssignment; }
    public void    setHasAssignment(boolean v)     { hasAssignment = v; }

    public int     getPointsEarned()               { return pointsEarned; }
    public void    setPointsEarned(int v)          { pointsEarned = v; }

    public boolean isPast()                        { return past; }
    public void    setPast(boolean v)              { past = v; }
}
