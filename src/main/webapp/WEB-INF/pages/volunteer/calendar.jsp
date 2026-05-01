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
    String volName = (String) session.getAttribute("userName");
    if (volName == null) volName = "Volunteer";
    String initials = volName.length() > 0
        ? String.valueOf(volName.charAt(0)).toUpperCase() : "V";

    @SuppressWarnings("unchecked")
    List<Event> events = (List<Event>) request.getAttribute("events");
    if (events == null) events = new java.util.ArrayList<>();

    // Build FullCalendar events JSON — color based on volunteer's own status
    StringBuilder evJson = new StringBuilder("[");
    for (int i = 0; i < events.size(); i++) {
        Event ev = events.get(i);
        String my = ev.getMyStatus(); // null | pending | accepted | declined
        String color;
        if      ("accepted".equals(my)) color = "#7c5cbf"; // purple  — I'm in
        else if ("pending".equals(my))  color = "#f5a623"; // amber   — waiting
        else if ("declined".equals(my)) color = "#e05c97"; // pink    — declined
        else {
            // Not applied — color by event lifecycle
            String d = ev.getDerivedStatus();
            color = "ongoing".equals(d) ? "#38c9b0"
                  : "upcoming".equals(d) ? "#4f8ef7"
                  : "#555577";
        }
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
    <title>Calendar – VolunteerHub</title>
    <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/volunteer.css">
    <script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.15/index.global.min.js"></script>
    <style>
        /* ── FullCalendar dark theme ── */
        :root {
            --fc-border-color: var(--border);
            --fc-page-bg-color: transparent;
            --fc-neutral-bg-color: var(--bg-card);
            --fc-today-bg-color: rgba(79,142,247,.1);
            --fc-button-bg-color: rgba(255,255,255,.06);
            --fc-button-border-color: var(--border);
            --fc-button-text-color: var(--text-primary);
            --fc-button-hover-bg-color: rgba(79,142,247,.15);
            --fc-button-hover-border-color: rgba(79,142,247,.35);
            --fc-button-active-bg-color: #4f8ef7;
            --fc-button-active-border-color: #4f8ef7;
            --fc-list-event-hover-bg-color: rgba(255,255,255,.04);
            --fc-highlight-color: rgba(79,142,247,.1);
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
        .fc-toolbar-title { color:var(--text-primary) !important; font-size:15px !important; font-weight:700 !important; }
        .fc-button         { font-family:inherit !important; font-size:12px !important; font-weight:600 !important; border-radius:8px !important; }
        .fc-button:focus   { box-shadow:none !important; }
        .fc-daygrid-event  { border-radius:5px !important; font-size:11px !important; font-weight:600 !important; }
        .fc-col-header-cell { background:rgba(79,142,247,.05) !important; }
        .fc-daygrid-more-link { color:#4f8ef7 !important; font-size:11px !important; font-weight:700 !important; }
        .fc-scrollgrid   { border-color:var(--border) !important; }
        .fc-list-table td, .fc-list-table th { border-color:var(--border) !important; }

        /* ── Layout ── */
        .cal-wrap { display:flex; gap:20px; align-items:flex-start; }
        .cal-main { flex:1; background:var(--bg-card); border:1px solid var(--border); border-radius:var(--radius); padding:20px; }
        .cal-side { width:230px; flex-shrink:0; display:flex; flex-direction:column; gap:14px; }

        /* ── Legend ── */
        .legend-panel { background:var(--bg-card); border:1px solid var(--border); border-radius:var(--radius); padding:16px; }
        .legend-title { font-size:11px; font-weight:700; color:var(--text-primary); margin-bottom:10px; text-transform:uppercase; letter-spacing:.6px; }
        .legend-item  { display:flex; align-items:center; gap:8px; font-size:12px; color:var(--text-secondary); margin-bottom:6px; }
        .legend-dot   { width:10px; height:10px; border-radius:3px; flex-shrink:0; }

        /* ── Event list panel ── */
        .ev-list-panel { background:var(--bg-card); border:1px solid var(--border); border-radius:var(--radius); padding:16px; }
        .ev-list-title { font-size:11px; font-weight:700; color:var(--text-primary); margin-bottom:12px; text-transform:uppercase; letter-spacing:.6px; }
        .ev-list-item  { padding:10px 0; border-bottom:1px solid var(--border); cursor:pointer; }
        .ev-list-item:last-child { border-bottom:none; padding-bottom:0; }
        .ev-list-item:hover .ev-list-name { color:#4f8ef7; }
        .ev-list-name  { font-size:12px; font-weight:600; color:var(--text-primary); margin-bottom:2px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; transition:color .15s; }
        .ev-list-date  { font-size:11px; color:var(--text-muted); }

        /* ── Detail Modal ── */
        .modal-overlay { display:none; position:fixed; inset:0; background:rgba(0,0,0,.7); z-index:1000; align-items:center; justify-content:center; padding:20px; }
        .modal-overlay.open { display:flex; }
        .modal-box { background:var(--bg-card); border:1px solid var(--border); border-radius:var(--radius);
                     width:100%; max-width:500px; max-height:90vh; overflow:hidden;
                     display:flex; flex-direction:column; animation:mUp .2s ease; }
        @keyframes mUp { from{opacity:0;transform:translateY(16px)} to{opacity:1;transform:translateY(0)} }
        .modal-header { padding:20px 24px 16px; border-bottom:1px solid var(--border); display:flex; align-items:center; justify-content:space-between; }
        .modal-title  { font-size:15px; font-weight:700; color:var(--text-primary); }
        .modal-close  { background:none; border:none; color:var(--text-secondary); font-size:16px; cursor:pointer; }
        .modal-body   { padding:22px 24px; overflow-y:auto; flex:1; }
        .modal-footer { padding:14px 24px; border-top:1px solid var(--border); display:flex; gap:10px; justify-content:flex-end; align-items:center; flex-wrap:wrap; }
        .detail-row   { display:flex; gap:12px; margin-bottom:13px; font-size:13px; }
        .detail-row i { color:var(--text-muted); width:16px; flex-shrink:0; margin-top:2px; font-size:12px; }
        .detail-row span { color:var(--text-secondary); line-height:1.5; }
        .detail-event-title { font-size:18px; font-weight:700; color:var(--text-primary); margin-bottom:16px; }
        .status-chip { display:inline-flex; align-items:center; gap:5px; padding:4px 11px; border-radius:20px; font-size:11px; font-weight:700; }
        .sc-upcoming { background:rgba(79,142,247,.1);  color:#4f8ef7; border:1px solid rgba(79,142,247,.25); }
        .sc-ongoing  { background:rgba(56,201,176,.1);  color:#38c9b0; border:1px solid rgba(56,201,176,.25); }
        .sc-finished { background:rgba(100,100,120,.1); color:var(--text-muted); border:1px solid var(--border); }
        .my-chip     { display:inline-flex; align-items:center; gap:5px; padding:4px 11px; border-radius:20px; font-size:11px; font-weight:700; }
        .mc-accepted { background:rgba(124,92,191,.12); color:#7c5cbf; border:1px solid rgba(124,92,191,.3); }
        .mc-pending  { background:rgba(245,166,35,.1);  color:#f5a623; border:1px solid rgba(245,166,35,.25); }
        .mc-declined { background:rgba(224,92,151,.1);  color:#e05c97; border:1px solid rgba(224,92,151,.25); }
        .btn-request { background:linear-gradient(135deg,#38c9b0,#4f8ef7); color:#fff; border:none; padding:9px 20px; border-radius:10px; font-size:13px; font-weight:700; cursor:pointer; font-family:inherit; }
        .btn-cancel-modal { background:rgba(255,255,255,.06); color:var(--text-secondary); border:1px solid var(--border); padding:9px 20px; border-radius:10px; font-size:13px; font-weight:700; cursor:pointer; font-family:inherit; }
    </style>
</head>
<body>

<!-- ══ SIDEBAR ══ -->
<aside class="sidebar">
    <div class="sidebar-logo"><div class="logo-icon">&#9825;</div><span>VolunteerHub</span></div>
    <div class="sidebar-section-label">Main Menu</div>
    <a href="${pageContext.request.contextPath}/volunteer/dashboard" class="nav-item"><i class="fas fa-th-large"></i> Dashboard</a>
    <div class="sidebar-section-label">Events</div>
    <a href="${pageContext.request.contextPath}/volunteer/browse-events" class="nav-item"><i class="fas fa-calendar-alt"></i> Browse Events</a>
    <a href="${pageContext.request.contextPath}/volunteer/calendar" class="nav-item active"><i class="fas fa-calendar-week"></i> Calendar</a>
    <a href="${pageContext.request.contextPath}/volunteer/my-events" class="nav-item"><i class="fas fa-heart"></i> My Events</a>
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
            <h2>Event Calendar</h2>
            <p>View all events — click any event for details</p>
        </div>
        <div class="topbar-right">
            <a href="${pageContext.request.contextPath}/volunteer/profile" style="text-decoration:none;">
                <div class="vol-avatar"><%= initials %></div>
            </a>
        </div>
    </div>

    <div class="page-body">
        <div class="cal-wrap">

            <!-- Calendar -->
            <div class="cal-main">
                <div id="calendar"></div>
            </div>

            <!-- Side panels -->
            <div class="cal-side">

                <!-- Legend -->
                <div class="legend-panel">
                    <div class="legend-title"><i class="fas fa-circle-info" style="margin-right:5px;"></i>My Color Key</div>
                    <div class="legend-item"><div class="legend-dot" style="background:#7c5cbf;"></div> Accepted (I'm in)</div>
                    <div class="legend-item"><div class="legend-dot" style="background:#f5a623;"></div> Pending approval</div>
                    <div class="legend-item"><div class="legend-dot" style="background:#e05c97;"></div> Declined</div>
                    <div class="legend-item"><div class="legend-dot" style="background:#4f8ef7;"></div> Upcoming (open)</div>
                    <div class="legend-item"><div class="legend-dot" style="background:#38c9b0;"></div> Ongoing (open)</div>
                    <div class="legend-item"><div class="legend-dot" style="background:#555577;"></div> Finished</div>
                </div>

                <!-- Events list -->
                <div class="ev-list-panel">
                    <div class="ev-list-title"><i class="fas fa-list" style="margin-right:5px;color:#4f8ef7;"></i>Upcoming</div>
                    <%
                        int shown2 = 0;
                        for (Event ev : events) {
                            if ("finished".equals(ev.getDerivedStatus())) continue;
                            if (shown2++ >= 7) break;
                    %>
                    <div class="ev-list-item" onclick="openDetail('<%= h(ev.getId()) %>')">
                        <div class="ev-list-name"><%= h(ev.getTitle()) %></div>
                        <div class="ev-list-date"><i class="fas fa-calendar" style="font-size:9px;"></i> <%= ev.getStartsAtDisplay() %></div>
                    </div>
                    <%  } %>
                    <% if (shown2 == 0) { %>
                    <div style="font-size:12px; color:var(--text-muted); text-align:center; padding:12px 0;">No upcoming events.</div>
                    <% } %>
                </div>

            </div>
        </div>
    </div>
</div>

<!-- ══ EVENT DETAIL MODAL (view only) ══ -->
<div class="modal-overlay" id="detailModal" onclick="if(event.target===this)closeDetail()">
    <div class="modal-box">
        <div class="modal-header">
            <span class="modal-title"><i class="fas fa-calendar-alt" style="color:#4f8ef7;margin-right:8px;"></i>Event Details</span>
            <button class="modal-close" onclick="closeDetail()"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body">
            <div style="display:flex; align-items:center; justify-content:space-between; gap:10px; margin-bottom:14px; flex-wrap:wrap;">
                <div class="detail-event-title" id="dTitle" style="margin-bottom:0;"></div>
                <div id="dStatusChip"></div>
            </div>
            <div id="dMyStatus" style="margin-bottom:14px;"></div>
            <div class="detail-row"><i class="fas fa-play-circle"></i><span id="dStarts"></span></div>
            <div class="detail-row"><i class="fas fa-stop-circle"></i><span id="dEnds"></span></div>
            <div class="detail-row" id="dLocRow" style="display:none;"><i class="fas fa-map-marker-alt"></i><span id="dLoc"></span></div>
            <div class="detail-row" id="dCapRow"><i class="fas fa-users"></i><span id="dCap"></span></div>
            <div class="detail-row" id="dDescRow" style="display:none;"><i class="fas fa-align-left"></i><span id="dDesc"></span></div>
        </div>
        <div class="modal-footer">
            <button class="btn-cancel-modal" onclick="closeDetail()">Close</button>
            <div id="dRequestBtn"></div>
        </div>
    </div>
</div>

<!-- Request form (submitted programmatically) -->
<form method="POST" action="${pageContext.request.contextPath}/volunteer/browse-events" id="requestForm" style="display:none;">
    <input type="hidden" name="action"  value="request">
    <input type="hidden" name="eventId" id="requestEventId">
</form>

<script>
var CTX = '<%= request.getContextPath() %>';
var EV  = {};
<%
    for (Event ev : events) {
        String loc  = ev.getLocation()    != null ? ev.getLocation()    : "";
        String desc = ev.getDescription() != null ? ev.getDescription() : "";
        String ml   = ev.getMaxLimit()    != null ? ev.getMaxLimit()    : "";
        String my   = ev.getMyStatus()    != null ? ev.getMyStatus()    : "";
%>
EV['<%= esc(ev.getId()) %>'] = {
    id:       '<%= esc(ev.getId()) %>',
    title:    '<%= esc(ev.getTitle()) %>',
    starts:   '<%= esc(ev.getStartsAtDisplay()) %>',
    ends:     '<%= esc(ev.getEndsAtDisplay()) %>',
    loc:      '<%= esc(loc) %>',
    desc:     '<%= esc(desc) %>',
    maxLimit: '<%= esc(ml) %>',
    volCount: <%= ev.getVolunteerCount() %>,
    derived:  '<%= esc(ev.getDerivedStatus()) %>',
    myStatus: '<%= esc(my) %>'
};
<% } %>

// ── FullCalendar ──
document.addEventListener('DOMContentLoaded', function() {
    var calEl = document.getElementById('calendar');
    var cal   = new FullCalendar.Calendar(calEl, {
        initialView: 'dayGridMonth',
        headerToolbar: {
            left:   'prev,next today',
            center: 'title',
            right:  'dayGridMonth,timeGridWeek,listMonth'
        },
        buttonText: { today:'Today', month:'Month', week:'Week', list:'List' },
        events: <%= evJson %>,
        eventClick: function(info) { openDetail(info.event.id); },
        eventMouseEnter: function(info) { info.el.style.cursor = 'pointer'; },
        height: 'auto',
        dayMaxEvents: 3
    });
    cal.render();
});

// ── Detail modal ──
function openDetail(id) {
    var ev = EV[id];
    if (!ev) return;

    document.getElementById('dTitle').textContent  = ev.title;
    document.getElementById('dStarts').textContent = 'Starts: ' + ev.starts;
    document.getElementById('dEnds').textContent   = 'Ends: '   + ev.ends;

    // Status chip
    var sLabel = ev.derived.charAt(0).toUpperCase() + ev.derived.slice(1);
    var sCls   = 'sc-' + ev.derived;
    var icon   = ev.derived === 'ongoing' ? 'fa-circle-dot' : ev.derived === 'upcoming' ? 'fa-clock' : 'fa-check-circle';
    document.getElementById('dStatusChip').innerHTML =
        '<span class="status-chip ' + sCls + '"><i class="fas ' + icon + '" style="font-size:9px;"></i>' + sLabel + '</span>';

    // My status chip
    var myEl = document.getElementById('dMyStatus');
    if (ev.myStatus) {
        var mLabel = ev.myStatus.charAt(0).toUpperCase() + ev.myStatus.slice(1);
        var mCls   = 'mc-' + ev.myStatus;
        var mIcon  = ev.myStatus === 'accepted' ? 'fa-check' : ev.myStatus === 'pending' ? 'fa-hourglass-half' : 'fa-times';
        myEl.innerHTML = '<span class="my-chip ' + mCls + '"><i class="fas ' + mIcon + '" style="font-size:10px;"></i> My status: ' + mLabel + '</span>';
        myEl.style.display = '';
    } else {
        myEl.style.display = 'none';
    }

    // Location
    var locRow = document.getElementById('dLocRow');
    if (ev.loc) { document.getElementById('dLoc').textContent = ev.loc; locRow.style.display = ''; }
    else          locRow.style.display = 'none';

    // Capacity
    var cap = ev.maxLimit ? (ev.volCount + ' / ' + ev.maxLimit + ' volunteers') : (ev.volCount + ' volunteer(s) — Unlimited');
    document.getElementById('dCap').textContent = cap;

    // Description
    var descRow = document.getElementById('dDescRow');
    if (ev.desc) { document.getElementById('dDesc').textContent = ev.desc; descRow.style.display = ''; }
    else           descRow.style.display = 'none';

    // Request button
    var btnEl = document.getElementById('dRequestBtn');
    if (!ev.myStatus && ev.derived !== 'finished') {
        btnEl.innerHTML = '<button class="btn-request" onclick="submitRequest(\'' + id + '\')"><i class="fas fa-hand-paper"></i> Request to Join</button>';
    } else {
        btnEl.innerHTML = '';
    }

    document.getElementById('detailModal').classList.add('open');
    document.body.style.overflow = 'hidden';
}

function submitRequest(eventId) {
    document.getElementById('requestEventId').value = eventId;
    document.getElementById('requestForm').submit();
}

function closeDetail() {
    document.getElementById('detailModal').classList.remove('open');
    document.body.style.overflow = '';
}

document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') closeDetail();
});
</script>
</body>
</html>
