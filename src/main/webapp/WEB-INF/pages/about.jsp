<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String ctx = request.getContextPath();

    int activeVolunteers = request.getAttribute("activeVolunteers") != null ? (Integer) request.getAttribute("activeVolunteers") : 0;
    int totalEvents      = request.getAttribute("totalEvents")      != null ? (Integer) request.getAttribute("totalEvents")      : 0;
    int hoursServed      = request.getAttribute("hoursServed")      != null ? (Integer) request.getAttribute("hoursServed")      : 0;
    int totalAttended    = request.getAttribute("totalAttended")    != null ? (Integer) request.getAttribute("totalAttended")    : 0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>About Us – VolunteerHub</title>
    <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;600;700;800&family=DM+Sans:wght@400;500;600&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<%= ctx %>/css/landing.css">
    <style>
        /* ── Page layout ── */
        .ab-page { max-width: 1100px; margin: 0 auto; padding: 0 24px 80px; }

        /* ── Hero ── */
        .ab-hero {
            text-align: center;
            padding: 100px 24px 64px;
            background: linear-gradient(160deg, #0f0c1a 0%, #1a1035 60%, #0f0c1a 100%);
        }
        .ab-hero-eyebrow {
            display: inline-flex; align-items: center; gap: 8px;
            background: rgba(124,92,191,.15); border: 1px solid rgba(124,92,191,.3);
            color: #a78bfa; font-size: 12px; font-weight: 700; letter-spacing: .8px;
            text-transform: uppercase; padding: 6px 16px; border-radius: 20px;
            margin-bottom: 24px;
        }
        .ab-hero-title {
            font-size: clamp(2rem, 5vw, 3.2rem); font-weight: 800;
            color: #fff; line-height: 1.15; margin-bottom: 20px;
        }
        .ab-hero-title span { background: linear-gradient(90deg,#7c5cbf,#4f8ef7); -webkit-background-clip:text; -webkit-text-fill-color:transparent; }
        .ab-hero-sub { font-size: 1.05rem; color: rgba(255,255,255,.65); max-width: 620px; margin: 0 auto; line-height: 1.7; }

        /* ── Stat row ── */
        .ab-stats {
            display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px;
            background: rgba(255,255,255,.03); border: 1px solid rgba(255,255,255,.08);
            border-radius: 16px; padding: 28px 32px; margin: 48px auto 0;
            max-width: 900px;
        }
        .ab-stat { text-align: center; }
        .ab-stat-val { font-size: 2rem; font-weight: 800; color: #fff; line-height: 1; }
        .ab-stat-lbl { font-size: 12px; color: rgba(255,255,255,.5); margin-top: 6px; text-transform: uppercase; letter-spacing: .6px; }
        .ab-stat-val span { background: linear-gradient(90deg,#7c5cbf,#4f8ef7); -webkit-background-clip:text; -webkit-text-fill-color:transparent; }
        @media(max-width:640px) { .ab-stats { grid-template-columns: 1fr 1fr; } }

        /* ── Section shared ── */
        .ab-section { padding: 72px 0 0; }
        .ab-section-tag {
            display: inline-flex; align-items: center; gap: 6px;
            font-size: 11px; font-weight: 700; letter-spacing: .8px; text-transform: uppercase;
            color: #7c5cbf; margin-bottom: 12px;
        }
        .ab-section-title { font-size: clamp(1.5rem,3vw,2.2rem); font-weight: 700; color: #fff; margin-bottom: 16px; }
        .ab-section-body  { font-size: 15px; color: rgba(255,255,255,.65); line-height: 1.8; max-width: 680px; }

        /* ── Mission / Vision / Values grid ── */
        .ab-mvv { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 20px; margin-top: 40px; }
        .ab-mvv-card {
            background: rgba(255,255,255,.03); border: 1px solid rgba(255,255,255,.08);
            border-radius: 14px; padding: 28px 24px;
        }
        .ab-mvv-icon {
            width: 48px; height: 48px; border-radius: 12px;
            display: flex; align-items: center; justify-content: center;
            font-size: 20px; margin-bottom: 16px;
        }
        .ic-purple { background: rgba(124,92,191,.15); color: #a78bfa; }
        .ic-blue   { background: rgba(79,142,247,.12);  color: #4f8ef7; }
        .ic-teal   { background: rgba(56,201,176,.12);  color: #38c9b0; }
        .ab-mvv-title { font-size: 15px; font-weight: 700; color: #fff; margin-bottom: 10px; }
        .ab-mvv-text  { font-size: 13px; color: rgba(255,255,255,.58); line-height: 1.7; }

        /* ── Team ── */
        .ab-team { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 20px; margin-top: 40px; }
        .ab-team-card {
            background: rgba(255,255,255,.03); border: 1px solid rgba(255,255,255,.08);
            border-radius: 14px; padding: 28px 20px; text-align: center;
        }
        .ab-team-avatar {
            width: 64px; height: 64px; border-radius: 50%; margin: 0 auto 14px;
            display: flex; align-items: center; justify-content: center;
            font-size: 24px; font-weight: 700; color: #fff;
        }
        .ab-team-name { font-size: 14px; font-weight: 700; color: #fff; margin-bottom: 4px; }
        .ab-team-role { font-size: 12px; color: rgba(255,255,255,.45); }

        /* ── Contact ── */
        .ab-contact-wrap {
            display: grid; grid-template-columns: 1fr 1fr; gap: 40px; margin-top: 40px;
        }
        @media(max-width:700px) { .ab-contact-wrap { grid-template-columns: 1fr; } }

        .ab-contact-info { display: flex; flex-direction: column; gap: 20px; }
        .ab-contact-item { display: flex; gap: 16px; align-items: flex-start; }
        .ab-contact-icon {
            width: 44px; height: 44px; border-radius: 12px; flex-shrink: 0;
            display: flex; align-items: center; justify-content: center; font-size: 17px;
        }
        .ab-contact-label { font-size: 11px; text-transform: uppercase; letter-spacing: .7px; color: rgba(255,255,255,.4); margin-bottom: 4px; }
        .ab-contact-val   { font-size: 14px; color: rgba(255,255,255,.85); font-weight: 500; }
        .ab-contact-val a { color: #a78bfa; text-decoration: none; }
        .ab-contact-val a:hover { text-decoration: underline; }

        /* Contact form */
        .ab-form { display: flex; flex-direction: column; gap: 14px; }
        .ab-form input, .ab-form textarea {
            background: rgba(255,255,255,.05); border: 1px solid rgba(255,255,255,.1);
            border-radius: 10px; color: #fff; padding: 12px 16px;
            font-size: 13px; font-family: inherit; outline: none; width: 100%; box-sizing: border-box;
            transition: border-color .2s;
        }
        .ab-form input::placeholder, .ab-form textarea::placeholder { color: rgba(255,255,255,.35); }
        .ab-form input:focus, .ab-form textarea:focus { border-color: rgba(124,92,191,.6); }
        .ab-form textarea { min-height: 110px; resize: vertical; }
        .ab-form-btn {
            background: linear-gradient(135deg,#7c5cbf,#4f8ef7); color: #fff; border: none;
            padding: 13px 28px; border-radius: 10px; font-size: 14px; font-weight: 700;
            cursor: pointer; font-family: inherit; transition: opacity .2s; width: 100%;
        }
        .ab-form-btn:hover { opacity: .88; }
        .ab-form-success {
            display: none; background: rgba(56,201,176,.1); border: 1px solid rgba(56,201,176,.25);
            color: #38c9b0; padding: 14px 18px; border-radius: 10px; font-size: 13px;
            text-align: center;
        }

        /* ── Divider ── */
        .ab-divider { border: none; border-top: 1px solid rgba(255,255,255,.07); margin: 48px 0 0; }
    </style>
</head>
<body class="lp-body">

<!-- ══ NAVBAR ══ -->
<nav class="lp-nav">
    <a href="<%= ctx %>/home" class="lp-nav__brand">
        <div class="lp-nav__icon"><i class="fa-solid fa-hands-helping" style="color:#fff;"></i></div>
        <span class="lp-nav__name">Volunteer<span>Hub</span></span>
    </a>
    <div class="lp-nav__links" style="display:flex; align-items:center; gap:24px;">
        <a href="<%= ctx %>/home#events" style="color:rgba(255,255,255,.75); font-size:14px; font-weight:500; text-decoration:none;">Events</a>
        <a href="<%= ctx %>/about"       style="color:#fff;                   font-size:14px; font-weight:600; text-decoration:none; border-bottom:2px solid #7c5cbf; padding-bottom:2px;">About</a>
        <a href="#contact"               style="color:rgba(255,255,255,.75); font-size:14px; font-weight:500; text-decoration:none;">Contact</a>
    </div>
    <div class="lp-nav__actions">
        <a href="<%= ctx %>/login"    class="lp-btn lp-btn--ghost">Log In</a>
        <a href="<%= ctx %>/register" class="lp-btn lp-btn--primary"><i class="fa-solid fa-user-plus"></i> Sign Up</a>
    </div>
</nav>

<!-- ══ HERO ══ -->
<div class="ab-hero">
    <div class="ab-hero-eyebrow"><i class="fas fa-heart"></i> Our Story</div>
    <h1 class="ab-hero-title">Empowering Communities<br>Through <span>Volunteering</span></h1>
    <p class="ab-hero-sub">
        VolunteerHub is Nepal's dedicated platform for connecting passionate volunteers with
        meaningful community events — making giving back simple, trackable, and rewarding.
    </p>

    <!-- Real-time impact stats -->
    <div class="ab-stats">
        <div class="ab-stat">
            <div class="ab-stat-val"><span><%= activeVolunteers > 0 ? activeVolunteers : "—" %></span></div>
            <div class="ab-stat-lbl">Active Volunteers</div>
        </div>
        <div class="ab-stat">
            <div class="ab-stat-val"><span><%= totalEvents > 0 ? totalEvents : "—" %></span></div>
            <div class="ab-stat-lbl">Events Hosted</div>
        </div>
        <div class="ab-stat">
            <div class="ab-stat-val"><span><%= hoursServed > 0 ? hoursServed : "—" %></span></div>
            <div class="ab-stat-lbl">Hours Served</div>
        </div>
        <div class="ab-stat">
            <div class="ab-stat-val"><span><%= totalAttended > 0 ? totalAttended : "—" %></span></div>
            <div class="ab-stat-lbl">Spots Filled</div>
        </div>
    </div>
</div>

<!-- ══ MAIN CONTENT ══ -->
<div class="ab-page">

    <!-- About section -->
    <div class="ab-section">
        <div class="ab-section-tag"><i class="fas fa-info-circle"></i> About Us</div>
        <h2 class="ab-section-title">Who We Are</h2>
        <p class="ab-section-body">
            Founded with the belief that every person has something valuable to give,
            VolunteerHub was built to remove the barriers between willing volunteers and the
            organizations that need them. We serve communities across Nepal by providing a
            transparent, easy-to-use platform where volunteers can discover events, track
            their contributions, earn recognition, and build a legacy of service.
        </p>
        <p class="ab-section-body" style="margin-top:14px;">
            Our platform handles everything — from volunteer registration and event management
            to attendance tracking, reward points, and digital badges — so organizations can
            focus on the work that matters, and volunteers can focus on making a difference.
        </p>
    </div>

    <!-- Mission / Vision / Values -->
    <div class="ab-section">
        <div class="ab-section-tag"><i class="fas fa-bullseye"></i> Our Foundation</div>
        <h2 class="ab-section-title">Mission, Vision &amp; Values</h2>
        <div class="ab-mvv">
            <div class="ab-mvv-card">
                <div class="ab-mvv-icon ic-purple"><i class="fas fa-rocket"></i></div>
                <div class="ab-mvv-title">Our Mission</div>
                <div class="ab-mvv-text">
                    To simplify and scale community volunteering in Nepal by connecting motivated
                    individuals with impactful events — making every act of service visible, valued, and celebrated.
                </div>
            </div>
            <div class="ab-mvv-card">
                <div class="ab-mvv-icon ic-blue"><i class="fas fa-eye"></i></div>
                <div class="ab-mvv-title">Our Vision</div>
                <div class="ab-mvv-text">
                    A Nepal where every community challenge has a line of volunteers ready to help —
                    where service is a lifestyle, not an afterthought, and where technology empowers compassion.
                </div>
            </div>
            <div class="ab-mvv-card">
                <div class="ab-mvv-icon ic-teal"><i class="fas fa-gem"></i></div>
                <div class="ab-mvv-title">Our Values</div>
                <div class="ab-mvv-text">
                    <strong style="color:#38c9b0;">Transparency</strong> in tracking every contribution.
                    <strong style="color:#38c9b0;">Inclusion</strong> — everyone has a role to play.
                    <strong style="color:#38c9b0;">Recognition</strong> — no effort goes unnoticed.
                    <strong style="color:#38c9b0;">Community first</strong> — always.
                </div>
            </div>
        </div>
    </div>

    <!-- What We Do -->
    <div class="ab-section">
        <div class="ab-section-tag"><i class="fas fa-tools"></i> What We Do</div>
        <h2 class="ab-section-title">How VolunteerHub Works</h2>
        <div class="ab-mvv">
            <div class="ab-mvv-card">
                <div class="ab-mvv-icon ic-purple"><i class="fas fa-calendar-plus"></i></div>
                <div class="ab-mvv-title">Event Management</div>
                <div class="ab-mvv-text">
                    Admins create and manage volunteer events with full details — dates, locations, capacity,
                    and images. Events automatically transition from Upcoming → Ongoing → Finished.
                </div>
            </div>
            <div class="ab-mvv-card">
                <div class="ab-mvv-icon ic-blue"><i class="fas fa-user-check"></i></div>
                <div class="ab-mvv-title">Volunteer Matching</div>
                <div class="ab-mvv-text">
                    Volunteers browse and apply to events. Admins review applications and accept or
                    decline, keeping the process organized and accountable for both sides.
                </div>
            </div>
            <div class="ab-mvv-card">
                <div class="ab-mvv-icon ic-teal"><i class="fas fa-medal"></i></div>
                <div class="ab-mvv-title">Recognition &amp; Rewards</div>
                <div class="ab-mvv-text">
                    Attendance is tracked after each event. Volunteers earn reward points and unlock
                    badge tiers — from First Step to Legend — as their service record grows.
                </div>
            </div>
        </div>
    </div>

    <hr class="ab-divider">

    <!-- Contact -->
    <div class="ab-section" id="contact">
        <div class="ab-section-tag"><i class="fas fa-envelope"></i> Get In Touch</div>
        <h2 class="ab-section-title">Contact Us</h2>
        <p class="ab-section-body">
            Have a question, want to partner with us, or need help with the platform?
            We'd love to hear from you. Reach out through any of the channels below.
        </p>

        <div class="ab-contact-wrap">

            <!-- Contact details -->
            <div class="ab-contact-info">
                <div class="ab-contact-item">
                    <div class="ab-contact-icon ic-purple"><i class="fas fa-map-marker-alt"></i></div>
                    <div>
                        <div class="ab-contact-label">Address</div>
                        <div class="ab-contact-val">Kathmandu, Bagmati Province<br>Nepal</div>
                    </div>
                </div>
                <div class="ab-contact-item">
                    <div class="ab-contact-icon ic-blue"><i class="fas fa-envelope"></i></div>
                    <div>
                        <div class="ab-contact-label">Email</div>
                        <div class="ab-contact-val"><a href="mailto:dahalgtm23@gmail.com">dahalgtm23@gmail.com</a></div>
                    </div>
                </div>
                <div class="ab-contact-item">
                    <div class="ab-contact-icon ic-teal"><i class="fas fa-phone"></i></div>
                    <div>
                        <div class="ab-contact-label">Phone</div>
                        <div class="ab-contact-val">+977 98XXXXXXXX</div>
                    </div>
                </div>
                <div class="ab-contact-item">
                    <div class="ab-contact-icon" style="background:rgba(245,166,35,.1); color:#f5a623;"><i class="fas fa-clock"></i></div>
                    <div>
                        <div class="ab-contact-label">Office Hours</div>
                        <div class="ab-contact-val">Sun – Fri &nbsp;·&nbsp; 9:00 AM – 5:00 PM NPT</div>
                    </div>
                </div>
            </div>

            <!-- Contact form -->
            <div>
                <div id="contactSuccess" class="ab-form-success">
                    <i class="fas fa-check-circle" style="font-size:18px; display:block; margin-bottom:8px;"></i>
                    Thank you! Your message has been sent. We'll get back to you within 24 hours.
                </div>
                <form class="ab-form" id="contactForm" onsubmit="handleContact(event)">
                    <input type="text"  name="name"    placeholder="Your full name"    required>
                    <input type="email" name="email"   placeholder="Your email address" required>
                    <input type="text"  name="subject" placeholder="Subject"            required>
                    <textarea           name="message" placeholder="Your message..."    required></textarea>
                    <button type="submit" class="ab-form-btn">
                        <i class="fas fa-paper-plane"></i> Send Message
                    </button>
                </form>
            </div>

        </div>
    </div>

</div><!-- ab-page -->

<!-- ══ FOOTER ══ -->
<footer class="lp-footer" style="margin-top:80px;">
    <div class="lp-footer__inner">
        <a href="<%= ctx %>/home" class="lp-footer__brand">
            <i class="fa-solid fa-hands-helping" style="color:#7c3aed;"></i> VolunteerHub
        </a>
        <p class="lp-footer__copy">&copy; 2026 VolunteerHub. Built with purpose.</p>
        <div class="lp-footer__links">
            <a href="<%= ctx %>/about">About Us</a>
            <a href="#contact">Contact</a>
            <a href="<%= ctx %>/login">Log In</a>
            <a href="<%= ctx %>/register">Sign Up</a>
        </div>
    </div>
</footer>

<script>
    function handleContact(e) {
        e.preventDefault();
        // In production, POST this to a backend endpoint.
        // For now, show success message.
        document.getElementById('contactForm').style.display    = 'none';
        document.getElementById('contactSuccess').style.display = 'block';
    }

    document.addEventListener('keydown', function(k) {
        if (k.key === 'Escape') document.querySelectorAll('[id$="Modal"]').forEach(function(m){ m.classList.remove('active'); });
    });

    // Smooth scroll for anchor links
    document.querySelectorAll('a[href^="#"]').forEach(function(a) {
        a.addEventListener('click', function(e) {
            var t = document.querySelector(this.getAttribute('href'));
            if (t) { e.preventDefault(); t.scrollIntoView({ behavior:'smooth' }); }
        });
    });
</script>
</body>
</html>
