package com.VMS.model;

public class VolunteerNotification {
    private String eventId;
    private String eventTitle;
    private String status;    // "accepted" or "declined"
    private String updatedAt; // formatted date string

    public VolunteerNotification() {}

    public String getEventId()    { return eventId; }
    public void   setEventId(String v)    { this.eventId = v; }

    public String getEventTitle() { return eventTitle; }
    public void   setEventTitle(String v) { this.eventTitle = v; }

    public String getStatus()     { return status; }
    public void   setStatus(String v)     { this.status = v; }

    public String getUpdatedAt()  { return updatedAt; }
    public void   setUpdatedAt(String v)  { this.updatedAt = v; }
}
