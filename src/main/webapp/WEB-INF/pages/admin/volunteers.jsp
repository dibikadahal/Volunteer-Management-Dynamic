<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.VMS.model.User, com.VMS.model.VolunteerEventEntry, java.util.List, java.util.Map" %>
<%!
    private static String esc(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("'",  "\\'")
                .replace("\r", "")
                .replace("\n", "\\n")
                .replace("<",  "\\x3C")
                .replace(">",  "\\x3E");
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
    String initials = adminName.length() > 0
        ? String.valueOf(adminName.charAt(0)).toUpperCase() : "A";

    @SuppressWarnings("unchecked")
    List<User> volunteers = (List<User>) request.getAttribute("volunteers");
    if (volunteers == null) volunteers = new java.util.ArrayList<>();

    @SuppressWarnings("unchecked")
    Map<String, List<VolunteerEventEntry>> eventsMap =
        (Map<String, List<VolunteerEventEntry>>) request.getAttribute("eventsMap");
    if (eventsMap == null) eventsMap = new java.util.HashMap<>();

    int activeCount  = request.getAttribute("activeCount")  != null ? (Integer) request.getAttribute("activeCount")  : 0;
    int pendingCount = request.getAttribute("pendingCount") != null ? (Integer) request.getAttribute("pendingCount") : 0;
    int totalRegs    = request.getAttribute("totalRegs")    != null ? (Integer) request.getAttribute("totalRegs")    : 0;

    String search  = (String) request.getAttribute("search");
    String sortBy  = (String) request.getAttribute("sortBy");
    String sortDir = (String) request.getAttribute("sortDir");
    if (search  == null) search  = "";
    if (sortBy  == null) sortBy  = "createdAt";
    if (sortDir == null) sortDir = "desc";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Volunteer Management – VolunteerHub</title>
    <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
    <style>
        /* ══ TABLE ══ */
        .vol-table-wrap {
            overflow-x: auto;
            border-radius: var(--radius);
            border: 1px solid var(--border);
            background: var(--bg-card);
        }
        .vol-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
        }
        .vol-table thead th {
            background: rgba(124,92,191,.08);
            color: var(--text-secondary);
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: .8px;
            padding: 13px 16px;
            text-align: left;
            white-space: nowrap;
        }
        .vol-table tbody tr {
            border-top: 1px solid var(--border);
            transition: background .15s;
            cursor: pointer;
        }
        .vol-table tbody tr:hover { background: rgba(124,92,191,.06); }
        .vol-table td {
            padding: 13px 16px;
            color: var(--text-primary);
            vertical-align: middle;
        }
        .vol-table td.muted { color: var(--text-secondary); font-size: 12px; }

        /* ══ VOLUNTEER CELL ══ */
        .vol-cell { display: flex; align-items: center; gap: 12px; }
        .vol-avatar-sm {
            width: 40px; height: 40px; border-radius: 50%; flex-shrink: 0;
            display: flex; align-items: center; justify-content: center;
            font-size: 14px; font-weight: 700; color: #fff; overflow: hidden;
        }
        .vol-avatar-sm img { width: 100%; height: 100%; object-fit: cover; }
        .vol-name  { font-weight: 600; color: var(--text-primary); line-height: 1.3; }
        .vol-email { font-size: 11px; color: var(--text-muted); margin-top: 2px; }

        /* ══ STATUS BADGES ══ */
        .badge {
            display: inline-flex; align-items: center; gap: 5px;
            padding: 4px 10px; border-radius: 20px;
            font-size: 11px; font-weight: 700; letter-spacing: .4px;
            white-space: nowrap;
        }
        .badge-dot  { width: 6px; height: 6px; border-radius: 50%; background: currentColor; }
        .badge-active   { background: rgba(56,201,176,.15);  color: #38c9b0; border: 1px solid rgba(56,201,176,.3); }
        .badge-pending  { background: rgba(245,166,35,.12);  color: #f5a623; border: 1px solid rgba(245,166,35,.3); }
        .badge-accepted { background: rgba(56,201,176,.15);  color: #38c9b0; border: 1px solid rgba(56,201,176,.3); }
        .badge-declined { background: rgba(224,92,151,.12);  color: #e05c97; border: 1px solid rgba(224,92,151,.25); }
        .badge-opened   { background: rgba(56,201,176,.1);   color: #38c9b0; border: 1px solid rgba(56,201,176,.2); }
        .badge-closed   { background: rgba(100,100,120,.15); color: var(--text-secondary); border: 1px solid var(--border); }

        /* ══ EVENT COUNT PILL ══ */
        .event-count-pill {
            display: inline-flex; align-items: center; gap: 5px;
            padding: 4px 10px; border-radius: 20px; font-size: 11px; font-weight: 700;
            background: rgba(124,92,191,.12); color: #9b7de8;
            border: 1px solid rgba(124,92,191,.22);
        }

        /* ══ TOOLBAR ══ */
        .vol-toolbar {
            display: flex; align-items: center; gap: 12px;
            flex-wrap: wrap; margin-bottom: 20px;
        }
        .search-box {
            flex: 1; min-width: 240px;
            display: flex; align-items: center; gap: 8px;
            background: var(--bg-card); border: 1px solid var(--border);
            border-radius: 10px; padding: 9px 14px;
            transition: border-color .2s;
        }
        .search-box:focus-within { border-color: #7c5cbf; }
        .search-box i { color: var(--text-muted); font-size: 13px; }
        .search-box input {
            flex: 1; background: none; border: none; outline: none;
            color: var(--text-primary); font-size: 13px; font-family: inherit;
        }
        .search-box input::placeholder { color: var(--text-muted); }
        .filter-select {
            background: var(--bg-card); border: 1px solid var(--border);
            color: var(--text-primary); border-radius: 10px;
            padding: 9px 14px; font-size: 13px; font-family: inherit;
            cursor: pointer; outline: none;
        }
        .filter-select:focus { border-color: #7c5cbf; }

        /* ══ ACTION BUTTON ══ */
        .btn-view {
            padding: 5px 12px; border-radius: 7px; font-size: 11px; font-weight: 600;
            background: rgba(79,142,247,.12); color: #4f8ef7;
            border: 1px solid rgba(79,142,247,.25); cursor: pointer;
            transition: opacity .2s; display: inline-flex; align-items: center; gap: 4px;
            font-family: inherit;
        }
        .btn-view:hover { opacity: .75; }

        /* ══ EMPTY STATE ══ */
        .empty-row td {
            text-align: center; padding: 56px; color: var(--text-muted); font-size: 13px;
        }
        .empty-row td i { font-size: 40px; display: block; margin-bottom: 14px; opacity: .25; }

        /* ══ RESULTS META ══ */
        .results-meta { font-size: 12px; color: var(--text-muted); margin-bottom: 12px; }

        /* ══ MODAL BASE ══ */
        .modal-overlay {
            display: none; position: fixed; inset: 0;
            background: rgba(0,0,0,.75); z-index: 1000;
            align-items: center; justify-content: center; padding: 20px;
        }
        .modal-overlay.open { display: flex; }
        .modal-box {
            background: var(--bg-card); border: 1px solid var(--border);
            border-radius: var(--radius); width: 100%; max-width: 640px;
            position: relative; animation: mUp .2s ease;
            display: flex; flex-direction: column;
            max-height: 90vh; overflow: hidden;
        }
        @keyframes mUp {
            from { opacity: 0; transform: translateY(18px); }
            to   { opacity: 1; transform: translateY(0); }
        }
        .modal-header {
            padding: 20px 24px 16px;
            border-bottom: 1px solid var(--border);
            display: flex; align-items: center; justify-content: space-between;
            flex-shrink: 0;
        }
        .modal-title { font-size: 15px; font-weight: 700; color: var(--text-primary); }
        .modal-close {
            background: none; border: none; color: var(--text-secondary);
            font-size: 16px; cursor: pointer; padding: 4px;
        }
        .modal-close:hover { color: var(--text-primary); }
        .modal-body  { padding: 24px; overflow-y: auto; flex: 1; }
        .modal-footer {
            padding: 16px 24px; border-top: 1px solid var(--border);
            display: flex; gap: 10px; justify-content: flex-end; flex-shrink: 0;
        }
        .btn-submit {
            padding: 10px 22px; border-radius: 10px; font-size: 13px;
            font-weight: 700; border: none; cursor: pointer;
            transition: opacity .2s; font-family: inherit;
        }
        .btn-cancel { background: rgba(255,255,255,.06); color: var(--text-secondary); border: 1px solid var(--border); }
        .btn-submit:hover { opacity: .85; }

        /* ══ MODAL PROFILE HEADER ══ */
        .profile-header {
            display: flex; align-items: center; gap: 20px;
            margin-bottom: 22px; padding-bottom: 20px;
            border-bottom: 1px solid var(--border);
        }
        .profile-avatar-lg {
            width: 72px; height: 72px; border-radius: 50%; flex-shrink: 0;
            display: flex; align-items: center; justify-content: center;
            font-size: 26px; font-weight: 700; color: #fff; overflow: hidden;
        }
        .profile-avatar-lg img { width: 100%; height: 100%; object-fit: cover; border-radius: 50%; }
        .profile-header-info h3 { font-size: 18px; font-weight: 700; margin: 0 0 4px; }
        .profile-header-info .username { font-size: 12px; color: var(--text-muted); margin-bottom: 8px; }

        /* ══ DETAIL INFO GRID ══ */
        .info-grid {
            display: grid; grid-template-columns: 1fr 1fr; gap: 14px;
            margin-bottom: 18px;
        }
        .info-item label {
            font-size: 10px; text-transform: uppercase; letter-spacing: .7px;
            color: var(--text-muted); display: block; margin-bottom: 4px;
        }
        .info-item span { font-size: 13px; color: var(--text-primary); font-weight: 500; }
        .info-item.full { grid-column: 1 / -1; }

        /* ══ BIO BLOCK ══ */
        .bio-block {
            background: rgba(255,255,255,.03); border: 1px solid var(--border);
            border-radius: 10px; padding: 14px 16px;
            font-size: 13px; color: var(--text-secondary); line-height: 1.7;
            margin-bottom: 20px;
        }

        /* ══ EVENTS SECTION IN MODAL ══ */
        .events-section-title {
            font-size: 12px; text-transform: uppercase; letter-spacing: .8px;
            color: var(--text-muted); margin-bottom: 12px;
            display: flex; align-items: center; gap: 8px;
        }
        .events-section-title::after {
            content: ''; flex: 1; height: 1px; background: var(--border);
        }
        .event-entry {
            display: flex; align-items: flex-start; gap: 14px;
            padding: 12px 14px; border-radius: 10px;
            border: 1px solid var(--border); background: rgba(255,255,255,.02);
            margin-bottom: 8px; transition: background .15s;
        }
        .event-entry:hover { background: rgba(124,92,191,.06); }
        .event-entry-icon {
            width: 36px; height: 36px; border-radius: 8px; flex-shrink: 0;
            display: flex; align-items: center; justify-content: center;
            background: rgba(79,142,247,.1); color: #4f8ef7; font-size: 14px;
        }
        .event-entry-info { flex: 1; min-width: 0; }
        .event-entry-title { font-size: 13px; font-weight: 600; color: var(--text-primary); margin-bottom: 3px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .event-entry-meta  { font-size: 11px; color: var(--text-muted); line-height: 1.5; }
        .event-entry-right { display: flex; flex-direction: column; align-items: flex-end; gap: 4px; flex-shrink: 0; }
        .event-joined-date { font-size: 10px; color: var(--text-muted); }

        /* ══ NO EVENTS EMPTY ══ */
        .no-events {
            text-align: center; padding: 28px 20px; color: var(--text-muted); font-size: 13px;
        }
        .no-events i { font-size: 28px; display: block; margin-bottom: 8px; opacity: .3; }

        /* ══ AVATAR COLOR VARIANTS (for initials) ══ */
        .av-purple { background: linear-gradient(135deg, #7c5cbf, #4f8ef7); }
        .av-blue   { background: linear-gradient(135deg, #4f8ef7, #38c9b0); }
        .av-teal   { background: linear-gradient(135deg, #38c9b0, #4fb9f7); }
        .av-amber  { background: linear-gradient(135deg, #f5a623, #e05c97); }
        .av-pink   { background: linear-gradient(135deg, #e05c97, #7c5cbf); }
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
    <a href="${pageContext.request.contextPath}/admin/dashboard" class="nav-item">
        <i class="fas fa-th-large"></i> Dashboard
    </a>
    <div class="sidebar-section-label">Management</div>
    <a href="${pageContext.request.contextPath}/admin/volunteers" class="nav-item active">
        <i class="fas fa-users"></i> Volunteer Management
    </a>
    <a href="${pageContext.request.contextPath}/admin/events" class="nav-item">
        <i class="fas fa-calendar-alt"></i> Event Management
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
                <h2>Volunteer Management</h2>
                <p>View and manage all registered volunteers</p>
            </div>
        </div>
        <div class="topbar-right">
            <div class="topbar-icon-btn" style="position:relative;">
                <i class="fas fa-bell"></i>
                <% if (pendingCount > 0) { %>
                <span class="nav-badge" style="position:absolute;top:-4px;right:-4px;min-width:16px;height:16px;font-size:9px;padding:0 4px;border-radius:8px;background:#e05c97;color:#fff;display:flex;align-items:center;justify-content:center;font-weight:700;">
                    <%= pendingCount %>
                </span>
                <% } %>
            </div>
            <a href="${pageContext.request.contextPath}/admin/profile" style="text-decoration:none;">
                <div class="admin-avatar"><%= initials %></div>
            </a>
        </div>
    </div>

    <!-- Page Body -->
    <div class="page-body">

        <%-- Flash messages --%>
        <% if (request.getParameter("success") != null) { %>
        <div id="flashMsg" style="background:rgba(56,201,176,0.12); border:1px solid rgba(56,201,176,0.25);
                    color:#38c9b0; padding:12px 16px; border-radius:10px;
                    font-size:13px; margin-bottom:20px; display:flex; align-items:center; gap:8px;">
            <i class="fas fa-check-circle"></i> <%= h(request.getParameter("success")) %>
        </div>
        <% } %>

        <!-- Stats Row -->
        <div class="stats-grid">

            <div class="stat-card teal">
                <div class="stat-icon"><i class="fas fa-user-check"></i></div>
                <div class="stat-value"><%= activeCount %></div>
                <div class="stat-label">Active Volunteers</div>
                <div class="stat-change up"><i class="fas fa-circle"></i> Fully approved</div>
            </div>

            <div class="stat-card purple">
                <div class="stat-icon"><i class="fas fa-user-clock"></i></div>
                <div class="stat-value"><%= pendingCount %></div>
                <div class="stat-label">Pending Approvals</div>
                <div class="stat-change">
                    <a href="${pageContext.request.contextPath}/admin/dashboard"
                       style="color:inherit;text-decoration:none;">
                        <i class="fas fa-arrow-right"></i> Review on dashboard
                    </a>
                </div>
            </div>

            <div class="stat-card blue">
                <div class="stat-icon"><i class="fas fa-calendar-check"></i></div>
                <div class="stat-value"><%= totalRegs %></div>
                <div class="stat-label">Accepted Registrations</div>
                <div class="stat-change up"><i class="fas fa-handshake"></i> Across all events</div>
            </div>

        </div>

        <!-- Toolbar -->
        <form method="GET" action="${pageContext.request.contextPath}/admin/volunteers" id="searchForm">
            <div class="vol-toolbar">

                <div class="search-box">
                    <i class="fas fa-search"></i>
                    <input type="text" name="search" id="searchInput"
                           placeholder="Search by name, email or phone..."
                           value="<%= h(search) %>">
                </div>

                <select name="sortBy" class="filter-select" onchange="document.getElementById('searchForm').submit()">
                    <option value="createdAt"  <%= "createdAt".equals(sortBy)  ? "selected" : "" %>>Sort: Date Joined</option>
                    <option value="firstName"  <%= "firstName".equals(sortBy)  ? "selected" : "" %>>Sort: First Name</option>
                    <option value="lastName"   <%= "lastName".equals(sortBy)   ? "selected" : "" %>>Sort: Last Name</option>
                    <option value="email"      <%= "email".equals(sortBy)      ? "selected" : "" %>>Sort: Email</option>
                </select>

                <select name="sortDir" class="filter-select" onchange="document.getElementById('searchForm').submit()">
                    <option value="desc" <%= "desc".equals(sortDir) ? "selected" : "" %>>&#8595; Descending</option>
                    <option value="asc"  <%= "asc".equals(sortDir)  ? "selected" : "" %>>&#8593; Ascending</option>
                </select>

                <button type="submit" class="filter-select" style="cursor:pointer;">
                    <i class="fas fa-filter"></i> Filter
                </button>

            </div>
        </form>

        <!-- Results count -->
        <div class="results-meta">
            Showing <strong style="color:var(--text-primary)"><%= volunteers.size() %></strong>
            active volunteer<%= volunteers.size() != 1 ? "s" : "" %>
            <% if (!search.isEmpty()) { %> matching "<strong style="color:#7c5cbf"><%= h(search) %></strong>"<% } %>
        </div>

        <!-- Volunteers Table -->
        <div class="vol-table-wrap">
            <table class="vol-table" id="volTable">
                <thead>
                    <tr>
                        <th style="width:40px;">#</th>
                        <th>Volunteer</th>
                        <th>Phone</th>
                        <th>Status</th>
                        <th>Member Since</th>
                        <th>Events</th>
                        <th style="width:100px;">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        if (volunteers.isEmpty()) {
                    %>
                    <tr class="empty-row">
                        <td colspan="7">
                            <i class="fas fa-users"></i>
                            No active volunteers found.<% if (!search.isEmpty()) { %> Try a different search term.<% } %>
                        </td>
                    </tr>
                    <%
                        } else {
                            int rowNum = 0;
                            for (User vol : volunteers) {
                                rowNum++;
                                String avColor = AV_COLORS[(rowNum - 1) % AV_COLORS.length];
                                String img     = vol.getImage() != null ? vol.getImage() : "";
                    %>
                    <tr onclick="openDetailModal('<%= h(vol.getId()) %>')">

                        <td class="muted"><%= rowNum %></td>

                        <!-- Volunteer cell: avatar + name + email -->
                        <td>
                            <div class="vol-cell">
                                <div class="vol-avatar-sm <%= img.isEmpty() ? avColor : "" %>">
                                    <% if (!img.isEmpty()) { %>
                                        <img src="${pageContext.request.contextPath}/<%= h(img) %>" alt="">
                                    <% } else { %>
                                        <%= h(vol.getInitials()) %>
                                    <% } %>
                                </div>
                                <div>
                                    <div class="vol-name"><%= h(vol.getFullName()) %></div>
                                    <div class="vol-email"><%= h(vol.getEmail()) %></div>
                                </div>
                            </div>
                        </td>

                        <!-- Phone -->
                        <td class="muted">
                            <%= vol.getPhone() != null && !vol.getPhone().isEmpty()
                                ? h(vol.getPhone()) : "<span style='opacity:.4'>—</span>" %>
                        </td>

                        <!-- Status -->
                        <td>
                            <span class="badge badge-active">
                                <span class="badge-dot"></span> Active
                            </span>
                        </td>

                        <!-- Member since -->
                        <td class="muted"><%= h(vol.getCreatedAtDisplay()) %></td>

                        <!-- Event count -->
                        <td>
                            <span class="event-count-pill">
                                <i class="fas fa-calendar-alt" style="font-size:10px;"></i>
                                <%= vol.getEventCount() %>
                            </span>
                        </td>

                        <!-- Actions -->
                        <td onclick="event.stopPropagation()">
                            <button class="btn-view" onclick="openDetailModal('<%= h(vol.getId()) %>')">
                                <i class="fas fa-eye"></i> View
                            </button>
                        </td>

                    </tr>
                    <%      }
                        }
                    %>
                </tbody>
            </table>
        </div>

    </div><!-- end page-body -->
</div><!-- end main -->

<!-- ════════════════════════════════════════════════
     VOLUNTEER DETAIL MODAL
════════════════════════════════════════════════ -->
<div class="modal-overlay" id="detailModal" onclick="closeOnBg(event,'detailModal')">
    <div class="modal-box">
        <div class="modal-header">
            <span class="modal-title"><i class="fas fa-user-circle" style="color:#7c5cbf;margin-right:8px;"></i>Volunteer Profile</span>
            <button class="modal-close" onclick="closeModal('detailModal')"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body">

            <!-- Profile header: avatar + name + status -->
            <div class="profile-header">
                <div class="profile-avatar-lg" id="modalAvatar"></div>
                <div class="profile-header-info">
                    <h3 id="modalFullName"></h3>
                    <div class="username" id="modalUsername"></div>
                    <span class="badge badge-active"><span class="badge-dot"></span> Active Volunteer</span>
                </div>
            </div>

            <!-- Info grid -->
            <div class="info-grid">
                <div class="info-item">
                    <label><i class="fas fa-envelope"></i> Email</label>
                    <span id="modalEmail"></span>
                </div>
                <div class="info-item">
                    <label><i class="fas fa-phone"></i> Phone</label>
                    <span id="modalPhone"></span>
                </div>
                <div class="info-item">
                    <label><i class="fas fa-calendar-plus"></i> Member Since</label>
                    <span id="modalSince"></span>
                </div>
                <div class="info-item">
                    <label><i class="fas fa-calendar-alt"></i> Total Events</label>
                    <span id="modalEventCount"></span>
                </div>
            </div>

            <!-- Bio -->
            <div id="modalBioWrap" style="display:none;">
                <div class="events-section-title">Bio</div>
                <div class="bio-block" id="modalBio"></div>
            </div>

            <!-- Events participated -->
            <div class="events-section-title">
                <i class="fas fa-calendar-check" style="font-size:10px;"></i>
                Event History
            </div>
            <div id="modalEventsList"></div>

        </div>
        <div class="modal-footer">
            <button type="button" class="btn-submit btn-cancel" onclick="closeModal('detailModal')">Close</button>
        </div>
    </div>
</div>

<!-- ════════════════════════════════════════════════
     JAVASCRIPT — embed volunteer + events data
════════════════════════════════════════════════ -->
<script>
const VOLUNTEERS = [
<%
    for (int i = 0; i < volunteers.size(); i++) {
        User vol = volunteers.get(i);
        String img  = vol.getImage() != null ? vol.getImage() : "";
        String bio  = vol.getBio()   != null ? vol.getBio()   : "";
        String ph   = vol.getPhone() != null ? vol.getPhone() : "";
        List<VolunteerEventEntry> volEvents = eventsMap.get(vol.getId());
        if (volEvents == null) volEvents = new java.util.ArrayList<>();
        String avColor = AV_COLORS[(i) % AV_COLORS.length];
%>
  {
    id:         '<%= esc(vol.getId()) %>',
    fullName:   '<%= esc(vol.getFullName()) %>',
    username:   '<%= esc(vol.getUsername()) %>',
    email:      '<%= esc(vol.getEmail()) %>',
    phone:      '<%= esc(ph) %>',
    bio:        '<%= esc(bio) %>',
    image:      '<%= esc(img) %>',
    initials:   '<%= esc(vol.getInitials()) %>',
    avColor:    '<%= avColor %>',
    since:      '<%= esc(vol.getCreatedAtDisplay()) %>',
    eventCount: <%= vol.getEventCount() %>,
    events: [
<%
        for (int j = 0; j < volEvents.size(); j++) {
            VolunteerEventEntry e = volEvents.get(j);
            String loc = e.getLocation() != null ? e.getLocation() : "";
%>
      {
        eventId:    '<%= esc(e.getEventId()) %>',
        title:      '<%= esc(e.getTitle()) %>',
        location:   '<%= esc(loc) %>',
        startsAt:   '<%= esc(e.getStartsAt()) %>',
        endsAt:     '<%= esc(e.getEndsAt()) %>',
        evStatus:   '<%= esc(e.getEventStatus()) %>',
        volStatus:  '<%= esc(e.getVolunteerStatus()) %>',
        joinedAt:   '<%= esc(e.getJoinedAt()) %>'
      }<%= j < volEvents.size()-1 ? "," : "" %>
<%      } %>
    ]
  }<%= i < volunteers.size()-1 ? "," : "" %>
<% } %>
];

const CTX = '<%= request.getContextPath() %>';

function openModal(id) {
    document.getElementById(id).classList.add('open');
    document.body.style.overflow = 'hidden';
}
function closeModal(id) {
    document.getElementById(id).classList.remove('open');
    document.body.style.overflow = '';
}
function closeOnBg(e, id) {
    if (e.target === document.getElementById(id)) closeModal(id);
}
document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') closeModal('detailModal');
});

function openDetailModal(id) {
    const vol = VOLUNTEERS.find(v => v.id === id);
    if (!vol) return;

    // Avatar
    const avatarEl = document.getElementById('modalAvatar');
    avatarEl.className = 'profile-avatar-lg';
    if (vol.image) {
        avatarEl.innerHTML = '<img src="' + CTX + '/' + vol.image + '" alt="">';
    } else {
        avatarEl.classList.add(vol.avColor);
        avatarEl.textContent = vol.initials;
    }

    document.getElementById('modalFullName').textContent   = vol.fullName;
    document.getElementById('modalUsername').textContent   = '@' + vol.username;
    document.getElementById('modalEmail').textContent      = vol.email;
    document.getElementById('modalPhone').textContent      = vol.phone || '—';
    document.getElementById('modalSince').textContent      = vol.since;
    document.getElementById('modalEventCount').textContent = vol.eventCount + ' event' + (vol.eventCount !== 1 ? 's' : '');

    // Bio
    const bioWrap = document.getElementById('modalBioWrap');
    if (vol.bio && vol.bio.trim()) {
        bioWrap.style.display = '';
        document.getElementById('modalBio').textContent = vol.bio;
    } else {
        bioWrap.style.display = 'none';
    }

    // Events list
    const evList = document.getElementById('modalEventsList');
    if (vol.events.length === 0) {
        evList.innerHTML = '<div class="no-events"><i class="fas fa-calendar-times"></i>This volunteer has not registered for any events yet.</div>';
    } else {
        let html = '';
        vol.events.forEach(function(ev) {
            const vsClass = ev.volStatus === 'accepted' ? 'badge-accepted'
                          : ev.volStatus === 'declined' ? 'badge-declined'
                          : 'badge-pending';
            const vsLabel = ev.volStatus.charAt(0).toUpperCase() + ev.volStatus.slice(1);
            const evsBadge = ev.evStatus === 'opened'
                ? '<span class="badge badge-opened" style="font-size:10px;padding:3px 8px;"><span class="badge-dot"></span>Open</span>'
                : '<span class="badge badge-closed" style="font-size:10px;padding:3px 8px;"><span class="badge-dot"></span>Closed</span>';
            const locHtml = ev.location
                ? '<span><i class="fas fa-map-marker-alt" style="font-size:9px;margin-right:3px;"></i>' + ev.location + '</span>&nbsp;&nbsp;'
                : '';
            html += '<div class="event-entry">' +
                '<div class="event-entry-icon"><i class="fas fa-calendar-alt"></i></div>' +
                '<div class="event-entry-info">' +
                    '<div class="event-entry-title">' + ev.title + '</div>' +
                    '<div class="event-entry-meta">' +
                        locHtml +
                        '<span><i class="fas fa-clock" style="font-size:9px;margin-right:3px;"></i>' + ev.startsAt + ' → ' + ev.endsAt + '</span>' +
                    '</div>' +
                '</div>' +
                '<div class="event-entry-right">' +
                    '<span class="badge ' + vsClass + '" style="font-size:10px;padding:3px 9px;">' +
                        '<span class="badge-dot"></span>' + vsLabel +
                    '</span>' +
                    evsBadge +
                    '<span class="event-joined-date">Joined ' + ev.joinedAt + '</span>' +
                '</div>' +
            '</div>';
        });
        evList.innerHTML = html;
    }

    openModal('detailModal');
}

// Auto-dismiss flash message
(function() {
    const flash = document.getElementById('flashMsg');
    if (flash) setTimeout(function() {
        flash.style.transition = 'opacity .5s';
        flash.style.opacity = '0';
        setTimeout(function() { flash.remove(); }, 500);
    }, 4000);
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
