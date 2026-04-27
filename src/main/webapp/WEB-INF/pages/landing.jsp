<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.VMS.model.Event, java.util.List" %>
<%!
    private static String h(String s) {
        if (s == null) return "";
        return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
                .replace("\"","&quot;").replace("'","&#39;");
    }
    private static String trunc(String s, int max) {
        if (s == null) return "";
        s = s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;");
        return s.length() <= max ? s : s.substring(0, max) + "…";
    }
    private static int pct(int count, String max) {
        if (max == null || max.trim().isEmpty()) return Math.min(count * 2, 80);
        try { int m = Integer.parseInt(max.trim()); return m > 0 ? Math.min(100, count * 100 / m) : 0; }
        catch (NumberFormatException e) { return 0; }
    }
%>
<%
    @SuppressWarnings("unchecked")
    List<Event> featuredEvents = (List<Event>) request.getAttribute("featuredEvents");
    if (featuredEvents == null) featuredEvents = new java.util.ArrayList<>();
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>VolunteerHub — Make a Difference Today</title>
    <link href="https://fonts.googleapis.com/css2?family=Sora:wght@400;600;700;800&family=DM+Sans:wght@400;500;600&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<%= ctx %>/css/landing.css">
</head>
<body class="lp-body">

<!-- ═══════════════════ NAVBAR ═══════════════════ -->
<nav class="lp-nav">
    <a href="<%= ctx %>/home" class="lp-nav__brand">
        <div class="lp-nav__icon">
            <i class="fa-solid fa-hands-helping" style="color:#fff;"></i>
        </div>
        <span class="lp-nav__name">Volunteer<span>Hub</span></span>
    </a>

    <div class="lp-nav__actions">
        <a href="<%= ctx %>/login"    class="lp-btn lp-btn--ghost">Log In</a>
        <a href="<%= ctx %>/register" class="lp-btn lp-btn--primary">
            <i class="fa-solid fa-user-plus"></i> Sign Up
        </a>
    </div>
</nav>

<!-- ═══════════════════ HERO ═══════════════════ -->
<section class="lp-hero">
    <div class="lp-hero__badge">
        <i class="fa-solid fa-star"></i> Join Our Volunteer Community
    </div>

    <h1 class="lp-hero__headline">
        Make a <span class="highlight">Difference</span><br>
        One Event at a Time
    </h1>

    <p class="lp-hero__sub">
        Connect with meaningful volunteer opportunities, build your impact,
        and be part of a community that cares. Every hour counts.
    </p>

    <div class="lp-hero__ctas">
        <a href="<%= ctx %>/register" class="lp-btn--primary-lg">
            <i class="fa-solid fa-rocket"></i> Get Started Free
        </a>
        <a href="#events" class="lp-btn--outline-lg">
            <i class="fa-solid fa-calendar-days"></i> Browse Events
        </a>
    </div>

    <div class="lp-hero__stats">
        <div class="lp-stat-pill">
            <span class="lp-stat-pill__value">2.5K+</span>
            <span class="lp-stat-pill__label">Active Volunteers</span>
        </div>
        <div class="lp-stat-divider"></div>
        <div class="lp-stat-pill">
            <span class="lp-stat-pill__value">500+</span>
            <span class="lp-stat-pill__label">Events Hosted</span>
        </div>
        <div class="lp-stat-divider"></div>
        <div class="lp-stat-pill">
            <span class="lp-stat-pill__value">50K+</span>
            <span class="lp-stat-pill__label">Lives Impacted</span>
        </div>
        <div class="lp-stat-divider"></div>
        <div class="lp-stat-pill">
            <span class="lp-stat-pill__value">100+</span>
            <span class="lp-stat-pill__label">Organizations</span>
        </div>
    </div>

    <div class="lp-scroll-hint">
        <span>Scroll to explore</span>
        <i class="fa-solid fa-chevron-down"></i>
    </div>
</section>

