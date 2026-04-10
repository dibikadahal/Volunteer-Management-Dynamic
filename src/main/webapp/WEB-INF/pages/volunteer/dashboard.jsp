<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Dashboard – VolunteerHub</title>
    <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/volunteer.css">
</head>
<body>

<%
    String volunteerName = (String) session.getAttribute("userName");
    if (volunteerName == null) volunteerName = "Volunteer";
    String initials = volunteerName.length() > 1
        ? String.valueOf(volunteerName.charAt(0)).toUpperCase()
        : "V";

    // These would come from your DAO/servlet attributes in production
    // For now using request attributes with fallback defaults
    Integer totalAttended  = (Integer) request.getAttribute("totalAttended");
    Integer upcomingCount  = (Integer) request.getAttribute("upcomingCount");
    Integer hoursServed    = (Integer) request.getAttribute("hoursServed");
    Integer badgesEarned   = (Integer) request.getAttribute("badgesEarned");

    if (totalAttended == null) totalAttended = 0;
    if (upcomingCount  == null) upcomingCount  = 0;
    if (hoursServed    == null) hoursServed    = 0;
    if (badgesEarned   == null) badgesEarned   = 0;
%>

<!-- ══════════════ SIDEBAR ══════════════ -->
<aside class="sidebar">
    <div class="sidebar-logo">
        <div class="logo-icon">&#9825;</div>
        <span>VolunteerHub</span>
    </div>

    <div class="sidebar-section-label">Main Menu</div>

    <a href="${pageContext.request.contextPath}/volunteer/dashboard" class="nav-item active">
        <i class="fas fa-th-large"></i>
        Dashboard
    </a>

    <div class="sidebar-section-label">My Activities</div>

    <a href="${pageContext.request.contextPath}/volunteer/events" class="nav-item">
        <i class="fas fa-calendar-alt"></i>
        My Events
    </a>

    <a href="${pageContext.request.contextPath}/volunteer/assignments" class="nav-item">
        <i class="fas fa-tasks"></i>
        My Assignments
    </a>

    <a href="${pageContext.request.contextPath}/volunteer/history" class="nav-item">
        <i class="fas fa-history"></i>
        Activity History
    </a>

    <div class="sidebar-section-label">Account</div>

    <a href="${pageContext.request.contextPath}/volunteer/profile" class="nav-item">
        <i class="fas fa-user-circle"></i>
        My Profile
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
            <h2>My Dashboard</h2>
            <p>Track your volunteer journey</p>
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

        <!-- Welcome Banner -->
        <div class="welcome-banner">
            <div class="welcome-left">
                <div class="welcome-tag"><i class="fas fa-heart"></i> Volunteer Member</div>
                <h1>Welcome back, <span class="gradient-text"><%= volunteerName %></span>!</h1>
                <p>Every effort you make creates a ripple of positive change. Keep going!</p>
                <a href="${pageContext.request.contextPath}/volunteer/events" class="browse-btn">
                    <i class="fas fa-search"></i> Browse Events
                </a>
            </div>
            <div class="datetime-block">
                <div class="datetime-time" id="live-time">--:--:--</div>
                <div class="datetime-date" id="live-date"></div>
                <div class="datetime-day"  id="live-day"></div>
            </div>
        </div>

        <!-- Stat Cards -->
        <div class="stats-grid">

            <div class="stat-card teal">
                <div class="stat-icon"><i class="fas fa-calendar-check"></i></div>
                <div class="stat-value"><%= totalAttended %></div>
                <div class="stat-label">Events Attended</div>
                <div class="stat-sub">Total participation record</div>
            </div>

            <div class="stat-card blue">
                <div class="stat-icon"><i class="fas fa-clock"></i></div>
                <div class="stat-value"><%= upcomingCount %></div>
                <div class="stat-label">Upcoming Events</div>
                <div class="stat-sub">You are registered for</div>
            </div>

            <div class="stat-card purple">
                <div class="stat-icon"><i class="fas fa-hourglass-half"></i></div>
                <div class="stat-value"><%= hoursServed %></div>
                <div class="stat-label">Hours Served</div>
                <div class="stat-sub">Community service hours</div>
            </div>

            <div class="stat-card amber">
                <div class="stat-icon"><i class="fas fa-award"></i></div>
                <div class="stat-value"><%= badgesEarned %></div>
                <div class="stat-label">Badges Earned</div>
                <div class="stat-sub">Recognition & achievements</div>
            </div>

        </div>

        <!-- Middle: Upcoming + Progress -->
        <div class="mid-grid">

            <!-- Upcoming Assigned Events -->
            <div class="panel panel-tall">
                <div class="panel-header">
                    <h3><i class="fas fa-calendar-alt"></i> Upcoming Assigned Events</h3>
                    <a href="${pageContext.request.contextPath}/volunteer/events">View all &rarr;</a>
                </div>
                <div class="event-list">

                    <div class="event-card green">
                        <div class="event-date-col">
                            <div class="ev-day">12</div>
                            <div class="ev-mon">APR</div>
                        </div>
                        <div class="event-details">
                            <div class="ev-title">Community Clean-up Drive</div>
                            <div class="ev-meta"><i class="fas fa-map-marker-alt"></i> Kathmandu, Ward 5</div>
                            <div class="ev-meta"><i class="fas fa-user-friends"></i> 32 volunteers joined</div>
                        </div>
                        <div class="ev-right">
                            <span class="ev-badge active">Active</span>
                            <div class="ev-time">08:00 AM</div>
                        </div>
                    </div>

                    <div class="event-card amber">
                        <div class="event-date-col">
                            <div class="ev-day">15</div>
                            <div class="ev-mon">APR</div>
                        </div>
                        <div class="event-details">
                            <div class="ev-title">Blood Donation Camp</div>
                            <div class="ev-meta"><i class="fas fa-map-marker-alt"></i> Patan Hospital</div>
                            <div class="ev-meta"><i class="fas fa-user-friends"></i> 18 volunteers joined</div>
                        </div>
                        <div class="ev-right">
                            <span class="ev-badge upcoming">Upcoming</span>
                            <div class="ev-time">10:00 AM</div>
                        </div>
                    </div>

                    <div class="event-card purple">
                        <div class="event-date-col">
                            <div class="ev-day">19</div>
                            <div class="ev-mon">APR</div>
                        </div>
                        <div class="event-details">
                            <div class="ev-title">Tree Plantation Program</div>
                            <div class="ev-meta"><i class="fas fa-map-marker-alt"></i> Shivapuri Area</div>
                            <div class="ev-meta"><i class="fas fa-user-friends"></i> 45 volunteers joined</div>
                        </div>
                        <div class="ev-right">
                            <span class="ev-badge planning">Planning</span>
                            <div class="ev-time">07:00 AM</div>
                        </div>
                    </div>

                    <div class="event-card blue">
                        <div class="event-date-col">
                            <div class="ev-day">24</div>
                            <div class="ev-mon">APR</div>
                        </div>
                        <div class="event-details">
                            <div class="ev-title">Youth Leadership Workshop</div>
                            <div class="ev-meta"><i class="fas fa-map-marker-alt"></i> Bhrikuti Mandap</div>
                            <div class="ev-meta"><i class="fas fa-user-friends"></i> 60 volunteers joined</div>
                        </div>
                        <div class="ev-right">
                            <span class="ev-badge upcoming">Upcoming</span>
                            <div class="ev-time">09:00 AM</div>
                        </div>
                    </div>

                </div>
            </div>

            <!-- Right column -->
            <div class="right-col">

                <!-- Volunteer Progress -->
                <div class="panel">
                    <div class="panel-header">
                        <h3><i class="fas fa-chart-line"></i> My Progress</h3>
                    </div>
                    <div class="progress-body">

                        <div class="progress-item">
                            <div class="progress-top">
                                <span class="progress-label">Events Goal (Monthly)</span>
                                <span class="progress-pct teal-text">60%</span>
                            </div>
                            <div class="progress-bar-bg">
                                <div class="progress-bar-fill teal-fill" style="width:60%"></div>
                            </div>
                            <div class="progress-note">3 of 5 events completed</div>
                        </div>

                        <div class="progress-item">
                            <div class="progress-top">
                                <span class="progress-label">Hours Goal (Monthly)</span>
                                <span class="progress-pct blue-text">45%</span>
                            </div>
                            <div class="progress-bar-bg">
                                <div class="progress-bar-fill blue-fill" style="width:45%"></div>
                            </div>
                            <div class="progress-note">9 of 20 hours served</div>
                        </div>

                        <div class="progress-item">
                            <div class="progress-top">
                                <span class="progress-label">Badge Progress</span>
                                <span class="progress-pct purple-text">75%</span>
                            </div>
                            <div class="progress-bar-bg">
                                <div class="progress-bar-fill purple-fill" style="width:75%"></div>
                            </div>
                            <div class="progress-note">3 of 4 requirements met</div>
                        </div>

                    </div>
                </div>

                <!-- Quick Actions -->
                <div class="panel">
                    <div class="panel-header">
                        <h3><i class="fas fa-bolt"></i> Quick Actions</h3>
                    </div>
                    <div class="quick-actions">
                        <a href="${pageContext.request.contextPath}/volunteer/events" class="qa-btn teal-qa">
                            <i class="fas fa-search"></i>
                            <span>Find Events</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/volunteer/assignments" class="qa-btn blue-qa">
                            <i class="fas fa-tasks"></i>
                            <span>My Tasks</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/volunteer/history" class="qa-btn purple-qa">
                            <i class="fas fa-history"></i>
                            <span>View History</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/volunteer/profile" class="qa-btn amber-qa">
                            <i class="fas fa-user-edit"></i>
                            <span>Edit Profile</span>
                        </a>
                    </div>
                </div>

            </div>
        </div>

        <!-- Recent Activity -->
        <div class="panel activity-panel">
            <div class="panel-header">
                <h3><i class="fas fa-history"></i> Recent Activity</h3>
                <a href="${pageContext.request.contextPath}/volunteer/history">View all &rarr;</a>
            </div>
            <div class="activity-list">

                <div class="activity-item">
                    <div class="activity-icon teal-icon"><i class="fas fa-check"></i></div>
                    <div class="activity-info">
                        <div class="activity-title">Attended: Community Health Camp</div>
                        <div class="activity-meta">April 5, 2026 &nbsp;&middot;&nbsp; 4 hours served</div>
                    </div>
                    <span class="activity-badge attended">Attended</span>
                </div>

                <div class="activity-item">
                    <div class="activity-icon blue-icon"><i class="fas fa-user-plus"></i></div>
                    <div class="activity-info">
                        <div class="activity-title">Registered: Blood Donation Camp</div>
                        <div class="activity-meta">April 8, 2026 &nbsp;&middot;&nbsp; Registration confirmed</div>
                    </div>
                    <span class="activity-badge registered">Registered</span>
                </div>

                <div class="activity-item">
                    <div class="activity-icon purple-icon"><i class="fas fa-award"></i></div>
                    <div class="activity-info">
                        <div class="activity-title">Badge Earned: Community Hero</div>
                        <div class="activity-meta">April 6, 2026 &nbsp;&middot;&nbsp; 10 events milestone</div>
                    </div>
                    <span class="activity-badge badge-earned">Badge</span>
                </div>

                <div class="activity-item">
                    <div class="activity-icon amber-icon"><i class="fas fa-calendar-check"></i></div>
                    <div class="activity-info">
                        <div class="activity-title">Attended: Youth Awareness Program</div>
                        <div class="activity-meta">April 2, 2026 &nbsp;&middot;&nbsp; 3 hours served</div>
                    </div>
                    <span class="activity-badge attended">Attended</span>
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
        var months = ['January','February','March','April','May','June','July','August','September','October','November','December'];
        document.getElementById('live-date').textContent = months[now.getMonth()] + ' ' + now.getDate() + ', ' + now.getFullYear();
        document.getElementById('live-day').textContent  = days[now.getDay()];
    }
    updateClock();
    setInterval(updateClock, 1000);
</script>

</body>
</html>
