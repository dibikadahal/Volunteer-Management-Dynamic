# VolunteerHub — A Volunteer Management System

> A full-stack, role-based web application for managing volunteers, events, and assignments — built with Jakarta EE, deployed on Apache Tomcat, and backed by MySQL.

---

## 📌 Overview

VolunteerHub is a web-based Volunteer Management System developed using **Java EE technologies** including Jakarta Servlets, JSP, and MySQL as the backend database. The system replaces manual volunteer coordination with a structured, digital platform to organise, track, and manage volunteer activities and community events.

The platform supports two distinct roles:
- **Administrator** — manages events, approves volunteers, marks attendance, and monitors system activity
- **Volunteer** — browses events, submits join requests, tracks participation history, and earns reward points

---

## ✨ Key Features

- 🔐 Role-based access control enforced globally via `AuthFilter`
- 🔒 BCrypt password hashing (cost factor 12) for secure authentication
- 🔁 Account lockout after 5 consecutive failed login attempts (15-minute lock)
- 📧 Email-based password reset with time-limited secure tokens (30 minutes)
- 📅 FullCalendar.js integration for event timeline views
- ⭐ Reward points and badge system for volunteer participation
- 🔔 In-app notification system for request status updates
- 📁 File upload support for profile photos and event banner images
- ✅ Real-time AJAX field validation during registration
- 📱 Responsive design with mobile-friendly sidebar navigation

---

## 🛠️ Tech Stack

| Technology | Version | Purpose |
|---|---|---|
| Java (Jakarta EE) | 11+ | Primary backend language |
| Jakarta Servlet API | 6.0 | HTTP request/response handling |
| JSP (Jakarta Server Pages) | 3.1 | Server-side HTML templating |
| Apache Tomcat | 10.x | Web application server |
| MySQL | 5.7+ | Relational database |
| MySQL Connector/J | 9.6.0 | JDBC driver |
| jBCrypt | 0.4 | Password hashing |
| Jakarta Mail | 2.0.3 | SMTP email sending |
| FullCalendar.js | — | Calendar widget |
| HTML5 / CSS3 / JavaScript | — | Frontend |
| Maven | — | Build and dependency management |
| Eclipse IDE | — | Development environment |
| XAMPP | — | Local MySQL server |

---

## 🗂️ Project Structure

```
VolunteerManagement/
├── src/
│   └── main/
│       ├── java/
│       │   └── com/VMS/
│       │       ├── config/
│       │       │   └── DBConnection.java          # Centralised JDBC connection
│       │       ├── controller/
│       │       │   ├── AuthController.java         # Login, register, logout
│       │       │   ├── AuthFilter.java             # Global security filter
│       │       │   ├── DashboardController.java    # Admin & volunteer dashboards
│       │       │   ├── EventController.java        # Event CRUD + image upload
│       │       │   ├── ProfileController.java      # Profile management
│       │       │   ├── AdminAssignmentController.java
│       │       │   ├── VolunteerEventsController.java
│       │       │   ├── VolunteerAssignmentController.java
│       │       │   ├── PasswordResetController.java
│       │       │   ├── NotificationController.java
│       │       │   ├── CheckFieldController.java   # AJAX duplicate checks
│       │       │   └── FileServlet.java            # Serves uploaded files
│       │       ├── dao/
│       │       │   ├── UserDAO.java
│       │       │   ├── EventDAO.java
│       │       │   ├── VolunteerDAO.java
│       │       │   ├── AssignmentDAO.java
│       │       │   ├── ProfileDAO.java
│       │       │   ├── AdminDashboardDAO.java
│       │       │   ├── VolunteerDashboardDAO.java
│       │       │   └── PasswordResetDAO.java
│       │       ├── model/
│       │       │   ├── User.java
│       │       │   ├── Event.java
│       │       │   ├── VolunteerNotification.java
│       │       │   ├── VolunteerAssignmentEntry.java
│       │       │   ├── VolunteerEventEntry.java
│       │       │   └── EventVolunteerEntry.java
│       │       └── service/
│       │           ├── UserService.java            # Registration & login logic
│       │           └── EmailService.java           # Jakarta Mail SMTP wrapper
│       └── webapp/
│           ├── css/
│           │   ├── login.css
│           │   ├── register.css
│           │   ├── landing.css
│           │   ├── admin.css
│           │   ├── volunteer.css
│           │   └── profile.css
│           ├── images/
│           └── WEB-INF/
│               └── pages/
│                   ├── login.jsp
│                   ├── register.jsp
│                   ├── landing.jsp
│                   ├── about.jsp
│                   ├── forgot-password.jsp
│                   ├── reset-password.jsp
│                   ├── admin/
│                   │   ├── dashboard.jsp
│                   │   ├── events.jsp
│                   │   ├── volunteers.jsp
│                   │   ├── assignments.jsp
│                   │   ├── calendar.jsp
│                   │   └── profile.jsp
│                   └── volunteer/
│                       ├── dashboard.jsp
│                       ├── browseEvents.jsp
│                       ├── myEvents.jsp
│                       ├── assignments.jsp
│                       ├── calendar.jsp
│                       └── profile.jsp
├── build/
├── LIB/
├── photo/
├── pom.xml
└── README.md
```

