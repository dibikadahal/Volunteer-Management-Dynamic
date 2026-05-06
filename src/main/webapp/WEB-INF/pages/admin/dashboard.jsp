<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.VMS.model.User, java.util.List, java.util.Map, java.text.SimpleDateFormat" %>
<%
    String adminName = (String) session.getAttribute("userName");
    if (adminName == null) adminName = "Admin";
    String initials = adminName.length() > 0 ? String.valueOf(adminName.charAt(0)).toUpperCase() : "A";

    int totalVolunteers   = (Integer) request.getAttribute("totalVolunteers");
    int activeVolunteers  = (Integer) request.getAttribute("activeVolunteers");
    int pendingCount      = (Integer) request.getAttribute("pendingCount");
    int pendingEventCount = request.getAttribute("pendingEventCount") != null
                            ? (Integer) request.getAttribute("pendingEventCount") : 0;
    int eventsThisMonth   = request.getAttribute("eventsThisMonth") != null
                            ? (Integer) request.getAttribute("eventsThisMonth") : 0;
    int openEvents        = request.getAttribute("openEvents") != null
                            ? (Integer) request.getAttribute("openEvents") : 0;

    @SuppressWarnings("unchecked")
    List<User> pendingVolunteers = (List<User>) request.getAttribute("pendingVolunteers");
    @SuppressWarnings("unchecked")
    List<User> recentVolunteers  = (List<User>) request.getAttribute("recentVolunteers");
    @SuppressWarnings("unchecked")
    List<Map<String,Object>> pendingEventRequests =
        (List<Map<String,Object>>) request.getAttribute("pendingEventRequests");
    if (pendingEventRequests == null) pendingEventRequests = new java.util.ArrayList<>();

    SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, yyyy");

    String[] avatarColors = {"av-purple","av-blue","av-teal","av-amber","av-pink"};
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard – VolunteerHub</title>
    <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
    <style>
        /* ── Pending Requests Panel ── */
        .pending-list { display:flex; flex-direction:column; gap:0; }
        .pending-item {
            display:flex; align-items:center; gap:14px;
            padding:14px 0; border-bottom:1px solid var(--border);
        }
        .pending-item:last-child { border-bottom:none; }
        .pending-info { flex:1; min-width:0; }
        .pending-name  { font-weight:600; font-size:14px; color:var(--text-primary); }
        .pending-email { font-size:12px; color:var(--text-secondary); margin-top:2px;
                         white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
        .pending-date  { font-size:11px; color:var(--text-muted); white-space:nowrap; }
        .pending-actions { display:flex; gap:8px; flex-shrink:0; }

        .btn-approve, .btn-decline, .btn-view {
            padding:6px 12px; border-radius:8px; font-size:12px; font-weight:600;
            border:none; cursor:pointer; transition:opacity .2s;
        }
        .btn-approve { background:rgba(56,201,176,.15); color:#38c9b0; border:1px solid rgba(56,201,176,.3); }
        .btn-decline { background:rgba(224,92,151,.12); color:#e05c97; border:1px solid rgba(224,92,151,.25); }
        .btn-view    { background:rgba(79,142,247,.12);  color:#4f8ef7; border:1px solid rgba(79,142,247,.25); }
        .btn-approve:hover { opacity:.8; }
        .btn-decline:hover { opacity:.8; }
        .btn-view:hover    { opacity:.8; }

        .empty-state {
            text-align:center; padding:32px 16px; color:var(--text-muted);
            font-size:13px;
        }
        .empty-state i { font-size:28px; margin-bottom:10px; display:block; opacity:.4; }

        /* ── Modal ── */
        .modal-overlay {
            display:none; position:fixed; inset:0;
            background:rgba(0,0,0,.65); z-index:999;
            align-items:center; justify-content:center;
        }
        .modal-overlay.open { display:flex; }
        .modal-box {
            background:var(--bg-card); border:1px solid var(--border);
            border-radius:var(--radius); padding:32px; width:100%; max-width:480px;
            position:relative; animation:fadeUp .2s ease;
        }
        @keyframes fadeUp {
            from { opacity:0; transform:translateY(16px); }
            to   { opacity:1; transform:translateY(0); }
        }
        .modal-close {
            position:absolute; top:16px; right:16px; background:none; border:none;
            color:var(--text-secondary); font-size:18px; cursor:pointer;
        }
        .modal-title {
            font-size:18px; font-weight:700; margin-bottom:20px; color:var(--text-primary);
        }
        .modal-avatar {
            width:60px; height:60px; border-radius:50%;
            display:flex; align-items:center; justify-content:center;
            font-size:22px; font-weight:700; margin:0 auto 16px;
        }
        .modal-identity { text-align:center; margin-bottom:24px; }
        .modal-fullname { font-size:20px; font-weight:700; }
        .modal-username { color:var(--text-secondary); font-size:13px; margin-top:4px; }
        .detail-grid { display:grid; grid-template-columns:1fr 1fr; gap:12px; margin-bottom:24px; }
        .detail-item label {
            font-size:10px; text-transform:uppercase; letter-spacing:.8px;
            color:var(--text-muted); display:block; margin-bottom:4px;
        }
        .detail-item span {
            font-size:13px; color:var(--text-primary); font-weight:500;
            word-break:break-all;
        }
        .detail-item.full { grid-column:1/-1; }
        .modal-footer { display:flex; gap:12px; }
        .modal-footer form { flex:1; }
        .modal-footer button {
            width:100%; padding:12px; border-radius:10px; font-size:14px;
            font-weight:700; border:none; cursor:pointer; transition:opacity .2s;
        }
        .modal-footer button:hover { opacity:.85; }
        .modal-btn-approve { background:linear-gradient(135deg,#38c9b0,#2fa891); color:#fff; }
        .modal-btn-decline { background:linear-gradient(135deg,#e05c97,#c0416f); color:#fff; }

        /* ── Pending badge on stat card ── */
        .pending-badge-num {
            display:inline-block; background:#e05c97; color:#fff;
            font-size:10px; font-weight:700; border-radius:20px;
            padding:2px 7px; margin-left:6px; vertical-align:middle;
        }

        /* ── Notification dropdown ── */
        .notif-wrapper  { position:relative; }
        .notif-badge    {
            position:absolute; top:-5px; right:-5px;
            background:#e05c97; color:#fff; font-size:9px; font-weight:700;
            border-radius:10px; padding:2px 5px; min-width:16px; text-align:center;
            border:2px solid var(--bg-primary); line-height:1.4; pointer-events:none;
        }
        .notif-dropdown {
            display:none; position:absolute; top:calc(100% + 12px); right:0;
            width:360px; background:var(--bg-card); border:1px solid var(--border);
            border-radius:var(--radius); z-index:600;
            box-shadow:0 8px 32px rgba(0,0,0,.4);
        }
        .notif-dropdown.open { display:block; animation:fadeUp .18s ease; }
        .notif-head     {
            padding:14px 18px; border-bottom:1px solid var(--border);
            display:flex; align-items:center; justify-content:space-between;
        }
        .notif-head-title { font-size:13px; font-weight:700; color:var(--text-primary); }
        .notif-head-sub   { font-size:11px; color:var(--text-muted); }
        .notif-section-label {
            padding:8px 18px 4px;
            font-size:10px; text-transform:uppercase; letter-spacing:.8px;
            color:var(--text-muted); font-weight:700;
            background:rgba(255,255,255,.02);
        }
        .notif-list     { max-height:380px; overflow-y:auto; }
        .notif-item     {
            padding:12px 18px; border-bottom:1px solid var(--border);
            display:flex; align-items:flex-start; gap:12px; transition:background .15s;
        }
        .notif-item:last-child  { border-bottom:none; }
        .notif-item:hover       { background:rgba(255,255,255,.03); }
        .notif-icon-wrap {
            width:30px; height:30px; border-radius:50%; flex-shrink:0;
            display:flex; align-items:center; justify-content:center; font-size:12px;
        }
        .ni-reg   { background:rgba(224,92,151,.1);  color:#e05c97; }
        .ni-event { background:rgba(56,201,176,.1);  color:#38c9b0; }
        .notif-body { flex:1; }
        .notif-msg  { font-size:12px; color:var(--text-primary); line-height:1.5; }
        .notif-time { font-size:11px; color:var(--text-muted); margin-top:3px; }
        .notif-empty {
            padding:24px 18px; text-align:center;
            color:var(--text-muted); font-size:13px;
        }
        .notif-empty i { font-size:22px; display:block; margin-bottom:8px; opacity:.3; }
        .notif-foot {
            padding:10px 18px; border-top:1px solid var(--border); text-align:center;
        }
        .notif-foot a { font-size:12px; color:#4f8ef7; text-decoration:none; font-weight:600; }
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
    <div class="sidebar-logo">
        <div class="logo-icon">&#9825;</div>
        <span>VolunteerHub</span>
    </div>
    <div class="sidebar-section-label">Main Menu</div>
    <a href="${pageContext.request.contextPath}/admin/dashboard" class="nav-item active">
        <i class="fas fa-th-large"></i> Dashboard
        <% if (pendingCount > 0) { %>
            <span class="nav-badge"><%= pendingCount %></span>
        <% } %>
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
    <a href="${pageContext.request.contextPath}/admin/profile" class="nav-item">
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
                <h2>Admin Dashboard</h2>
                <p>Manage your volunteer operations</p>
            </div>
        </div>
        <div class="topbar-right">
            <% int totalNotifCount = pendingCount + pendingEventCount; %>
            <div class="notif-wrapper">
                <div class="topbar-icon-btn" id="notifBtn" onclick="toggleNotif(event)"
                     style="cursor:pointer; position:relative;">
                    <i class="fas fa-bell"></i>
                    <% if (totalNotifCount > 0) { %>
                    <span class="notif-badge"><%= totalNotifCount %></span>
                    <% } %>
                </div>
                <div class="notif-dropdown" id="notifDropdown">
                    <div class="notif-head">
                        <span class="notif-head-title"><i class="fas fa-bell" style="color:#f5a623;margin-right:6px;font-size:12px;"></i>Notifications</span>
                        <span class="notif-head-sub"><%= totalNotifCount %> pending</span>
                    </div>
                    <div class="notif-list">
                        <%-- Pending volunteer registrations --%>
                        <% if (pendingVolunteers != null && !pendingVolunteers.isEmpty()) { %>
                        <div class="notif-section-label"><i class="fas fa-user-plus" style="font-size:9px;margin-right:4px;"></i>New Registrations</div>
                        <% int pi = 0; for (User pv : pendingVolunteers) { if (++pi > 5) break; %>
                        <div class="notif-item">
                            <div class="notif-icon-wrap ni-reg"><i class="fas fa-user-clock"></i></div>
                            <div class="notif-body">
                                <div class="notif-msg"><strong><%= pv.getFullName() %></strong> wants to join as a volunteer</div>
                                <div class="notif-time"><i class="fas fa-clock" style="font-size:9px;"></i> <%= pv.getCreatedAt() != null ? sdf.format(pv.getCreatedAt()) : "" %></div>
                            </div>
                        </div>
                        <% } } %>
                        <%-- Pending event requests --%>
                        <% if (!pendingEventRequests.isEmpty()) { %>
                        <div class="notif-section-label"><i class="fas fa-calendar-plus" style="font-size:9px;margin-right:4px;"></i>Event Requests</div>
                        <% int ei2 = 0; for (java.util.Map<String,Object> er : pendingEventRequests) { if (++ei2 > 5) break; %>
                        <div class="notif-item">
                            <div class="notif-icon-wrap ni-event"><i class="fas fa-calendar-alt"></i></div>
                            <div class="notif-body">
                                <div class="notif-msg"><strong><%= er.get("volunteerName") %></strong> requested to join <strong><%= er.get("eventTitle") %></strong></div>
                                <div class="notif-time"><i class="fas fa-clock" style="font-size:9px;"></i> <%= er.get("requestedOn") %></div>
                            </div>
                        </div>
                        <% } } %>
                        <% if (totalNotifCount == 0) { %>
                        <div class="notif-empty"><i class="fas fa-check-circle"></i>All caught up — no pending items!</div>
                        <% } %>
                    </div>
                    <div class="notif-foot">
                        <a href="${pageContext.request.contextPath}/admin/assignments">Go to Assignments &rarr;</a>
                    </div>
                </div>
            </div>
            <a href="${pageContext.request.contextPath}/admin/profile" style="text-decoration:none;">
                <div class="admin-avatar"><%= initials %></div>
            </a>
        </div>
    </div>

    <!-- Page body -->
    <div class="page-body">

        <%-- Flash messages --%>
        <% if (request.getParameter("success") != null) { %>
        <div style="background:rgba(56,201,176,0.12); border:1px solid rgba(56,201,176,0.25);
                    color:#38c9b0; padding:12px 16px; border-radius:10px;
                    font-size:13px; margin-bottom:20px; display:flex; align-items:center; gap:8px;">
            <i class="fas fa-check-circle"></i> <%= request.getParameter("success") %>
        </div>
        <% } %>
        <% if (request.getParameter("error") != null) { %>
        <div style="background:rgba(224,92,151,0.12); border:1px solid rgba(224,92,151,0.25);
                    color:#e05c97; padding:12px 16px; border-radius:10px;
                    font-size:13px; margin-bottom:20px; display:flex; align-items:center; gap:8px;">
            <i class="fas fa-exclamation-circle"></i> <%= request.getParameter("error") %>
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
                <div class="stat-value"><%= totalVolunteers %></div>
                <div class="stat-label">Total Volunteers</div>
                <div class="stat-change up"><i class="fas fa-user-check"></i> <%= activeVolunteers %> active</div>
            </div>

            <div class="stat-card pink">
                <div class="stat-icon"><i class="fas fa-user-plus"></i></div>
                <div class="stat-value"><%= pendingCount %></div>
                <div class="stat-label">Pending Approvals</div>
                <div class="stat-change <%= pendingCount > 0 ? "up" : "" %>">
                    <i class="fas fa-<%= pendingCount > 0 ? "exclamation-circle" : "check" %>"></i>
                    <%= pendingCount > 0 ? "Awaiting review" : "All caught up" %>
                </div>
            </div>

            <div class="stat-card teal">
                <div class="stat-icon"><i class="fas fa-calendar-plus"></i></div>
                <div class="stat-value"><%= pendingEventCount %></div>
                <div class="stat-label">Event Requests</div>
                <div class="stat-change <%= pendingEventCount > 0 ? "up" : "" %>">
                    <i class="fas fa-<%= pendingEventCount > 0 ? "bell" : "check" %>"></i>
                    <%= pendingEventCount > 0 ? "Awaiting approval" : "All caught up" %>
                </div>
            </div>

            <div class="stat-card blue">
                <div class="stat-icon"><i class="fas fa-calendar-check"></i></div>
                <div class="stat-value"><%= eventsThisMonth %></div>
                <div class="stat-label">Events This Month</div>
                <div class="stat-change <%= openEvents > 0 ? "up" : "" %>">
                    <i class="fas fa-door-open"></i> <%= openEvents %> open event<%= openEvents != 1 ? "s" : "" %>
                </div>
            </div>

        </div>

        <!-- Bottom panels -->
        <div class="bottom-grid">

            <!-- ══ PENDING REGISTRATION REQUESTS ══ -->
            <div class="panel">
                <div class="panel-header">
                    <h3>
                        <i class="fas fa-user-clock" style="color:#e05c97;margin-right:6px;"></i>
                        Pending Requests
                        <% if (pendingCount > 0) { %>
                            <span class="pending-badge-num"><%= pendingCount %></span>
                        <% } %>
                    </h3>
                    <span style="font-size:12px;color:var(--text-muted);">New registrations</span>
                </div>

                <% if (pendingVolunteers == null || pendingVolunteers.isEmpty()) { %>
                <div class="empty-state">
                    <i class="fas fa-inbox"></i>
                    No pending registrations right now.
                </div>
                <% } else { %>
                <div class="pending-list">
                    <% int ci = 0; for (User pv : pendingVolunteers) {
                        String color = avatarColors[ci % avatarColors.length]; ci++;
                        String pvInitials = pv.getInitials();
                        String pvDate = pv.getCreatedAt() != null ? sdf.format(pv.getCreatedAt()) : "—";
                        // escape for JS data attribute
                        String pvFullName = pv.getFullName().replace("'","&#39;");
                        String pvEmail    = pv.getEmail().replace("'","&#39;");
                        String pvUsername = pv.getUsername().replace("'","&#39;");
                        String pvPhone    = (pv.getPhone() != null && !pv.getPhone().isEmpty()) ? pv.getPhone() : "—";
                        String pvBio      = (pv.getBio() != null && !pv.getBio().isEmpty()) ? pv.getBio().replace("'","&#39;") : "—";
                    %>
                    <div class="pending-item">
                        <div class="reg-avatar <%= color %>"><%= pvInitials %></div>
                        <div class="pending-info">
                            <div class="pending-name"><%= pv.getFullName() %></div>
                            <div class="pending-email"><%= pv.getEmail() %></div>
                        </div>
                        <div class="pending-date"><%= pvDate %></div>
                        <div class="pending-actions">
                            <button class="btn-view" onclick="openModal(
                                '<%= pv.getId() %>',
                                '<%= pvFullName %>',
                                '@<%= pvUsername %>',
                                '<%= pvEmail %>',
                                '<%= pvPhone %>',
                                '<%= pvDate %>',
                                '<%= pvBio %>',
                                '<%= color %>'
                            )"><i class="fas fa-eye"></i> View</button>
                        </div>
                    </div>
                    <% } %>
                </div>
                <% } %>
            </div>

            <!-- ══ PENDING EVENT JOIN REQUESTS ══ -->
            <div class="panel">
                <div class="panel-header">
                    <h3>
                        <i class="fas fa-calendar-plus" style="color:#38c9b0; margin-right:6px;"></i>
                        Event Requests
                        <% if (pendingEventCount > 0) { %>
                            <span class="pending-badge-num"><%= pendingEventCount %></span>
                        <% } %>
                    </h3>
                    <a href="${pageContext.request.contextPath}/admin/assignments">View all &rarr;</a>
                </div>

                <% if (pendingEventRequests.isEmpty()) { %>
                <div class="empty-state">
                    <i class="fas fa-calendar-check"></i>
                    No pending event requests right now.
                </div>
                <% } else { %>
                <div class="pending-list">
                <% int ei = 0; for (Map<String,Object> req : pendingEventRequests) {
                    String eColor    = avatarColors[ei % avatarColors.length]; ei++;
                    String vName     = (String) req.get("volunteerName");
                    String vEmail    = (String) req.get("email");
                    String vUserId   = (String) req.get("userId");
                    String evId      = (String) req.get("eventId");
                    String evTitle   = (String) req.get("eventTitle");
                    String evStarts  = (String) req.get("eventStartsAt");
                    String evLoc     = (String) req.get("location");
                    String reqOn     = (String) req.get("requestedOn");
                    String vInitials = vName != null && vName.trim().length() > 0
                        ? String.valueOf(vName.trim().charAt(0)).toUpperCase() : "?";
                %>
                <div class="pending-item" style="align-items:flex-start; padding:16px 0;">
                    <div class="reg-avatar <%= eColor %>" style="margin-top:2px;"><%= vInitials %></div>
                    <div class="pending-info" style="flex:1;">
                        <div class="pending-name"><%= vName != null ? vName : "—" %></div>
                        <div class="pending-email"><%= vEmail != null ? vEmail : "" %></div>
                        <div style="margin-top:6px; padding:8px 10px; border-radius:8px;
                                    background:rgba(56,201,176,.06); border:1px solid rgba(56,201,176,.15);">
                            <div style="font-size:12px; font-weight:600; color:var(--text-primary);">
                                <i class="fas fa-calendar-alt" style="color:#38c9b0; font-size:10px;"></i>
                                <%= evTitle != null ? evTitle : "—" %>
                            </div>
                            <div style="font-size:11px; color:var(--text-muted); margin-top:3px;">
                                <i class="fas fa-clock" style="font-size:9px;"></i> <%= evStarts %>
                                <% if (evLoc != null && !evLoc.isEmpty()) { %>
                                &nbsp;·&nbsp;<i class="fas fa-map-marker-alt" style="font-size:9px;"></i> <%= evLoc %>
                                <% } %>
                            </div>
                        </div>
                        <div style="font-size:10px; color:var(--text-muted); margin-top:5px;">
                            Requested on <%= reqOn %>
                        </div>
                    </div>
                    <div class="pending-actions" style="flex-direction:column; gap:6px; margin-top:2px;">
                        <form method="POST" action="${pageContext.request.contextPath}/admin/assignments" style="margin:0;">
                            <input type="hidden" name="action"     value="accept">
                            <input type="hidden" name="userId"     value="<%= vUserId %>">
                            <input type="hidden" name="eventId"    value="<%= evId %>">
                            <input type="hidden" name="redirectTo" value="dashboard">
                            <button type="submit" class="btn-approve" style="width:100%;">
                                <i class="fas fa-check"></i> Accept
                            </button>
                        </form>
                        <form method="POST" action="${pageContext.request.contextPath}/admin/assignments"
                              onsubmit="return confirm('Decline this request?')" style="margin:0;">
                            <input type="hidden" name="action"     value="decline">
                            <input type="hidden" name="userId"     value="<%= vUserId %>">
                            <input type="hidden" name="eventId"    value="<%= evId %>">
                            <input type="hidden" name="redirectTo" value="dashboard">
                            <button type="submit" class="btn-decline" style="width:100%;">
                                <i class="fas fa-times"></i> Decline
                            </button>
                        </form>
                    </div>
                </div>
                <% } %>
                </div>
                <% } %>
            </div>

        </div>
    </div>
</div>

<!-- ══ VOLUNTEER DETAILS MODAL ══ -->
<div class="modal-overlay" id="modalOverlay" onclick="closeModalOnBg(event)">
    <div class="modal-box">
        <button class="modal-close" onclick="closeModal()"><i class="fas fa-times"></i></button>
        <div class="modal-title"><i class="fas fa-user-circle" style="color:#4f8ef7;margin-right:8px;"></i>Volunteer Details</div>

        <div class="modal-identity">
            <div class="modal-avatar" id="modalAvatar"></div>
            <div class="modal-fullname" id="modalFullName"></div>
            <div class="modal-username" id="modalUsername"></div>
        </div>

        <div class="detail-grid">
            <div class="detail-item">
                <label><i class="fas fa-envelope"></i> Email</label>
                <span id="modalEmail"></span>
            </div>
            <div class="detail-item">
                <label><i class="fas fa-phone"></i> Phone</label>
                <span id="modalPhone"></span>
            </div>
            <div class="detail-item">
                <label><i class="fas fa-calendar-alt"></i> Registered</label>
                <span id="modalDate"></span>
            </div>
            <div class="detail-item">
                <label><i class="fas fa-shield-alt"></i> Role</label>
                <span>Volunteer</span>
            </div>
            <div class="detail-item full">
                <label><i class="fas fa-pen"></i> Bio</label>
                <span id="modalBio"></span>
            </div>
        </div>

        <div class="modal-footer">
            <form method="POST" action="${pageContext.request.contextPath}/admin/volunteer-requests">
                <input type="hidden" name="action" value="approve">
                <input type="hidden" name="id" id="approveId">
                <button type="submit" class="modal-btn-approve">
                    <i class="fas fa-check"></i> Approve
                </button>
            </form>
            <form method="POST" action="${pageContext.request.contextPath}/admin/volunteer-requests"
                  onsubmit="return confirm('Decline and remove this registration?')">
                <input type="hidden" name="action" value="decline">
                <input type="hidden" name="id" id="declineId">
                <button type="submit" class="modal-btn-decline">
                    <i class="fas fa-times"></i> Decline
                </button>
            </form>
        </div>
    </div>
</div>

<script>
    // ── Clock ──
    function updateClock() {
        var now   = new Date();
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

    // ── Modal ──
    var avatarColorMap = {
        'av-purple': '#7c5cbf',
        'av-blue':   '#4f8ef7',
        'av-teal':   '#38c9b0',
        'av-amber':  '#f5a623',
        'av-pink':   '#e05c97'
    };

    function openModal(id, fullName, username, email, phone, date, bio, colorClass) {
        document.getElementById('approveId').value = id;
        document.getElementById('declineId').value = id;
        document.getElementById('modalFullName').textContent = fullName;
        document.getElementById('modalUsername').textContent = username;
        document.getElementById('modalEmail').textContent    = email;
        document.getElementById('modalPhone').textContent    = phone;
        document.getElementById('modalDate').textContent     = date;
        document.getElementById('modalBio').textContent      = bio;

        var av = document.getElementById('modalAvatar');
        var initials = fullName.split(' ').map(function(w){ return w[0]; }).join('').toUpperCase().slice(0,2);
        av.textContent = initials || '?';
        av.style.background = avatarColorMap[colorClass] || '#7c5cbf';
        av.style.color = '#fff';

        document.getElementById('modalOverlay').classList.add('open');
    }

    function closeModal() {
        document.getElementById('modalOverlay').classList.remove('open');
    }

    function closeModalOnBg(event) {
        if (event.target === document.getElementById('modalOverlay')) closeModal();
    }

    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') { closeModal(); document.getElementById('notifDropdown').classList.remove('open'); }
    });

    // ── Notification dropdown ──
    function toggleNotif(e) {
        e.stopPropagation();
        document.getElementById('notifDropdown').classList.toggle('open');
    }
    document.addEventListener('click', function(e) {
        var dd = document.getElementById('notifDropdown');
        if (dd && !document.getElementById('notifBtn').contains(e.target)) {
            dd.classList.remove('open');
        }
    });

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
