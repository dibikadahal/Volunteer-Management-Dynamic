package com.VMS.model;

import java.sql.Timestamp;

public class User {
    private String    id;
    private String    firstName;
    private String    lastName;
    private String    email;
    private String    username;
    private String    password;
    private String    phone;
    private String    bio;
    private String    image;
    private String    role;
    private boolean   isActive;
    private Timestamp createdAt;

    // ── Constructors ──
    public User() {}

    public User(String email, String username, String password) {
        this.email    = email;
        this.username = username;
        this.password = password;
    }

    // ── Getters & Setters ──
    public String getId()                     { return id; }
    public void   setId(String id)            { this.id = id; }

    public String getFirstName()              { return firstName; }
    public void   setFirstName(String v)      { this.firstName = v; }

    public String getLastName()               { return lastName; }
    public void   setLastName(String v)       { this.lastName = v; }

    public String getEmail()                  { return email; }
    public void   setEmail(String v)          { this.email = v; }

    public String getUsername()               { return username; }
    public void   setUsername(String v)       { this.username = v; }

    public String getPassword()               { return password; }
    public void   setPassword(String v)       { this.password = v; }

    public String getPhone()                  { return phone; }
    public void   setPhone(String v)          { this.phone = v; }

    public String getBio()                    { return bio; }
    public void   setBio(String v)            { this.bio = v; }

    public String getImage()                  { return image; }
    public void   setImage(String v)          { this.image = v; }

    public String getRole()                   { return role; }
    public void   setRole(String v)           { this.role = v; }

    public boolean getIsActive()              { return isActive; }
    public void    setIsActive(boolean v)     { this.isActive = v; }

    public Timestamp getCreatedAt()           { return createdAt; }
    public void      setCreatedAt(Timestamp v){ this.createdAt = v; }

    // ── Helper: full name ──
    public String getFullName() {
        String f = firstName != null ? firstName.trim() : "";
        String l = lastName  != null ? lastName.trim()  : "";
        if (!f.isEmpty() && !l.isEmpty()) return f + " " + l;
        if (!f.isEmpty()) return f;
        if (!l.isEmpty()) return l;
        return username;
    }

    // ── Helper: initials for avatar fallback ──
    public String getInitials() {
        String f = firstName != null && !firstName.isEmpty() ? firstName : "";
        String l = lastName  != null && !lastName.isEmpty()  ? lastName  : "";
        if (!f.isEmpty() && !l.isEmpty())
            return String.valueOf(f.charAt(0)).toUpperCase()
                 + String.valueOf(l.charAt(0)).toUpperCase();
        if (!f.isEmpty()) return String.valueOf(f.charAt(0)).toUpperCase();
        return username != null && !username.isEmpty()
            ? String.valueOf(username.charAt(0)).toUpperCase() : "U";
    }
}