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
    List<VolunteerAssignmentEntry> pending  = (List<VolunteerAssignmentEntry>) request.getAttribute("pending");
    @SuppressWarnings("unchecked")
    List<VolunteerAssignmentEntry> upcoming = (List<VolunteerAssignmentEntry>) request.getAttribute("upcoming");
    @SuppressWarnings("unchecked")
    List<VolunteerAssignmentEntry> past     = (List<VolunteerAssignmentEntry>) request.getAttribute("past");
    if (pending  == null) pending  = new java.util.ArrayList<>();
    if (upcoming == null) upcoming = new java.util.ArrayList<>();
    if (past     == null) past     = new java.util.ArrayList<>();

    int totalPoints   = request.getAttribute("totalPoints")   != null ? (Integer) request.getAttribute("totalPoints")   : 0;
    int totalAttended = request.getAttribute("totalAttended") != null ? (Integer) request.getAttribute("totalAttended") : 0;
    int totalAccepted = request.getAttribute("totalAccepted") != null ? (Integer) request.getAttribute("totalAccepted") : 0;

    // ── Badge tiers (attendance-count based) ──────────────────────────────────
    int[]    tierAt     = {0, 1,           3,        5,         10,          25,          50};
    String[] tierName   = {"Newcomer", "First Step", "Helper",  "Regular",   "Dedicated", "Champion",  "Legend"};
    String[] tierIcon   = {"seedling",  "star",      "medal",   "award",     "trophy",    "crown",     "gem"};
    String[] tierColor  = {"#888",     "#38c9b0",   "#4f8ef7", "#7c5cbf",   "#f5a623",   "#e05c97",   "#a78bfa"};

    int currentTier = 0;
    for (int i = tierAt.length - 1; i >= 0; i--) {
        if (totalAttended >= tierAt[i]) { currentTier = i; break; }
    }
    int nextTier      = Math.min(currentTier + 1, tierAt.length - 1);
    int nextThreshold = tierAt[nextTier];
    int eventsToNext  = Math.max(0, nextThreshold - totalAttended);
    boolean isMaxTier = currentTier == tierAt.length - 1;
    int progressPct   = isMaxTier ? 100 :
        (totalAttended - tierAt[currentTier]) * 100 /
        Math.max(1, tierAt[nextTier] - tierAt[currentTier]);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Events – VolunteerHub</title>
    <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/volunteer.css">
    <style>
        /* ── STATUS BADGES ──────────────────────────────── */
        .chip { display:inline-flex; align-items:center; gap:5px; padding:3px 10px; border-radius:20px; font-size:11px; font-weight:700; white-space:nowrap; }
        .chip-dot { width:6px; height:6px; border-radius:50%; background:currentColor; flex-shrink:0; }
        .chip-open     { background:rgba(56,201,176,.12);  color:#38c9b0; border:1px solid rgba(56,201,176,.3);  }
        .chip-closed   { background:rgba(100,100,120,.12); color:var(--text-secondary); border:1px solid var(--border); }
        .chip-attended { background:rgba(56,201,176,.12);  color:#38c9b0; border:1px solid rgba(56,201,176,.3);  }
        .chip-absent   { background:rgba(224,92,151,.1);   color:#e05c97; border:1px solid rgba(224,92,151,.25); }
        .chip-upcoming { background:rgba(79,142,247,.1);   color:#4f8ef7; border:1px solid rgba(79,142,247,.25); }
        .chip-pending  { background:rgba(245,166,35,.1);   color:#f5a623; border:1px solid rgba(245,166,35,.25); }
        .pts-chip      { background:rgba(245,166,35,.12);  color:#f5a623; border:1px solid rgba(245,166,35,.25); }
        .pts-chip-nil  { background:rgba(255,255,255,.04); color:var(--text-muted); border:1px solid var(--border); }

        /* ── BADGE PANEL ────────────────────────────────── */
        .badge-panel {
            background: linear-gradient(135deg, rgba(124,92,191,.12), rgba(79,142,247,.08));
            border: 1px solid rgba(124,92,191,.22);
            border-radius: var(--radius);
            padding: 22px 24px;
            margin-bottom: 24px;
            display: flex;
            gap: 28px;
            flex-wrap: wrap;
            align-items: flex-start;
        }
        .badge-current {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            min-width: 90px;
        }
        .badge-icon-ring {
            width: 64px; height: 64px;
            border-radius: 50%;
            border: 3px solid;
            display: flex; align-items: center; justify-content: center;
            font-size: 26px;
            margin-bottom: 8px;
        }
        .badge-tier-name { font-size: 12px; font-weight: 700; }
        .badge-tier-sub  { font-size: 10px; color: var(--text-muted); margin-top: 2px; }

        .badge-progress-wrap { flex: 1; min-width: 220px; }
        .badge-progress-title { font-size: 15px; font-weight: 700; color: var(--text-primary); margin-bottom: 4px; }
        .badge-progress-sub   { font-size: 12px; color: var(--text-secondary); margin-bottom: 14px; }
        .progress-bar-bg   { background: rgba(255,255,255,.07); border-radius: 6px; height: 8px; overflow: hidden; }
        .progress-bar-fill { height: 100%; border-radius: 6px; transition: width .6s ease; }
        .progress-bar-label { font-size: 11px; color: var(--text-muted); margin-top: 5px; }

        /* ── ALL BADGE TIERS ROW ────────────────────────── */
        .tier-row {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
            margin-top: 18px;
        }
        .tier-item {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 4px;
            min-width: 52px;
        }
        .tier-bubble {
            width: 36px; height: 36px;
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 14px;
            border: 2px solid;
            transition: transform .2s;
        }
        .tier-bubble.locked { opacity: .22; filter: grayscale(1); }
        .tier-bubble.active { transform: scale(1.15); box-shadow: 0 0 12px rgba(0,0,0,.3); }
        .tier-bubble-label { font-size: 9px; font-weight: 600; text-align: center; white-space: nowrap; }
        .tier-bubble-label.locked { color: var(--text-muted); }

        /* ── TABS ────────────────────────────────────────── */
        .tab-bar {
            display: flex;
            gap: 4px;
            margin-bottom: 18px;
            border-bottom: 1px solid var(--border);
            padding-bottom: 0;
        }
        .tab-btn {
            padding: 9px 16px;
            font-size: 13px;
            font-weight: 600;
            color: var(--text-secondary);
            background: none;
            border: none;
            cursor: pointer;
            border-bottom: 2px solid transparent;
            margin-bottom: -1px;
            display: flex;
            align-items: center;
            gap: 6px;
            transition: color .15s;
        }
        .tab-btn:hover { color: var(--text-primary); }
        .tab-btn.active { color: #7c5cbf; border-bottom-color: #7c5cbf; }
        .tab-count {
            display: inline-flex; align-items: center;
            padding: 1px 7px; border-radius: 10px;
            font-size: 10px; font-weight: 700;
        }
        .tc-pending  { background:rgba(245,166,35,.12);  color:#f5a623; }
        .tc-upcoming { background:rgba(79,142,247,.12);  color:#4f8ef7; }
        .tc-past     { background:rgba(56,201,176,.12);  color:#38c9b0; }
        .tc-all      { background:rgba(124,92,191,.12);  color:#7c5cbf; }

        .tab-panel { display: none; }
        .tab-panel.active { display: block; }

        /* ── SECTION HEADER ──────────────────────────────── */
        .section-hdr { display:flex; align-items:center; gap:10px; margin-bottom: 14px; }
        .section-hdr h3 { font-size:14px; font-weight:700; color:var(--text-primary); margin:0; }

        /* ── EVENT CARDS (upcoming / pending) ───────────── */
        .cards-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(270px, 1fr));
            gap: 14px;
        }
        .ev-card {
            background: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 16px 18px;
            transition: border-color .2s, background .2s;
        }
        .ev-card:hover { border-color: rgba(124,92,191,.35); }
        .ev-card-top { display:flex; align-items:flex-start; justify-content:space-between; gap:10px; margin-bottom:10px; }
        .ev-card-icon { width:38px; height:38px; border-radius:9px; flex-shrink:0; display:flex; align-items:center; justify-content:center; font-size:15px; }
        .ev-icon-blue   { background:rgba(79,142,247,.1);  color:#4f8ef7; }
        .ev-icon-amber  { background:rgba(245,166,35,.1);  color:#f5a623; }
        .ev-card-title  { font-size:14px; font-weight:700; color:var(--text-primary); margin-bottom:3px; line-height:1.3; }
        .ev-card-meta   { font-size:11px; color:var(--text-muted); line-height:1.8; }
        .ev-card-meta i { font-size:10px; margin-right:3px; }

        /* ── HISTORY TABLE ───────────────────────────────── */
        .tbl-wrap { overflow-x:auto; border-radius:var(--radius); border:1px solid var(--border); background:var(--bg-card); }
        .hist-tbl { width:100%; border-collapse:collapse; font-size:13px; }
        .hist-tbl thead th {
            background:rgba(56,201,176,.06); color:var(--text-secondary);
            font-size:11px; text-transform:uppercase; letter-spacing:.8px;
            padding:12px 16px; text-align:left; white-space:nowrap;
        }
        .hist-tbl tbody tr { border-top:1px solid var(--border); transition:background .15s; }
        .hist-tbl tbody tr:hover { background:rgba(56,201,176,.04); }
        .hist-tbl td { padding:12px 16px; color:var(--text-primary); vertical-align:middle; }
        .hist-tbl td.dim { color:var(--text-secondary); font-size:12px; }
        .completion-time { font-size:11px; color:var(--text-muted); margin-top:2px; }

        /* ── EMPTY STATE ─────────────────────────────────── */
        .empty { text-align:center; padding:36px 20px; color:var(--text-muted); font-size:13px; background:var(--bg-card); border-radius:var(--radius); border:1px solid var(--border); }
        .empty i { font-size:28px; display:block; margin-bottom:10px; opacity:.3; }
        .empty a { display:inline-block; margin-top:12px; padding:8px 18px; border-radius:9px; background:rgba(79,142,247,.15); color:#4f8ef7; font-size:12px; font-weight:600; text-decoration:none; border:1px solid rgba(79,142,247,.25); }
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
    <a href="${pageContext.request.contextPath}/volunteer/my-events" class="nav-item active"><i class="fas fa-heart"></i> My Events</a>
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
            <h2>My Events</h2>
            <p>Your pending requests, upcoming commitments, and completed history</p>
        </div>
        <div class="topbar-right">
            <div class="topbar-icon-btn"><i class="fas fa-bell"></i></div>
            <a href="${pageContext.request.contextPath}/volunteer/profile" style="text-decoration:none;">
                <div class="vol-avatar"><%= initials %></div>
            </a>
        </div>
    </div>

    <div class="page-body">

        <%-- Flash --%>
        <% if (request.getParameter("success") != null) { %>
        <div id="flashMsg" style="background:rgba(56,201,176,.12); border:1px solid rgba(56,201,176,.25); color:#38c9b0; padding:12px 16px; border-radius:10px; font-size:13px; margin-bottom:20px; display:flex; align-items:center; gap:8px;">
            <i class="fas fa-check-circle"></i> <%= h(request.getParameter("success")) %>
        </div>
        <% } %>

        <!-- ── STAT CARDS ─────────────────────────────────────────────────── -->
        <div class="stats-grid">
            <div class="stat-card amber">
                <div class="stat-icon"><i class="fas fa-hourglass-half"></i></div>
                <div class="stat-value"><%= pending.size() %></div>
                <div class="stat-label">Pending Requests</div>
                <div class="stat-sub">Awaiting admin approval</div>
            </div>
            <div class="stat-card blue">
                <div class="stat-icon"><i class="fas fa-clock"></i></div>
                <div class="stat-value"><%= upcoming.size() %></div>
                <div class="stat-label">Upcoming Events</div>
                <div class="stat-sub">You are confirmed for</div>
            </div>
            <div class="stat-card teal">
                <div class="stat-icon"><i class="fas fa-calendar-check"></i></div>
                <div class="stat-value"><%= totalAttended %></div>
                <div class="stat-label">Events Completed</div>
                <div class="stat-sub">Confirmed attendance</div>
            </div>
        </div>

        <!-- ── BADGE PANEL ────────────────────────────────────────────────── -->
        <div class="badge-panel">
            <!-- Current badge icon -->
            <div class="badge-current">
                <div class="badge-icon-ring" style="border-color:<%= tierColor[currentTier] %>; background: rgba(0,0,0,.2); color:<%= tierColor[currentTier] %>;">
                    <i class="fas fa-<%= tierIcon[currentTier] %>"></i>
                </div>
                <div class="badge-tier-name" style="color:<%= tierColor[currentTier] %>"><%= tierName[currentTier] %></div>
                <div class="badge-tier-sub"><%= totalAttended %> event<%= totalAttended != 1 ? "s" : "" %></div>
            </div>

            <!-- Progress to next -->
            <div class="badge-progress-wrap">
                <div class="badge-progress-title">
                    <% if (isMaxTier) { %>
                    <i class="fas fa-gem" style="color:#a78bfa;"></i> You have reached the highest rank!
                    <% } else { %>
                    <i class="fas fa-<%= tierIcon[currentTier] %>" style="color:<%= tierColor[currentTier] %>;"></i>
                    <%= tierName[currentTier] %> → <span style="color:<%= tierColor[nextTier] %>"><%= tierName[nextTier] %></span>
                    <% } %>
                </div>
                <div class="badge-progress-sub">
                    <% if (!isMaxTier) { %>
                    Attend <strong style="color:<%= tierColor[nextTier] %>"><%= eventsToNext %> more event<%= eventsToNext != 1 ? "s" : "" %></strong> to unlock <strong><%= tierName[nextTier] %></strong>
                    <% } else { %>
                    Thank you for your incredible dedication to volunteering!
                    <% } %>
                </div>
                <div class="progress-bar-bg">
                    <div class="progress-bar-fill"
                         style="width:<%= progressPct %>%; background: linear-gradient(90deg, <%= tierColor[currentTier] %>, <%= tierColor[nextTier] %>);"></div>
                </div>
                <div class="progress-bar-label">
                    <%= totalAttended - tierAt[currentTier] %> / <%= isMaxTier ? totalAttended : tierAt[nextTier] - tierAt[currentTier] %> events
                </div>

                <!-- All tiers row -->
                <div class="tier-row">
                <% for (int t = 0; t < tierAt.length; t++) {
                       boolean earned = totalAttended >= tierAt[t];
                       boolean active = (t == currentTier);
                %>
                    <div class="tier-item">
                        <div class="tier-bubble <%= earned ? (active ? "active" : "") : "locked" %>"
                             style="border-color:<%= tierColor[t] %>; background: rgba(0,0,0,.2); color:<%= tierColor[t] %>;"
                             title="<%= tierName[t] %> — <%= tierAt[t] %> events">
                            <i class="fas fa-<%= tierIcon[t] %>" style="font-size:13px;"></i>
                        </div>
                        <div class="tier-bubble-label <%= earned ? "" : "locked" %>" style="<%= earned ? "color:"+tierColor[t] : "" %>">
                            <%= tierName[t] %>
                        </div>
                    </div>
                <% } %>
                </div>

                <!-- Points summary -->
                <div style="margin-top:12px; font-size:12px; color:var(--text-muted);">
                    <i class="fas fa-star" style="color:#f5a623; font-size:11px;"></i>
                    <strong style="color:#f5a623;"><%= totalPoints %></strong> reward points earned
                </div>
            </div>
        </div>

        <!-- ── TABS ───────────────────────────────────────────────────────── -->
        <div class="tab-bar">
            <button class="tab-btn active" onclick="switchTab('all', this)">
                <i class="fas fa-list" style="font-size:11px;"></i> All
                <span class="tab-count tc-all"><%= pending.size() + upcoming.size() + past.size() %></span>
            </button>
            <button class="tab-btn" onclick="switchTab('pending', this)">
                <i class="fas fa-hourglass-half" style="font-size:11px;"></i> Pending
                <span class="tab-count tc-pending"><%= pending.size() %></span>
            </button>
            <button class="tab-btn" onclick="switchTab('upcoming', this)">
                <i class="fas fa-clock" style="font-size:11px;"></i> Upcoming
                <span class="tab-count tc-upcoming"><%= upcoming.size() %></span>
            </button>
            <button class="tab-btn" onclick="switchTab('completed', this)">
                <i class="fas fa-check-circle" style="font-size:11px;"></i> Completed
                <span class="tab-count tc-past"><%= past.size() %></span>
            </button>
        </div>

        <!-- ══ TAB: ALL ══ -->
        <div id="tab-all" class="tab-panel active">

            <!-- Pending section (inside All tab) -->
            <% if (!pending.isEmpty()) { %>
            <div class="section-hdr" style="margin-bottom:12px;">
                <h3><i class="fas fa-hourglass-half" style="color:#f5a623; font-size:13px;"></i> Pending Requests</h3>
                <span class="chip chip-pending"><%= pending.size() %></span>
            </div>
            <div class="cards-grid" style="margin-bottom:28px;">
            <% for (VolunteerAssignmentEntry e : pending) { %>
                <div class="ev-card">
                    <div class="ev-card-top">
                        <div style="display:flex; align-items:flex-start; gap:10px; flex:1;">
                            <div class="ev-card-icon ev-icon-amber"><i class="fas fa-hourglass-half"></i></div>
                            <div>
                                <div class="ev-card-title"><%= h(e.getTitle()) %></div>
                                <span class="chip <%= "opened".equals(e.getEventStatus()) ? "chip-open" : "chip-closed" %>" style="font-size:10px;">
                                    <span class="chip-dot"></span><%= "opened".equals(e.getEventStatus()) ? "Open" : "Closed" %>
                                </span>
                            </div>
                        </div>
                        <span class="chip chip-pending"><i class="fas fa-hourglass-half" style="font-size:9px;"></i> Awaiting</span>
                    </div>
                    <div class="ev-card-meta">
                        <% if (!e.getLocation().isEmpty()) { %>
                        <div><i class="fas fa-map-marker-alt"></i> <%= h(e.getLocation()) %></div>
                        <% } %>
                        <div><i class="fas fa-play-circle"></i> Starts: <%= h(e.getStartsAt()) %></div>
                        <div><i class="fas fa-stop-circle"></i> Ends: &nbsp;&nbsp;<%= h(e.getEndsAt()) %></div>
                        <div style="margin-top:4px; color:var(--text-muted); font-size:10px;">Requested on <%= h(e.getJoinedAt()) %></div>
                    </div>
                </div>
            <% } %>
            </div>
            <% } %>

            <!-- Upcoming section (inside All tab) -->
            <% if (!upcoming.isEmpty()) { %>
            <div class="section-hdr" style="margin-bottom:12px;">
                <h3><i class="fas fa-clock" style="color:#4f8ef7; font-size:13px;"></i> Upcoming</h3>
                <span class="chip chip-upcoming"><%= upcoming.size() %></span>
            </div>
            <div class="cards-grid" style="margin-bottom:28px;">
            <% for (VolunteerAssignmentEntry e : upcoming) { %>
                <div class="ev-card">
                    <div class="ev-card-top">
                        <div style="display:flex; align-items:flex-start; gap:10px; flex:1;">
                            <div class="ev-card-icon ev-icon-blue"><i class="fas fa-calendar-alt"></i></div>
                            <div>
                                <div class="ev-card-title"><%= h(e.getTitle()) %></div>
                                <span class="chip <%= "opened".equals(e.getEventStatus()) ? "chip-open" : "chip-closed" %>" style="font-size:10px;">
                                    <span class="chip-dot"></span><%= "opened".equals(e.getEventStatus()) ? "Open" : "Closed" %>
                                </span>
                            </div>
                        </div>
                        <span class="chip chip-upcoming"><i class="fas fa-check" style="font-size:9px;"></i> Confirmed</span>
                    </div>
                    <div class="ev-card-meta">
                        <% if (!e.getLocation().isEmpty()) { %>
                        <div><i class="fas fa-map-marker-alt"></i> <%= h(e.getLocation()) %></div>
                        <% } %>
                        <div><i class="fas fa-play-circle"></i> Starts: <%= h(e.getStartsAt()) %></div>
                        <div><i class="fas fa-stop-circle"></i> Ends: &nbsp;&nbsp;<%= h(e.getEndsAt()) %></div>
                        <div style="margin-top:4px; color:var(--text-muted); font-size:10px;">Accepted on <%= h(e.getJoinedAt()) %></div>
                    </div>
                </div>
            <% } %>
            </div>
            <% } %>

            <!-- Completed section (inside All tab) -->
            <div class="section-hdr" style="margin-bottom:12px;">
                <h3><i class="fas fa-history" style="color:#38c9b0; font-size:13px;"></i> Completed</h3>
                <span class="chip chip-attended"><%= past.size() %></span>
            </div>
            <% if (past.isEmpty()) { %>
            <div class="empty">
                <i class="fas fa-history"></i>
                <p>No completed events yet. Keep going!</p>
                <a href="${pageContext.request.contextPath}/volunteer/browse-events">
                    <i class="fas fa-search"></i> Browse Events
                </a>
            </div>
            <% } else { %>
            <div class="tbl-wrap">
                <table class="hist-tbl">
                    <thead>
                        <tr>
                            <th>#</th><th>Event</th><th>Location</th>
                            <th>Event Period</th><th>Attendance</th><th>Completed At</th><th>Points</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% int row = 0; for (VolunteerAssignmentEntry pe : past) { row++; %>
                        <tr>
                            <td class="dim"><%= row %></td>
                            <td><div style="font-weight:600;"><%= h(pe.getTitle()) %></div></td>
                            <td class="dim"><%= pe.getLocation().isEmpty() ? "<span style='opacity:.4'>—</span>" : h(pe.getLocation()) %></td>
                            <td class="dim">
                                <div><i class="fas fa-play-circle" style="font-size:10px;color:#4f8ef7;"></i> <%= h(pe.getStartsAt()) %></div>
                                <div><i class="fas fa-stop-circle" style="font-size:10px;color:#e05c97;"></i> <%= h(pe.getEndsAt()) %></div>
                            </td>
                            <td>
                                <% if (!pe.isHasAssignment()) { %><span style="font-size:12px;color:var(--text-muted);">Pending review</span>
                                <% } else if (pe.isAttended()) { %><span class="chip chip-attended"><i class="fas fa-check" style="font-size:9px;"></i> Attended</span>
                                <% } else { %><span class="chip chip-absent"><i class="fas fa-times" style="font-size:9px;"></i> Absent</span><% } %>
                            </td>
                            <td class="dim">
                                <% if (!pe.getMarkedAt().isEmpty()) { %><i class="fas fa-calendar-check" style="font-size:10px;color:#38c9b0;"></i> <%= h(pe.getMarkedAt()) %>
                                <% } else { %><span style="opacity:.4">Not marked yet</span><% } %>
                            </td>
                            <td>
                                <% if (pe.isAttended() && pe.getPointsEarned() > 0) { %><span class="chip pts-chip"><i class="fas fa-star" style="font-size:9px;"></i> +<%= pe.getPointsEarned() %></span>
                                <% } else { %><span class="chip pts-chip-nil">—</span><% } %>
                            </td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
            <% } %>

            <% if (pending.isEmpty() && upcoming.isEmpty() && past.isEmpty()) { %>
            <div class="empty" style="margin-top:12px;">
                <i class="fas fa-calendar-times"></i>
                <p>You haven't joined any events yet.</p>
                <a href="${pageContext.request.contextPath}/volunteer/browse-events">
                    <i class="fas fa-search"></i> Browse Events
                </a>
            </div>
            <% } %>
        </div>

        <!-- ══ TAB: PENDING ══ -->
        <div id="tab-pending" class="tab-panel">
            <% if (pending.isEmpty()) { %>
            <div class="empty">
                <i class="fas fa-hourglass-half"></i>
                <p>No pending requests. Browse open events to apply!</p>
                <a href="${pageContext.request.contextPath}/volunteer/browse-events">
                    <i class="fas fa-search"></i> Browse Events
                </a>
            </div>
            <% } else { %>
            <div class="cards-grid">
            <% for (VolunteerAssignmentEntry e : pending) { %>
                <div class="ev-card">
                    <div class="ev-card-top">
                        <div style="display:flex; align-items:flex-start; gap:10px; flex:1;">
                            <div class="ev-card-icon ev-icon-amber"><i class="fas fa-hourglass-half"></i></div>
                            <div>
                                <div class="ev-card-title"><%= h(e.getTitle()) %></div>
                                <span class="chip <%= "opened".equals(e.getEventStatus()) ? "chip-open" : "chip-closed" %>" style="font-size:10px;">
                                    <span class="chip-dot"></span><%= "opened".equals(e.getEventStatus()) ? "Open" : "Closed" %>
                                </span>
                            </div>
                        </div>
                        <span class="chip chip-pending"><i class="fas fa-hourglass-half" style="font-size:9px;"></i> Awaiting</span>
                    </div>
                    <div class="ev-card-meta">
                        <% if (!e.getLocation().isEmpty()) { %>
                        <div><i class="fas fa-map-marker-alt"></i> <%= h(e.getLocation()) %></div>
                        <% } %>
                        <div><i class="fas fa-play-circle"></i> Starts: <%= h(e.getStartsAt()) %></div>
                        <div><i class="fas fa-stop-circle"></i> Ends: &nbsp;&nbsp;<%= h(e.getEndsAt()) %></div>
                        <div style="margin-top:4px; color:var(--text-muted); font-size:10px;">Requested on <%= h(e.getJoinedAt()) %></div>
                    </div>
                </div>
            <% } %>
            </div>
            <% } %>
        </div>

        <!-- ══ TAB: UPCOMING ══ -->
        <div id="tab-upcoming" class="tab-panel">
            <% if (upcoming.isEmpty()) { %>
            <div class="empty">
                <i class="fas fa-calendar-times"></i>
                <p>No upcoming events. Browse open events to apply!</p>
                <a href="${pageContext.request.contextPath}/volunteer/browse-events">
                    <i class="fas fa-search"></i> Browse Events
                </a>
            </div>
            <% } else { %>
            <div class="cards-grid">
            <% for (VolunteerAssignmentEntry e : upcoming) { %>
                <div class="ev-card">
                    <div class="ev-card-top">
                        <div style="display:flex; align-items:flex-start; gap:10px; flex:1;">
                            <div class="ev-card-icon ev-icon-blue"><i class="fas fa-calendar-alt"></i></div>
                            <div>
                                <div class="ev-card-title"><%= h(e.getTitle()) %></div>
                                <span class="chip <%= "opened".equals(e.getEventStatus()) ? "chip-open" : "chip-closed" %>" style="font-size:10px;">
                                    <span class="chip-dot"></span><%= "opened".equals(e.getEventStatus()) ? "Open" : "Closed" %>
                                </span>
                            </div>
                        </div>
                        <span class="chip chip-upcoming"><i class="fas fa-check" style="font-size:9px;"></i> Confirmed</span>
                    </div>
                    <div class="ev-card-meta">
                        <% if (!e.getLocation().isEmpty()) { %>
                        <div><i class="fas fa-map-marker-alt"></i> <%= h(e.getLocation()) %></div>
                        <% } %>
                        <div><i class="fas fa-play-circle"></i> Starts: <%= h(e.getStartsAt()) %></div>
                        <div><i class="fas fa-stop-circle"></i> Ends: &nbsp;&nbsp;<%= h(e.getEndsAt()) %></div>
                        <div style="margin-top:4px; color:var(--text-muted); font-size:10px;">Accepted on <%= h(e.getJoinedAt()) %></div>
                    </div>
                </div>
            <% } %>
            </div>
            <% } %>
        </div>

        <!-- ══ TAB: COMPLETED ══ -->
        <div id="tab-completed" class="tab-panel">
            <% if (past.isEmpty()) { %>
            <div class="empty">
                <i class="fas fa-history"></i>
                <p>No completed events yet. Keep going!</p>
            </div>
            <% } else { %>
            <div class="tbl-wrap">
                <table class="hist-tbl">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Event</th>
                            <th>Location</th>
                            <th>Event Period</th>
                            <th>Attendance</th>
                            <th>Completed At</th>
                            <th>Points</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% int n = 0; for (VolunteerAssignmentEntry e : past) { n++; %>
                        <tr>
                            <td class="dim"><%= n %></td>
                            <td>
                                <div style="font-weight:600;"><%= h(e.getTitle()) %></div>
                                <span class="chip <%= "opened".equals(e.getEventStatus()) ? "chip-open" : "chip-closed" %>" style="font-size:10px; margin-top:3px;">
                                    <span class="chip-dot"></span><%= "opened".equals(e.getEventStatus()) ? "Open" : "Closed" %>
                                </span>
                            </td>
                            <td class="dim">
                                <%= e.getLocation().isEmpty() ? "<span style='opacity:.4'>—</span>" : h(e.getLocation()) %>
                            </td>
                            <td class="dim">
                                <div><i class="fas fa-play-circle" style="font-size:10px; color:#4f8ef7;"></i> <%= h(e.getStartsAt()) %></div>
                                <div><i class="fas fa-stop-circle" style="font-size:10px; color:#e05c97;"></i> <%= h(e.getEndsAt()) %></div>
                            </td>
                            <td>
                                <% if (!e.isHasAssignment()) { %>
                                    <span style="font-size:12px; color:var(--text-muted);">Pending review</span>
                                <% } else if (e.isAttended()) { %>
                                    <span class="chip chip-attended"><i class="fas fa-check" style="font-size:9px;"></i> Attended</span>
                                <% } else { %>
                                    <span class="chip chip-absent"><i class="fas fa-times" style="font-size:9px;"></i> Absent</span>
                                <% } %>
                            </td>
                            <td class="dim">
                                <% if (!e.getMarkedAt().isEmpty()) { %>
                                    <div><i class="fas fa-calendar-check" style="font-size:10px; color:#38c9b0;"></i> <%= h(e.getMarkedAt()) %></div>
                                <% } else { %>
                                    <span style="opacity:.4">Not marked yet</span>
                                <% } %>
                            </td>
                            <td>
                                <% if (e.isAttended() && e.getPointsEarned() > 0) { %>
                                    <span class="chip pts-chip"><i class="fas fa-star" style="font-size:9px;"></i> +<%= e.getPointsEarned() %></span>
                                <% } else { %>
                                    <span class="chip pts-chip-nil">—</span>
                                <% } %>
                            </td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
            <% } %>
        </div>

    </div><!-- page-body -->
</div><!-- main -->

<script>
function switchTab(name, btn) {
    document.querySelectorAll('.tab-panel').forEach(p => p.classList.remove('active'));
    document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
    document.getElementById('tab-' + name).classList.add('active');
    btn.classList.add('active');
}

(function() {
    const flash = document.getElementById('flashMsg');
    if (flash) setTimeout(function() {
        flash.style.transition = 'opacity .5s';
        flash.style.opacity = '0';
        setTimeout(function() { flash.remove(); }, 500);
    }, 4000);

    // Auto-open the tab that has something relevant
    const url = new URL(window.location.href);
    const tab = url.searchParams.get('tab');
    if (tab) {
        const btn = document.querySelector('.tab-btn[onclick*="' + tab + '"]');
        if (btn) btn.click();
    }
})();
</script>

</body>
</html>
