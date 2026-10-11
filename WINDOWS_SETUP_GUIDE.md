# 🎬 JMovie - Online Movie Ticket Booking System
## Windows Setup & Technology Specification Guide

This guide provides a comprehensive overview of the **technologies used**, **OOP design concepts implemented**, and **step-by-step instructions for running the application on a Windows machine** with **XAMPP (MySQL)**.

---

## 🛠️ 1. Technologies & Stack Overview

| Layer | Technology / Tool | Purpose |
|---|---|---|
| **Programming Language** | Java (JDK 11+) | Core application logic and OOP design |
| **Web Framework / Specification** | Java Servlets 4.0 & JSP 2.3 | Dynamic web request handling & page rendering |
| **Templating & UI Components** | JSTL 1.2 (Java Standard Tag Library) | JSP custom tags for loops, conditionals, and formatting |
| **Database** | MySQL (via XAMPP) / MariaDB | Relational Data Storage for Users, Movies, Showtimes, Bookings, and Reviews |
| **Database Connectivity** | JDBC (MySQL Connector/J 8.0.33) | Pure JDBC DAO pattern for SQL queries |
| **Database Admin GUI** | phpMyAdmin (XAMPP) | Web interface for database import and SQL management |
| **Build & Dependency Tool** | Apache Maven 3.x | Project building, packaging WAR files, and managing dependencies |
| **Embedded Web Server** | Apache Tomcat 9.0 (via Cargo Maven Plugin) | Servlet container for serving the web app on `http://localhost:8080/jmovie` |
| **Front-End Styling** | HTML5, Vanilla CSS3 (Custom Design System) | Modern dark mode visual aesthetic with glassmorphism effects |
| **Front-End Logic** | Vanilla JavaScript (ES6+) | Interactive seat selection grid, modals, AJAX review submission |

---

## 🏗️ 2. Core OOP Concepts Implemented (SE1020 Requirement)

1. **Encapsulation**: Private fields with public getter/setter methods in entity models (`User`, `Movie`, `Showtime`, `Booking`, `Review`).
2. **Inheritance & Polymorphism**:
   - `User` abstract base class extended by `AdminUser` and `RegularUser`.
   - Dynamic polymorphism via overridden `getDashboardUrl()` and role-based privilege handling.
3. **Abstraction & DAO Pattern**:
   - Data access logic decoupled into `UserDAO`, `MovieDAO`, `ShowtimeDAO`, `BookingDAO`, and `ReviewDAO`.
   - Abstracted database connection management in `DBConnection`.
4. **CRUD Operations**:
   - **Create**: Add new movies, register users, create showtimes, place bookings, post reviews.
   - **Read**: Browse movie catalog, search/filter movies, view available seats, list user booking history.
   - **Update**: Edit movie details, update showtimes, modify user profiles, approve/reject reviews.
   - **Delete**: Remove movies, delete showtimes, delete user accounts, remove bookings.

---

## 🖥️ 3. Prerequisites for Windows Setup

Before starting, install the following software on your Windows machine:

