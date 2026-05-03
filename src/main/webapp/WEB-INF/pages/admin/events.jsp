<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.VMS.model.Event, java.util.List" %>
<%!
    /* JavaScript-safe string escape helper */
    private static String esc(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("'",  "\\'")
                .replace("\r", "")
                .replace("\n", "\\n")
                .replace("<",  "\\x3C")
                .replace(">",  "\\x3E");
    }
    /* HTML-safe output helper */
    private static String h(String s) {
        if (s == null) return "";
        return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
                .replace("\"","&quot;").replace("'","&#39;");
    }
%>
<%
    String adminName = (String) session.getAttribute("userName");
    if (adminName == null) adminName = "Admin";
    String initials = adminName.length() > 0
        ? String.valueOf(adminName.charAt(0)).toUpperCase() : "A";

    @SuppressWarnings("unchecked")
    List<Event> events = (List<Event>) request.getAttribute("events");
    if (events == null) events = new java.util.ArrayList<>();

    int totalEvents        = request.getAttribute("totalEvents")        != null ? (Integer) request.getAttribute("totalEvents")        : 0;
    int openEvents         = request.getAttribute("openEvents")         != null ? (Integer) request.getAttribute("openEvents")         : 0;
    int eventsThisMonth    = request.getAttribute("eventsThisMonth")    != null ? (Integer) request.getAttribute("eventsThisMonth")    : 0;
    int totalRegistrations = request.getAttribute("totalRegistrations") != null ? (Integer) request.getAttribute("totalRegistrations") : 0;

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
    <title>Event Management – VolunteerHub</title>
    <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
    <style>
        /* ══ TABLE ══ */
        .events-table-wrap {
            overflow-x: auto;
            border-radius: var(--radius);
            border: 1px solid var(--border);
            background: var(--bg-card);
        }
        .events-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
        }
        .events-table thead th {
            background: rgba(124,92,191,.08);
            color: var(--text-secondary);
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: .8px;
            padding: 13px 16px;
            text-align: left;
            white-space: nowrap;
            user-select: none;
        }
        .events-table thead th.sortable { cursor: pointer; }
        .events-table thead th.sortable:hover { color: var(--text-primary); }
        .events-table thead th .sort-icon { margin-left: 4px; opacity: .5; }
        .events-table thead th.active-sort .sort-icon { opacity: 1; color: #7c5cbf; }
        .events-table tbody tr {
            border-top: 1px solid var(--border);
            transition: background .15s;
            cursor: pointer;
        }
        .events-table tbody tr:hover { background: rgba(124,92,191,.06); }
        .events-table td {
            padding: 13px 16px;
            color: var(--text-primary);
            vertical-align: middle;
        }
        .events-table td.muted { color: var(--text-secondary); font-size: 12px; }

        /* ══ EVENT TITLE CELL ══ */
        .event-title-cell { display: flex; align-items: center; gap: 12px; }
        .event-thumb {
            width: 40px; height: 40px; border-radius: 8px;
            object-fit: cover; flex-shrink: 0;
            border: 1px solid var(--border);
        }
        .event-thumb-placeholder {
            width: 40px; height: 40px; border-radius: 8px; flex-shrink: 0;
            background: rgba(124,92,191,.15);
            display: flex; align-items: center; justify-content: center;
            color: #7c5cbf; font-size: 16px;
        }
        .event-title-text { font-weight: 600; color: var(--text-primary); line-height: 1.3; }
        .event-title-loc  { font-size: 11px; color: var(--text-muted); margin-top: 2px; }

        /* ══ STATUS BADGE ══ */
        .badge {
            display: inline-flex; align-items: center; gap: 5px;
            padding: 4px 10px; border-radius: 20px;
            font-size: 11px; font-weight: 700; letter-spacing: .4px;
            white-space: nowrap;
        }
        .badge-upcoming  { background: rgba(79,142,247,.12);  color: #4f8ef7; border: 1px solid rgba(79,142,247,.3); }
        .badge-ongoing   { background: rgba(56,201,176,.12);  color: #38c9b0; border: 1px solid rgba(56,201,176,.3); }
        .badge-finished  { background: rgba(100,100,120,.12); color: var(--text-secondary); border: 1px solid var(--border); }
        .badge-dot { width: 6px; height: 6px; border-radius: 50%; background: currentColor; }

        /* ══ CAPACITY BAR ══ */
        .cap-wrap { min-width: 80px; }
        .cap-text  { font-size: 12px; color: var(--text-secondary); margin-bottom: 4px; }
        .cap-bar   { height: 4px; border-radius: 2px; background: rgba(255,255,255,.08); overflow: hidden; }
        .cap-fill  { height: 100%; border-radius: 2px; background: linear-gradient(90deg,#7c5cbf,#4f8ef7); transition: width .4s; }

        /* ══ ACTION BUTTONS ══ */
        .action-btns { display: flex; gap: 6px; flex-shrink: 0; }
        .btn-sm {
            padding: 5px 11px; border-radius: 7px; font-size: 11px; font-weight: 600;
            border: none; cursor: pointer; transition: opacity .2s; display: inline-flex; align-items: center; gap: 4px;
        }
        .btn-view   { background: rgba(79,142,247,.12);  color: #4f8ef7; border: 1px solid rgba(79,142,247,.25); }
        .btn-edit   { background: rgba(245,166,35,.12);  color: #f5a623; border: 1px solid rgba(245,166,35,.25); }
        .btn-delete { background: rgba(224,92,151,.12);  color: #e05c97; border: 1px solid rgba(224,92,151,.25); }
        .btn-sm:hover { opacity: .75; }

        /* ══ TOOLBAR ══ */
        .events-toolbar {
            display: flex; align-items: center; gap: 12px;
            flex-wrap: wrap; margin-bottom: 20px;
        }
        .search-box {
            flex: 1; min-width: 220px;
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
        .btn-add {
            display: inline-flex; align-items: center; gap: 7px;
            background: linear-gradient(135deg,#7c5cbf,#4f8ef7);
            color: #fff; border: none; border-radius: 10px;
            padding: 9px 18px; font-size: 13px; font-weight: 700;
            cursor: pointer; transition: opacity .2s; white-space: nowrap;
            font-family: inherit;
        }
        .btn-add:hover { opacity: .88; }

        /* ══ EMPTY STATE ══ */
        .empty-row td {
            text-align: center; padding: 48px; color: var(--text-muted); font-size: 13px;
        }
        .empty-row td i { font-size: 36px; display: block; margin-bottom: 14px; opacity: .3; }

        /* ══ MODAL BASE ══ */
        .modal-overlay {
            display: none; position: fixed; inset: 0;
            background: rgba(0,0,0,.7); z-index: 1000;
            align-items: center; justify-content: center; padding: 20px;
        }
        .modal-overlay.open { display: flex; }
        .modal-box {
            background: var(--bg-card); border: 1px solid var(--border);
            border-radius: var(--radius); width: 100%; position: relative;
            animation: mUp .2s ease;
            display: flex; flex-direction: column;
            max-height: 90vh; overflow: hidden;
        }
        @keyframes mUp {
            from { opacity: 0; transform: translateY(18px); }
            to   { opacity: 1; transform: translateY(0); }
        }
        .modal-header {
            padding: 22px 24px 16px;
            border-bottom: 1px solid var(--border);
            display: flex; align-items: center; justify-content: space-between;
            flex-shrink: 0;
        }
        .modal-title { font-size: 16px; font-weight: 700; color: var(--text-primary); }
        .modal-close {
            background: none; border: none; color: var(--text-secondary);
            font-size: 16px; cursor: pointer; padding: 4px;
        }
        .modal-close:hover { color: var(--text-primary); }
        .modal-body { padding: 22px 24px; overflow-y: auto; flex: 1; }
        .modal-footer {
            padding: 16px 24px; border-top: 1px solid var(--border);
            display: flex; gap: 10px; justify-content: flex-end; flex-shrink: 0;
        }

        /* ══ FORM STYLES (inside modal) ══ */
        .form-grid-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
        .form-full   { grid-column: 1 / -1; }
        .f-group label {
            display: block; font-size: 10px; text-transform: uppercase;
            letter-spacing: .8px; color: var(--text-muted); margin-bottom: 6px;
        }
        .f-group input, .f-group textarea, .f-group select {
            width: 100%; background: rgba(255,255,255,.04);
            border: 1px solid var(--border); border-radius: 9px;
            color: var(--text-primary); padding: 9px 12px;
            font-size: 13px; font-family: inherit; outline: none;
            transition: border-color .2s; box-sizing: border-box;
        }
        .f-group textarea { resize: vertical; min-height: 80px; }
        .f-group input:focus, .f-group textarea:focus, .f-group select:focus {
            border-color: #7c5cbf;
        }
        .f-group select option { background: #1e1836; }

        /* ══ SUBMIT BUTTONS ══ */
        .btn-submit {
            padding: 10px 22px; border-radius: 10px; font-size: 13px;
            font-weight: 700; border: none; cursor: pointer;
            transition: opacity .2s; font-family: inherit;
        }
        .btn-primary { background: linear-gradient(135deg,#7c5cbf,#4f8ef7); color: #fff; }
        .btn-cancel  { background: rgba(255,255,255,.06); color: var(--text-secondary); border: 1px solid var(--border); }
        .btn-submit:hover { opacity: .85; }
        .btn-danger  { background: linear-gradient(135deg,#e05c97,#c0416f); color: #fff; }

        /* ══ DETAIL MODAL SPECIFIC ══ */
        .detail-event-img {
            width: 100%; height: 200px; object-fit: cover;
            border-radius: 10px; margin-bottom: 18px;
        }
        .detail-event-img-placeholder {
            width: 100%; height: 160px; border-radius: 10px;
            background: rgba(124,92,191,.1);
            display: flex; align-items: center; justify-content: center;
            color: rgba(124,92,191,.4); font-size: 48px; margin-bottom: 18px;
        }
        .detail-title   { font-size: 20px; font-weight: 700; margin-bottom: 6px; }
        .detail-desc    { color: var(--text-secondary); font-size: 13px; line-height: 1.7; margin-bottom: 20px; }
        .detail-grid    { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin-bottom: 18px; }
        .detail-item label {
            font-size: 10px; text-transform: uppercase; letter-spacing: .7px;
            color: var(--text-muted); display: block; margin-bottom: 4px;
        }
        .detail-item span { font-size: 13px; color: var(--text-primary); font-weight: 500; }
        .detail-item.full { grid-column: 1/-1; }
        .map-btn {
            display: inline-flex; align-items: center; gap: 6px;
            padding: 7px 14px; border-radius: 8px; font-size: 12px; font-weight: 600;
            background: rgba(79,142,247,.12); color: #4f8ef7;
            border: 1px solid rgba(79,142,247,.25); text-decoration: none;
            transition: opacity .2s; margin-top: 8px;
        }
        .map-btn:hover { opacity: .8; }

        /* ══ IMAGE UPLOAD PREVIEW ══ */
        .img-preview-wrap {
            margin-top: 8px; display: none;
        }
        .img-preview-wrap img {
            max-height: 120px; border-radius: 8px;
            border: 1px solid var(--border); object-fit: cover;
        }
        .current-img-wrap {
            margin-top: 8px;
        }
        .current-img-wrap img {
            max-height: 80px; border-radius: 8px;
            border: 1px solid var(--border); object-fit: cover;
        }
        .current-img-wrap p { font-size: 11px; color: var(--text-muted); margin: 4px 0 0; }

        /* ══ RESULTS COUNT ══ */
        .results-meta {
            font-size: 12px; color: var(--text-muted); margin-bottom: 12px;
        }

        /* ══ MODAL WIDTHS ══ */
        #detailModal .modal-box { max-width: 600px; }
        #addModal    .modal-box { max-width: 680px; }
        #editModal   .modal-box { max-width: 680px; }
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
    <a href="${pageContext.request.contextPath}/admin/events" class="nav-item active">
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
                <h2>Event Management</h2>
                <p>Create, manage and track all volunteer events</p>
            </div>
        </div>
        <div class="topbar-right">
            <div class="topbar-icon-btn">
                <i class="fas fa-bell"></i>
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
        <% if (request.getParameter("error") != null) { %>
        <div id="flashMsg" style="background:rgba(224,92,151,0.12); border:1px solid rgba(224,92,151,0.25);
                    color:#e05c97; padding:12px 16px; border-radius:10px;
                    font-size:13px; margin-bottom:20px; display:flex; align-items:center; gap:8px;">
            <i class="fas fa-exclamation-circle"></i> <%= h(request.getParameter("error")) %>
        </div>
        <% } %>

        <!-- Stats Row -->
        <div class="stats-grid">

            <div class="stat-card purple">
                <div class="stat-icon"><i class="fas fa-calendar-alt"></i></div>
                <div class="stat-value"><%= totalEvents %></div>
                <div class="stat-label">Total Events</div>
                <div class="stat-change up"><i class="fas fa-list"></i> All time</div>
            </div>

            <div class="stat-card teal">
                <div class="stat-icon"><i class="fas fa-calendar-check"></i></div>
                <div class="stat-value"><%= openEvents %></div>
                <div class="stat-label">Active Events</div>
                <div class="stat-change up"><i class="fas fa-door-open"></i> Upcoming &amp; ongoing</div>
            </div>

            <div class="stat-card blue">
                <div class="stat-icon"><i class="fas fa-calendar-day"></i></div>
                <div class="stat-value"><%= eventsThisMonth %></div>
                <div class="stat-label">Events This Month</div>
                <div class="stat-change"><i class="fas fa-clock"></i> Starting this month</div>
            </div>

            <div class="stat-card pink">
                <div class="stat-icon"><i class="fas fa-users"></i></div>
                <div class="stat-value"><%= totalRegistrations %></div>
                <div class="stat-label">Total Registrations</div>
                <div class="stat-change up"><i class="fas fa-user-check"></i> Accepted across all events</div>
            </div>

        </div>

        <!-- Toolbar: search + filter + add button -->
        <form method="GET" action="${pageContext.request.contextPath}/admin/events" id="searchForm">
            <div class="events-toolbar">

                <div class="search-box">
                    <i class="fas fa-search"></i>
                    <input type="text" name="search" id="searchInput"
                           placeholder="Search events by title, description or location..."
                           value="<%= h(search) %>">
                </div>

                <select name="sortBy" class="filter-select" onchange="document.getElementById('searchForm').submit()">
                    <option value="createdAt" <%= "createdAt".equals(sortBy) ? "selected" : "" %>>Sort: Date Added</option>
                    <option value="title"     <%= "title".equals(sortBy)     ? "selected" : "" %>>Sort: Title</option>
                    <option value="startsAt"  <%= "startsAt".equals(sortBy)  ? "selected" : "" %>>Sort: Start Date</option>
                    <option value="endsAt"    <%= "endsAt".equals(sortBy)    ? "selected" : "" %>>Sort: End Date</option>
                    <option value="status"    <%= "status".equals(sortBy)    ? "selected" : "" %>>Sort: Status</option>
                </select>

                <select name="sortDir" class="filter-select" onchange="document.getElementById('searchForm').submit()">
                    <option value="desc" <%= "desc".equals(sortDir) ? "selected" : "" %>>&#8595; Descending</option>
                    <option value="asc"  <%= "asc".equals(sortDir)  ? "selected" : "" %>>&#8593; Ascending</option>
                </select>

                <button type="submit" class="filter-select" style="cursor:pointer;">
                    <i class="fas fa-filter"></i> Filter
                </button>

                <button type="button" class="btn-add" onclick="openAddModal()">
                    <i class="fas fa-plus"></i> Add New Event
                </button>

            </div>
        </form>

        <!-- Results count -->
        <div class="results-meta">
            Showing <strong style="color:var(--text-primary)"><%= events.size() %></strong> event<%= events.size() != 1 ? "s" : ""%>
            <% if (!search.isEmpty()) { %> matching "<strong style="color:#7c5cbf"><%= h(search) %></strong>"<% } %>
        </div>

        <!-- Events Table -->
        <div class="events-table-wrap">
            <table class="events-table" id="eventsTable">
                <thead>
                    <tr>
                        <th style="width:40px;">#</th>
                        <th>Event</th>
                        <th>Status</th>
                        <th>Starts</th>
                        <th>Ends</th>
                        <th>Location</th>
                        <th>Volunteers</th>
                        <th style="width:150px;">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        if (events.isEmpty()) {
                    %>
                    <tr class="empty-row">
                        <td colspan="8">
                            <i class="fas fa-calendar-times"></i>
                            No events found.<% if (!search.isEmpty()) { %> Try a different search term.<% } %>
                            <br><br>
                            <button type="button" class="btn-add" onclick="openAddModal()" style="margin:0 auto;">
                                <i class="fas fa-plus"></i> Create Your First Event
                            </button>
                        </td>
                    </tr>
                    <%
                        } else {
                            int rowNum = 0;
                            for (Event ev : events) {
                                rowNum++;
                                String derived    = ev.getDerivedStatus(); // upcoming | ongoing | finished
                                String statusClass = "badge-" + derived;
                                String statusLabel = derived.substring(0,1).toUpperCase() + derived.substring(1);
                                String loc  = ev.getLocation()    != null ? ev.getLocation()    : "";
                                String img  = ev.getImage()       != null ? ev.getImage()       : "";
                                String desc = ev.getDescription() != null ? ev.getDescription() : "";

                                // Cap fill percentage
                                int cap = 0;
                                try {
                                    if (ev.getMaxLimit() != null && !ev.getMaxLimit().isEmpty())
                                        cap = Integer.parseInt(ev.getMaxLimit().trim());
                                } catch (NumberFormatException ignored) {}
                                int fillPct = (cap > 0) ? Math.min((ev.getVolunteerCount() * 100 / cap), 100) : 0;
                    %>
                    <tr onclick="openDetailModal('<%= h(ev.getId()) %>')"
                        data-id="<%= h(ev.getId()) %>">

                        <td class="muted"><%= rowNum %></td>

                        <!-- Event title + thumbnail -->
                        <td>
                            <div class="event-title-cell">
                                <% if (!img.isEmpty()) { %>
                                    <img src="${pageContext.request.contextPath}/<%= h(img) %>"
                                         alt="" class="event-thumb">
                                <% } else { %>
                                    <div class="event-thumb-placeholder">
                                        <i class="fas fa-calendar-alt"></i>
                                    </div>
                                <% } %>
                                <div>
                                    <div class="event-title-text"><%= h(ev.getTitle()) %></div>
                                    <% if (!loc.isEmpty()) { %>
                                    <div class="event-title-loc">
                                        <i class="fas fa-map-marker-alt" style="font-size:10px;"></i>
                                        <%= h(loc) %>
                                    </div>
                                    <% } %>
                                </div>
                            </div>
                        </td>

                        <!-- Status (auto-derived from dates) -->
                        <td>
                            <span class="badge <%= statusClass %>">
                                <span class="badge-dot"></span>
                                <%= statusLabel %>
                            </span>
                        </td>

                        <!-- Dates -->
                        <td class="muted"><%= ev.getStartsAtDisplay() %></td>
                        <td class="muted"><%= ev.getEndsAtDisplay() %></td>

                        <!-- Location -->
                        <td class="muted" style="max-width:140px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;">
                            <%= loc.isEmpty() ? "<span style='opacity:.4'>—</span>" : h(loc) %>
                        </td>

                        <!-- Capacity bar -->
                        <td>
                            <div class="cap-wrap">
                                <div class="cap-text"><%= ev.getCapacityDisplay() %></div>
                                <% if (cap > 0) { %>
                                <div class="cap-bar">
                                    <div class="cap-fill" style="width:<%= fillPct %>%"></div>
                                </div>
                                <% } %>
                            </div>
                        </td>

                        <!-- Action buttons (stop row click propagation) -->
                        <td onclick="event.stopPropagation()">
                            <div class="action-btns">
                                <button class="btn-sm btn-view"
                                        onclick="openDetailModal('<%= h(ev.getId()) %>')">
                                    <i class="fas fa-eye"></i> View
                                </button>
                                <button class="btn-sm btn-edit"
                                        onclick="openEditModal('<%= h(ev.getId()) %>')">
                                    <i class="fas fa-pen"></i> Edit
                                </button>
                                <button class="btn-sm btn-delete"
                                        onclick="confirmDelete('<%= h(ev.getId()) %>','<%= esc(ev.getTitle()) %>')">
                                    <i class="fas fa-trash"></i>
                                </button>
                            </div>
                        </td>
                    </tr>
                    <%      } // end for
                        }   // end else
                    %>
                </tbody>
            </table>
        </div>

    </div><!-- end page-body -->
</div><!-- end main -->

<!-- ════════════════════════════════════════════════
     MODAL 1 — VIEW DETAIL
════════════════════════════════════════════════ -->
<div class="modal-overlay" id="detailModal" onclick="closeOnBg(event,'detailModal')">
    <div class="modal-box">
        <div class="modal-header">
            <span class="modal-title"><i class="fas fa-calendar-alt" style="color:#4f8ef7;margin-right:8px;"></i>Event Details</span>
            <button class="modal-close" onclick="closeModal('detailModal')"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body">
            <div id="detailImgWrap"></div>
            <div style="display:flex;align-items:center;gap:12px;margin-bottom:10px;">
                <h2 class="detail-title" id="detailTitle" style="margin:0;flex:1;"></h2>
                <span id="detailStatus"></span>
            </div>
            <p class="detail-desc" id="detailDesc"></p>
            <div class="detail-grid">
                <div class="detail-item">
                    <label><i class="fas fa-calendar-check"></i> Starts</label>
                    <span id="detailStarts"></span>
                </div>
                <div class="detail-item">
                    <label><i class="fas fa-calendar-times"></i> Ends</label>
                    <span id="detailEnds"></span>
                </div>
                <div class="detail-item">
                    <label><i class="fas fa-users"></i> Volunteers / Capacity</label>
                    <span id="detailCap"></span>
                </div>
                <div class="detail-item">
                    <label><i class="fas fa-info-circle"></i> Status</label>
                    <span id="detailStatusText"></span>
                </div>
                <div class="detail-item full" id="detailLocWrap" style="display:none;">
                    <label><i class="fas fa-map-marker-alt"></i> Location</label>
                    <span id="detailLoc"></span>
                    <br>
                    <a id="detailMapBtn" href="#" target="_blank" class="map-btn">
                        <i class="fas fa-map"></i> View on Map
                    </a>
                </div>
            </div>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn-submit btn-cancel" onclick="closeModal('detailModal')">Close</button>
            <button type="button" class="btn-submit btn-primary" id="detailEditBtn" onclick="">
                <i class="fas fa-pen"></i> Edit Event
            </button>
        </div>
    </div>
</div>

<!-- ════════════════════════════════════════════════
     MODAL 2 — ADD EVENT
════════════════════════════════════════════════ -->
<div class="modal-overlay" id="addModal" onclick="closeOnBg(event,'addModal')">
    <div class="modal-box">
        <div class="modal-header">
            <span class="modal-title"><i class="fas fa-plus-circle" style="color:#38c9b0;margin-right:8px;"></i>Add New Event</span>
            <button class="modal-close" onclick="closeModal('addModal')"><i class="fas fa-times"></i></button>
        </div>
        <form method="POST" action="${pageContext.request.contextPath}/admin/events?action=create"
              enctype="multipart/form-data" id="addForm">
            <div class="modal-body">
                <div class="form-grid-2">

                    <div class="f-group form-full">
                        <label>Event Title *</label>
                        <input type="text" name="title" placeholder="e.g. Community Clean-Up Drive" required>
                    </div>

                    <div class="f-group form-full">
                        <label>Description</label>
                        <textarea name="description" placeholder="Describe the event, purpose, activities..."></textarea>
                    </div>

                    <div class="f-group">
                        <label>Start Date &amp; Time *</label>
                        <input type="datetime-local" name="startsAt" required>
                    </div>

                    <div class="f-group">
                        <label>End Date &amp; Time *</label>
                        <input type="datetime-local" name="endsAt" required>
                    </div>

                    <div class="f-group">
                        <label>Max Volunteers (leave blank = unlimited)</label>
                        <input type="number" name="maxLimit" placeholder="e.g. 50" min="1">
                    </div>

                    <div class="f-group">
                        <label>Status</label>
                        <div style="padding:9px 12px; border-radius:9px; border:1px solid var(--border);
                                    background:rgba(255,255,255,.03); font-size:13px; color:var(--text-muted);">
                            <i class="fas fa-magic" style="font-size:11px; color:#7c5cbf;"></i>
                            Auto — derived from start &amp; end dates
                        </div>
                    </div>

                    <div class="f-group form-full">
                        <label>Location</label>
                        <input type="text" name="location" placeholder="e.g. Central Park, New York">
                    </div>

                    <div class="f-group form-full">
                        <label>Event Image (JPG, PNG, GIF, WEBP — max 5MB)</label>
                        <input type="file" name="eventImage" accept="image/jpeg,image/png,image/gif,image/webp"
                               onchange="previewImg(this,'addPreview')">
                        <div class="img-preview-wrap" id="addPreview">
                            <img src="" alt="preview">
                        </div>
                    </div>

                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-submit btn-cancel" onclick="closeModal('addModal')">Cancel</button>
                <button type="submit" class="btn-submit btn-primary">
                    <i class="fas fa-save"></i> Create Event
                </button>
            </div>
        </form>
    </div>
</div>

<!-- ════════════════════════════════════════════════
     MODAL 3 — EDIT EVENT
════════════════════════════════════════════════ -->
<div class="modal-overlay" id="editModal" onclick="closeOnBg(event,'editModal')">
    <div class="modal-box">
        <div class="modal-header">
            <span class="modal-title"><i class="fas fa-pen" style="color:#f5a623;margin-right:8px;"></i>Edit Event</span>
            <button class="modal-close" onclick="closeModal('editModal')"><i class="fas fa-times"></i></button>
        </div>
        <form method="POST" action="${pageContext.request.contextPath}/admin/events?action=update"
              enctype="multipart/form-data" id="editForm">
            <input type="hidden" name="id" id="editId">
            <div class="modal-body">
                <div class="form-grid-2">

                    <div class="f-group form-full">
                        <label>Event Title *</label>
                        <input type="text" name="title" id="editTitle" placeholder="Event title" required>
                    </div>

                    <div class="f-group form-full">
                        <label>Description</label>
                        <textarea name="description" id="editDesc" placeholder="Event description..."></textarea>
                    </div>

                    <div class="f-group">
                        <label>Start Date &amp; Time *</label>
                        <input type="datetime-local" name="startsAt" id="editStartsAt" required>
                    </div>

                    <div class="f-group">
                        <label>End Date &amp; Time *</label>
                        <input type="datetime-local" name="endsAt" id="editEndsAt" required>
                    </div>

                    <div class="f-group">
                        <label>Max Volunteers (leave blank = unlimited)</label>
                        <input type="number" name="maxLimit" id="editMaxLimit" placeholder="e.g. 50" min="1">
                    </div>

                    <div class="f-group">
                        <label>Status</label>
                        <div id="editStatusDisplay" style="padding:9px 12px; border-radius:9px; border:1px solid var(--border);
                                    background:rgba(255,255,255,.03); font-size:13px; color:var(--text-muted);">
                            <i class="fas fa-magic" style="font-size:11px; color:#7c5cbf;"></i>
                            Auto — derived from start &amp; end dates
                        </div>
                    </div>

                    <div class="f-group form-full">
                        <label>Location</label>
                        <input type="text" name="location" id="editLocation" placeholder="Event location">
                    </div>

                    <div class="f-group form-full">
                        <label>Event Image</label>

                        <!-- Current image (shown only when event has one) -->
                        <div class="current-img-wrap" id="editCurrentImg" style="display:none;">
                            <img src="" alt="current" id="editCurrentImgEl"
                                 style="transition:opacity .25s;">
                            <div style="display:flex; align-items:center; gap:10px; margin-top:6px; flex-wrap:wrap;">
                                <p style="margin:0; font-size:11px; color:var(--text-muted);">Current image</p>
                                <label style="display:inline-flex; align-items:center; gap:6px;
                                              font-size:11px; font-weight:600; color:#e05c97;
                                              cursor:pointer; text-transform:none; letter-spacing:0;">
                                    <input type="checkbox" name="removeImage" value="true"
                                           id="removeImageCheck"
                                           onchange="onRemoveImageToggle(this)"
                                           style="width:auto; accent-color:#e05c97;">
                                    Remove this image
                                </label>
                            </div>
                        </div>

                        <!-- File picker (disabled while "remove" is ticked) -->
                        <div style="margin-top:10px;">
                            <input type="file" name="eventImage" id="editImageInput"
                                   accept="image/jpeg,image/png,image/gif,image/webp"
                                   onchange="previewImg(this,'editPreview')">
                            <div style="font-size:10px; color:var(--text-muted); margin-top:4px;">
                                JPG · PNG · GIF · WEBP — leave blank to keep existing
                            </div>
                        </div>
                        <div class="img-preview-wrap" id="editPreview">
                            <img src="" alt="new preview">
                        </div>
                    </div>

                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-submit btn-cancel" onclick="closeModal('editModal')">Cancel</button>
                <button type="submit" class="btn-submit btn-primary">
                    <i class="fas fa-save"></i> Save Changes
                </button>
            </div>
        </form>
    </div>
</div>

<!-- ════════════════════════════════════════════════
     HIDDEN DELETE FORM
════════════════════════════════════════════════ -->
<form method="POST" action="${pageContext.request.contextPath}/admin/events?action=delete"
      id="deleteForm" style="display:none;">
    <input type="hidden" name="id" id="deleteId">
</form>

<!-- ════════════════════════════════════════════════
     JAVASCRIPT — embed event data + modal logic
════════════════════════════════════════════════ -->
<script>
// ── Embed all event data server-side for client-side modals ──
const EVENTS = [
<% for (int i = 0; i < events.size(); i++) {
    Event ev = events.get(i);
    String loc = ev.getLocation()    != null ? ev.getLocation()    : "";
    String img = ev.getImage()       != null ? ev.getImage()       : "";
    String desc = ev.getDescription() != null ? ev.getDescription() : "";
%>
  {
    id:          '<%= esc(ev.getId()) %>',
    title:       '<%= esc(ev.getTitle()) %>',
    description: '<%= esc(desc) %>',
    startsAt:    '<%= esc(ev.getStartsAtDisplay()) %>',
    endsAt:      '<%= esc(ev.getEndsAtDisplay()) %>',
    startsInput: '<%= esc(ev.getStartsAtInput()) %>',
    endsInput:   '<%= esc(ev.getEndsAtInput()) %>',
    maxLimit:    '<%= esc(ev.getMaxLimit() != null ? ev.getMaxLimit() : "") %>',
    status:      '<%= esc(ev.getDerivedStatus()) %>',
    location:    '<%= esc(loc) %>',
    image:       '<%= esc(img) %>',
    volCount:    <%= ev.getVolunteerCount() %>,
    capDisplay:  '<%= esc(ev.getCapacityDisplay()) %>'
  }<%= i < events.size()-1 ? "," : "" %>
<% } %>
];

const CTX = '<%= request.getContextPath() %>';

// ── Modal open/close helpers ──────────────────────────────
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
    if (e.key === 'Escape') {
        ['detailModal','addModal','editModal'].forEach(closeModal);
    }
});

// ── View Detail ───────────────────────────────────────────
function openDetailModal(id) {
    const ev = EVENTS.find(x => x.id === id);
    if (!ev) return;

    // Image
    const imgWrap = document.getElementById('detailImgWrap');
    if (ev.image) {
        imgWrap.innerHTML = '<img src="' + CTX + '/' + ev.image + '" class="detail-event-img" alt="">';
    } else {
        imgWrap.innerHTML = '<div class="detail-event-img-placeholder"><i class="fas fa-calendar-alt"></i></div>';
    }

    document.getElementById('detailTitle').textContent = ev.title;
    document.getElementById('detailDesc').textContent  = ev.description || 'No description provided.';
    document.getElementById('detailStarts').textContent = ev.startsAt;
    document.getElementById('detailEnds').textContent   = ev.endsAt;
    document.getElementById('detailCap').textContent    = ev.capDisplay;
    const statusLabel = ev.status.charAt(0).toUpperCase() + ev.status.slice(1);
    document.getElementById('detailStatusText').textContent = statusLabel;

    const statusEl = document.getElementById('detailStatus');
    statusEl.className = 'badge badge-' + ev.status;
    statusEl.innerHTML = '<span class="badge-dot"></span>' + statusLabel;

    // Location + Map
    const locWrap = document.getElementById('detailLocWrap');
    if (ev.location) {
        locWrap.style.display = '';
        document.getElementById('detailLoc').textContent = ev.location;
        document.getElementById('detailMapBtn').href =
            'https://maps.google.com/maps?q=' + encodeURIComponent(ev.location);
    } else {
        locWrap.style.display = 'none';
    }

    // Edit button wires to openEditModal
    document.getElementById('detailEditBtn').onclick = function() {
        closeModal('detailModal');
        openEditModal(id);
    };

    openModal('detailModal');
}

// ── Add Event ─────────────────────────────────────────────
function openAddModal() {
    document.getElementById('addForm').reset();
    document.getElementById('addPreview').style.display = 'none';
    openModal('addModal');
}

// ── Edit Event ────────────────────────────────────────────
function openEditModal(id) {
    const ev = EVENTS.find(x => x.id === id);
    if (!ev) return;

    document.getElementById('editId').value          = ev.id;
    document.getElementById('editTitle').value       = ev.title;
    document.getElementById('editDesc').value        = ev.description;
    document.getElementById('editStartsAt').value    = ev.startsInput;
    document.getElementById('editEndsAt').value      = ev.endsInput;
    document.getElementById('editMaxLimit').value    = ev.maxLimit;
    document.getElementById('editLocation').value    = ev.location;
    // Status is auto-derived — no dropdown to set

    // Current image thumbnail + remove checkbox
    const curImgWrap     = document.getElementById('editCurrentImg');
    const removeCheck    = document.getElementById('removeImageCheck');
    const editImgInput   = document.getElementById('editImageInput');
    removeCheck.checked  = false;
    editImgInput.disabled = false;
    if (ev.image) {
        curImgWrap.style.display = '';
        document.getElementById('editCurrentImgEl').src   = CTX + '/' + ev.image;
        document.getElementById('editCurrentImgEl').style.opacity = '1';
    } else {
        curImgWrap.style.display = 'none';
    }

    document.getElementById('editPreview').style.display = 'none';
    openModal('editModal');
}

// ── Remove-image checkbox toggle ──────────────────────────
function onRemoveImageToggle(checkbox) {
    const imgEl       = document.getElementById('editCurrentImgEl');
    const fileInput   = document.getElementById('editImageInput');
    if (checkbox.checked) {
        imgEl.style.opacity   = '0.25';
        fileInput.disabled    = true;
        fileInput.value       = '';
        document.getElementById('editPreview').style.display = 'none';
    } else {
        imgEl.style.opacity   = '1';
        fileInput.disabled    = false;
    }
}

// ── Delete Event ──────────────────────────────────────────
function confirmDelete(id, title) {
    if (confirm('Delete event "' + title + '"?\n\nThis will also remove all volunteer registrations for this event. This action cannot be undone.')) {
        document.getElementById('deleteId').value = id;
        document.getElementById('deleteForm').submit();
    }
}

// ── Image preview ─────────────────────────────────────────
function previewImg(input, previewWrapId) {
    const wrap = document.getElementById(previewWrapId);
    if (input.files && input.files[0]) {
        const reader = new FileReader();
        reader.onload = function(e) {
            wrap.querySelector('img').src = e.target.result;
            wrap.style.display = '';
        };
        reader.readAsDataURL(input.files[0]);
    }
}

// ── Auto-dismiss flash message ────────────────────────────
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
