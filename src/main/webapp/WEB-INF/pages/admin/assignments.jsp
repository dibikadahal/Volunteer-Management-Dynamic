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

        /* ══ VOLUNTEER MODAL ══ */
        .vol-modal-overlay {
            display:none; position:fixed; inset:0;
            background:rgba(0,0,0,.72); z-index:800;
            align-items:center; justify-content:center;
            backdrop-filter:blur(5px); padding:20px;
        }
        .vol-modal-overlay.open { display:flex; }
        .vol-modal {
            background:var(--bg-card); border:1px solid rgba(124,92,191,.35);
            border-radius:18px; width:100%; max-width:780px; max-height:88vh;
            display:flex; flex-direction:column; overflow:hidden;
            animation:fadeUp .22s ease; box-shadow:0 24px 64px rgba(0,0,0,.55);
        }
        .vol-modal-header {
            padding:20px 24px 16px; border-bottom:1px solid var(--border);
            background:rgba(124,92,191,.06); flex-shrink:0;
            display:flex; align-items:flex-start; justify-content:space-between; gap:12px;
        }
        .vol-modal-title { font-family:'Sora',sans-serif; font-size:15px; font-weight:700; color:var(--text-primary); margin-bottom:8px; }
        .vol-modal-meta  { display:flex; align-items:center; gap:8px; flex-wrap:wrap; }
        .vol-modal-close {
            width:32px; height:32px; border-radius:8px; flex-shrink:0;
            background:rgba(255,255,255,.06); border:1px solid var(--border);
            color:var(--text-secondary); cursor:pointer;
            display:flex; align-items:center; justify-content:center; font-size:13px;
            transition:background .15s,color .15s; text-decoration:none;
        }
        .vol-modal-close:hover { background:rgba(255,255,255,.12); color:var(--text-primary); }
        .vol-modal-body  { overflow-y:auto; flex:1; padding:18px 24px; }

        /* volunteer cards inside modal */
        .vol-summary { display:flex; gap:10px; flex-wrap:wrap; margin-bottom:16px; }
        .vol-card {
            display:flex; align-items:flex-start; gap:14px;
            padding:14px 16px; border-radius:12px;
            border:1px solid var(--border); background:rgba(255,255,255,.025);
            margin-bottom:10px; transition:background .15s;
        }
        .vol-card:last-child { margin-bottom:0; }
        .vol-card:hover { background:rgba(124,92,191,.06); }
        .vol-card-av {
            width:46px; height:46px; border-radius:50%; flex-shrink:0;
            display:flex; align-items:center; justify-content:center;
            font-size:15px; font-weight:700; color:#fff; overflow:hidden;
        }
        .vol-card-av img { width:100%; height:100%; object-fit:cover; }
        .vol-card-av.av-purple { background:linear-gradient(135deg,#7c5cbf,#4f8ef7); }
        .vol-card-av.av-blue   { background:linear-gradient(135deg,#4f8ef7,#38c9b0); }
        .vol-card-av.av-teal   { background:linear-gradient(135deg,#38c9b0,#2dd4bf); }
        .vol-card-av.av-amber  { background:linear-gradient(135deg,#f5a623,#e05c97); }
        .vol-card-av.av-pink   { background:linear-gradient(135deg,#e05c97,#7c5cbf); }
        .vol-card-info  { flex:1; min-width:0; }
        .vol-card-name  { font-weight:700; font-size:14px; color:var(--text-primary); }
        .vol-card-sub   { font-size:12px; color:var(--text-secondary); margin-top:2px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
        .vol-card-chips { display:flex; align-items:center; gap:7px; margin-top:8px; flex-wrap:wrap; }
        .vol-card-actions { display:flex; flex-direction:column; gap:5px; flex-shrink:0; align-items:flex-end; justify-content:center; min-width:96px; }

        @media (max-width:600px) {
            .vol-card { flex-wrap:wrap; }
            .vol-card-actions { flex-direction:row; min-width:auto; margin-top:8px; }
        }

        /* ══ EMPTY STATE ══ */
        .empty-row td { text-align:center; padding:40px; color:var(--text-muted); font-size:13px; }
        .empty-row td i { font-size:32px; display:block; margin-bottom:12px; opacity:.25; }

        /* ══ FLASH ══ */
        #flashMsg { padding:12px 16px; border-radius:10px; font-size:13px; margin-bottom:20px; display:flex; align-items:center; gap:8px; }
        .flash-ok  { background:rgba(56,201,176,.12); border:1px solid rgba(56,201,176,.25); color:#38c9b0; }
        .flash-err { background:rgba(224,92,151,.12); border:1px solid rgba(224,92,151,.25); color:#e05c97; }

        /* ══ TABLE RESPONSIVE ══ */
        .assign-table-wrap {
            overflow-x: auto;
            -webkit-overflow-scrolling: touch;
        }

        /* ≤ 1024px — hide Ends column */
        @media (max-width: 1024px) {
            .assign-table th:nth-child(5),
            .assign-table td:nth-child(5) { display: none; }
        }

        /* ≤ 768px — also hide Starts column, shrink padding */
        @media (max-width: 768px) {
            .assign-table th:nth-child(4),
            .assign-table td:nth-child(4) { display: none; }
            .assign-table td,
            .assign-table thead th { padding: 10px 10px; font-size: 12px; }
            .ev-icon { display: none; }
            .ev-title { font-size: 13px; }
            .ev-loc   { display: none; }
            .stats-grid { grid-template-columns: repeat(2,1fr) !important; gap: 10px !important; }
        }

        /* ≤ 560px — also hide Status column, shrink further */
        @media (max-width: 560px) {
            .assign-table th:nth-child(3),
            .assign-table td:nth-child(3) { display: none; }
            .assign-table td,
            .assign-table thead th { padding: 8px 8px; font-size: 11px; }
            .count-pill { font-size: 10px; padding: 2px 7px; }
            .btn-sm     { font-size: 10px; padding: 4px 8px; }
        }

        /* ≤ 400px — hide Pending & Accepted, keep only Attended + Action */
        @media (max-width: 400px) {
            .assign-table th:nth-child(6),
            .assign-table td:nth-child(6),
            .assign-table th:nth-child(7),
            .assign-table td:nth-child(7) { display: none; }
            .stats-grid { grid-template-columns: 1fr !important; }
        }

        /* modal mobile */
        @media (max-width: 600px) {
            .vol-modal { border-radius: 14px; }
            .vol-modal-header { padding: 14px 16px 12px; }
            .vol-modal-body   { padding: 12px 16px; }
            .vol-card { gap: 10px; }
            .vol-card-actions { min-width: auto; }
        }
    </style>
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
    <div class="sidebar-logo"><div class="logo-icon"><i class="fas fa-heart"></i></div><span>VolunteerHub</span></div>
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
            <div class="stat-card">
                <div class="stat-icon"><i class="fas fa-calendar-alt"></i></div>
                <div class="stat-value"><%= totalEvents %></div>
                <div class="stat-label">Total Events</div>
                <div class="stat-change"><i class="fas fa-list"></i> All events</div>
            </div>
            <div class="stat-card">
                <div class="stat-icon"><i class="fas fa-user-check"></i></div>
                <div class="stat-value"><%= totalAccepted %></div>
                <div class="stat-label">Accepted Volunteers</div>
                <div class="stat-change up"><i class="fas fa-handshake"></i> Across all events</div>
            </div>
            <div class="stat-card">
                <div class="stat-icon"><i class="fas fa-calendar-check"></i></div>
                <div class="stat-value"><%= totalAttended %></div>
                <div class="stat-label">Total Attended</div>
                <div class="stat-change up"><i class="fas fa-check"></i> Attendance marked</div>
            </div>
            <div class="stat-card">
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

        <%-- ════ VOLUNTEER MODAL ════ --%>
        <% if (selectedEvent != null && eventVolunteers != null) {
            String selTitle  = (String) selectedEvent.get("title");
            String selStatus = (String) selectedEvent.get("status");
            int cntPending = 0, cntAccepted = 0, cntDeclined = 0;
            for (EventVolunteerEntry v : eventVolunteers) {
                String vs = v.getVolunteerStatus();
                if ("pending".equals(vs))       cntPending++;
                else if ("accepted".equals(vs)) cntAccepted++;
                else if ("declined".equals(vs)) cntDeclined++;
            }
        %>
        <div class="vol-modal-overlay open" id="volModal">
            <div class="vol-modal">

                <%-- Header --%>
                <div class="vol-modal-header">
                    <div style="min-width:0;">
                        <div class="vol-modal-title">
                            <i class="fas fa-users-cog" style="color:#9b7de8; margin-right:6px;"></i>
                            <%= h(selTitle) %>
                        </div>
                        <div class="vol-modal-meta">
                            <span class="badge <%= "opened".equals(selStatus) ? "badge-opened" : "badge-closed" %>">
                                <span class="badge-dot"></span><%= "opened".equals(selStatus) ? "Open" : "Closed" %>
                            </span>
                            <% if (selectedIsPast) { %>
                            <span class="badge badge-closed"><i class="fas fa-history" style="font-size:9px; margin-right:3px;"></i>Past event</span>
                            <% } else { %>
                            <span class="badge badge-upcoming"><i class="fas fa-clock" style="font-size:9px; margin-right:3px;"></i>Upcoming</span>
                            <% } %>
                            <span style="font-size:12px; color:var(--text-muted);">
                                <%= eventVolunteers.size() %> volunteer<%= eventVolunteers.size() != 1 ? "s" : "" %>
                            </span>
                        </div>
                    </div>
                    <a href="${pageContext.request.contextPath}/admin/assignments"
                       class="vol-modal-close" title="Close (Esc)">
                        <i class="fas fa-times"></i>
                    </a>
                </div>

                <%-- Body --%>
                <div class="vol-modal-body">

                    <%-- Summary row --%>
                    <% if (!eventVolunteers.isEmpty()) { %>
                    <div class="vol-summary">
                        <% if (cntPending  > 0) { %><span class="badge badge-pending"><span class="badge-dot"></span><%= cntPending %>  pending</span><% } %>
                        <% if (cntAccepted > 0) { %><span class="badge badge-accepted"><span class="badge-dot"></span><%= cntAccepted %> accepted</span><% } %>
                        <% if (cntDeclined > 0) { %><span class="badge badge-declined"><span class="badge-dot"></span><%= cntDeclined %> declined</span><% } %>
                    </div>
                    <% } %>

                    <% if (eventVolunteers.isEmpty()) { %>
                    <div style="text-align:center; padding:52px 20px; color:var(--text-muted); font-size:13px;">
                        <i class="fas fa-user-slash" style="font-size:34px; display:block; margin-bottom:12px; opacity:.2;"></i>
                        No volunteers have registered for this event yet.
                    </div>
                    <% } else {
                        int vRowNum = 0;
                        for (EventVolunteerEntry v : eventVolunteers) {
                            vRowNum++;
                            String avColor    = AV_COLORS[(vRowNum - 1) % AV_COLORS.length];
                            String vImg       = v.getImage() != null && !v.getImage().isEmpty() ? v.getImage() : "";
                            String vStatus    = v.getVolunteerStatus();
                            boolean vAcc      = "accepted".equals(vStatus);
                            boolean vPend     = "pending".equals(vStatus);
                            boolean vDec      = "declined".equals(vStatus);
                            boolean vAttended  = v.isAttended();
                            boolean vHasAssign = v.isHasAssignment();
                            String  phone      = v.getPhone() != null ? v.getPhone().trim() : "";
                    %>
                    <div class="vol-card">

                        <%-- Avatar --%>
                        <div class="vol-card-av <%= vImg.isEmpty() ? avColor : "" %>">
                            <% if (!vImg.isEmpty()) { %>
                            <img src="${pageContext.request.contextPath}/<%= h(vImg) %>" alt="">
                            <% } else { %><%= h(v.getInitials()) %><% } %>
                        </div>

                        <%-- Info --%>
                        <div class="vol-card-info">
                            <div class="vol-card-name"><%= h(v.getFullName()) %></div>
                            <div class="vol-card-sub">
                                @<%= h(v.getUsername()) %>&ensp;&middot;&ensp;<%= h(v.getEmail()) %>
                                <% if (!phone.isEmpty()) { %>&ensp;&middot;&ensp;<i class="fas fa-phone" style="font-size:10px;opacity:.7;"></i>&thinsp;<%= h(phone) %><% } %>
                            </div>
                            <div class="vol-card-sub" style="margin-top:2px; color:var(--text-muted);">
                                <i class="fas fa-calendar-plus" style="font-size:10px;opacity:.6;"></i>&thinsp;Joined <%= h(v.getJoinedAt()) %>
                            </div>
                            <div class="vol-card-chips">
                                <%-- Volunteer status badge --%>
                                <% if (vPend) { %>
                                <span class="badge badge-pending"><span class="badge-dot"></span>Pending</span>
                                <% } else if (vAcc) { %>
                                <span class="badge badge-accepted"><span class="badge-dot"></span>Accepted</span>
                                <% } else { %>
                                <span class="badge badge-declined"><span class="badge-dot"></span>Declined</span>
                                <% } %>

                                <%-- Attendance badge --%>
                                <% if (vAcc) { %>
                                    <% if (!vHasAssign) { %>
                                    <span style="font-size:11px; color:var(--text-muted);">No assignment record</span>
                                    <% } else if (vAttended) { %>
                                    <span class="badge badge-attended"><i class="fas fa-check" style="font-size:9px;"></i>&nbsp;Attended</span>
                                    <% if (!v.getMarkedAt().isEmpty()) { %>
                                    <span style="font-size:11px; color:var(--text-muted);"><i class="fas fa-clock" style="font-size:9px;"></i>&thinsp;<%= h(v.getMarkedAt()) %></span>
                                    <% } %>
                                    <% } else if (selectedIsPast) { %>
                                    <span class="badge badge-absent"><i class="fas fa-times" style="font-size:9px;"></i>&nbsp;Absent</span>
                                    <% } else { %>
                                    <span class="badge badge-upcoming"><i class="fas fa-clock" style="font-size:9px;"></i>&nbsp;Upcoming</span>
                                    <% } %>
                                <% } %>

                                <%-- Points chip --%>
                                <% if (vAttended && v.getPointsEarned() > 0) { %>
                                <span class="pts-chip"><i class="fas fa-star" style="font-size:9px;"></i>&nbsp;+<%= v.getPointsEarned() %> pts</span>
                                <% } %>
                            </div>
                        </div>

                        <%-- Actions --%>
                        <div class="vol-card-actions">
                            <% if (vPend) { %>
                            <form method="POST" action="${pageContext.request.contextPath}/admin/assignments" style="margin:0;">
                                <input type="hidden" name="action"  value="accept">
                                <input type="hidden" name="userId"  value="<%= h(v.getUserId()) %>">
                                <input type="hidden" name="eventId" value="<%= h(selectedEventId) %>">
                                <button type="submit" class="btn-sm btn-accept" style="width:100%;justify-content:center;">
                                    <i class="fas fa-check"></i> Accept
                                </button>
                            </form>
                            <form method="POST" action="${pageContext.request.contextPath}/admin/assignments" style="margin:0;">
                                <input type="hidden" name="action"  value="decline">
                                <input type="hidden" name="userId"  value="<%= h(v.getUserId()) %>">
                                <input type="hidden" name="eventId" value="<%= h(selectedEventId) %>">
                                <button type="submit" class="btn-sm btn-decline" style="width:100%;justify-content:center;">
                                    <i class="fas fa-times"></i> Decline
                                </button>
                            </form>
                            <% } else if (vAcc && vHasAssign) { %>
                                <% if (!vAttended) { %>
                                <form method="POST" action="${pageContext.request.contextPath}/admin/assignments" style="margin:0;">
                                    <input type="hidden" name="action"  value="mark-attended">
                                    <input type="hidden" name="userId"  value="<%= h(v.getUserId()) %>">
                                    <input type="hidden" name="eventId" value="<%= h(selectedEventId) %>">
                                    <button type="submit" class="btn-sm btn-attend" style="width:100%;justify-content:center;">
                                        <i class="fas fa-check-circle"></i> Attended
                                    </button>
                                </form>
                                <% } else { %>
                                <form method="POST" action="${pageContext.request.contextPath}/admin/assignments" style="margin:0;">
                                    <input type="hidden" name="action"  value="mark-absent">
                                    <input type="hidden" name="userId"  value="<%= h(v.getUserId()) %>">
                                    <input type="hidden" name="eventId" value="<%= h(selectedEventId) %>">
                                    <button type="submit" class="btn-sm btn-absent" style="width:100%;justify-content:center;">
                                        <i class="fas fa-undo"></i> Absent
                                    </button>
                                </form>
                                <% } %>
                            <% } else if (vDec) { %>
                            <span style="font-size:11px; color:var(--text-muted); text-align:center;">—</span>
                            <% } else { %>
                            <span style="font-size:11px; color:var(--text-muted); text-align:center;">—</span>
                            <% } %>
                        </div>

                    </div><%-- end vol-card --%>
                    <%  }  // end for each volunteer
                    }      // end else (not empty)
                    %>
                </div><%-- end vol-modal-body --%>
            </div><%-- end vol-modal --%>
        </div><%-- end vol-modal-overlay --%>

        <% } // end if selectedEvent %>

    </div><!-- page-body -->
</div><!-- main -->

<script>
(function() {
    // ── Auto-dismiss flash ──
    var flash = document.getElementById('flashMsg');
    if (flash) setTimeout(function() {
        flash.style.transition = 'opacity .5s';
        flash.style.opacity    = '0';
        setTimeout(function() { flash.remove(); }, 500);
    }, 4000);

    // ── Modal close helpers ──
    var CTX   = '<%= request.getContextPath() %>';
    var closeUrl = CTX + '/admin/assignments';

    // Close on backdrop click
    var overlay = document.getElementById('volModal');
    if (overlay) {
        overlay.addEventListener('click', function(e) {
            if (e.target === overlay) window.location.href = closeUrl;
        });
    }

    // Close on Escape
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape' && overlay) window.location.href = closeUrl;
    });

    // Lock body scroll while modal is open
    if (overlay && overlay.classList.contains('open')) {
        document.body.style.overflow = 'hidden';
    }
})();

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