---

## 🗃️ Database Schema

The system uses a MySQL database named `vms` with five core tables:

| Table | Description |
|---|---|
| `user` | Stores all registered users (admins and volunteers) |
| `event` | Stores all volunteer events created by admins |
| `volunteer` | Join requests linking users to events (pending/accepted/declined) |
| `assignment` | Records attendance and reward points per volunteer per event |
| `notification` | Stores in-app alerts for status changes and event updates |

**JDBC Connection URL:**
```
jdbc:mysql://localhost:3306/vms?useSSL=false&serverTimezone=UTC
```

---

## ⚙️ Installation & Setup

### Prerequisites

- Java JDK 11 or higher — [Download](https://www.oracle.com/java/technologies/downloads/)
- Apache Tomcat 10.x — [Download](https://tomcat.apache.org/)
- XAMPP (for MySQL) — [Download](https://www.apachefriends.org/)
- Eclipse IDE (Enterprise Edition) — [Download](https://www.eclipse.org/downloads/)
- Maven — included with Eclipse or [Download](https://maven.apache.org/)

### Steps

**1. Clone the repository**
```bash
git clone https://github.com/dibikadahal/Volunteer-Management-Dynamic.git
cd Volunteer-Management-Dynamic
```

**2. Set up the database**
- Start XAMPP and run the MySQL service
- Open phpMyAdmin at `http://localhost/phpmyadmin`
- Create a new database named `vms`
- Import the provided SQL schema file to create all five tables

**3. Configure the JDBC connection**

Open `src/main/java/com/VMS/config/DBConnection.java` and verify:
```java
private static final String URL = "jdbc:mysql://localhost:3306/vms?useSSL=false&serverTimezone=UTC";
private static final String USER = "root";
private static final String PASSWORD = "";
```

**4. Configure Gmail SMTP (for password reset emails)**

Open `EmailService.java` and update with your Gmail credentials:
```java
private static final String SMTP_EMAIL = "your-email@gmail.com";
private static final String SMTP_PASSWORD = "your-app-password";
```
> Use a Gmail App Password, not your regular Gmail password. Enable 2FA first, then generate an App Password from your Google account settings.

**5. Build and deploy**
- Open Eclipse → File → Import → Existing Maven Project
- Select the cloned folder
- Right-click project → Run on Server → Select Tomcat 10.x
- Access the application at `http://localhost:8080/VolunteerManagement`

---

## 🚀 Default Login

| Role | Username | Password |
|---|---|---|
| Admin | Dibika | (set during registration) |

> New volunteer accounts require admin approval before login is permitted.

---

## 🔐 Security Features

- **BCrypt hashing** — all passwords are hashed with cost factor 12
- **PreparedStatement** — all SQL queries use parameterised statements to prevent SQL injection
- **AuthFilter** — every request passes through a global filter enforcing role-based routing
- **Account lockout** — 5 failed login attempts locks the account for 15 minutes
- **Timed reset tokens** — password reset links expire after 30 minutes and cannot be reused
- **File upload validation** — MIME type and size limits enforced on all uploads
- **Path traversal protection** — FileServlet validates all file paths before serving

---

## 📄 Key Workflows

1. **Registration & Approval** — Volunteers register and await admin activation (`is_active = 0` by default)
2. **Event Lifecycle** — Admins create events → volunteers request to join → admin accepts/declines → event status derived automatically from timestamps
3. **Attendance & Points** — Admin marks attendance → reward points awarded automatically based on participation milestones
4. **Password Reset** — Email → timed token → new password → token invalidated
5. **Notifications** — Status changes (accepted/declined) generate in-app notifications for volunteers

---

## 👩‍💻 Author

**Dibika Dahal**
- GitHub: [dibikadahal](https://github.com/dibikadahal)
- LinkedIn: [Dibika Dahal](https://www.linkedin.com/in/dibika-dahal-a720642b0/)
- College: Islington College, Kathmandu
- Student ID: NP01AI4S250030

---

## 📜 License

This project was developed as part of the CS5003NI Data Structures and Specialist Programming coursework at Islington College (London Metropolitan University), Academic Year 2025/2026.
