package com.VMS.model;

import java.sql.Timestamp;

public class User {

    private String id;
    private String email;
    private String username;
    private boolean emailVerified;
    private String image;
    private String password;
    private String phone;
    private String bio;
    private String role;           // "admin", "staff", or "volunteer"
    private boolean isActive;
    private boolean twoFactorEnabled;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Default constructor
    public User() {}
    
 // ── Getters & Setters ──────────────────────────────────────

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public boolean isEmailVerified() { return emailVerified; }
    public void setEmailVerified(boolean emailVerified) { this.emailVerified = emailVerified; }

    public String getImage() { return image; }
    public void setImage(String image) { this.image = image; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getBio() { return bio; }
    public void setBio(String bio) { this.bio = bio; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean isActive) { this.isActive = isActive; }

    public boolean isTwoFactorEnabled() { return twoFactorEnabled; }
    public void setTwoFactorEnabled(boolean twoFactorEnabled) { this.twoFactorEnabled = twoFactorEnabled; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}