<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.VMS.model.Event, java.util.List" %>
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
%>
<%
    String volunteerName = (String) session.getAttribute("userName");
    if (volunteerName == null) volunteerName = "Volunteer";
    String initials = volunteerName.length() > 0
        ? String.valueOf(volunteerName.charAt(0)).toUpperCase() : "V";

    @SuppressWarnings("unchecked")
    List<Event> events = (List<Event>) request.getAttribute("events");
    if (events == null) events = new java.util.ArrayList<>();

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
    <title>Browse Events – VolunteerHub</title>
    <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/volunteer.css">
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
            background: rgba(79,142,247,.08);
            color: var(--text-secondary);
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: .8px;
            padding: 13px 16px;
            text-align: left;
            white-space: nowrap;
            user-select: none;
        }
        .events-table tbody tr {
            border-top: 1px solid var(--border);
            transition: background .15s;
            cursor: pointer;
        }
        .events-table tbody tr:hover { background: rgba(79,142,247,.06); }
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
            background: rgba(79,142,247,.12);
            display: flex; align-items: center; justify-content: center;
            color: #4f8ef7; font-size: 16px;
        }
        .event-title-text { font-weight: 600; color: var(--text-primary); line-height: 1.3; }
        .event-title-loc  { font-size: 11px; color: var(--text-muted); margin-top: 2px; }

        /* ══ BADGES ══ */
        .badge {
            display: inline-flex; align-items: center; gap: 5px;
            padding: 4px 10px; border-radius: 20px;
            font-size: 11px; font-weight: 700; letter-spacing: .4px;
            white-space: nowrap;
        }
        .badge-dot { width: 6px; height: 6px; border-radius: 50%; background: currentColor; }
        .badge-opened   { background: rgba(56,201,176,.15);  color: #38c9b0; border: 1px solid rgba(56,201,176,.3); }
        .badge-closed   { background: rgba(224,92,151,.12);  color: #e05c97; border: 1px solid rgba(224,92,151,.25); }
        .badge-pending  { background: rgba(245,166,35,.12);  color: #f5a623; border: 1px solid rgba(245,166,35,.3); }
        .badge-accepted { background: rgba(56,201,176,.15);  color: #38c9b0; border: 1px solid rgba(56,201,176,.3); }
        .badge-declined { background: rgba(224,92,151,.12);  color: #e05c97; border: 1px solid rgba(224,92,151,.25); }

        /* ══ CAPACITY BAR ══ */
        .cap-wrap { min-width: 80px; }
        .cap-text  { font-size: 12px; color: var(--text-secondary); margin-bottom: 4px; }
        .cap-bar   { height: 4px; border-radius: 2px; background: rgba(255,255,255,.08); overflow: hidden; }
        .cap-fill  { height: 100%; border-radius: 2px; background: linear-gradient(90deg,#4f8ef7,#38c9b0); transition: width .4s; }

        /* ══ REQUEST BUTTON ══ */
        .btn-request {
            padding: 5px 12px; border-radius: 7px; font-size: 11px; font-weight: 700;
            background: rgba(56,201,176,.12); color: #38c9b0;
            border: 1px solid rgba(56,201,176,.3); cursor: pointer;
            transition: opacity .2s; display: inline-flex; align-items: center; gap: 4px;
            font-family: inherit;
        }
        .btn-request:hover { opacity: .75; }

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
        .search-box:focus-within { border-color: #4f8ef7; }
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
        .filter-select:focus { border-color: #4f8ef7; }

        /* ══ EMPTY STATE ══ */
        .empty-row td {
            text-align: center; padding: 48px; color: var(--text-muted); font-size: 13px;
        }
        .empty-row td i { font-size: 36px; display: block; margin-bottom: 14px; opacity: .3; }

        /* ══ RESULTS META ══ */
        .results-meta { font-size: 12px; color: var(--text-muted); margin-bottom: 12px; }

        /* ══ MODAL BASE ══ */
        .modal-overlay {
            display: none; position: fixed; inset: 0;
            background: rgba(0,0,0,.72); z-index: 1000;
            align-items: center; justify-content: center; padding: 20px;
        }
        .modal-overlay.open { display: flex; }
        .modal-box {
            background: var(--bg-card); border: 1px solid var(--border);
            border-radius: var(--radius); width: 100%; max-width: 600px;
            position: relative; animation: mUp .2s ease;
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
        .modal-body  { padding: 22px 24px; overflow-y: auto; flex: 1; }
        .modal-footer {
            padding: 16px 24px; border-top: 1px solid var(--border);
            display: flex; gap: 10px; justify-content: flex-end; flex-shrink: 0;
            align-items: center; flex-wrap: wrap;
        }

        /* ══ DETAIL MODAL ══ */
        .detail-event-img {
            width: 100%; height: 200px; object-fit: cover;
            border-radius: 10px; margin-bottom: 18px;
        }
        .detail-event-img-placeholder {
            width: 100%; height: 140px; border-radius: 10px;
            background: rgba(79,142,247,.08);
            display: flex; align-items: center; justify-content: center;
            color: rgba(79,142,247,.35); font-size: 48px; margin-bottom: 18px;
        }
        .detail-title { font-size: 20px; font-weight: 700; margin-bottom: 6px; }
        .detail-desc  { color: var(--text-secondary); font-size: 13px; line-height: 1.7; margin-bottom: 20px; }
        .detail-grid  { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin-bottom: 18px; }
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

        /* ══ MODAL SUBMIT BUTTONS ══ */
        .btn-submit {
            padding: 10px 22px; border-radius: 10px; font-size: 13px;
            font-weight: 700; border: none; cursor: pointer;
            transition: opacity .2s; font-family: inherit;
        }
        .btn-cancel  { background: rgba(255,255,255,.06); color: var(--text-secondary); border: 1px solid var(--border); }
        .btn-primary { background: linear-gradient(135deg,#38c9b0,#4f8ef7); color: #fff; }
        .btn-submit:hover { opacity: .85; }

        /* ══ STATUS NOTICE IN MODAL FOOTER ══ */
        .modal-status-notice {
            flex: 1; font-size: 13px; font-weight: 600; padding: 8px 14px;
            border-radius: 10px; display: inline-flex; align-items: center; gap: 8px;
        }
        .notice-pending  { background: rgba(245,166,35,.1);  color: #f5a623; border: 1px solid rgba(245,166,35,.25); }
        .notice-accepted { background: rgba(56,201,176,.1);  color: #38c9b0; border: 1px solid rgba(56,201,176,.25); }
        .notice-declined { background: rgba(224,92,151,.1);  color: #e05c97; border: 1px solid rgba(224,92,151,.25); }
    </style>
</head>
<body>

<!-- ══ SIDEBAR ══ -->
<aside class="sidebar">
    <div class="sidebar-logo">
        <div class="logo-icon">&#9825;</div>
        <span>VolunteerHub</span>
    </div>
    <div class="sidebar-section-label">Main Menu</div>
    <a href="${pageContext.request.contextPath}/volunteer/dashboard" class="nav-item">
        <i class="fas fa-th-large"></i> Dashboard
    </a>
    <div class="sidebar-section-label">Events</div>
    <a href="${pageContext.request.contextPath}/volunteer/browse-events" class="nav-item active">
        <i class="fas fa-calendar-alt"></i> Browse Events
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

    <!-- Topbar -->
    <div class="topbar">
        <div class="topbar-left">
            <h2>Browse Events</h2>
            <p>Explore all events and request to volunteer</p>
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

        <!-- Toolbar -->
        <form method="GET" action="${pageContext.request.contextPath}/volunteer/browse-events" id="searchForm">
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

            </div>
        </form>

        <!-- Results count -->
        <div class="results-meta">
            Showing <strong style="color:var(--text-primary)"><%= events.size() %></strong> event<%= events.size() != 1 ? "s" : "" %>
            <% if (!search.isEmpty()) { %> matching "<strong style="color:#4f8ef7"><%= h(search) %></strong>"<% } %>
        </div>

        <!-- Events Table -->
        <div class="events-table-wrap">
            <table class="events-table">
                <thead>
                    <tr>
                        <th style="width:40px;">#</th>
                        <th>Event</th>
                        <th>Status</th>
                        <th>Starts</th>
                        <th>Ends</th>
                        <th>Volunteers</th>
                        <th>My Status</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        if (events.isEmpty()) {
                    %>
                    <tr class="empty-row">
                        <td colspan="7">
                            <i class="fas fa-calendar-times"></i>
                            No events found.<% if (!search.isEmpty()) { %> Try a different search term.<% } %>
                        </td>
                    </tr>
                    <%
                        } else {
                            int rowNum = 0;
                            for (Event ev : events) {
                                rowNum++;
                                String evStatus    = ev.getStatus()   != null ? ev.getStatus()   : "closed";
                                String loc         = ev.getLocation() != null ? ev.getLocation() : "";
                                String img         = ev.getImage()    != null ? ev.getImage()    : "";
                                String myStatus    = ev.getMyStatus(); // null | pending | accepted | declined
                                String statusClass = "opened".equals(evStatus) ? "badge-opened" : "badge-closed";

                                int cap = 0;
                                try {
                                    if (ev.getMaxLimit() != null && !ev.getMaxLimit().isEmpty())
                                        cap = Integer.parseInt(ev.getMaxLimit().trim());
                                } catch (NumberFormatException ignored) {}
                                int fillPct = (cap > 0) ? Math.min((ev.getVolunteerCount() * 100 / cap), 100) : 0;
                    %>
                    <tr onclick="openDetailModal('<%= h(ev.getId()) %>')" data-id="<%= h(ev.getId()) %>">

                        <td class="muted"><%= rowNum %></td>

                        <!-- Event -->
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

                        <!-- Event Status -->
                        <td>
                            <span class="badge <%= statusClass %>">
                                <span class="badge-dot"></span>
                                <%= "opened".equals(evStatus) ? "Open" : "Closed" %>
                            </span>
                        </td>

                        <!-- Dates -->
                        <td class="muted"><%= ev.getStartsAtDisplay() %></td>
                        <td class="muted"><%= ev.getEndsAtDisplay() %></td>

                        <!-- Capacity -->
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

                        <!-- My Status (stop row click propagation on interactive elements) -->
                        <td onclick="event.stopPropagation()">
                            <% if ("pending".equals(myStatus)) { %>
                                <span class="badge badge-pending">
                                    <span class="badge-dot"></span> Pending
                                </span>
                            <% } else if ("accepted".equals(myStatus)) { %>
                                <span class="badge badge-accepted">
                                    <span class="badge-dot"></span> Accepted
                                </span>
                            <% } else if ("declined".equals(myStatus)) { %>
                                <span class="badge badge-declined">
                                    <span class="badge-dot"></span> Declined
                                </span>
                            <% } else if ("opened".equals(evStatus)) { %>
                                <form method="POST" action="${pageContext.request.contextPath}/volunteer/browse-events"
                                      style="display:inline; margin:0;">
                                    <input type="hidden" name="action"  value="request">
                                    <input type="hidden" name="eventId" value="<%= h(ev.getId()) %>">
                                    <button type="submit" class="btn-request">
                                        <i class="fas fa-hand-paper"></i> Request
                                    </button>
                                </form>
                            <% } else { %>
                                <span style="color:var(--text-muted); font-size:12px;">—</span>
                            <% } %>
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
     DETAIL MODAL
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
                <span id="detailStatusBadge"></span>
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
                    <label><i class="fas fa-info-circle"></i> Event Status</label>
                    <span id="detailEventStatus"></span>
                </div>
                <div class="detail-item full" id="detailLocWrap" style="display:none;">
                    <label><i class="fas fa-map-marker-alt"></i> Location</label>
                    <span id="detailLoc"></span>
                    <br>
                    <a id="detailMapBtn" href="#" target="_blank" class="map-btn">
                        <i class="fas fa-map"></i> View on Google Maps
                    </a>
                </div>
            </div>
        </div>
        <div class="modal-footer" id="detailFooter">
            <%-- populated by JS --%>
        </div>
    </div>
</div>

<!-- Hidden request form (used by detail modal) -->
<form method="POST" action="${pageContext.request.contextPath}/volunteer/browse-events"
      id="modalRequestForm" style="display:none;">
    <input type="hidden" name="action"  value="request">
    <input type="hidden" name="eventId" id="modalRequestEventId">
</form>

<!-- ════════════════════════════════════════════════
     JAVASCRIPT
════════════════════════════════════════════════ -->
<script>
// ── Embed all event data ─────────────────────────────
const EVENTS = [
<% for (int i = 0; i < events.size(); i++) {
    Event ev   = events.get(i);
    String loc  = ev.getLocation()    != null ? ev.getLocation()    : "";
    String img  = ev.getImage()       != null ? ev.getImage()       : "";
    String desc = ev.getDescription() != null ? ev.getDescription() : "";
    String mySt = ev.getMyStatus()    != null ? ev.getMyStatus()    : "";
%>
  {
    id:         '<%= esc(ev.getId()) %>',
    title:      '<%= esc(ev.getTitle()) %>',
    description:'<%= esc(desc) %>',
    startsAt:   '<%= esc(ev.getStartsAtDisplay()) %>',
    endsAt:     '<%= esc(ev.getEndsAtDisplay()) %>',
    maxLimit:   '<%= esc(ev.getMaxLimit() != null ? ev.getMaxLimit() : "") %>',
    status:     '<%= esc(ev.getStatus()) %>',
    location:   '<%= esc(loc) %>',
    image:      '<%= esc(img) %>',
    volCount:   <%= ev.getVolunteerCount() %>,
    capDisplay: '<%= esc(ev.getCapacityDisplay()) %>',
    myStatus:   '<%= esc(mySt) %>'
  }<%= i < events.size()-1 ? "," : "" %>
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
    const ev = EVENTS.find(x => x.id === id);
    if (!ev) return;

    // Image
    const imgWrap = document.getElementById('detailImgWrap');
    if (ev.image) {
        imgWrap.innerHTML = '<img src="' + CTX + '/' + ev.image + '" class="detail-event-img" alt="">';
    } else {
        imgWrap.innerHTML = '<div class="detail-event-img-placeholder"><i class="fas fa-calendar-alt"></i></div>';
    }

    document.getElementById('detailTitle').textContent       = ev.title;
    document.getElementById('detailDesc').textContent        = ev.description || 'No description provided.';
    document.getElementById('detailStarts').textContent      = ev.startsAt;
    document.getElementById('detailEnds').textContent        = ev.endsAt;
    document.getElementById('detailCap').textContent         = ev.capDisplay;
    document.getElementById('detailEventStatus').textContent = ev.status === 'opened' ? 'Open' : 'Closed';

    const statusBadge = document.getElementById('detailStatusBadge');
    statusBadge.className = 'badge ' + (ev.status === 'opened' ? 'badge-opened' : 'badge-closed');
    statusBadge.innerHTML = '<span class="badge-dot"></span>' + (ev.status === 'opened' ? 'Open' : 'Closed');

    // Location
    const locWrap = document.getElementById('detailLocWrap');
    if (ev.location) {
        locWrap.style.display = '';
        document.getElementById('detailLoc').textContent = ev.location;
        document.getElementById('detailMapBtn').href =
            'https://maps.google.com/maps?q=' + encodeURIComponent(ev.location);
    } else {
        locWrap.style.display = 'none';
    }

    // Footer — depends on myStatus + event status
    const footer = document.getElementById('detailFooter');
    const closeBtn = '<button type="button" class="btn-submit btn-cancel" onclick="closeModal(\'detailModal\')">Close</button>';

    if (ev.myStatus === 'pending') {
        footer.innerHTML = '<span class="modal-status-notice notice-pending"><i class="fas fa-clock"></i> Your request is pending admin review.</span>' + closeBtn;
    } else if (ev.myStatus === 'accepted') {
        footer.innerHTML = '<span class="modal-status-notice notice-accepted"><i class="fas fa-check-circle"></i> You are accepted as a volunteer for this event!</span>' + closeBtn;
    } else if (ev.myStatus === 'declined') {
        footer.innerHTML = '<span class="modal-status-notice notice-declined"><i class="fas fa-times-circle"></i> Your request for this event was declined.</span>' + closeBtn;
    } else if (ev.status === 'opened') {
        document.getElementById('modalRequestEventId').value = ev.id;
        footer.innerHTML = closeBtn + '<button type="button" class="btn-submit btn-primary" onclick="submitModalRequest()"><i class="fas fa-hand-paper"></i> Request to Volunteer</button>';
    } else {
        footer.innerHTML = '<span style="flex:1;font-size:12px;color:var(--text-muted);">This event is closed and not accepting volunteers.</span>' + closeBtn;
    }

    openModal('detailModal');
}

function submitModalRequest() {
    document.getElementById('modalRequestForm').submit();
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
</script>

</body>
</html>
