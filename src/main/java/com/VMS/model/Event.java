package com.VMS.model;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;

public class Event {
    private String    id;
    private String    title;
    private String    description;
    private Timestamp startsAt;
    private Timestamp endsAt;
    private String    maxLimit;
    private String    status;      // DB legacy value — use getDerivedStatus() for display
    private String    location;
    private String    image;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Computed — not stored in DB, filled by DAO join
    private int    volunteerCount;
    private String myStatus; // null = not applied, "pending", "accepted", "declined"

    public Event() {}

    // ── Getters & Setters ──────────────────────────────────
    public String    getId()                       { return id; }
    public void      setId(String v)               { this.id = v; }

    public String    getTitle()                    { return title; }
    public void      setTitle(String v)            { this.title = v; }

    public String    getDescription()              { return description; }
    public void      setDescription(String v)      { this.description = v; }

    public Timestamp getStartsAt()                 { return startsAt; }
    public void      setStartsAt(Timestamp v)      { this.startsAt = v; }

    public Timestamp getEndsAt()                   { return endsAt; }
    public void      setEndsAt(Timestamp v)        { this.endsAt = v; }

    public String    getMaxLimit()                 { return maxLimit; }
    public void      setMaxLimit(String v)         { this.maxLimit = v; }

    public String    getStatus()                   { return status; }
    public void      setStatus(String v)           { this.status = v; }

    public String    getLocation()                 { return location; }
    public void      setLocation(String v)         { this.location = v; }

    public String    getImage()                    { return image; }
    public void      setImage(String v)            { this.image = v; }

    public Timestamp getCreatedAt()                { return createdAt; }
    public void      setCreatedAt(Timestamp v)     { this.createdAt = v; }

    public Timestamp getUpdatedAt()                { return updatedAt; }
    public void      setUpdatedAt(Timestamp v)     { this.updatedAt = v; }

    public int       getVolunteerCount()           { return volunteerCount; }
    public void      setVolunteerCount(int v)      { this.volunteerCount = v; }

    public String    getMyStatus()                 { return myStatus; }
    public void      setMyStatus(String v)         { this.myStatus = v; }

    // ── Helpers for JSP ───────────────────────────────────

    /** ISO-8601 for FullCalendar: "yyyy-MM-ddTHH:mm:ss" */
    public String getStartsAtISO() {
        if (startsAt == null) return "";
        return new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss").format(startsAt);
    }
    public String getEndsAtISO() {
        if (endsAt == null) return "";
        return new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss").format(endsAt);
    }

    /** Format for HTML datetime-local input: "yyyy-MM-ddTHH:mm" */
    public String getStartsAtInput() {
        if (startsAt == null) return "";
        return new SimpleDateFormat("yyyy-MM-dd'T'HH:mm").format(startsAt);
    }

    public String getEndsAtInput() {
        if (endsAt == null) return "";
        return new SimpleDateFormat("yyyy-MM-dd'T'HH:mm").format(endsAt);
    }

    /** Human-readable display: "Jan 25, 2026 14:30" */
    public String getStartsAtDisplay() {
        if (startsAt == null) return "—";
        return new SimpleDateFormat("MMM dd, yyyy HH:mm").format(startsAt);
    }

    public String getEndsAtDisplay() {
        if (endsAt == null) return "—";
        return new SimpleDateFormat("MMM dd, yyyy HH:mm").format(endsAt);
    }

    /**
     * Derives event status from its dates — fully automatic, no manual input needed.
     * upcoming : starts in the future
     * ongoing  : started but not yet ended
     * finished : end date has passed
     */
    public String getDerivedStatus() {
        Timestamp now = new Timestamp(System.currentTimeMillis());
        if (endsAt != null && endsAt.before(now))    return "finished";
        if (startsAt != null && startsAt.after(now)) return "upcoming";
        return "ongoing";
    }

    /** "25 / 100" or "25 / Unlimited" for display */
    public String getCapacityDisplay() {
        String cap = (maxLimit != null && !maxLimit.trim().isEmpty()) ? maxLimit : "Unlimited";
        return volunteerCount + " / " + cap;
    }
}
