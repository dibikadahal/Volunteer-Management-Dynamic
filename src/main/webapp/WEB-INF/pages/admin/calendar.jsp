<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.VMS.model.Event, java.util.List" %>
<%!
    private static String esc(String s) {
        if (s == null) return "";
        return s.replace("\\","\\\\").replace("\"","\\\"")
                .replace("\r","").replace("\n","\\n")
                .replace("<","\\x3C").replace(">","\\x3E");
    }
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

    // Build FullCalendar events JSON
    StringBuilder evJson = new StringBuilder("[");
    for (int i = 0; i < events.size(); i++) {
        Event ev = events.get(i);
        String derived = ev.getDerivedStatus();
        String color = "ongoing".equals(derived) ? "#38c9b0"
                     : "upcoming".equals(derived) ? "#4f8ef7"
                     : "#555577";
        if (i > 0) evJson.append(",");
        evJson.append("{")
            .append("\"id\":\"").append(esc(ev.getId())).append("\",")
            .append("\"title\":\"").append(esc(ev.getTitle())).append("\",")
            .append("\"start\":\"").append(esc(ev.getStartsAtISO())).append("\",")
            .append("\"end\":\"").append(esc(ev.getEndsAtISO())).append("\",")
            .append("\"backgroundColor\":\"").append(color).append("\",")
            .append("\"borderColor\":\"transparent\",")
            .append("\"textColor\":\"#ffffff\"")
            .append("}");
    }
    evJson.append("]");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Calendar – VolunteerHub Admin</title>
    <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
    <script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.15/index.global.min.js"></script>
    <style>
        /* ── FullCalendar dark theme overrides ── */
        :root {
            --fc-border-color: var(--border);
            --fc-page-bg-color: transparent;
            --fc-neutral-bg-color: var(--bg-card);
            --fc-today-bg-color: rgba(124,92,191,.12);
            --fc-event-bg-color: #4f8ef7;
            --fc-event-border-color: transparent;
            --fc-event-text-color: #fff;
            --fc-button-bg-color: rgba(255,255,255,.06);
            --fc-button-border-color: var(--border);
            --fc-button-text-color: var(--text-primary);
            --fc-button-hover-bg-color: rgba(124,92,191,.2);
            --fc-button-hover-border-color: rgba(124,92,191,.4);
            --fc-button-active-bg-color: #7c5cbf;
            --fc-button-active-border-color: #7c5cbf;
            --fc-list-event-hover-bg-color: rgba(255,255,255,.04);
            --fc-highlight-color: rgba(124,92,191,.1);
            --fc-non-business-color: rgba(0,0,0,.06);
        }
        .fc-col-header-cell-cushion,
        .fc-daygrid-day-number,
        .fc-list-event-title a,
        .fc-list-day-text,
        .fc-list-day-side-text,
        .fc-timegrid-slot-label-cushion {
            color: var(--text-primary) !important;
            text-decoration: none !important;
        }
        .fc-toolbar-title { color: var(--text-primary) !important; font-size:15px !important; font-weight:700 !important; }
        .fc-button         { font-family:inherit !important; font-size:12px !important; font-weight:600 !important; border-radius:8px !important; }
        .fc-button:focus   { box-shadow:none !important; }
        .fc-daygrid-event  { border-radius:5px !important; font-size:11px !important; font-weight:600 !important; }
        .fc-list-event-dot { border-color: currentColor !important; }
        .fc-daygrid-more-link { color:#7c5cbf !important; font-size:11px !important; font-weight:700 !important; }
        .fc-col-header-cell { background: rgba(124,92,191,.06) !important; }
        .fc-scrollgrid      { border-color: var(--border) !important; }
        .fc-list-table td, .fc-list-table th { border-color: var(--border) !important; }

        /* ── Layout ── */
        .cal-wrap  { display:flex; gap:20px; align-items:flex-start; }
        .cal-main  { flex:1; background:var(--bg-card); border:1px solid var(--border); border-radius:var(--radius); padding:20px; }
        .cal-side  { width:240px; flex-shrink:0; display:flex; flex-direction:column; gap:14px; }

        /* ── Legend ── */
        .legend-panel { background:var(--bg-card); border:1px solid var(--border); border-radius:var(--radius); padding:16px; }
        .legend-title { font-size:12px; font-weight:700; color:var(--text-primary); margin-bottom:10px; text-transform:uppercase; letter-spacing:.6px; }
        .legend-item  { display:flex; align-items:center; gap:8px; font-size:12px; color:var(--text-secondary); margin-bottom:6px; }
        .legend-dot   { width:10px; height:10px; border-radius:3px; flex-shrink:0; }

        /* ── Upcoming events list panel ── */
        .upcoming-panel { background:var(--bg-card); border:1px solid var(--border); border-radius:var(--radius); padding:16px; }
        .upcoming-title { font-size:12px; font-weight:700; color:var(--text-primary); margin-bottom:12px; text-transform:uppercase; letter-spacing:.6px; }
        .upcoming-item  { padding:10px 0; border-bottom:1px solid var(--border); }
        .upcoming-item:last-child { border-bottom:none; padding-bottom:0; }
        .upcoming-name  { font-size:12px; font-weight:600; color:var(--text-primary); margin-bottom:3px;
                          white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
        .upcoming-date  { font-size:11px; color:var(--text-muted); }
        .upcoming-badge { display:inline-flex; align-items:center; gap:4px; font-size:10px; font-weight:700;
                          padding:2px 7px; border-radius:8px; margin-top:4px; }
        .ub-upcoming { background:rgba(79,142,247,.1);  color:#4f8ef7; border:1px solid rgba(79,142,247,.2); }
        .ub-ongoing  { background:rgba(56,201,176,.1);  color:#38c9b0; border:1px solid rgba(56,201,176,.2); }
        .ub-finished { background:rgba(100,100,120,.1); color:var(--text-muted); border:1px solid var(--border); }

        /* ── Modal ── */
        .modal-overlay { display:none; position:fixed; inset:0; background:rgba(0,0,0,.7); z-index:1000; align-items:center; justify-content:center; padding:20px; }
        .modal-overlay.open { display:flex; }
        .modal-box { background:var(--bg-card); border:1px solid var(--border); border-radius:var(--radius);
                     width:100%; max-width:580px; max-height:90vh; overflow:hidden;
                     display:flex; flex-direction:column; animation:mUp .2s ease; }
        @keyframes mUp { from{opacity:0;transform:translateY(16px)} to{opacity:1;transform:translateY(0)} }
        .modal-header { padding:20px 24px 16px; border-bottom:1px solid var(--border); display:flex; align-items:center; justify-content:space-between; }
        .modal-title  { font-size:15px; font-weight:700; color:var(--text-primary); }
        .modal-close  { background:none; border:none; color:var(--text-secondary); font-size:16px; cursor:pointer; }
        .modal-body   { padding:22px 24px; overflow-y:auto; flex:1; }
        .modal-footer { padding:14px 24px; border-top:1px solid var(--border); display:flex; gap:10px; justify-content:flex-end; }
        .f-group { margin-bottom:16px; }
        .f-group label { display:block; font-size:10px; text-transform:uppercase; letter-spacing:.8px; color:var(--text-muted); margin-bottom:6px; }
        .f-group input, .f-group textarea, .f-group select {
            width:100%; background:rgba(255,255,255,.04); border:1px solid var(--border); border-radius:9px;
            color:var(--text-primary); padding:9px 12px; font-size:13px; font-family:inherit;
            outline:none; transition:border-color .2s; box-sizing:border-box;
        }
        .f-group input:focus, .f-group textarea:focus { border-color:#7c5cbf; }
        .f-group textarea { resize:vertical; min-height:70px; }
        .form-row { display:grid; grid-template-columns:1fr 1fr; gap:14px; }
        .btn-primary { background:linear-gradient(135deg,#7c5cbf,#4f8ef7); color:#fff; border:none; padding:10px 22px; border-radius:10px; font-size:13px; font-weight:700; cursor:pointer; font-family:inherit; }
        .btn-cancel  { background:rgba(255,255,255,.06); color:var(--text-secondary); border:1px solid var(--border); padding:10px 22px; border-radius:10px; font-size:13px; font-weight:700; cursor:pointer; font-family:inherit; }
        .btn-danger  { background:rgba(224,92,151,.15); color:#e05c97; border:1px solid rgba(224,92,151,.3); padding:10px 22px; border-radius:10px; font-size:13px; font-weight:700; cursor:pointer; font-family:inherit; }
        .detail-row  { display:flex; gap:12px; margin-bottom:12px; font-size:13px; }
        .detail-row i { color:var(--text-muted); width:16px; flex-shrink:0; margin-top:2px; }
        .detail-row span { color:var(--text-secondary); line-height:1.5; }
    </style>
</head>
<body>

<!-- ══ SIDEBAR ══ -->
<aside class="sidebar">
    <div class="sidebar-logo"><div class="logo-icon">&#9825;</div><span>VolunteerHub</span></div>
    <div class="sidebar-section-label">Main Menu</div>
    <a href="${pageContext.request.contextPath}/admin/dashboard" class="nav-item"><i class="fas fa-th-large"></i> Dashboard</a>
    <div class="sidebar-section-label">Management</div>
    <a href="${pageContext.request.contextPath}/admin/volunteers" class="nav-item"><i class="fas fa-users"></i> Volunteer Management</a>
    <a href="${pageContext.request.contextPath}/admin/events" class="nav-item"><i class="fas fa-calendar-alt"></i> Event Management</a>
    <a href="${pageContext.request.contextPath}/admin/calendar" class="nav-item active"><i class="fas fa-calendar-week"></i> Calendar</a>
    <a href="${pageContext.request.contextPath}/admin/assignments" class="nav-item"><i class="fas fa-link"></i> Assignments</a>
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
            <h2>Event Calendar</h2>
            <p>Visual overview of all events — click any event to edit</p>
        </div>
        <div class="topbar-right">
            <a href="${pageContext.request.contextPath}/admin/events" class="nav-item"
               style="background:rgba(124,92,191,.12); border:1px solid rgba(124,92,191,.25);
                      color:#7c5cbf; padding:8px 16px; border-radius:9px; text-decoration:none;
                      font-size:13px; font-weight:600;">
                <i class="fas fa-plus"></i> Add Event
            </a>
            <a href="${pageContext.request.contextPath}/admin/profile" style="text-decoration:none;">
                <div class="admin-avatar"><%= initials %></div>
            </a>
        </div>
    </div>

    <div class="page-body">

        <% if (request.getParameter("success") != null) { %>
        <div id="flashMsg" style="background:rgba(56,201,176,.12); border:1px solid rgba(56,201,176,.25);
                    color:#38c9b0; padding:12px 16px; border-radius:10px; font-size:13px;
                    margin-bottom:20px; display:flex; align-items:center; gap:8px;">
            <i class="fas fa-check-circle"></i> <%= h(request.getParameter("success")) %>
        </div>
        <% } %>
        <% if (request.getParameter("error") != null) { %>
        <div id="flashMsg" style="background:rgba(224,92,151,.12); border:1px solid rgba(224,92,151,.25);
                    color:#e05c97; padding:12px 16px; border-radius:10px; font-size:13px;
                    margin-bottom:20px; display:flex; align-items:center; gap:8px;">
            <i class="fas fa-exclamation-circle"></i> <%= h(request.getParameter("error")) %>
        </div>
        <% } %>

        <div class="cal-wrap">

            <!-- Calendar -->
            <div class="cal-main">
                <div id="calendar"></div>
            </div>

            <!-- Sidebar panels -->
            <div class="cal-side">

                <!-- Legend -->
                <div class="legend-panel">
                    <div class="legend-title"><i class="fas fa-circle-info" style="margin-right:5px;"></i>Legend</div>
                    <div class="legend-item"><div class="legend-dot" style="background:#4f8ef7;"></div> Upcoming</div>
                    <div class="legend-item"><div class="legend-dot" style="background:#38c9b0;"></div> Ongoing</div>
                    <div class="legend-item"><div class="legend-dot" style="background:#555577;"></div> Finished</div>
                </div>

                <!-- Upcoming events list -->
                <div class="upcoming-panel">
                    <div class="upcoming-title"><i class="fas fa-clock" style="margin-right:5px;color:#4f8ef7;"></i>All Events</div>
                    <% if (events.isEmpty()) { %>
                    <div style="font-size:12px; color:var(--text-muted); text-align:center; padding:16px 0;">No events yet.</div>
                    <% } else {
                        int shown = 0;
                        for (Event ev : events) {
                            if (shown++ >= 8) break;
                            String d = ev.getDerivedStatus();
                            String ub = "upcoming".equals(d) ? "ub-upcoming" : "ongoing".equals(d) ? "ub-ongoing" : "ub-finished";
                            String dl = d.substring(0,1).toUpperCase() + d.substring(1);
                    %>
                    <div class="upcoming-item" style="cursor:pointer;" onclick="openEditById('<%= h(ev.getId()) %>')">
                        <div class="upcoming-name"><%= h(ev.getTitle()) %></div>
                        <div class="upcoming-date"><i class="fas fa-calendar" style="font-size:9px;"></i> <%= ev.getStartsAtDisplay() %></div>
                        <span class="upcoming-badge <%= ub %>"><%= dl %></span>
                    </div>
                    <% } %>
                    <% if (events.size() > 8) { %>
                    <div style="font-size:11px; color:var(--text-muted); text-align:center; margin-top:8px;">
                        +<%= events.size()-8 %> more — see calendar
                    </div>
                    <% } %>
                    <% } %>
                </div>

            </div>
        </div>
    </div>
</div>

<!-- ══ EDIT EVENT MODAL ══ -->
<div class="modal-overlay" id="editModal" onclick="if(event.target===this)closeEditModal()">
    <div class="modal-box">
        <div class="modal-header">
            <span class="modal-title"><i class="fas fa-pen" style="color:#f5a623;margin-right:8px;"></i>Edit Event</span>
            <button class="modal-close" onclick="closeEditModal()"><i class="fas fa-times"></i></button>
        </div>
        <form method="POST" action="${pageContext.request.contextPath}/admin/events?action=update"
              enctype="multipart/form-data" id="editForm">
            <input type="hidden" name="id"         id="eId">
            <input type="hidden" name="redirectTo" value="calendar">
            <div class="modal-body">
                <div class="f-group">
                    <label>Event Title *</label>
                    <input type="text" name="title" id="eTitle" required>
                </div>
                <div class="f-group">
                    <label>Description</label>
                    <textarea name="description" id="eDesc"></textarea>
                </div>
                <div class="form-row">
                    <div class="f-group">
                        <label>Start Date &amp; Time *</label>
                        <input type="datetime-local" name="startsAt" id="eStartsAt" required>
                    </div>
                    <div class="f-group">
                        <label>End Date &amp; Time *</label>
                        <input type="datetime-local" name="endsAt" id="eEndsAt" required>
                    </div>
                </div>
                <div class="form-row">
                    <div class="f-group">
                        <label>Max Volunteers (blank = unlimited)</label>
                        <input type="number" name="maxLimit" id="eMaxLimit" min="1">
                    </div>
                    <div class="f-group">
                        <label>Status</label>
                        <div style="padding:9px 12px; border-radius:9px; border:1px solid var(--border);
                                    background:rgba(255,255,255,.03); font-size:13px; color:var(--text-muted);">
                            <i class="fas fa-magic" style="font-size:11px; color:#7c5cbf;"></i>
                            Auto — derived from dates
                        </div>
                    </div>
                </div>
                <div class="f-group">
                    <label>Location</label>
                    <input type="text" name="location" id="eLocation">
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-cancel" onclick="closeEditModal()">Cancel</button>
                <button type="submit" class="btn-primary"><i class="fas fa-save"></i> Save Changes</button>
            </div>
        </form>
    </div>
</div>

<!-- Embed event data for JS -->
<script>
var CTX = '<%= request.getContextPath() %>';
var EVENTS_DATA = {};
<%
    for (Event ev : events) {
        String loc = ev.getLocation() != null ? ev.getLocation() : "";
        String desc = ev.getDescription() != null ? ev.getDescription() : "";
        String ml = ev.getMaxLimit() != null ? ev.getMaxLimit() : "";
%>
EVENTS_DATA['<%= esc(ev.getId()) %>'] = {
    id:        '<%= esc(ev.getId()) %>',
    title:     '<%= esc(ev.getTitle()) %>',
    desc:      '<%= esc(desc) %>',
    startsAt:  '<%= esc(ev.getStartsAtInput()) %>',
    endsAt:    '<%= esc(ev.getEndsAtInput()) %>',
    startDisp: '<%= esc(ev.getStartsAtDisplay()) %>',
    endDisp:   '<%= esc(ev.getEndsAtDisplay()) %>',
    location:  '<%= esc(loc) %>',
    maxLimit:  '<%= esc(ml) %>',
    status:    '<%= esc(ev.getDerivedStatus()) %>'
};
<% } %>

// ── FullCalendar ──
document.addEventListener('DOMContentLoaded', function() {
    var calEl = document.getElementById('calendar');
    var cal   = new FullCalendar.Calendar(calEl, {
        initialView:  'dayGridMonth',
        headerToolbar: {
            left:   'prev,next today',
            center: 'title',
            right:  'dayGridMonth,timeGridWeek,listMonth'
        },
        buttonText: { today:'Today', month:'Month', week:'Week', list:'List' },
        events: <%= evJson %>,
        eventClick: function(info) {
            openEditById(info.event.id);
        },
        eventMouseEnter: function(info) {
            info.el.style.cursor = 'pointer';
        },
        height: 'auto',
        dayMaxEvents: 3
    });
    cal.render();
});

// ── Edit modal ──
function openEditById(id) {
    var ev = EVENTS_DATA[id];
    if (!ev) return;
    document.getElementById('eId').value       = ev.id;
    document.getElementById('eTitle').value    = ev.title;
    document.getElementById('eDesc').value     = ev.desc;
    document.getElementById('eStartsAt').value = ev.startsAt;
    document.getElementById('eEndsAt').value   = ev.endsAt;
    document.getElementById('eMaxLimit').value = ev.maxLimit;
    document.getElementById('eLocation').value = ev.location;
    document.getElementById('editModal').classList.add('open');
    document.body.style.overflow = 'hidden';
}
function closeEditModal() {
    document.getElementById('editModal').classList.remove('open');
    document.body.style.overflow = '';
}
document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') closeEditModal();
});

// Flash auto-dismiss
(function() {
    var f = document.getElementById('flashMsg');
    if (f) setTimeout(function() { f.style.opacity='0'; f.style.transition='opacity .5s'; setTimeout(function(){f.remove();},500); }, 4000);
})();
</script>
</body>
</html>