### A. Java Development Kit (JDK 11 or later)
1. Download JDK 11 or 17 from [Oracle JDK Downloads](https://www.oracle.com/java/technologies/downloads/) or [Eclipse Temurin OpenJDK](https://adoptium.net/).
2. Run the installer and complete the setup.
3. Set Environment Variables in Windows:
   - Search for **"Edit environment variables for your account"** in Start menu.
   - Create a System Variable:
     - **Variable Name:** `JAVA_HOME`
     - **Variable Value:** `C:\Program Files\Java\jdk-17` *(or your installed JDK folder path)*
   - Add `%JAVA_HOME%\bin` to your System `Path` variable.
4. Verify installation in Command Prompt (`cmd`):
   ```cmd
   java -version
   javac -version
   ```

### B. Apache Maven
1. Download Maven binary zip (`apache-maven-3.x.x-bin.zip`) from [Maven Official Site](https://maven.apache.org/download.cgi).
2. Extract the ZIP file to `C:\apache-maven` (or any preferred directory).
3. Set Environment Variable:
   - Create System Variable: `MAVEN_HOME` = `C:\apache-maven`
   - Add `C:\apache-maven\bin` to your System `Path` variable.
4. Verify in Command Prompt:
   ```cmd
   mvn -version
   ```

### C. XAMPP (Apache + MySQL)
1. Download XAMPP for Windows from [Apache Friends](https://www.apachefriends.org/index.html).
2. Install XAMPP to `C:\xampp`.
3. Open **XAMPP Control Panel** as Administrator.
4. Click **Start** next to **MySQL** (and **Apache** if phpMyAdmin is used).

> 📌 **IMPORTANT NOTE REGARDING XAMPP `htdocs`:**
> **NO, you do NOT need to move your project folder into `C:\xampp\htdocs`!**
> - `htdocs` is only used for PHP scripts or static HTML files served by Apache.
> - Since JMovie is a **Java Web Application (Servlets & JSP)**, it is compiled by **Maven** and hosted by an embedded **Apache Tomcat** web server (`mvn cargo:run`).
> - You can keep the `jmovie` project folder **anywhere on your computer** (e.g., `C:\Projects\jmovie` or `Desktop`). XAMPP is used **only to run the MySQL database server**.

---

## 🗄️ 4. XAMPP MySQL Database Setup

1. Open your web browser and go to: **`http://localhost/phpmyadmin`**
2. Click on the **Import** tab in the top navigation bar.
3. Click **Browse...** / **Choose File** and select the [`schema.sql`](file:///home/nimantha/code/jmovie/schema.sql) file located in the root of the project.
4. Click **Import** (or **Go**) at the bottom.
5. phpMyAdmin will execute the script, creating:
   - Database: `jmovie`
   - Tables: `users`, `movies`, `showtimes`, `bookings`, `reviews`
   - Initial Seed Data: Default Admin (`admin` / `admin123`), regular user, 6 sample movies with posters, and 9 sample showtimes.

> 💡 **Note on DB Credentials:**
> The Java connection file [`DBConnection.java`](file:///home/nimantha/code/jmovie/src/main/java/com/jmovie/db/DBConnection.java) uses standard XAMPP defaults:
> - **Host:** `localhost:3306`
> - **User:** `root`
> - **Password:** `""` *(empty string)*
> 
> If your XAMPP MySQL has a password set, edit `DB_PASSWORD` in `DBConnection.java` or run Maven with property:
> `-Djmovie.db.password=yourpassword`

---

## 🚀 5. How to Build & Run on Windows

1. Open **Command Prompt (`cmd`)** or **PowerShell**.
2. Navigate to the project folder:
   ```cmd
   cd C:\path\to\jmovie
   ```

3. **Clean and Compile the Project:**
   ```cmd
   mvn clean compile
   ```

4. **Start the Web Application Server:**
   ```cmd
   mvn cargo:run
   ```
   *(Cargo will automatically spin up an embedded Tomcat 9 server on port 8080)*

5. Once you see `[INFO] Press Ctrl+C to stop the container...`, the server is active!

---

## 🌐 6. Accessing the Application

Open your browser and navigate to:

| Page | URL | Description |
|---|---|---|
| **Public Movies Page** | [http://localhost:8080/jmovie/movies](http://localhost:8080/jmovie/movies) | Browse movies, search/filter, and view showtimes |
| **Login Page** | [http://localhost:8080/jmovie/auth/login](http://localhost:8080/jmovie/auth/login) | User & Admin Login |
| **Register Page** | [http://localhost:8080/jmovie/auth/register](http://localhost:8080/jmovie/auth/register) | New user sign up |
| **Admin Dashboard** | [http://localhost:8080/jmovie/admin/dashboard](http://localhost:8080/jmovie/admin/dashboard) | Admin statistics & management portal |

### 🔑 Default Login Credentials

- **Admin Account:**
  - **Username:** `admin`
  - **Password:** `admin123`
  - Access: Full CRUD permissions for Movies, Showtimes, Users, Bookings, and Reviews.

- **Sample User Account:**
  - **Username:** `john_doe`
  - **Password:** `admin123`
  - Access: Ticket booking, seat selection, booking history, and review posting.

---

## 🛠️ 7. Troubleshooting Common Windows Issues

### Issue 1: `Port 8080 is already in use`
- **Cause:** Another application (like Skype, Oracle DB, or another Tomcat instance) is using port 8080.
- **Fix:** Kill the process on port 8080 or change port in `pom.xml` under `cargo-maven3-plugin` (`<cargo.servlet.port>8080</cargo.servlet.port>`).
- To find & kill the process in Windows `cmd`:
  ```cmd
  netstat -ano | findstr :8080
  taskkill /PID <process_id> /F
  ```

### Issue 2: `Access denied for user 'root'@'localhost'`
- **Cause:** XAMPP MySQL has a root password set.
- **Fix:** Update line 21 in [`DBConnection.java`](file:///home/nimantha/code/jmovie/src/main/java/com/jmovie/db/DBConnection.java):
  ```java
  private static final String DB_PASSWORD = "your_mysql_password";
  ```
  Then re-run `mvn clean compile` and `mvn cargo:run`.

### Issue 3: `mvn is not recognized as an internal or external command`
- **Cause:** Maven `bin` directory is not added to Windows environment `Path`.
- **Fix:** Add `C:\apache-maven\bin` to your System `Path` variable and restart Command Prompt.

---

## 📝 Project File Structure Quick Reference

```
jmovie/
├── schema.sql                               # MySQL database setup script for phpMyAdmin
├── WINDOWS_SETUP_GUIDE.md                   # This Windows setup & technical guide
├── pom.xml                                  # Maven dependencies & Cargo plugin configuration
└── src/
    └── main/
        ├── java/com/jmovie/
        │   ├── db/                          # MySQL DAO layer (DBConnection, UserDAO, MovieDAO, etc.)
        │   ├── model/                       # OOP Entity classes (User, AdminUser, Movie, Showtime, etc.)
        │   ├── servlet/                     # Servlets handling requests (MovieServlet, AuthServlet, etc.)
        │   └── util/                        # Security (PasswordUtil), ID generation, initializers
        └── webapp/
            ├── WEB-INF/
            │   ├── includes/                # Shared header, navbar, footer JSP templates
            │   └── views/                   # Application JSPs (movies, seat layout, admin dashboard)
            └── css/                         # Custom dark-theme CSS stylesheet
```

http://localhost:8080/jmovie/movies