<!-- ═══════════════════ EVENTS SECTION ═══════════════════ -->
<section class="lp-events" id="events">
    <div class="lp-section-header">
        <span class="lp-section-eyebrow">
            <i class="fa-solid fa-fire-flame-curved"></i>&nbsp; Open Opportunities
        </span>
        <h2 class="lp-section-title">Featured Volunteer Events</h2>
        <p class="lp-section-sub">
            Discover events where your time and skills create real impact in the community.
        </p>
    </div>

    <div class="lp-events-grid">
        <%
            if (featuredEvents.isEmpty()) {
        %>
        <div class="lp-events-empty">
            <i class="fa-regular fa-calendar-xmark"></i>
            <p style="font-size:1.05rem; font-weight:600; color:#4a4068; margin-bottom:0.35rem;">
                No events open right now
            </p>
            <p style="font-size:0.88rem;">
                Check back soon — new opportunities are added regularly!
            </p>
        </div>
        <%
            } else {
                for (Event ev : featuredEvents) {
                    String imageUrl  = (ev.getImage() != null && !ev.getImage().isEmpty())
                                       ? ctx + "/" + ev.getImage() : null;
                    String maxLbl    = (ev.getMaxLimit() != null && !ev.getMaxLimit().trim().isEmpty())
                                       ? ev.getMaxLimit() : "Unlimited";
                    int    fillPct   = pct(ev.getVolunteerCount(), ev.getMaxLimit());
                    String location  = (ev.getLocation() != null && !ev.getLocation().trim().isEmpty())
                                       ? ev.getLocation() : "To be announced";
        %>
        <div class="lp-card">
            <!-- image -->
            <div class="lp-card__img-wrap">
                <% if (imageUrl != null) { %>
                    <img class="lp-card__img"
                         src="<%= h(imageUrl) %>"
                         alt="<%= h(ev.getTitle()) %>"
                         onerror="this.style.display='none';this.nextElementSibling.style.display='flex';">
                    <div class="lp-card__img-placeholder" style="display:none;">🤝</div>
                <% } else { %>
                    <div class="lp-card__img-placeholder">🤝</div>
                <% } %>
                <span class="lp-card__badge lp-card__badge--open">
                    <i class="fa-solid fa-circle" style="font-size:0.5rem;"></i> Open
                </span>
            </div>

            <!-- body -->
            <div class="lp-card__body">
                <div class="lp-card__title"><%= h(ev.getTitle()) %></div>
                <div class="lp-card__desc"><%= trunc(ev.getDescription(), 140) %></div>

                <div class="lp-card__meta">
                    <div class="lp-card__meta-row">
                        <i class="fa-regular fa-calendar"></i>
                        <span><%= ev.getStartsAtDisplay() %></span>
                    </div>
                    <div class="lp-card__meta-row">
                        <i class="fa-solid fa-location-dot"></i>
                        <span><%= h(location) %></span>
                    </div>
                </div>

                <div class="lp-card__vol-bar">
                    <div class="lp-card__vol-label">
                        <span>
                            <i class="fa-solid fa-users" style="color:#7c3aed;font-size:0.7rem;"></i>
                            Volunteers
                        </span>
                        <span><%= ev.getVolunteerCount() %> / <%= h(maxLbl) %></span>
                    </div>
                    <div class="lp-card__vol-track">
                        <div class="lp-card__vol-fill" style="width:<%= fillPct %>%;"></div>
                    </div>
                </div>
            </div>

            <!-- join button -->
            <div class="lp-card__footer">
                <button class="lp-card__join-btn" onclick="openLoginPrompt('<%= h(ev.getTitle()) %>')">
                    <i class="fa-solid fa-hand-holding-heart"></i>
                    Join &amp; Volunteer
                </button>
            </div>
        </div>
        <%
                }
            }
        %>
    </div>
</section>

<!-- ═══════════════════ CTA BANNER ═══════════════════ -->
<section class="lp-cta">
    <h2 class="lp-cta__title">Ready to make a real difference?</h2>
    <p class="lp-cta__sub">
        Create your free account in under a minute and start applying to events.
    </p>
    <div class="lp-cta__actions">
        <a href="<%= ctx %>/register" class="lp-btn--primary-lg">
            <i class="fa-solid fa-user-plus"></i> Join as a Volunteer
        </a>
        <a href="<%= ctx %>/login" class="lp-btn--outline-lg">
            <i class="fa-solid fa-arrow-right-to-bracket"></i> I have an account
        </a>
    </div>
</section>

<!-- ═══════════════════ FOOTER ═══════════════════ -->
<footer class="lp-footer">
    <div class="lp-footer__inner">
        <a href="<%= ctx %>/home" class="lp-footer__brand">
            <i class="fa-solid fa-hands-helping" style="color:#7c3aed;"></i>
            VolunteerHub
        </a>
        <p class="lp-footer__copy">
            &copy; 2025 VolunteerHub. Built with purpose.
        </p>
        <div class="lp-footer__links">
            <a href="<%= ctx %>/login">Log In</a>
            <a href="<%= ctx %>/register">Sign Up</a>
        </div>
    </div>
</footer>

<!-- ═══════════════════ LOGIN PROMPT MODAL ═══════════════════ -->
<div class="lp-modal-overlay" id="loginModal" onclick="handleOverlayClick(event)">
    <div class="lp-modal">
        <button class="lp-modal__close" onclick="closeLoginPrompt()" title="Close">
            <i class="fa-solid fa-xmark"></i>
        </button>

        <div class="lp-modal__icon">🤝</div>

        <h3 class="lp-modal__title">Want to join?</h3>
        <p class="lp-modal__sub" id="modalEventName">
            Create a free account or log in to sign up as a volunteer for this event.
        </p>

        <div class="lp-modal__actions">
            <a href="<%= ctx %>/register" class="lp-btn lp-btn--primary">
                <i class="fa-solid fa-user-plus"></i> Sign Up Free
            </a>
            <a href="<%= ctx %>/login" class="lp-btn lp-btn--ghost">
                <i class="fa-solid fa-arrow-right-to-bracket"></i> Log In
            </a>
        </div>
    </div>
</div>

<script>
    function openLoginPrompt(eventTitle) {
        var sub = document.getElementById('modalEventName');
        if (eventTitle) {
            sub.textContent = 'Create a free account or log in to volunteer for "' + eventTitle + '".';
        }
        document.getElementById('loginModal').classList.add('active');
    }

    function closeLoginPrompt() {
        document.getElementById('loginModal').classList.remove('active');
    }

    function handleOverlayClick(e) {
        if (e.target === document.getElementById('loginModal')) {
            closeLoginPrompt();
        }
    }

    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') closeLoginPrompt();
    });
</script>

</body>
</html>
