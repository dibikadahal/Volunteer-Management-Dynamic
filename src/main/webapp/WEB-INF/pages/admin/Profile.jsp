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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/profile.css">
    <style>
        /* ── MOBILE RESPONSIVE CRITICAL OVERRIDE ── */
        @media (max-width: 768px) {
            aside.sidebar { display: none !important; }
            aside.sidebar.open {
                display: flex !important;
                position: fixed !important;
                top: 0 !important;
                left: 0 !important;
                width: 260px !important;
                max-width: 82vw !important;
                height: 100vh !important;
                z-index: 9999 !important;
                flex-direction: column !important;
                overflow-y: auto !important;
                -webkit-overflow-scrolling: touch !important;
                transform: none !important;
            }
            div.main {
                margin-left: 0 !important;
                width: 100% !important;
                max-width: 100vw !important;
                min-width: 0 !important;
            }
            button.menu-toggle { display: flex !important; }
            .sidebar-overlay   { z-index: 9000 !important; }
            .topbar            { padding: 10px 14px !important; }
            .topbar-left p, .topbar-left-text p { display: none !important; }
            .page-body         { padding: 12px !important; }
            .stats-grid        { grid-template-columns: repeat(2, 1fr) !important; gap: 10px !important; }
            .bottom-grid, .mid-grid { grid-template-columns: 1fr !important; }
            .welcome-banner    { flex-direction: column !important; padding: 16px !important; gap: 14px !important; }
            .welcome-left      { width: 100% !important; }
            .datetime-block    { text-align: left !important; }
        }
        @media (max-width: 400px) {
            .stats-grid { grid-template-columns: 1fr !important; }
            .page-body  { padding: 8px !important; }
        }
    </style>
</head>
<body>

<!-- ══ SIDEBAR OVERLAY (mobile) ══ -->
<div class="sidebar-overlay" id="sidebarOverlay" onclick="closeSidebar()"></div>

<!-- ══ SIDEBAR ══ -->
<aside class="sidebar">
    <div class="sidebar-logo">
        <div class="logo-icon">&#9825;</div>
        <span>VolunteerHub</span>
    </div>
    <div class="sidebar-section-label">Main Menu</div>
    <a href="${pageContext.request.contextPath}/admin/dashboard" class="nav-item">
        <i class="fas fa-th-large"></i> Dashboard
    </a>
    <div class="sidebar-section-label">Management</div>
    <a href="${pageContext.request.contextPath}/admin/volunteers" class="nav-item">
        <i class="fas fa-users"></i> Volunteer Management
    </a>
    <a href="${pageContext.request.contextPath}/admin/events" class="nav-item">
        <i class="fas fa-calendar-alt"></i> Event Management
    </a>
    <a href="${pageContext.request.contextPath}/admin/calendar" class="nav-item">
        <i class="fas fa-calendar-week"></i> Calendar
    </a>
    <a href="${pageContext.request.contextPath}/admin/assignments" class="nav-item">
        <i class="fas fa-link"></i> Assignments
    </a>
    <div class="sidebar-section-label">Account</div>
    <a href="${pageContext.request.contextPath}/admin/profile" class="nav-item active">
        <i class="fas fa-user-circle"></i> Profile Management
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
            <button class="menu-toggle" onclick="toggleSidebar()" aria-label="Toggle menu">
                <i class="fas fa-bars"></i>
            </button>
            <div class="topbar-left-text">
                <h2>My Profile</h2>
                <p>View and update your personal information</p>
            </div>
        </div>
        <div class="topbar-right">
            <div class="topbar-icon-btn">
                <i class="fas fa-bell"></i>
                <span class="notif-dot"></span>
            </div>
            <div class="admin-avatar"><%= initials %></div>
        </div>
    </div>

    <!-- Page Body -->
    <div class="page-body">

        <form action="${pageContext.request.contextPath}/admin/profile"
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

    // ── Mobile sidebar toggle ──
    function toggleSidebar() {
        var sidebar = document.querySelector('.sidebar');
        var overlay = document.getElementById('sidebarOverlay');
        var isOpen  = sidebar.classList.toggle('open');
        overlay.classList.toggle('active', isOpen);
        document.documentElement.style.overflow = isOpen ? 'hidden' : '';
    }
    function closeSidebar() {
        document.querySelector('.sidebar').classList.remove('open');
        document.getElementById('sidebarOverlay').classList.remove('active');
        document.documentElement.style.overflow = '';
    }
</script>

</body>
</html>