# 🎬 JMovie — Online Movie Ticket Booking System
**SE1020 Object Oriented Programming — Group Project**

---

## 📖 Complete Guides & Documentation
- **Windows Setup & Technical Specification Guide:** See [`WINDOWS_SETUP_GUIDE.md`](WINDOWS_SETUP_GUIDE.md)
- **Database Schema Script (XAMPP / phpMyAdmin):** See [`schema.sql`](schema.sql)
- **Workload Distribution:** See [`SE1020_Workload_Distribution.md`](SE1020_Workload_Distribution.md)

---

## 🛠️ Tech Stack & Technologies Used

| Layer | Technology |
|---|---|
| **Backend Core** | Java 11+, Java Servlets 4.0, JSP 2.3, JSTL 1.2 |
| **Database** | MySQL / MariaDB (via XAMPP), JDBC (MySQL Connector/J 8.0.33) |
| **Database Administration** | phpMyAdmin (XAMPP) |
| **Frontend** | HTML5, Modern Dark Theme Vanilla CSS3, Vanilla JavaScript (ES6+) |
| **Build & Dependencies** | Apache Maven 3.x |
| **Embedded Server** | Apache Tomcat 9.0 (via `cargo-maven3-plugin`) |

---

## 🚀 Quick Start (Windows with XAMPP)

1. **Start MySQL in XAMPP** Control Panel.
2. Open **http://localhost/phpmyadmin**, create database `jmovie`, and import [`schema.sql`](schema.sql).
3. Open Command Prompt in project directory and run:
   ```cmd
   mvn clean compile
   mvn cargo:run
   ```
4. Open browser at: **`http://localhost:8080/jmovie/movies`**

---

## 🔑 Credentials & Access

- **Public Website:** `http://localhost:8080/jmovie/movies`
- **Admin Panel:** `http://localhost:8080/jmovie/admin/dashboard`
- **Default Admin Login:** Username `admin` | Password `admin123`

---

## 🧠 OOP Concepts Demonstrated

| Concept | Location & Implementation |
|---|---|
| **Encapsulation** | Entity classes (`User`, `Movie`, `Showtime`, `Booking`, `Review`) with private fields & public accessors |
| **Inheritance** | `User` abstract base class extended by `AdminUser` and `RegularUser` |
| **Polymorphism** | Overridden `getDashboardUrl()` and role-specific permissions |
| **Abstraction & DAO** | Decoupled SQL data layer in `UserDAO`, `MovieDAO`, `ShowtimeDAO`, `BookingDAO`, `ReviewDAO` |

---
*Built for SE1020 — Object Oriented Programming, University Project*
//
///

