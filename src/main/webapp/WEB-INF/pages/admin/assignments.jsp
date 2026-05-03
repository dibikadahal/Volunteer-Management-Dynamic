<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.VMS.model.EventVolunteerEntry, java.util.List, java.util.Map" %>
<%!
    private static String esc(String s) {
        if (s == null) return "";
        return s.replace("\\","\\\\").replace("'","\\'")
                .replace("\r","").replace("\n","\\n")
                .replace("<","\\x3C").replace(">","\\x3E");
    }
    private static String h(String s) {
        if (s == null) return "";
        return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
                .replace("\"","&quot;").replace("'","&#39;");
    }
    private static final String[] AV_COLORS = {"av-purple","av-blue","av-teal","av-amber","av-pink"};
%>
<%
    String adminName = (String) session.getAttribute("userName");
    if (adminName == null) adminName = "Admin";
    String initials = adminName.length() > 0 ? String.valueOf(adminName.charAt(0)).toUpperCase() : "A";

    @SuppressWarnings("unchecked")
    List<Map<String,Object>> events = (List<Map<String,Object>>) request.getAttribute("events");
    if (events == null) events = new java.util.ArrayList<>();

    @SuppressWarnings("unchecked")
    List<EventVolunteerEntry> eventVolunteers = (List<EventVolunteerEntry>) request.getAttribute("eventVolunteers");

    @SuppressWarnings("unchecked")
    Map<String,Object> selectedEvent = (Map<String,Object>) request.getAttribute("selectedEvent");
    String selectedEventId = (String) request.getAttribute("selectedEventId");
    if (selectedEventId == null) selectedEventId = "";

    int totalEvents        = request.getAttribute("totalEvents")        != null ? (Integer) request.getAttribute("totalEvents")        : 0;
    int totalAttended      = request.getAttribute("totalAttended")      != null ? (Integer) request.getAttribute("totalAttended")      : 0;
    int totalPointsAwarded = request.getAttribute("totalPointsAwarded") != null ? (Integer) request.getAttribute("totalPointsAwarded") : 0;
    int pendingCount       = request.getAttribute("pendingCount")       != null ? (Integer) request.getAttribute("pendingCount")       : 0;

    // Compute total accepted across all events
    int totalAccepted = 0;
    for (Map<String,Object> ev : events) {
        Object ac = ev.get("acceptedCount");
        if (ac instanceof Integer) totalAccepted += (Integer) ac;
    }

    // Is the selected event in the past?
    boolean selectedIsPast = selectedEvent != null && Boolean.TRUE.equals(selectedEvent.get("isPast"));
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Assignments – VolunteerHub</title>
    <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
    <style>
        /* ══ SHARED TABLE STYLES ══ */
        .assign-table-wrap { overflow-x:auto; border-radius:var(--radius); border:1px solid var(--border); background:var(--bg-card); }
        .assign-table { width:100%; border-collapse:collapse; font-size:13px; }
        .assign-table thead th { background:rgba(124,92,191,.08); color:var(--text-secondary); font-size:11px; text-transform:uppercase; letter-spacing:.8px; padding:13px 16px; text-align:left; white-space:nowrap; }
        .assign-table tbody tr { border-top:1px solid var(--border); transition:background .15s; }
        .assign-table tbody tr.clickable { cursor:pointer; }
        .assign-table tbody tr.clickable:hover { background:rgba(124,92,191,.06); }
        .assign-table tbody tr.selected-row { background:rgba(124,92,191,.12) !important; }
        .assign-table td { padding:12px 16px; color:var(--text-primary); vertical-align:middle; }
        .assign-table td.muted { color:var(--text-secondary); font-size:12px; }

        /* ══ BADGES ══ */
        .badge { display:inline-flex; align-items:center; gap:5px; padding:4px 10px; border-radius:20px; font-size:11px; font-weight:700; letter-spacing:.4px; white-space:nowrap; }
        .badge-dot { width:6px; height:6px; border-radius:50%; background:currentColor; }
        .badge-opened   { background:rgba(56,201,176,.15);   color:#38c9b0; border:1px solid rgba(56,201,176,.3); }
        .badge-closed   { background:rgba(100,100,120,.15);  color:var(--text-secondary); border:1px solid var(--border); }
        .badge-pending  { background:rgba(245,166,35,.12);   color:#f5a623; border:1px solid rgba(245,166,35,.3); }
        .badge-accepted { background:rgba(56,201,176,.15);   color:#38c9b0; border:1px solid rgba(56,201,176,.3); }
        .badge-declined { background:rgba(224,92,151,.12);   color:#e05c97; border:1px solid rgba(224,92,151,.25); }
        .badge-attended { background:rgba(56,201,176,.15);   color:#38c9b0; border:1px solid rgba(56,201,176,.3); }
        .badge-absent   { background:rgba(224,92,151,.12);   color:#e05c97; border:1px solid rgba(224,92,151,.25); }
        .badge-upcoming { background:rgba(79,142,247,.12);   color:#4f8ef7; border:1px solid rgba(79,142,247,.25); }

        /* ══ COUNT PILLS ══ */
        .count-pill { display:inline-flex; align-items:center; gap:4px; padding:3px 9px; border-radius:12px; font-size:11px; font-weight:700; }
        .pill-yellow { background:rgba(245,166,35,.12); color:#f5a623; border:1px solid rgba(245,166,35,.25); }
        .pill-green  { background:rgba(56,201,176,.12); color:#38c9b0; border:1px solid rgba(56,201,176,.25); }
        .pill-blue   { background:rgba(79,142,247,.12); color:#4f8ef7; border:1px solid rgba(79,142,247,.25); }

        /* ══ ACTION BUTTONS ══ */
        .btn-sm { padding:5px 11px; border-radius:7px; font-size:11px; font-weight:600; border:none; cursor:pointer; transition:opacity .2s; display:inline-flex; align-items:center; gap:4px; font-family:inherit; }
        .btn-manage  { background:rgba(124,92,191,.12); color:#9b7de8; border:1px solid rgba(124,92,191,.25); }
        .btn-accept  { background:rgba(56,201,176,.12); color:#38c9b0; border:1px solid rgba(56,201,176,.25); }
        .btn-decline { background:rgba(224,92,151,.12); color:#e05c97; border:1px solid rgba(224,92,151,.25); }
        .btn-attend  { background:rgba(56,201,176,.12); color:#38c9b0; border:1px solid rgba(56,201,176,.25); }
        .btn-absent  { background:rgba(245,166,35,.12); color:#f5a623; border:1px solid rgba(245,166,35,.25); }
        .btn-sm:hover { opacity:.75; }

        /* ══ VOLUNTEER CELL ══ */
        .vol-cell { display:flex; align-items:center; gap:10px; }
        .vol-av { width:34px; height:34px; border-radius:50%; flex-shrink:0; display:flex; align-items:center; justify-content:center; font-size:12px; font-weight:700; color:#fff; overflow:hidden; }
        .vol-av img { width:100%; height:100%; object-fit:cover; }
        .vol-av.av-purple { background:linear-gradient(135deg,#7c5cbf,#4f8ef7); }
        .vol-av.av-blue   { background:linear-gradient(135deg,#4f8ef7,#38c9b0); }
        .vol-av.av-teal   { background:linear-gradient(135deg,#38c9b0,#4fb9f7); }
        .vol-av.av-amber  { background:linear-gradient(135deg,#f5a623,#e05c97); }
        .vol-av.av-pink   { background:linear-gradient(135deg,#e05c97,#7c5cbf); }

        /* ══ POINTS CHIP ══ */
        .pts-chip { display:inline-flex; align-items:center; gap:4px; padding:3px 8px; border-radius:10px; font-size:11px; font-weight:700; background:rgba(245,166,35,.12); color:#f5a623; border:1px solid rgba(245,166,35,.25); }

        /* ══ EVENT TITLE CELL ══ */
        .ev-cell { display:flex; align-items:center; gap:10px; }
        .ev-icon { width:36px; height:36px; border-radius:8px; flex-shrink:0; display:flex; align-items:center; justify-content:center; background:rgba(79,142,247,.1); color:#4f8ef7; font-size:14px; }
        .ev-title { font-weight:600; color:var(--text-primary); line-height:1.3; }
        .ev-loc   { font-size:11px; color:var(--text-muted); margin-top:2px; }

        /* ══ MANAGEMENT PANEL ══ */
        .mgmt-panel { margin-top:24px; border-radius:var(--radius); border:1px solid rgba(124,92,191,.3); background:var(--bg-card); overflow:hidden; }
        .mgmt-panel-header { display:flex; align-items:center; justify-content:space-between; padding:16px 20px; border-bottom:1px solid var(--border); background:rgba(124,92,191,.05); }
        .mgmt-panel-header h3 { margin:0; font-size:14px; font-weight:700; color:var(--text-primary); display:flex; align-items:center; gap:8px; }
        .mgmt-panel-header .close-btn { padding:5px 12px; border-radius:7px; font-size:11px; font-weight:600; background:rgba(255,255,255,.06); color:var(--text-secondary); border:1px solid var(--border); text-decoration:none; }

        /* ══ EMPTY STATE ══ */
        .empty-row td { text-align:center; padding:40px; color:var(--text-muted); font-size:13px; }
        .empty-row td i { font-size:32px; display:block; margin-bottom:12px; opacity:.25; }

        /* ══ FLASH ══ */
        #flashMsg { padding:12px 16px; border-radius:10px; font-size:13px; margin-bottom:20px; display:flex; align-items:center; gap:8px; }
        .flash-ok  { background:rgba(56,201,176,.12); border:1px solid rgba(56,201,176,.25); color:#38c9b0; }
        .flash-err { background:rgba(224,92,151,.12); border:1px solid rgba(224,92,151,.25); color:#e05c97; }
    </style>
</head>
<body>

<!-- ══ SIDEBAR OVERLAY (mobile) ══ -->
<div class="sidebar-overlay" id="sidebarOverlay" onclick="closeSidebar()"></div>

<!-- ══ SIDEBAR ══ -->
<aside class="sidebar">
    <div class="sidebar-logo"><div class="logo-icon">&#9825;</div><span>VolunteerHub</span></div>
    <div class="sidebar-section-label">Main Menu</div>
    <a href="${pageContext.request.contextPath}/admin/dashboard" class="nav-item"><i class="fas fa-th-large"></i> Dashboard</a>
    <div class="sidebar-section-label">Management</div>
    <a href="${pageContext.request.contextPath}/admin/volunteers" class="nav-item"><i class="fas fa-users"></i> Volunteer Management</a>
    <a href="${pageContext.request.contextPath}/admin/events" class="nav-item"><i class="fas fa-calendar-alt"></i> Event Management</a>
    <a href="${pageContext.request.contextPath}/admin/calendar" class="nav-item"><i class="fas fa-calendar-week"></i> Calendar</a>
    <a href="${pageContext.request.contextPath}/admin/assignments" class="nav-item active"><i class="fas fa-link"></i> Assignments</a>
    <div class="sidebar-section-label">Account</div>
    <a href="${pageContext.request.contextPath}/admin/profile" class="nav-item"><i class="fas fa-user-circle"></i> Profile Management</a>
    <div class="sidebar-bottom">
        <a href="${pageContext.request.contextPath}/logout" class="nav-item logout-link"><i class="fas fa-sign-out-alt"></i> Logout</a>
    </div>
</aside>

<!-- ══ MAIN ══ -->
<div class="main">
    <div class="topbar">
        <div class="topbar-left">
            <button class="menu-toggle" onclick="toggleSidebar()" aria-label="Toggle menu">
                <i class="fas fa-bars"></i>
            </button>
            <div class="topbar-left-text">
                <h2>Assignments</h2>
                <p>Connect events with volunteers and track attendance &amp; reward points</p>
            </div>
        </div>
        <div class="topbar-right">
            <div class="topbar-icon-btn"><i class="fas fa-bell"></i></div>
            <a href="${pageContext.request.contextPath}/admin/profile" style="text-decoration:none;">
                <div class="admin-avatar"><%= initials %></div>
            </a>
        </div>
    </div>

    <div class="page-body">

        <%-- Flash messages --%>
        <% if (request.getParameter("success") != null) { %>
        <div id="flashMsg" class="flash-ok"><i class="fas fa-check-circle"></i> <%= h(request.getParameter("success")) %></div>
        <% } %>
        <% if (request.getParameter("error") != null) { %>
        <div id="flashMsg" class="flash-err"><i class="fas fa-exclamation-circle"></i> <%= h(request.getParameter("error")) %></div>
        <% } %>

        <!-- Stats -->
        <div class="stats-grid">
            <div class="stat-card purple">
                <div class="stat-icon"><i class="fas fa-calendar-alt"></i></div>
                <div class="stat-value"><%= totalEvents %></div>
                <div class="stat-label">Total Events</div>
                <div class="stat-change"><i class="fas fa-list"></i> All events</div>
            </div>
            <div class="stat-card blue">
                <div class="stat-icon"><i class="fas fa-user-check"></i></div>
                <div class="stat-value"><%= totalAccepted %></div>
                <div class="stat-label">Accepted Volunteers</div>
                <div class="stat-change up"><i class="fas fa-handshake"></i> Across all events</div>
            </div>
            <div class="stat-card teal">
                <div class="stat-icon"><i class="fas fa-calendar-check"></i></div>
                <div class="stat-value"><%= totalAttended %></div>
                <div class="stat-label">Total Attended</div>
                <div class="stat-change up"><i class="fas fa-check"></i> Attendance marked</div>
            </div>
            <div class="stat-card amber">
                <div class="stat-icon"><i class="fas fa-star"></i></div>
                <div class="stat-value"><%= totalPointsAwarded %></div>
                <div class="stat-label">Points Awarded</div>
                <div class="stat-change up"><i class="fas fa-award"></i> Across all volunteers</div>
            </div>
        </div>

        <!-- Events Table -->
        <div style="font-size:12px; color:var(--text-muted); margin-bottom:10px;">
            Click <strong style="color:#9b7de8;">Manage</strong> on any event to view and manage its volunteers.
        </div>

        <div class="assign-table-wrap">
            <table class="assign-table">
                <thead>
                    <tr>
                        <th style="width:36px;">#</th>
                        <th>Event</th>
                        <th>Status</th>
                        <th>Starts</th>
                        <th>Ends</th>
                        <th>Pending</th>
                        <th>Accepted</th>
                        <th>Attended</th>
                        <th style="width:100px;">Action</th>
                    </tr>
                </thead>
                <tbody>
                <%  if (events.isEmpty()) { %>
                    <tr class="empty-row">
                        <td colspan="9"><i class="fas fa-calendar-times"></i>No events found. Create events first.</td>
                    </tr>
                <%  } else {
                        int rowNum = 0;
                        for (Map<String,Object> ev : events) {
                            rowNum++;
                            String evId       = (String) ev.get("id");
                            String evTitle    = (String) ev.get("title");
                            String evLoc      = (String) ev.get("location");
                            String evStatus   = (String) ev.get("status");
                            String evStartsAt = (String) ev.get("startsAt");
                            String evEndsAt   = (String) ev.get("endsAt");
                            int    evPending  = ev.get("pendingCount")  instanceof Integer ? (Integer) ev.get("pendingCount")  : 0;
                            int    evAccepted = ev.get("acceptedCount") instanceof Integer ? (Integer) ev.get("acceptedCount") : 0;
                            int    evAttended = ev.get("attendedCount") instanceof Integer ? (Integer) ev.get("attendedCount") : 0;
                            boolean isSelected = evId.equals(selectedEventId);
                            String rowClass = isSelected ? "clickable selected-row" : "clickable";
                %>
                    <tr class="<%= rowClass %>">
                        <td class="muted"><%= rowNum %></td>
                        <td>
                            <div class="ev-cell">
                                <div class="ev-icon"><i class="fas fa-calendar-alt"></i></div>
                                <div>
                                    <div class="ev-title"><%= h(evTitle) %></div>
                                    <% if (!evLoc.isEmpty()) { %>
                                    <div class="ev-loc"><i class="fas fa-map-marker-alt" style="font-size:9px;"></i> <%= h(evLoc) %></div>
                                    <% } %>
                                </div>
                            </div>
                        </td>
                        <td>
                            <span class="badge <%= "opened".equals(evStatus) ? "badge-opened" : "badge-closed" %>">
                                <span class="badge-dot"></span><%= "opened".equals(evStatus) ? "Open" : "Closed" %>
                            </span>
                        </td>
                        <td class="muted"><%= h(evStartsAt) %></td>
                        <td class="muted"><%= h(evEndsAt) %></td>
                        <td>
                            <% if (evPending > 0) { %>
                            <span class="count-pill pill-yellow"><%= evPending %></span>
                            <% } else { %><span style="color:var(--text-muted);font-size:12px;">—</span><% } %>
                        </td>
                        <td>
                            <% if (evAccepted > 0) { %>
                            <span class="count-pill pill-green"><%= evAccepted %></span>
                            <% } else { %><span style="color:var(--text-muted);font-size:12px;">—</span><% } %>
                        </td>
                        <td>
                            <% if (evAttended > 0) { %>
                            <span class="count-pill pill-blue"><%= evAttended %></span>
                            <% } else { %><span style="color:var(--text-muted);font-size:12px;">—</span><% } %>
                        </td>
                        <td>
                            <a href="?eventId=<%= h(evId) %>"
                               class="btn-sm btn-manage" onclick="event.stopPropagation()">
                                <i class="fas fa-users-cog"></i> Manage
                            </a>
                        </td>
                    </tr>
                <%      }
                    }
                %>
                </tbody>
            </table>
        </div>

        <%-- ════ VOLUNTEER MANAGEMENT PANEL ════ --%>
        <% if (selectedEvent != null && eventVolunteers != null) {
            String selTitle  = (String) selectedEvent.get("title");
            String selStatus = (String) selectedEvent.get("status");
        %>
        <div class="mgmt-panel" id="mgmtPanel">
            <div class="mgmt-panel-header">
                <h3>
                    <i class="fas fa-users-cog" style="color:#9b7de8;"></i>
                    Volunteers for: <em style="color:#9b7de8; font-style:normal;"><%= h(selTitle) %></em>
                    <span class="badge <%= "opened".equals(selStatus) ? "badge-opened" : "badge-closed" %>" style="font-size:10px; margin-left:6px;">
                        <span class="badge-dot"></span><%= "opened".equals(selStatus) ? "Open" : "Closed" %>
                    </span>
                    <% if (selectedIsPast) { %>
                    <span class="badge badge-closed" style="font-size:10px; margin-left:4px;"><i class="fas fa-history" style="font-size:9px;"></i> Past Event</span>
                    <% } else { %>
                    <span class="badge badge-upcoming" style="font-size:10px; margin-left:4px;"><i class="fas fa-clock" style="font-size:9px;"></i> Upcoming</span>
                    <% } %>
                </h3>
                <a href="${pageContext.request.contextPath}/admin/assignments" class="close-btn">
                    <i class="fas fa-times"></i> Close
                </a>
            </div>

            <div style="padding:16px 20px;">
                <% if (eventVolunteers.isEmpty()) { %>
                <div style="text-align:center; padding:36px; color:var(--text-muted); font-size:13px;">
                    <i class="fas fa-user-slash" style="font-size:28px; display:block; margin-bottom:10px; opacity:.25;"></i>
                    No volunteers have registered for this event yet.
                </div>
                <% } else { %>
                <div class="assign-table-wrap" style="border:none; border-radius:0;">
                    <table class="assign-table">
                        <thead>
                            <tr>
                                <th style="width:36px;">#</th>
                                <th>Volunteer</th>
                                <th>Email</th>
                                <th>Registered</th>
                                <th>Status</th>
                                <th>Attendance</th>
                                <th>Points</th>
                                <th style="width:180px;">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                        <%
                            int vRowNum = 0;
                            for (EventVolunteerEntry v : eventVolunteers) {
                                vRowNum++;
                                String avColor  = AV_COLORS[(vRowNum - 1) % AV_COLORS.length];
                                String vImg     = v.getImage() != null && !v.getImage().isEmpty() ? v.getImage() : "";
                                String vStatus  = v.getVolunteerStatus();
                                boolean vAcc    = "accepted".equals(vStatus);
                                boolean vPend   = "pending".equals(vStatus);
                                boolean vDec    = "declined".equals(vStatus);
                                boolean vAttended = v.isAttended();
                                boolean vHasAssign = v.isHasAssignment();
                        %>
                            <tr>
                                <td class="muted"><%= vRowNum %></td>
                                <td>
                                    <div class="vol-cell">
                                        <div class="vol-av <%= vImg.isEmpty() ? avColor : "" %>">
                                            <% if (!vImg.isEmpty()) { %>
                                                <img src="${pageContext.request.contextPath}/<%= h(vImg) %>" alt="">
                                            <% } else { %><%= h(v.getInitials()) %><% } %>
                                        </div>
                                        <div>
                                            <div style="font-weight:600; font-size:13px;"><%= h(v.getFullName()) %></div>
                                            <div style="font-size:11px; color:var(--text-muted);">@<%= h(v.getUsername()) %></div>
                                        </div>
                                    </div>
                                </td>
                                <td class="muted"><%= h(v.getEmail()) %></td>
                                <td class="muted"><%= h(v.getJoinedAt()) %></td>
                                <td>
                                    <% if (vPend) { %>
                                    <span class="badge badge-pending"><span class="badge-dot"></span>Pending</span>
                                    <% } else if (vAcc) { %>
                                    <span class="badge badge-accepted"><span class="badge-dot"></span>Accepted</span>
                                    <% } else { %>
                                    <span class="badge badge-declined"><span class="badge-dot"></span>Declined</span>
                                    <% } %>
                                </td>
                                <td>
                                    <% if (!vAcc) { %>
                                    <span style="font-size:12px; color:var(--text-muted);">—</span>
                                    <% } else if (!vHasAssign) { %>
                                    <span style="font-size:12px; color:var(--text-muted);">Not tracked</span>
                                    <% } else if (vAttended) { %>
                                    <span class="badge badge-attended"><i class="fas fa-check" style="font-size:9px;"></i> Attended</span>
                                    <% } else if (selectedIsPast) { %>
                                    <span class="badge badge-absent"><i class="fas fa-times" style="font-size:9px;"></i> Absent</span>
                                    <% } else { %>
                                    <span class="badge badge-upcoming"><i class="fas fa-clock" style="font-size:9px;"></i> Upcoming</span>
                                    <% } %>
                                </td>
                                <td>
                                    <% if (vAttended && v.getPointsEarned() > 0) { %>
                                    <span class="pts-chip"><i class="fas fa-star" style="font-size:9px;"></i> +<%= v.getPointsEarned() %> pts</span>
                                    <% } else { %>
                                    <span style="font-size:12px; color:var(--text-muted);">—</span>
                                    <% } %>
                                </td>
                                <td>
                                    <div style="display:flex; gap:5px; flex-wrap:wrap;">
                                        <% if (vPend) { %>
                                        <form method="POST" action="${pageContext.request.contextPath}/admin/assignments" style="display:inline;">
                                            <input type="hidden" name="action"  value="accept">
                                            <input type="hidden" name="userId"  value="<%= h(v.getUserId()) %>">
                                            <input type="hidden" name="eventId" value="<%= h(selectedEventId) %>">
                                            <button type="submit" class="btn-sm btn-accept"><i class="fas fa-check"></i> Accept</button>
                                        </form>
                                        <form method="POST" action="${pageContext.request.contextPath}/admin/assignments" style="display:inline;">
                                            <input type="hidden" name="action"  value="decline">
                                            <input type="hidden" name="userId"  value="<%= h(v.getUserId()) %>">
                                            <input type="hidden" name="eventId" value="<%= h(selectedEventId) %>">
                                            <button type="submit" class="btn-sm btn-decline"><i class="fas fa-times"></i> Decline</button>
                                        </form>
                                        <% } else if (vAcc && vHasAssign) { %>
                                        <% if (!vAttended) { %>
                                        <form method="POST" action="${pageContext.request.contextPath}/admin/assignments" style="display:inline;">
                                            <input type="hidden" name="action"  value="mark-attended">
                                            <input type="hidden" name="userId"  value="<%= h(v.getUserId()) %>">
                                            <input type="hidden" name="eventId" value="<%= h(selectedEventId) %>">
                                            <button type="submit" class="btn-sm btn-attend"><i class="fas fa-check-circle"></i> Mark Attended</button>
                                        </form>
                                        <% } else { %>
                                        <form method="POST" action="${pageContext.request.contextPath}/admin/assignments" style="display:inline;">
                                            <input type="hidden" name="action"  value="mark-absent">
                                            <input type="hidden" name="userId"  value="<%= h(v.getUserId()) %>">
                                            <input type="hidden" name="eventId" value="<%= h(selectedEventId) %>">
                                            <button type="submit" class="btn-sm btn-absent"><i class="fas fa-undo"></i> Mark Absent</button>
                                        </form>
                                        <% } %>
                                        <% } else if (vAcc && !vHasAssign) { %>
                                        <span style="font-size:11px; color:var(--text-muted);">No record</span>
                                        <% } else { %>
                                        <span style="font-size:11px; color:var(--text-muted);">—</span>
                                        <% } %>
                                    </div>
                                </td>
                            </tr>
                        <%  } %>
                        </tbody>
                    </table>
                </div>
                <% } %>
            </div>
        </div>

        <% } // end if selectedEvent %>

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

    // Smooth scroll to management panel when it appears
    const panel = document.getElementById('mgmtPanel');
    if (panel) setTimeout(function() {
        panel.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }, 120);
})();

// ── Mobile sidebar toggle ──
function toggleSidebar() {
    document.querySelector('.sidebar').classList.toggle('open');
    document.getElementById('sidebarOverlay').classList.toggle('active');
}
function closeSidebar() {
    document.querySelector('.sidebar').classList.remove('open');
    document.getElementById('sidebarOverlay').classList.remove('active');
}
</script>

</body>
</html>
