<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard – VolunteerHub</title>
    <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
</head>
<body>

<%
    String adminName = (String) session.getAttribute("userName");
    if (adminName == null) adminName = "Admin";
    String initials = adminName.length() > 0 ? String.valueOf(adminName.charAt(0)).toUpperCase() : "A";
%>

<!-- ══════════════ SIDEBAR ══════════════ -->
<aside class="sidebar">
    <div class="sidebar-logo">
        <div class="logo-icon">&#9825;</div>
        <span>VolunteerHub</span>
    </div>

    <div class="sidebar-section-label">Main Menu</div>

    <a href="${pageContext.request.contextPath}/admin/dashboard" class="nav-item active">
        <i class="fas fa-th-large"></i>
        Dashboard
    </a>

    <div class="sidebar-section-label">Management</div>

    <a href="${pageContext.request.contextPath}/admin/volunteers" class="nav-item">
        <i class="fas fa-users"></i>
        Volunteer Management
        <span class="nav-badge">12</span>
    </a>

    <a href="${pageContext.request.contextPath}/admin/events" class="nav-item">
        <i class="fas fa-calendar-alt"></i>
        Event Management
    </a>

    <a href="${pageContext.request.contextPath}/admin/assignments" class="nav-item">
        <i class="fas fa-link"></i>
        Assignments
    </a>

    <div class="sidebar-section-label">Account</div>

    <a href="${pageContext.request.contextPath}/admin/profile" class="nav-item">
        <i class="fas fa-user-circle"></i>
        Profile Management
    </a>

    <div class="sidebar-bottom">
        <a href="${pageContext.request.contextPath}/logout" class="nav-item logout-link">
            <i class="fas fa-sign-out-alt"></i>
            Logout
        </a>
    </div>
</aside>

