<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.VMS.model.VolunteerNotification, java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Dashboard – VolunteerHub</title>
    <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/volunteer.css">
    <style>
        .empty-panel {
            text-align:center; padding:40px 20px; color:var(--text-muted); font-size:13px;
        }
        .empty-panel i { font-size:32px; display:block; margin-bottom:12px; opacity:.35; }
        .empty-panel p { margin:0 0 16px; }
        .empty-panel a {
            display:inline-block; padding:9px 20px; border-radius:10px;
            background:rgba(79,142,247,.15); color:#4f8ef7;
            font-size:13px; font-weight:600; text-decoration:none;
            border:1px solid rgba(79,142,247,.25);
        }
        .empty-panel a:hover { opacity:.8; }
    </style>
</head>
<body>

<%
    String volunteerName = (String) session.getAttribute("userName");
    if (volunteerName == null) volunteerName = "Volunteer";
    String initials = volunteerName.length() > 0
        ? String.valueOf(volunteerName.charAt(0)).toUpperCase() : "V";

    int totalAttended = (request.getAttribute("totalAttended") != null)
                        ? (Integer) request.getAttribute("totalAttended") : 0;
    int upcomingCount = (request.getAttribute("upcomingCount") != null)
                        ? (Integer) request.getAttribute("upcomingCount") : 0;
    int hoursServed   = (request.getAttribute("hoursServed") != null)
                        ? (Integer) request.getAttribute("hoursServed")   : 0;
    int badgesEarned  = (request.getAttribute("badgesEarned") != null)
                        ? (Integer) request.getAttribute("badgesEarned")  : 0;
%>

