<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.VMS.model.User, java.text.SimpleDateFormat" %>
<%
    User user = (User) request.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    String fullName  = user.getFullName();
    String initials  = user.getInitials();
    String joinedStr = "";
    if (user.getCreatedAt() != null) {
        joinedStr = new SimpleDateFormat("MMMM dd, yyyy").format(user.getCreatedAt());
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile – VolunteerHub</title>
    <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/volunteer.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/profile.css">
</head>
<body>

<!-- ══ SIDEBAR ══ -->
<aside class="sidebar">
    <div class="sidebar-logo">
        <div class="logo-icon">&#9825;</div>
        <span>VolunteerHub</span>
    </div>
    <div class="sidebar-section-label">Main Menu</div>
    <a href="${pageContext.request.contextPath}/volunteer/dashboard" class="nav-item">
        <i class="fas fa-th-large"></i> Dashboard
    </a>
    <div class="sidebar-section-label">Events</div>
    <a href="${pageContext.request.contextPath}/volunteer/browse-events" class="nav-item">
        <i class="fas fa-calendar-alt"></i> Browse Events
    </a>
    <a href="${pageContext.request.contextPath}/volunteer/my-events" class="nav-item">
        <i class="fas fa-heart"></i> My Events
    </a>
    <div class="sidebar-section-label">Account</div>
    <a href="${pageContext.request.contextPath}/volunteer/profile" class="nav-item active">
        <i class="fas fa-user-circle"></i> My Profile
    </a>
    <div class="sidebar-bottom">
        <a href="${pageContext.request.contextPath}/logout" class="nav-item logout-link">
            <i class="fas fa-sign-out-alt"></i> Logout
        </a>
    </div>
</aside>

<!-- ══ MAIN ══ -->
<div class="main">

    <!-- Topbar -->
    <div class="topbar">
        <div class="topbar-left">
            <h2>My Profile</h2>
            <p>View and update your personal information</p>
        </div>
        <div class="topbar-right">
            <div class="topbar-icon-btn">
                <i class="fas fa-bell"></i>
                <span class="notif-dot"></span>
            </div>
            <div class="vol-avatar"><%= initials %></div>
        </div>
    </div>

    <!-- Page Body -->
    <div class="page-body">

        <form action="${pageContext.request.contextPath}/volunteer/profile"
              method="POST" enctype="multipart/form-data" id="profileForm">

            <!-- ══ PROFILE CARD ══ -->
            <div class="profile-card">

                <!-- Photo Section -->
                <div class="photo-section">
                    <div class="avatar-wrap" id="avatarWrap">
                        <% if (user.getImage() != null && !user.getImage().isEmpty()) { %>
                            <img src="${pageContext.request.contextPath}/<%= user.getImage() %>"
                                 alt="Profile Photo" class="avatar-img" id="avatarPreview">
                        <% } else { %>
                            <div class="avatar-initials" id="avatarInitials"><%= initials %></div>
                            <img src="" alt="" class="avatar-img" id="avatarPreview" style="display:none;">
                        <% } %>
                        <label for="profilePhoto" class="avatar-edit-btn" title="Change photo">
                            <i class="fas fa-camera"></i>
                        </label>
                    </div>
                    <input type="file" id="profilePhoto" name="profilePhoto"
                           accept="image/jpeg,image/png,image/gif,image/webp"
                           style="display:none;" onchange="previewPhoto(this)">
                    <p class="photo-hint">Click the camera icon to upload a photo<br>
                       <small>JPG, PNG, GIF or WEBP &nbsp;&middot;&nbsp; Max 2MB</small></p>
                </div>

                <!-- Name & Role display -->
                <div class="profile-identity">
                    <h2 class="profile-fullname"><%= fullName %></h2>
                    <p class="profile-username">@<%= user.getUsername() %></p>
                    <span class="profile-role-badge <%= user.getRole() %>">
                        <i class="fas fa-<%= "admin".equals(user.getRole()) ? "shield-alt" : "heart" %>"></i>
                        <%= user.getRole().substring(0,1).toUpperCase() + user.getRole().substring(1) %>
                    </span>
                </div>

                <!-- ══ ALERTS ══ -->
                <% if (request.getParameter("success") != null) { %>
                <div class="profile-alert success">
                    <i class="fas fa-check-circle"></i>
                    <%= request.getParameter("success") %>
                </div>
                <% } %>
                <% if (request.getParameter("error") != null) { %>
                <div class="profile-alert error">
                    <i class="fas fa-exclamation-circle"></i>
                    <%= request.getParameter("error") %>
                </div>
                <% } %>
                <% if (request.getAttribute("error") != null) { %>
                <div class="profile-alert error">
                    <i class="fas fa-exclamation-circle"></i>
                    <%= request.getAttribute("error") %>
                </div>
                <% } %>

                <!-- ══ FORM FIELDS ══ -->
                <div class="form-grid">

                    <div class="field-group">
                        <label>FIRST NAME</label>
                        <div class="field-wrap">
                            <i class="fas fa-user"></i>
                            <input type="text" name="firstName"
                                   value="<%= user.getFirstName() %>"
                                   placeholder="Enter first name" required>
                        </div>
                    </div>

                    <div class="field-group">
                        <label>LAST NAME</label>
                        <div class="field-wrap">
                            <i class="fas fa-user"></i>
                            <input type="text" name="lastName"
                                   value="<%= user.getLastName() %>"
                                   placeholder="Enter last name" required>
                        </div>
                    </div>

                    <div class="field-group">
                        <label>USERNAME</label>
                        <div class="field-wrap">
                            <i class="fas fa-at"></i>
                            <input type="text" name="username"
                                   value="<%= user.getUsername() %>"
                                   placeholder="Enter username" required>
                        </div>
                    </div>

                    <div class="field-group">
                        <label>EMAIL ADDRESS</label>
                        <div class="field-wrap">
                            <i class="fas fa-envelope"></i>
                            <input type="email" name="email"
                                   value="<%= user.getEmail() %>"
                                   placeholder="Enter email" required>
                        </div>
                    </div>

                    <div class="field-group">
                        <label>PHONE NUMBER</label>
                        <div class="field-wrap">
                            <i class="fas fa-phone"></i>
                            <input type="text" name="phone"
                                   value="<%= user.getPhone() %>"
                                   placeholder="Enter phone number">
                        </div>
                    </div>

                    <div class="field-group">
                        <label>DATE JOINED</label>
                        <div class="field-wrap readonly">
                            <i class="fas fa-calendar-alt"></i>
                            <input type="text" value="<%= joinedStr %>" readonly>
                        </div>
                    </div>

                    <div class="field-group field-full">
                        <label>BIO</label>
                        <div class="field-wrap textarea-wrap">
                            <i class="fas fa-pen"></i>
                            <textarea name="bio" rows="4"
                                      placeholder="Tell us a little about yourself..."><%= user.getBio() %></textarea>
                        </div>
                    </div>

                    <div class="field-group">
                        <label>ROLE</label>
                        <div class="field-wrap readonly">
                            <i class="fas fa-shield-alt"></i>
                            <input type="text"
                                   value="<%= user.getRole().substring(0,1).toUpperCase() + user.getRole().substring(1) %>"
                                   readonly>
                        </div>
                    </div>

                    <div class="field-group">
                        <label>ACCOUNT STATUS</label>
                        <div class="field-wrap readonly">
                            <i class="fas fa-circle" style="color:<%= user.getIsActive() ? "#38c9b0" : "#e05c97" %>"></i>
                            <input type="text"
                                   value="<%= user.getIsActive() ? "Active" : "Inactive" %>"
                                   readonly>
                        </div>
                    </div>

                </div>

                <!-- Save Button -->
                <div class="save-row">
                    <button type="submit" class="save-btn">
                        <i class="fas fa-save"></i> Save Changes
                    </button>
                </div>

            </div>
        </form>
    </div>
</div>

<script>
    function previewPhoto(input) {
        if (input.files && input.files[0]) {
            var reader = new FileReader();
            reader.onload = function(e) {
                var preview  = document.getElementById('avatarPreview');
                var initials = document.getElementById('avatarInitials');
                preview.src = e.target.result;
                preview.style.display = 'block';
                if (initials) initials.style.display = 'none';
            };
            reader.readAsDataURL(input.files[0]);
        }
    }
</script>

</body>
</html>