<!-- ══════════════ MAIN ══════════════ -->
<div class="main">

    <!-- Topbar -->
    <div class="topbar">
        <div class="topbar-left">
            <h2>Admin Dashboard</h2>
            <p>Manage your volunteer operations</p>
        </div>
        <div class="topbar-right">
            <div class="topbar-icon-btn">
                <i class="fas fa-search"></i>
            </div>
            <div class="topbar-icon-btn">
                <i class="fas fa-bell"></i>
                <span class="notif-dot"></span>
            </div>
            <%-- Avatar — clicking goes to profile --%>
            <a href="${pageContext.request.contextPath}/admin/profile" style="text-decoration:none;">
                <div class="admin-avatar"><%= initials %></div>
            </a>
        </div>
    </div>

    <!-- Page body -->
    <div class="page-body">


	<%-- Success message after profile update --%>
        <% if (request.getParameter("success") != null) { %>
        <div style="background:rgba(56,201,176,0.12); border:1px solid rgba(56,201,176,0.25);
                    color:#38c9b0; padding:12px 16px; border-radius:10px;
                    font-size:13px; margin-bottom:20px; display:flex; align-items:center; gap:8px;">
            <i class="fas fa-check-circle"></i> <%= request.getParameter("success") %>
        </div>
        <% } %>
        
        <!-- Welcome banner -->
        <div class="welcome-banner">
            <div class="welcome-text">
                <h1>Welcome back, <span class="gradient-text"><%= adminName %></span> &#128075;</h1>
                <p>Here's what's happening in your volunteer network today.</p>
            </div>
            <div class="datetime-block">
                <div class="datetime-time" id="live-time">--:--:--</div>
                <div class="datetime-date" id="live-date"></div>
                <div class="datetime-day"  id="live-day"></div>
            </div>
        </div>

        <!-- Stat cards -->
        <div class="stats-grid">

            <div class="stat-card purple">
                <div class="stat-icon"><i class="fas fa-users"></i></div>
                <div class="stat-value">248</div>
                <div class="stat-label">Total Volunteers Registered</div>
                <div class="stat-change up"><i class="fas fa-arrow-up"></i> +14 this week</div>
            </div>

            <div class="stat-card blue">
                <div class="stat-icon"><i class="fas fa-calendar-check"></i></div>
                <div class="stat-value">18</div>
                <div class="stat-label">Total Events This Month</div>
                <div class="stat-change up"><i class="fas fa-arrow-up"></i> +3 from last month</div>
            </div>

            <div class="stat-card teal">
                <div class="stat-icon"><i class="fas fa-clock"></i></div>
                <div class="stat-value">6</div>
                <div class="stat-label">Upcoming Events</div>
                <div class="stat-change up"><i class="fas fa-arrow-up"></i> Next in 2 days</div>
            </div>

            <div class="stat-card pink">
                <div class="stat-icon"><i class="fas fa-user-plus"></i></div>
                <div class="stat-value">31</div>
                <div class="stat-label">Recent Registrations</div>
                <div class="stat-change up"><i class="fas fa-arrow-up"></i> +5 today</div>
            </div>

        </div>

        <!-- Bottom panels -->
        <div class="bottom-grid">

            <!-- Recent Registrations -->
            <div class="panel">
                <div class="panel-header">
                    <h3>Recent Registrations</h3>
                    <a href="${pageContext.request.contextPath}/admin/volunteers">View all &rarr;</a>
                </div>
                <div class="reg-list">
                    <div class="reg-item">
                        <div class="reg-avatar av-purple">RS</div>
                        <div class="reg-info">
                            <div class="reg-name">Raj Sharma</div>
                            <div class="reg-email">raj.sharma@email.com</div>
                        </div>
                        <span class="role-badge volunteer">Volunteer</span>
                        <div class="reg-time">2h ago</div>
                    </div>
                    <div class="reg-item">
                        <div class="reg-avatar av-blue">AP</div>
                        <div class="reg-info">
                            <div class="reg-name">Anita Poudel</div>
                            <div class="reg-email">anita.p@email.com</div>
                        </div>
                        <span class="role-badge volunteer">Volunteer</span>
                        <div class="reg-time">5h ago</div>
                    </div>
                    <div class="reg-item">
                        <div class="reg-avatar av-teal">BK</div>
                        <div class="reg-info">
                            <div class="reg-name">Bikash KC</div>
                            <div class="reg-email">bikash.kc@email.com</div>
                        </div>
                        <span class="role-badge volunteer">Volunteer</span>
                        <div class="reg-time">1d ago</div>
                    </div>
                    <div class="reg-item">
                        <div class="reg-avatar av-amber">SM</div>
                        <div class="reg-info">
                            <div class="reg-name">Sita Maharjan</div>
                            <div class="reg-email">sita.m@email.com</div>
                        </div>
                        <span class="role-badge volunteer">Volunteer</span>
                        <div class="reg-time">1d ago</div>
                    </div>
                    <div class="reg-item">
                        <div class="reg-avatar av-pink">DT</div>
                        <div class="reg-info">
                            <div class="reg-name">Dipesh Tamang</div>
                            <div class="reg-email">dipesh.t@email.com</div>
                        </div>
                        <span class="role-badge volunteer">Volunteer</span>
                        <div class="reg-time">2d ago</div>
                    </div>
                </div>
            </div>

            <!-- Upcoming Events -->
            <div class="panel">
                <div class="panel-header">
                    <h3>Upcoming Events</h3>
                    <a href="${pageContext.request.contextPath}/admin/events">View all &rarr;</a>
                </div>
                <div class="event-list">
                    <div class="event-item">
                        <div class="event-date-box">
                            <div class="event-day-num teal-text">12</div>
                            <div class="event-month">Apr</div>
                        </div>
                        <div class="event-info">
                            <div class="event-name">Community Clean-up Drive</div>
                            <div class="event-meta"><i class="fas fa-map-marker-alt"></i> Kathmandu, Ward 5 &nbsp;&middot;&nbsp; 32 volunteers</div>
                        </div>
                        <span class="event-status active">Active</span>
                    </div>
                    <div class="event-item">
                        <div class="event-date-box">
                            <div class="event-day-num amber-text">15</div>
                            <div class="event-month">Apr</div>
                        </div>
                        <div class="event-info">
                            <div class="event-name">Blood Donation Camp</div>
                            <div class="event-meta"><i class="fas fa-map-marker-alt"></i> Patan Hospital &nbsp;&middot;&nbsp; 18 volunteers</div>
                        </div>
                        <span class="event-status upcoming">Upcoming</span>
                    </div>
                    <div class="event-item">
                        <div class="event-date-box">
                            <div class="event-day-num purple-text">19</div>
                            <div class="event-month">Apr</div>
                        </div>
                        <div class="event-info">
                            <div class="event-name">Tree Plantation Program</div>
                            <div class="event-meta"><i class="fas fa-map-marker-alt"></i> Shivapuri Area &nbsp;&middot;&nbsp; 45 volunteers</div>
                        </div>
                        <span class="event-status planning">Planning</span>
                    </div>
                    <div class="event-item">
                        <div class="event-date-box">
                            <div class="event-day-num blue-text">24</div>
                            <div class="event-month">Apr</div>
                        </div>
                        <div class="event-info">
                            <div class="event-name">Youth Leadership Workshop</div>
                            <div class="event-meta"><i class="fas fa-map-marker-alt"></i> Bhrikuti Mandap &nbsp;&middot;&nbsp; 60 volunteers</div>
                        </div>
                        <span class="event-status upcoming">Upcoming</span>
                    </div>
                    <div class="event-item">
                        <div class="event-date-box">
                            <div class="event-day-num pink-text">30</div>
                            <div class="event-month">Apr</div>
                        </div>
                        <div class="event-info">
                            <div class="event-name">Earthquake Awareness Drill</div>
                            <div class="event-meta"><i class="fas fa-map-marker-alt"></i> Lalitpur Metro &nbsp;&middot;&nbsp; 25 volunteers</div>
                        </div>
                        <span class="event-status planning">Planning</span>
                    </div>
                </div>
            </div>

        </div>
    </div>
</div>

<script>
    function updateClock() {
        var now   = new Date();
        var h     = String(now.getHours()).padStart(2, '0');
        var m     = String(now.getMinutes()).padStart(2, '0');
        var s     = String(now.getSeconds()).padStart(2, '0');
        document.getElementById('live-time').textContent = h + ':' + m + ':' + s;

        var days   = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'];
        var months = ['January','February','March','April','May','June','July',
                      'August','September','October','November','December'];
        document.getElementById('live-date').textContent =
            months[now.getMonth()] + ' ' + now.getDate() + ', ' + now.getFullYear();
        document.getElementById('live-day').textContent = days[now.getDay()];
    }
    updateClock();
    setInterval(updateClock, 1000);
</script>

</body>
</html>
