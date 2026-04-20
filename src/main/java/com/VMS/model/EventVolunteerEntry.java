package com.VMS.model;

/** Volunteer registration + attendance record for one event (admin assignments view). */
public class EventVolunteerEntry {

    private String  userId;
    private String  firstName;
    private String  lastName;
    private String  email;
    private String  phone;
    private String  image;
    private String  username;
    private String  volunteerStatus;  // pending | accepted | declined
    private boolean attended;
    private boolean hasAssignment;
    private int     pointsEarned;
    private String  markedAt;
    private String  joinedAt;

    public EventVolunteerEntry() {}

    public String  getUserId()                     { return userId; }
    public void    setUserId(String v)             { userId = v; }

    public String  getFirstName()                  { return firstName; }
    public void    setFirstName(String v)          { firstName = v; }

    public String  getLastName()                   { return lastName; }
    public void    setLastName(String v)           { lastName = v; }

    public String  getEmail()                      { return email; }
    public void    setEmail(String v)              { email = v; }

    public String  getPhone()                      { return phone; }
    public void    setPhone(String v)              { phone = v; }

    public String  getImage()                      { return image; }
    public void    setImage(String v)              { image = v; }

    public String  getUsername()                   { return username; }
    public void    setUsername(String v)           { username = v; }

    public String  getVolunteerStatus()            { return volunteerStatus; }
    public void    setVolunteerStatus(String v)    { volunteerStatus = v; }

    public boolean isAttended()                    { return attended; }
    public void    setAttended(boolean v)          { attended = v; }

    public boolean isHasAssignment()               { return hasAssignment; }
    public void    setHasAssignment(boolean v)     { hasAssignment = v; }

    public int     getPointsEarned()               { return pointsEarned; }
    public void    setPointsEarned(int v)          { pointsEarned = v; }

    public String  getMarkedAt()                   { return markedAt; }
    public void    setMarkedAt(String v)           { markedAt = v; }

    public String  getJoinedAt()                   { return joinedAt; }
    public void    setJoinedAt(String v)           { joinedAt = v; }

    public String getFullName() {
        String f = firstName != null ? firstName.trim() : "";
        String l = lastName  != null ? lastName.trim()  : "";
        if (!f.isEmpty() && !l.isEmpty()) return f + " " + l;
        if (!f.isEmpty()) return f;
        if (!l.isEmpty()) return l;
        return username != null ? username : "";
    }

    public String getInitials() {
        String f = firstName != null && !firstName.isEmpty() ? firstName : "";
        String l = lastName  != null && !lastName.isEmpty()  ? lastName  : "";
        if (!f.isEmpty() && !l.isEmpty())
            return String.valueOf(f.charAt(0)).toUpperCase()
                 + String.valueOf(l.charAt(0)).toUpperCase();
        if (!f.isEmpty()) return String.valueOf(f.charAt(0)).toUpperCase();
        return username != null && !username.isEmpty()
            ? String.valueOf(username.charAt(0)).toUpperCase() : "V";
    }
}
