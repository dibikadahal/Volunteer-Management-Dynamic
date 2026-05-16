package com.VMS.model;

public class VolunteerNotification {
    private String  id;
    private String  recipientId;
    private String  actorId;
    private String  actorName;
    private String  eventId;
    private String  eventTitle;
    private String  status;        // maps to the `type` column: accepted | declined | new_registration | event_request
    private String  recipientRole; // 'volunteer' | 'admin'
    private String  message;
    private boolean isRead;
    private String  updatedAt;

    public VolunteerNotification() {}

    public String  getId()                    { return id; }
    public void    setId(String v)            { this.id = v; }

    public String  getRecipientId()           { return recipientId; }
    public void    setRecipientId(String v)   { this.recipientId = v; }

    public String  getActorId()               { return actorId; }
    public void    setActorId(String v)       { this.actorId = v; }

    public String  getActorName()             { return actorName; }
    public void    setActorName(String v)     { this.actorName = v; }

    public String  getEventId()               { return eventId; }
    public void    setEventId(String v)       { this.eventId = v; }

    public String  getEventTitle()            { return eventTitle; }
    public void    setEventTitle(String v)    { this.eventTitle = v; }

    public String  getStatus()                { return status; }
    public void    setStatus(String v)        { this.status = v; }

    public String  getRecipientRole()         { return recipientRole; }
    public void    setRecipientRole(String v) { this.recipientRole = v; }

    public String  getMessage()               { return message; }
    public void    setMessage(String v)       { this.message = v; }

    public boolean isRead()                   { return isRead; }
    public void    setRead(boolean v)         { this.isRead = v; }

    public String  getUpdatedAt()             { return updatedAt; }
    public void    setUpdatedAt(String v)     { this.updatedAt = v; }
}
