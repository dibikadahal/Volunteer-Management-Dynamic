<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.VMS.model.VolunteerNotification, java.util.List" %>
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
    int rewardPoints  = (request.getAttribute("rewardPoints") != null)
                        ? (Integer) request.getAttribute("rewardPoints")  : 0;

    @SuppressWarnings("unchecked")
    List<VolunteerNotification> notifications =
        (List<VolunteerNotification>) request.getAttribute("notifications");
    if (notifications == null) notifications = new java.util.ArrayList<>();

    int notifTotal  = request.getAttribute("notifTotal")  != null ? (Integer) request.getAttribute("notifTotal")  : notifications.size();
    int unreadCount = request.getAttribute("unreadCount") != null ? (Integer) request.getAttribute("unreadCount") : notifTotal;
%>
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
        .empty-panel { text-align:center; padding:40px 20px; color:var(--text-muted); font-size:13px; }
        .empty-panel i { font-size:32px; display:block; margin-bottom:12px; opacity:.35; }
        .empty-panel p { margin:0 0 16px; }
        .empty-panel a {
            display:inline-block; padding:9px 20px; border-radius:10px;
            background:rgba(79,142,247,.15); color:#4f8ef7;
            font-size:13px; font-weight:600; text-decoration:none;
            border:1px solid rgba(79,142,247,.25);
        }
        .empty-panel a:hover { opacity:.8; }

        /* ── Notification dropdown ── */
        .notif-wrapper  { position:relative; }
        .notif-badge    {
            position:absolute; top:-5px; right:-5px;
            background:#e05c97; color:#fff; font-size:9px; font-weight:700;
            border-radius:10px; padding:2px 5px; min-width:16px; text-align:center;
            border:2px solid var(--bg-primary); line-height:1.4; pointer-events:none;
            transition: opacity .3s;
        }
        .notif-dropdown {
            display:none; position:absolute; top:calc(100% + 12px); right:0;
            width:340px; background:var(--bg-card); border:1px solid var(--border);
            border-radius:var(--radius); z-index:600;
            box-shadow:0 8px 32px rgba(0,0,0,.4);
        }
        .notif-dropdown.open { display:block; animation:mUp .18s ease; }
        @keyframes mUp {
            from { opacity:0; transform:translateY(10px); }
            to   { opacity:1; transform:translateY(0); }
        }
        .notif-head     {
            padding:14px 18px; border-bottom:1px solid var(--border);
            display:flex; align-items:center; justify-content:space-between;
        }
        .notif-head-title { font-size:13px; font-weight:700; color:var(--text-primary); }
        .notif-head-sub   { font-size:11px; color:var(--text-muted); }
        .notif-list     { max-height:340px; overflow-y:auto; }
        .notif-item     {
            padding:13px 18px; border-bottom:1px solid var(--border);
            display:flex; align-items:flex-start; gap:12px; transition:background .15s;
        }
        .notif-item:last-child { border-bottom:none; }
        .notif-item:hover { background:rgba(255,255,255,.03); }
        .notif-icon-wrap {
            width:32px; height:32px; border-radius:50%; flex-shrink:0;
            display:flex; align-items:center; justify-content:center; font-size:13px;
        }
        .ni-accepted { background:rgba(56,201,176,.12); color:#38c9b0; }
        .ni-declined { background:rgba(224,92,151,.1);  color:#e05c97; }
        .notif-body  { flex:1; }
        .notif-msg   { font-size:12px; color:var(--text-primary); line-height:1.5; }
        .notif-time  { font-size:11px; color:var(--text-muted); margin-top:3px; }
        .notif-empty { padding:30px 18px; text-align:center; color:var(--text-muted); font-size:13px; }
        .notif-empty i { font-size:24px; display:block; margin-bottom:8px; opacity:.3; }
        .notif-foot  { padding:10px 18px; border-top:1px solid var(--border); text-align:center; }
        .notif-foot a { font-size:12px; color:#4f8ef7; text-decoration:none; font-weight:600; }
        .notif-foot a:hover { opacity:.8; }
    </style>
</head>
<body>

<!-- ══ SIDEBAR ══ -->
<aside class="sidebar">
    <div class="sidebar-logo"><div class="logo-icon">&#9825;</div><span>VolunteerHub</span></div>
    <div class="sidebar-section-label">Main Menu</div>
    <a href="${pageContext.request.contextPath}/volunteer/dashboard" class="nav-item active">
        <i class="fas fa-th-large"></i> Dashboard
    </a>
    <div class="sidebar-section-label">Events</div>
    <a href="${pageContext.request.contextPath}/volunteer/browse-events" class="nav-item">
        <i class="fas fa-calendar-alt"></i> Browse Events
    </a>
    <a href="${pageContext.request.contextPath}/volunteer/calendar" class="nav-item">
        <i class="fas fa-calendar-week"></i> Calendar
    </a>
    <a href="${pageContext.request.contextPath}/volunteer/my-events" class="nav-item">
        <i class="fas fa-heart"></i> My Events
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

    <div class="topbar">
        <div class="topbar-left">
            <h2>My Dashboard</h2>
            <p>Track your volunteer journey</p>
        </div>
        <div class="topbar-right">

            <!-- ── Bell + notification dropdown ── -->
            <div class="notif-wrapper">
                <div class="topbar-icon-btn" id="notifBtn" onclick="toggleNotif(event)"
                     style="cursor:pointer; position:relative;">
                    <i class="fas fa-bell"></i>
                    <% if (unreadCount > 0) { %>
                    <span class="notif-badge" id="notifBadge"><%= unreadCount %></span>
                    <% } %>
                </div>

                <div class="notif-dropdown" id="notifDropdown">
                    <div class="notif-head">
                        <span class="notif-head-title">
                            <i class="fas fa-bell" style="color:#f5a623;margin-right:6px;font-size:12px;"></i>
                            Notifications
                        </span>
                        <span class="notif-head-sub" id="notifSubText">
                            <%= notifTotal %> update<%= notifTotal != 1 ? "s" : "" %>
                        </span>
                    </div>

                    <div class="notif-list">
                        <% if (notifications.isEmpty()) { %>
                        <div class="notif-empty">
                            <i class="fas fa-bell-slash"></i>
                            You're all caught up!
                        </div>
                        <% } else {
                            for (VolunteerNotification n : notifications) {
                                boolean acc = "accepted".equals(n.getStatus());
                        %>
                        <div class="notif-item">
                            <div class="notif-icon-wrap <%= acc ? "ni-accepted" : "ni-declined" %>">
                                <i class="fas <%= acc ? "fa-check" : "fa-times" %>"></i>
                            </div>
                            <div class="notif-body">
                                <div class="notif-msg">
                                    <% if (acc) { %>
                                        You were <strong style="color:#38c9b0;">accepted</strong> for
                                    <% } else { %>
                                        Your request for
                                    <% } %>
                                    <strong><%= n.getEventTitle() != null ? n.getEventTitle() : "" %></strong>
                                    <% if (!acc) { %> was <strong style="color:#e05c97;">declined</strong><% } %>
                                </div>
                                <% if (n.getUpdatedAt() != null && !n.getUpdatedAt().isEmpty()) { %>
                                <div class="notif-time">
                                    <i class="fas fa-clock" style="font-size:9px;"></i> <%= n.getUpdatedAt() %>
                                </div>
                                <% } %>
                            </div>
                        </div>
                        <%  }
                           } %>
                    </div>

                    <div class="notif-foot">
                        <a href="${pageContext.request.contextPath}/volunteer/my-events">View all my events &rarr;</a>
                    </div>
                </div>
            </div>

            <a href="${pageContext.request.contextPath}/volunteer/profile" style="text-decoration:none;">
                <div class="vol-avatar"><%= initials %></div>
            </a>
        </div>
    </div>

    <div class="page-body">

        <% if (request.getParameter("success") != null) { %>
        <div style="background:rgba(56,201,176,0.12); border:1px solid rgba(56,201,176,0.25);
                    color:#38c9b0; padding:12px 16px; border-radius:10px;
                    font-size:13px; margin-bottom:20px; display:flex; align-items:center; gap:8px;">
            <i class="fas fa-check-circle"></i> <%= request.getParameter("success") %>
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
                <div class="stat-icon"><i class="fas fa-star"></i></div>
                <div class="stat-value"><%= rewardPoints %></div>
                <div class="stat-label">Reward Points</div>
                <div class="stat-sub"><%= badgesEarned %> badge<%= badgesEarned != 1 ? "s" : "" %> earned</div>
            </div>
        </div>

        <!-- Middle Grid -->
        <div class="mid-grid">

            <div class="panel panel-tall">
                <div class="panel-header">
                    <h3><i class="fas fa-calendar-alt"></i> Upcoming Assigned Events</h3>
                    <a href="${pageContext.request.contextPath}/volunteer/my-events">View all &rarr;</a>
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
                <div class="event-list">
                    <div class="empty-panel">
                        <i class="fas fa-calendar-alt"></i>
                        <p>You have <%= upcomingCount %> upcoming event(s).</p>
                        <a href="${pageContext.request.contextPath}/volunteer/my-events">View My Events</a>
                    </div>
                </div>
                <% } %>
            </div>

            <div class="right-col">
                <div class="panel">
                    <div class="panel-header"><h3><i class="fas fa-bolt"></i> Quick Actions</h3></div>
                    <div class="quick-actions">
                        <a href="${pageContext.request.contextPath}/volunteer/browse-events" class="qa-btn teal-qa">
                            <i class="fas fa-search"></i><span>Find Events</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/volunteer/my-events" class="qa-btn blue-qa">
                            <i class="fas fa-heart"></i><span>My Events</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/volunteer/my-events?tab=completed" class="qa-btn purple-qa">
                            <i class="fas fa-history"></i><span>View History</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/volunteer/profile" class="qa-btn amber-qa">
                            <i class="fas fa-user-edit"></i><span>Edit Profile</span>
                        </a>
                    </div>
                </div>

                <div class="panel">
                    <div class="panel-header"><h3><i class="fas fa-chart-line"></i> My Progress</h3></div>
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
                                <div class="progress-bar-fill teal-fill" style="width:<%= Math.min(totalAttended*10,100) %>%"></div>
                            </div>
                            <div class="progress-note"><%= totalAttended %> event(s) completed</div>
                        </div>
                        <div class="progress-item">
                            <div class="progress-top">
                                <span class="progress-label">Hours Served</span>
                                <span class="progress-pct blue-text"><%= hoursServed %>h</span>
                            </div>
                            <div class="progress-bar-bg">
                                <div class="progress-bar-fill blue-fill" style="width:<%= Math.min(hoursServed*5,100) %>%"></div>
                            </div>
                            <div class="progress-note"><%= hoursServed %> hours of community service</div>
                        </div>
                        <div class="progress-item">
                            <div class="progress-top">
                                <span class="progress-label">Badges Earned</span>
                                <span class="progress-pct purple-text"><%= badgesEarned %></span>
                            </div>
                            <div class="progress-bar-bg">
                                <div class="progress-bar-fill purple-fill" style="width:<%= Math.min(badgesEarned*25,100) %>%"></div>
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
                <a href="${pageContext.request.contextPath}/volunteer/my-events?tab=completed">View all &rarr;</a>
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
            <div class="activity-list">
                <div class="empty-panel">
                    <i class="fas fa-check-circle"></i>
                    <p>You have attended <%= totalAttended %> event(s).</p>
                    <a href="${pageContext.request.contextPath}/volunteer/my-events?tab=completed">View Full History</a>
                </div>
            </div>
            <% } %>
        </div>

    </div>
</div>

<script>
    var CTX        = '<%= request.getContextPath() %>';
    var NOTIF_TOTAL = <%= notifTotal %>;

    // ── Clock ──
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

    // ── Notification dropdown ──
    function toggleNotif(e) {
        e.stopPropagation();
        var dd = document.getElementById('notifDropdown');
        var isOpening = !dd.classList.contains('open');
        dd.classList.toggle('open');

        if (isOpening && NOTIF_TOTAL > 0) {
            // Hide badge immediately
            var badge = document.getElementById('notifBadge');
            if (badge) badge.style.opacity = '0';

            // Tell server the user has seen these notifications
            fetch(CTX + '/volunteer/notifications/mark-read', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'count=' + NOTIF_TOTAL
            }).then(function() {
                if (badge) badge.remove();
            });
        }
    }

    document.addEventListener('click', function(e) {
        var dd = document.getElementById('notifDropdown');
        if (dd && !document.getElementById('notifBtn').contains(e.target)) {
            dd.classList.remove('open');
        }
    });

    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            var dd = document.getElementById('notifDropdown');
            if (dd) dd.classList.remove('open');
        }
    });
</script>

</body>
</html>