<!-- ══ SIDEBAR ══ -->
<aside class="sidebar">
    <div class="sidebar-logo">
        <div class="logo-icon">&#9825;</div>
        <span>VolunteerHub</span>
    </div>
    <div class="sidebar-section-label">Main Menu</div>
    <a href="${pageContext.request.contextPath}/volunteer/dashboard" class="nav-item active">
        <i class="fas fa-th-large"></i> Dashboard
    </a>
    <div class="sidebar-section-label">Events</div>
    <a href="${pageContext.request.contextPath}/volunteer/browse-events" class="nav-item">
        <i class="fas fa-calendar-alt"></i> All Events
    </a>
    <div class="sidebar-section-label">My Activities</div>
    <a href="${pageContext.request.contextPath}/volunteer/browse-events" class="nav-item">
        <i class="fas fa-heart"></i> My Events
    </a>
    <a href="${pageContext.request.contextPath}/volunteer/assignments" class="nav-item">
        <i class="fas fa-tasks"></i> My Assignments
    </a>
    <a href="${pageContext.request.contextPath}/volunteer/history" class="nav-item">
        <i class="fas fa-history"></i> Activity History
    </a>
    <div class="sidebar-section-label">Account</div>
    <a href="${pageContext.request.contextPath}/volunteer/profile" class="nav-item">
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
            <h2>My Dashboard</h2>
            <p>Track your volunteer journey</p>
        </div>
        <div class="topbar-right">
            <div class="topbar-icon-btn">
                <i class="fas fa-bell"></i>
            </div>
            <a href="${pageContext.request.contextPath}/volunteer/profile" style="text-decoration:none;">
                <div class="vol-avatar"><%= initials %></div>
            </a>
        </div>
    </div>

    <!-- Page Body -->
    <div class="page-body">

        <% if (request.getParameter("success") != null) { %>
        <div style="background:rgba(56,201,176,0.12); border:1px solid rgba(56,201,176,0.25);
                    color:#38c9b0; padding:12px 16px; border-radius:10px;
                    font-size:13px; margin-bottom:20px; display:flex; align-items:center; gap:8px;">
            <i class="fas fa-check-circle"></i> <%= request.getParameter("success") %>
        </div>
        <% } %>

        <!-- Notifications Panel — accepted / declined events -->
        <%
            @SuppressWarnings("unchecked")
            List<VolunteerNotification> notifications =
                (List<VolunteerNotification>) request.getAttribute("notifications");
            if (notifications != null && !notifications.isEmpty()) {
        %>
        <div style="background:var(--bg-card); border:1px solid var(--border); border-radius:var(--radius);
                    padding:18px 20px; margin-bottom:24px;">
            <div style="display:flex; align-items:center; gap:8px; margin-bottom:14px;">
                <i class="fas fa-bell" style="color:#f5a623; font-size:14px;"></i>
                <span style="font-size:13px; font-weight:700; color:var(--text-primary);">Notifications</span>
                <span style="font-size:11px; color:var(--text-muted); margin-left:4px;">— updates on your volunteer requests</span>
            </div>
            <div style="display:flex; flex-direction:column; gap:10px;">
                <%  for (VolunteerNotification n : notifications) {
                        boolean accepted = "accepted".equals(n.getStatus());
                        String bgColor   = accepted ? "rgba(56,201,176,.08)"   : "rgba(224,92,151,.08)";
                        String border    = accepted ? "rgba(56,201,176,.25)"   : "rgba(224,92,151,.22)";
                        String txtColor  = accepted ? "#38c9b0"                : "#e05c97";
                        String icon      = accepted ? "fa-check-circle"        : "fa-times-circle";
                        String msg       = accepted
                            ? "You have been <strong>accepted</strong> as a volunteer for"
                            : "Sorry, your request for";
                        String suffix    = accepted ? "!" : " was <strong>declined</strong>.";
                %>
                <div style="background:<%= bgColor %>; border:1px solid <%= border %>;
                            border-radius:10px; padding:11px 16px;
                            display:flex; align-items:center; gap:12px;">
                    <i class="fas <%= icon %>" style="color:<%= txtColor %>; font-size:16px; flex-shrink:0;"></i>
                    <div style="flex:1; font-size:13px; color:var(--text-primary); line-height:1.5;">
                        <%= msg %> <strong>&ldquo;<%= n.getEventTitle() != null ? n.getEventTitle().replace("\"","&quot;") : "" %>&rdquo;</strong><%= suffix %>
                    </div>
                    <% if (n.getUpdatedAt() != null && !n.getUpdatedAt().isEmpty()) { %>
                    <span style="font-size:11px; color:var(--text-muted); white-space:nowrap;"><%= n.getUpdatedAt() %></span>
                    <% } %>
                </div>
                <% } %>
            </div>
        </div>
        <% } %>

        <!-- Welcome Banner -->
        <div class="welcome-banner">
            <div class="welcome-left">
                <div class="welcome-tag"><i class="fas fa-heart"></i> Volunteer Member</div>
                <h1>Welcome back, <span class="gradient-text"><%= volunteerName %></span>!</h1>
                <p>Every effort you make creates a ripple of positive change. Keep going!</p>
                <a href="${pageContext.request.contextPath}/volunteer/browse-events" class="browse-btn">
                    <i class="fas fa-search"></i> Browse Events
                </a>
            </div>
            <div class="datetime-block">
                <div class="datetime-time" id="live-time">--:--:--</div>
                <div class="datetime-date" id="live-date"></div>
                <div class="datetime-day"  id="live-day"></div>
            </div>
        </div>

        <!-- Stat Cards — real values from DB -->
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
                <div class="stat-sub">Recognition &amp; achievements</div>
            </div>

        </div>

        <!-- Middle Grid -->
        <div class="mid-grid">

            <!-- Upcoming Assigned Events -->
            <div class="panel panel-tall">
                <div class="panel-header">
                    <h3><i class="fas fa-calendar-alt"></i> Upcoming Assigned Events</h3>
                    <a href="${pageContext.request.contextPath}/volunteer/browse-events">View all &rarr;</a>
                </div>

                <% if (upcomingCount == 0) { %>
                <div class="empty-panel">
                    <i class="fas fa-calendar-times"></i>
                    <p>You have no upcoming events yet.</p>
                    <a href="${pageContext.request.contextPath}/volunteer/browse-events">
                        <i class="fas fa-search"></i> Browse Events
                    </a>
                </div>
                <% } else { %>
                <%-- This block will be filled dynamically once the events DAO is implemented --%>
                <div class="event-list">
                    <div class="empty-panel">
                        <i class="fas fa-calendar-alt"></i>
                        <p>You have <%= upcomingCount %> upcoming event(s).</p>
                        <a href="${pageContext.request.contextPath}/volunteer/browse-events">View Events</a>
                    </div>
                </div>
                <% } %>
            </div>

            <!-- Right column -->
            <div class="right-col">

                <!-- Quick Actions -->
                <div class="panel">
                    <div class="panel-header">
                        <h3><i class="fas fa-bolt"></i> Quick Actions</h3>
                    </div>
                    <div class="quick-actions">
                        <a href="${pageContext.request.contextPath}/volunteer/browse-events" class="qa-btn teal-qa">
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

                <!-- Progress — shown only when there's data -->
                <div class="panel">
                    <div class="panel-header">
                        <h3><i class="fas fa-chart-line"></i> My Progress</h3>
                    </div>
                    <% if (totalAttended == 0 && hoursServed == 0 && badgesEarned == 0) { %>
                    <div class="empty-panel" style="padding:24px 16px;">
                        <i class="fas fa-seedling" style="font-size:24px;"></i>
                        <p>Your journey is just beginning.<br>Attend events to track progress!</p>
                    </div>
                    <% } else { %>
                    <div class="progress-body">
                        <div class="progress-item">
                            <div class="progress-top">
                                <span class="progress-label">Events Attended</span>
                                <span class="progress-pct teal-text"><%= totalAttended %></span>
                            </div>
                            <div class="progress-bar-bg">
                                <div class="progress-bar-fill teal-fill"
                                     style="width:<%= Math.min(totalAttended * 10, 100) %>%"></div>
                            </div>
                            <div class="progress-note"><%= totalAttended %> event(s) completed</div>
                        </div>
                        <div class="progress-item">
                            <div class="progress-top">
                                <span class="progress-label">Hours Served</span>
                                <span class="progress-pct blue-text"><%= hoursServed %>h</span>
                            </div>
                            <div class="progress-bar-bg">
                                <div class="progress-bar-fill blue-fill"
                                     style="width:<%= Math.min(hoursServed * 5, 100) %>%"></div>
                            </div>
                            <div class="progress-note"><%= hoursServed %> hours of community service</div>
                        </div>
                        <div class="progress-item">
                            <div class="progress-top">
                                <span class="progress-label">Badges Earned</span>
                                <span class="progress-pct purple-text"><%= badgesEarned %></span>
                            </div>
                            <div class="progress-bar-bg">
                                <div class="progress-bar-fill purple-fill"
                                     style="width:<%= Math.min(badgesEarned * 25, 100) %>%"></div>
                            </div>
                            <div class="progress-note"><%= badgesEarned %> badge(s) earned</div>
                        </div>
                    </div>
                    <% } %>
                </div>

            </div>
        </div>

        <!-- Recent Activity -->
        <div class="panel activity-panel">
            <div class="panel-header">
                <h3><i class="fas fa-history"></i> Recent Activity</h3>
                <a href="${pageContext.request.contextPath}/volunteer/history">View all &rarr;</a>
            </div>
            <% if (totalAttended == 0) { %>
            <div class="empty-panel">
                <i class="fas fa-history"></i>
                <p>No activity yet. Join your first event to get started!</p>
                <a href="${pageContext.request.contextPath}/volunteer/browse-events">
                    <i class="fas fa-search"></i> Find Events
                </a>
            </div>
            <% } else { %>
            <%-- Activity list will be populated once the activity DAO is implemented --%>
            <div class="activity-list">
                <div class="empty-panel">
                    <i class="fas fa-check-circle"></i>
                    <p>You have attended <%= totalAttended %> event(s).</p>
                    <a href="${pageContext.request.contextPath}/volunteer/history">View Full History</a>
                </div>
            </div>
            <% } %>
        </div>

    </div>
</div>

<script>
    function updateClock() {
        var now = new Date();
        var h = String(now.getHours()).padStart(2,'0');
        var m = String(now.getMinutes()).padStart(2,'0');
        var s = String(now.getSeconds()).padStart(2,'0');
        document.getElementById('live-time').textContent = h+':'+m+':'+s;
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
