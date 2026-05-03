<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.VMS.model.VolunteerAssignmentEntry, java.util.List" %>
<%!
    private static String h(String s) {
        if (s == null) return "";
        return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
                .replace("\"","&quot;").replace("'","&#39;");
    }
%>
<%
    String volName = (String) session.getAttribute("userName");
    if (volName == null) volName = "Volunteer";
    String initials = volName.length() > 0 ? String.valueOf(volName.charAt(0)).toUpperCase() : "V";

    @SuppressWarnings("unchecked")
    List<VolunteerAssignmentEntry> upcoming = (List<VolunteerAssignmentEntry>) request.getAttribute("upcoming");
    @SuppressWarnings("unchecked")
    List<VolunteerAssignmentEntry> past     = (List<VolunteerAssignmentEntry>) request.getAttribute("past");
    if (upcoming == null) upcoming = new java.util.ArrayList<>();
    if (past     == null) past     = new java.util.ArrayList<>();

    int totalPoints   = request.getAttribute("totalPoints")   != null ? (Integer) request.getAttribute("totalPoints")   : 0;
    int totalAccepted = request.getAttribute("totalAccepted") != null ? (Integer) request.getAttribute("totalAccepted") : 0;
    int totalAttended = request.getAttribute("totalAttended") != null ? ((Number) request.getAttribute("totalAttended")).intValue() : 0;

    // Attendance-based badges: 1 event attended = 1 badge earned
    String[] badgeNames = {"First Timer", "Helping Hand", "Team Player", "Dedicated", "Champion"};
    String[] badgeIcons = {"star", "award", "trophy", "crown", "gem"};
    String currentBadge;
    if (totalAttended == 0) {
        currentBadge = "New Volunteer";
    } else if (totalAttended <= badgeNames.length) {
        currentBadge = badgeNames[totalAttended - 1];
    } else {
        currentBadge = "Master";
    }
    String nextBadgeName = totalAttended < badgeNames.length ? badgeNames[totalAttended] : "Master";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Assignments – VolunteerHub</title>
    <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/volunteer.css">
    <style>
        /* ══ BADGES / CHIPS ══ */
        .badge { display:inline-flex; align-items:center; gap:5px; padding:4px 10px; border-radius:20px; font-size:11px; font-weight:700; white-space:nowrap; }
        .badge-dot { width:6px; height:6px; border-radius:50%; background:currentColor; }
        .badge-opened   { background:rgba(56,201,176,.15);  color:#38c9b0; border:1px solid rgba(56,201,176,.3); }
        .badge-closed   { background:rgba(100,100,120,.15); color:var(--text-secondary); border:1px solid var(--border); }
        .badge-attended { background:rgba(56,201,176,.15);  color:#38c9b0; border:1px solid rgba(56,201,176,.3); }
        .badge-absent   { background:rgba(224,92,151,.12);  color:#e05c97; border:1px solid rgba(224,92,151,.25); }
        .badge-upcoming { background:rgba(79,142,247,.12);  color:#4f8ef7; border:1px solid rgba(79,142,247,.25); }

        /* ══ POINTS BANNER ══ */
        .pts-banner {
            background: linear-gradient(135deg, rgba(124,92,191,.15), rgba(79,142,247,.1));
            border: 1px solid rgba(124,92,191,.25);
            border-radius: var(--radius);
            padding: 20px 24px;
            margin-bottom: 24px;
            display: flex;
            align-items: center;
            gap: 24px;
            flex-wrap: wrap;
        }
        .pts-big { font-size: 42px; font-weight: 700; color: #f5a623; line-height: 1; }
        .pts-label { font-size: 11px; text-transform: uppercase; letter-spacing: .8px; color: var(--text-muted); }
        .pts-info { flex: 1; min-width: 180px; }
        .pts-title { font-size: 15px; font-weight: 700; color: var(--text-primary); margin-bottom: 4px; }
        .pts-sub { font-size: 12px; color: var(--text-secondary); margin-bottom: 12px; }
        .pts-progress-wrap { background: rgba(255,255,255,.06); border-radius: 6px; height: 6px; overflow: hidden; }
        .pts-progress-fill { height: 100%; border-radius: 6px; background: linear-gradient(90deg,#f5a623,#e05c97); transition: width .5s; }
        .badge-chip {
            display: inline-flex; align-items: center; gap: 6px;
            padding: 6px 14px; border-radius: 20px; font-size: 12px; font-weight: 700;
            background: rgba(245,166,35,.12); color: #f5a623;
            border: 1px solid rgba(245,166,35,.25);
        }

        /* ══ SECTION HEADER ══ */
        .section-header {
            display: flex; align-items: center; gap: 10px;
            margin: 28px 0 14px;
        }
        .section-header h3 { font-size: 14px; font-weight: 700; color: var(--text-primary); margin: 0; }
        .section-header .count-pill {
            display: inline-flex; align-items: center;
            padding: 3px 10px; border-radius: 12px; font-size: 11px; font-weight: 700;
        }
        .pill-blue   { background:rgba(79,142,247,.12); color:#4f8ef7; border:1px solid rgba(79,142,247,.25); }
        .pill-teal   { background:rgba(56,201,176,.12); color:#38c9b0; border:1px solid rgba(56,201,176,.25); }

        /* ══ EVENT CARDS (upcoming) ══ */
        .event-cards-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 14px;
        }
        .event-card {
            background: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 16px 18px;
            transition: border-color .2s, background .2s;
        }
        .event-card:hover { border-color: rgba(124,92,191,.35); background: rgba(124,92,191,.04); }
        .event-card-top { display: flex; align-items: flex-start; justify-content: space-between; gap: 10px; margin-bottom: 10px; }
        .event-card-icon { width: 38px; height: 38px; border-radius: 9px; flex-shrink: 0; display: flex; align-items: center; justify-content: center; background: rgba(79,142,247,.1); color: #4f8ef7; font-size: 15px; }
        .event-card-title { font-size: 14px; font-weight: 700; color: var(--text-primary); margin-bottom: 3px; line-height: 1.3; }
        .event-card-meta { font-size: 11px; color: var(--text-muted); line-height: 1.7; }
        .event-card-meta i { font-size: 10px; margin-right: 3px; }

        /* ══ HISTORY TABLE ══ */
        .hist-table-wrap { overflow-x: auto; border-radius: var(--radius); border: 1px solid var(--border); background: var(--bg-card); }
        .hist-table { width: 100%; border-collapse: collapse; font-size: 13px; }
        .hist-table thead th { background: rgba(56,201,176,.06); color: var(--text-secondary); font-size: 11px; text-transform: uppercase; letter-spacing: .8px; padding: 12px 16px; text-align: left; white-space: nowrap; }
        .hist-table tbody tr { border-top: 1px solid var(--border); transition: background .15s; }
        .hist-table tbody tr:hover { background: rgba(56,201,176,.04); }
        .hist-table td { padding: 12px 16px; color: var(--text-primary); vertical-align: middle; }
        .hist-table td.muted { color: var(--text-secondary); font-size: 12px; }

        /* ══ POINTS CHIP ══ */
        .pts-chip { display: inline-flex; align-items: center; gap: 4px; padding: 3px 9px; border-radius: 10px; font-size: 11px; font-weight: 700; background: rgba(245,166,35,.12); color: #f5a623; border: 1px solid rgba(245,166,35,.25); }
        .pts-chip-muted { background: rgba(255,255,255,.04); color: var(--text-muted); border: 1px solid var(--border); }

        /* ══ EMPTY STATE ══ */
        .empty-state { text-align: center; padding: 36px 20px; color: var(--text-muted); font-size: 13px; background: var(--bg-card); border-radius: var(--radius); border: 1px solid var(--border); }
        .empty-state i { font-size: 28px; display: block; margin-bottom: 10px; opacity: .3; }
        .empty-state a { display: inline-block; margin-top: 12px; padding: 8px 18px; border-radius: 9px; background: rgba(79,142,247,.15); color: #4f8ef7; font-size: 12px; font-weight: 600; text-decoration: none; border: 1px solid rgba(79,142,247,.25); }
    </style>
</head>
<body>

<!-- ══ SIDEBAR ══ -->
<aside class="sidebar">
    <div class="sidebar-logo"><div class="logo-icon">&#9825;</div><span>VolunteerHub</span></div>
    <div class="sidebar-section-label">Main Menu</div>
    <a href="${pageContext.request.contextPath}/volunteer/dashboard" class="nav-item"><i class="fas fa-th-large"></i> Dashboard</a>
    <div class="sidebar-section-label">Events</div>
    <a href="${pageContext.request.contextPath}/volunteer/browse-events" class="nav-item"><i class="fas fa-calendar-alt"></i> All Events</a>
    <div class="sidebar-section-label">My Activities</div>
    <a href="${pageContext.request.contextPath}/volunteer/browse-events" class="nav-item"><i class="fas fa-heart"></i> My Events</a>
    <a href="${pageContext.request.contextPath}/volunteer/assignments" class="nav-item active"><i class="fas fa-tasks"></i> My Assignments</a>
    <a href="${pageContext.request.contextPath}/volunteer/history" class="nav-item"><i class="fas fa-history"></i> Activity History</a>
    <div class="sidebar-section-label">Account</div>
    <a href="${pageContext.request.contextPath}/volunteer/profile" class="nav-item"><i class="fas fa-user-circle"></i> My Profile</a>
    <div class="sidebar-bottom">
        <a href="${pageContext.request.contextPath}/logout" class="nav-item logout-link"><i class="fas fa-sign-out-alt"></i> Logout</a>
    </div>
</aside>

<!-- ══ MAIN ══ -->
<div class="main">
    <div class="topbar">
        <div class="topbar-left">
            <h2>My Assignments</h2>
            <p>Your accepted events, attendance status and reward points</p>
        </div>
        <div class="topbar-right">
            <div class="topbar-icon-btn"><i class="fas fa-bell"></i></div>
            <a href="${pageContext.request.contextPath}/volunteer/profile" style="text-decoration:none;">
                <div class="vol-avatar"><%= initials %></div>
            </a>
        </div>
    </div>

    <div class="page-body">

        <%-- Flash messages --%>
        <% if (request.getParameter("success") != null) { %>
        <div id="flashMsg" style="background:rgba(56,201,176,.12); border:1px solid rgba(56,201,176,.25); color:#38c9b0; padding:12px 16px; border-radius:10px; font-size:13px; margin-bottom:20px; display:flex; align-items:center; gap:8px;">
            <i class="fas fa-check-circle"></i> <%= h(request.getParameter("success")) %>
        </div>
        <% } %>

        <!-- Stat Cards -->
        <div class="stats-grid">
            <div class="stat-card blue">
                <div class="stat-icon"><i class="fas fa-clock"></i></div>
                <div class="stat-value"><%= upcoming.size() %></div>
                <div class="stat-label">Upcoming Events</div>
                <div class="stat-sub">You are assigned to</div>
            </div>
            <div class="stat-card teal">
                <div class="stat-icon"><i class="fas fa-calendar-check"></i></div>
                <div class="stat-value"><%= totalAttended %></div>
                <div class="stat-label">Events Attended</div>
                <div class="stat-sub">Confirmed attendance</div>
            </div>
            <div class="stat-card amber">
                <div class="stat-icon"><i class="fas fa-star"></i></div>
                <div class="stat-value"><%= totalPoints %></div>
                <div class="stat-label">Reward Points</div>
                <div class="stat-sub">Earned from attendance</div>
            </div>
        </div>

        <!-- Badge Banner -->
        <% if (totalAccepted > 0 || totalAttended > 0) { %>
        <div class="pts-banner">
            <div>
                <div class="pts-big"><%= totalAttended %></div>
                <div class="pts-label">badge<%= totalAttended != 1 ? "s" : "" %></div>
            </div>
            <div class="pts-info">
                <div class="pts-title">
                    <% if (totalAttended > 0) { %>
                    <i class="fas fa-medal" style="color:#f5a623;"></i> <%= currentBadge %> Volunteer
                    <% } else { %>
                    <i class="fas fa-seedling" style="color:#38c9b0;"></i> Welcome, <%= volName %>!
                    <% } %>
                </div>
                <div class="pts-sub">
                    <% if (totalAttended == 0) { %>
                    Attend your first event to earn the <strong><%= nextBadgeName %></strong> badge!
                    <% } else if (totalAttended < badgeNames.length) { %>
                    Attend <strong style="color:#f5a623;">1 more event</strong> to earn the <strong><%= nextBadgeName %></strong> badge!
                    <% } else { %>
                    You've unlocked all milestone badges — keep going for Master status!
                    <% } %>
                </div>
                <div style="font-size:11px; color:var(--text-muted); margin-top:8px;">
                    <i class="fas fa-star" style="color:#f5a623; font-size:10px;"></i>
                    <%= totalPoints %> reward points &nbsp;·&nbsp; 1 badge per event attended
                </div>
            </div>
            <div style="display:flex; flex-direction:column; gap:6px; align-items:flex-end;">
                <% if (totalAttended > 0) { %>
                <%  int visibleBadges = Math.min(totalAttended, 5);
                    for (int b = 0; b < visibleBadges; b++) { %>
                <span class="badge-chip">
                    <i class="fas fa-<%= badgeIcons[b] %>" style="font-size:10px;"></i>
                    <%= badgeNames[b] %>
                </span>
                <%  } %>
                <%  if (totalAttended > 5) { %>
                <span class="badge-chip" style="opacity:.75; font-size:11px;">
                    <i class="fas fa-plus" style="font-size:9px;"></i> <%= totalAttended - 5 %> more
                </span>
                <%  } %>
                <% } else { %>
                <span class="badge-chip" style="opacity:.5;"><i class="fas fa-star" style="font-size:10px;"></i> Attend 1 event for first badge</span>
                <% } %>
            </div>
        </div>
        <% } %>

        <!-- ══ UPCOMING EVENTS ══ -->
        <div class="section-header">
            <h3><i class="fas fa-clock" style="color:#4f8ef7;"></i> Upcoming Events</h3>
            <span class="count-pill pill-blue"><%= upcoming.size() %></span>
        </div>

        <% if (upcoming.isEmpty()) { %>
        <div class="empty-state">
            <i class="fas fa-calendar-times"></i>
            <p>You have no upcoming assigned events.</p>
            <a href="${pageContext.request.contextPath}/volunteer/browse-events">
                <i class="fas fa-search"></i> Browse Events
            </a>
        </div>
        <% } else { %>
        <div class="event-cards-grid">
        <%  for (VolunteerAssignmentEntry e : upcoming) { %>
            <div class="event-card">
                <div class="event-card-top">
                    <div style="display:flex; align-items:flex-start; gap:10px; flex:1;">
                        <div class="event-card-icon"><i class="fas fa-calendar-alt"></i></div>
                        <div>
                            <div class="event-card-title"><%= h(e.getTitle()) %></div>
                            <span class="badge <%= "opened".equals(e.getEventStatus()) ? "badge-opened" : "badge-closed" %>" style="font-size:10px; padding:3px 8px;">
                                <span class="badge-dot"></span><%= "opened".equals(e.getEventStatus()) ? "Open" : "Closed" %>
                            </span>
                        </div>
                    </div>
                    <span class="badge badge-upcoming" style="font-size:10px; padding:3px 8px;"><i class="fas fa-check" style="font-size:9px;"></i> Assigned</span>
                </div>
                <div class="event-card-meta">
                    <% if (!e.getLocation().isEmpty()) { %>
                    <div><i class="fas fa-map-marker-alt"></i> <%= h(e.getLocation()) %></div>
                    <% } %>
                    <div><i class="fas fa-play-circle"></i> Starts: <%= h(e.getStartsAt()) %></div>
                    <div><i class="fas fa-stop-circle"></i> Ends: &nbsp;&nbsp;<%= h(e.getEndsAt()) %></div>
                    <div style="margin-top:4px; color:var(--text-muted); font-size:10px;">Registered <%= h(e.getJoinedAt()) %></div>
                </div>
            </div>
        <%  } %>
        </div>
        <% } %>

        <!-- ══ COMPLETED EVENTS ══ -->
        <div class="section-header" style="margin-top:32px;">
            <h3><i class="fas fa-history" style="color:#38c9b0;"></i> Completed Events</h3>
            <span class="count-pill pill-teal"><%= past.size() %></span>
        </div>

        <% if (past.isEmpty()) { %>
        <div class="empty-state">
            <i class="fas fa-history"></i>
            <p>No completed events yet. Keep going!</p>
        </div>
        <% } else { %>
        <div class="hist-table-wrap">
            <table class="hist-table">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Event</th>
                        <th>Location</th>
                        <th>Ended</th>
                        <th>Attendance</th>
                        <th>Points</th>
                        <th>Marked</th>
                    </tr>
                </thead>
                <tbody>
                <%  int rowNum = 0;
                    for (VolunteerAssignmentEntry e : past) {
                        rowNum++;
                %>
                    <tr>
                        <td class="muted"><%= rowNum %></td>
                        <td>
                            <div style="font-weight:600;"><%= h(e.getTitle()) %></div>
                            <span class="badge <%= "opened".equals(e.getEventStatus()) ? "badge-opened" : "badge-closed" %>" style="font-size:10px; padding:2px 7px; margin-top:3px;">
                                <span class="badge-dot"></span><%= "opened".equals(e.getEventStatus()) ? "Open" : "Closed" %>
                            </span>
                        </td>
                        <td class="muted">
                            <%= e.getLocation().isEmpty() ? "<span style='opacity:.4'>—</span>" : h(e.getLocation()) %>
                        </td>
                        <td class="muted"><%= h(e.getEndsAt()) %></td>
                        <td>
                            <% if (!e.isHasAssignment()) { %>
                            <span style="font-size:12px; color:var(--text-muted);">Pending review</span>
                            <% } else if (e.isAttended()) { %>
                            <span class="badge badge-attended"><i class="fas fa-check" style="font-size:9px;"></i> Attended</span>
                            <% } else { %>
                            <span class="badge badge-absent"><i class="fas fa-times" style="font-size:9px;"></i> Absent</span>
                            <% } %>
                        </td>
                        <td>
                            <% if (e.isAttended() && e.getPointsEarned() > 0) { %>
                            <span class="pts-chip"><i class="fas fa-star" style="font-size:9px;"></i> +<%= e.getPointsEarned() %></span>
                            <% } else if (!e.isHasAssignment()) { %>
                            <span class="pts-chip pts-chip-muted">—</span>
                            <% } else { %>
                            <span class="pts-chip pts-chip-muted">0</span>
                            <% } %>
                        </td>
                        <td class="muted">
                            <%= e.getMarkedAt().isEmpty() ? "<span style='opacity:.4'>—</span>" : h(e.getMarkedAt()) %>
                        </td>
                    </tr>
                <%  } %>
                </tbody>
            </table>
        </div>
        <% } %>

    </div><!-- page-body -->
</div><!-- main -->

<script>
(function() {
    const flash = document.getElementById('flashMsg');
    if (flash) setTimeout(function() {
        flash.style.transition = 'opacity .5s';
        flash.style.opacity    = '0';
        setTimeout(function() { flash.remove(); }, 500);
    }, 4000);
})();
</script>

</body>
</html>
