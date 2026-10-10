-- ============================================================
-- JMovie - Online Movie Ticket Booking System
-- MySQL / XAMPP Database Schema & Initial Seed Data
-- ============================================================

CREATE DATABASE IF NOT EXISTS `jmovie` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `jmovie`;

-- ------------------------------------------------------------
-- Table Cleanup
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `reviews`;
DROP TABLE IF EXISTS `bookings`;
DROP TABLE IF EXISTS `showtimes`;
DROP TABLE IF EXISTS `movies`;
DROP TABLE IF EXISTS `users`;

-- ------------------------------------------------------------
-- 1. Users Table
-- ------------------------------------------------------------
CREATE TABLE `users` (
  `id`           VARCHAR(20)  NOT NULL,
  `username`     VARCHAR(50)  NOT NULL,
  `password`     VARCHAR(64)  NOT NULL,
  `email`        VARCHAR(100) NOT NULL,
  `phone`        VARCHAR(20)  DEFAULT '',
  `role`         VARCHAR(10)  NOT NULL DEFAULT 'USER',
  `created_at`   VARCHAR(30)  NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Seed Default Admin & Sample User (password for both is admin123 / SHA-256)
INSERT INTO `users` (`id`, `username`, `password`, `email`, `phone`, `role`, `created_at`) VALUES
('USR00001', 'admin', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', 'admin@jmovie.lk', '0777000001', 'ADMIN', '2026-10-10 00:00:00'),
('USR00002', 'john_doe', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', 'john@gmail.com', '0771234567', 'USER', '2026-10-10 00:00:00');

-- ------------------------------------------------------------
-- 2. Movies Table
-- NOTE: poster_url is MEDIUMTEXT (was VARCHAR(500)) so long image
--       URLs or uploaded images (base64 data URIs) are not truncated.
-- ------------------------------------------------------------
CREATE TABLE `movies` (
  `id`           VARCHAR(20)  NOT NULL,
  `title`        VARCHAR(200) NOT NULL,
  `genre`        VARCHAR(50)  NOT NULL,
  `description`  TEXT,
  `duration`     INT          NOT NULL DEFAULT 0,
  `rating`       DOUBLE       NOT NULL DEFAULT 0.0,
  `poster_url`   MEDIUMTEXT,
  `release_date` VARCHAR(15)  NOT NULL,
  `status`       VARCHAR(15)  NOT NULL DEFAULT 'NOW_SHOWING',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Seed Sample Movies with Poster Image URLs
INSERT INTO `movies` (`id`, `title`, `genre`, `description`, `duration`, `rating`, `poster_url`, `release_date`, `status`) VALUES
('MOV00001', 'Spider-Man: Brand New Day', 'Action', 'Fighting crime full-time as Spider-Man in a world that doesn\'t remember him, Peter Parker feels a change begin that he may not be able to control. It might also be the only thing that can stop a powerful villain no one can even see.', 145, 8.1, 'https://image.tmdb.org/t/p/w500/bjiS5ipwxb9JFy3XRRN4OAilSeX.jpg', '2026-07-31', 'NOW_SHOWING'),
('MOV00002', 'The Death of Robin Hood', 'Drama', 'Grappling with his past after a life of crime and murder, Robin Hood is gravely injured after a battle he thought would be his last. In the hands of a mysterious woman, he is offered a chance at salvation.', 123, 6.1, 'https://image.tmdb.org/t/p/w500/13MmRwmG5NmaMfU8qNrtgGXisiD.jpg', '2026-06-19', 'NOW_SHOWING'),
('MOV00003', 'Schindler\'s List', 'Drama', 'The true story of how businessman Oskar Schindler saved over a thousand Jewish lives from the Nazis while they worked as slaves in his factory during World War II.', 195, 9.0, 'https://image.tmdb.org/t/p/w500/sF1U4EUQS8YHUYjNl3pMGNIQyr0.jpg', '1993-12-15', 'NOW_SHOWING'),
('MOV00004', 'The Bridges of Madison County', 'Romance', 'Photographer Robert Kincaid wanders into the life of housewife Francesca Johnson for four days in the 1960s.', 135, 7.6, 'https://image.tmdb.org/t/p/w500/aCBrhOQjhG397GLkEZ49zReQEKX.jpg', '1995-06-02', 'NOW_SHOWING'),
('MOV00005', '2001: A Space Odyssey', 'Sci-Fi', 'Humanity finds a mysterious object buried beneath the lunar surface and sets off to find its origins with the help of HAL 9000, the world\'s most advanced super computer.', 149, 8.3, 'https://image.tmdb.org/t/p/w500/ve72VxNqjGM69Uky4WTo2bK6rfq.jpg', '1968-04-02', 'NOW_SHOWING');


-- ------------------------------------------------------------
-- 3. Showtimes Table
-- ------------------------------------------------------------
CREATE TABLE `showtimes` (
  `id`              VARCHAR(20)  NOT NULL,
  `movie_id`        VARCHAR(20)  NOT NULL,
  `movie_title`     VARCHAR(200) NOT NULL,
  `theatre_hall`    VARCHAR(50)  NOT NULL,
  `show_date`       VARCHAR(15)  NOT NULL,
  `show_time`       VARCHAR(10)  NOT NULL,
  `total_seats`     INT          NOT NULL DEFAULT 80,
  `available_seats` INT          NOT NULL DEFAULT 80,
  `price`           DOUBLE       NOT NULL DEFAULT 0.0,
  `booked_seats`    TEXT         DEFAULT '',
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_showtime_movie` FOREIGN KEY (`movie_id`) REFERENCES `movies` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Seed Sample Showtimes (movie_title now matches the new movies)
INSERT INTO `showtimes` (`id`, `movie_id`, `movie_title`, `theatre_hall`, `show_date`, `show_time`, `total_seats`, `available_seats`, `price`, `booked_seats`) VALUES
('SHW00001', 'MOV00001', 'Spider-Man: Brand New Day', 'Hall A', '2026-10-15', '10:00', 80, 80, 850.00, ''),
('SHW00002', 'MOV00001', 'Spider-Man: Brand New Day', 'Hall B', '2026-10-15', '14:30', 80, 80, 850.00, ''),
('SHW00003', 'MOV00001', 'Spider-Man: Brand New Day', 'Hall A', '2026-10-16', '18:00', 80, 80, 850.00, ''),
('SHW00004', 'MOV00002', 'The Death of Robin Hood', 'Hall C', '2026-10-15', '11:00', 80, 80, 750.00, ''),
('SHW00005', 'MOV00002', 'The Death of Robin Hood', 'Hall C', '2026-10-16', '15:00', 80, 80, 750.00, ''),
('SHW00006', 'MOV00003', 'Schindler\'s List', 'Hall B', '2026-10-17', '13:00', 80, 80, 800.00, ''),
('SHW00007', 'MOV00004', 'The Bridges of Madison County', 'IMAX Hall', '2026-10-15', '16:00', 60, 60, 1200.00, ''),
('SHW00008', 'MOV00004', 'The Bridges of Madison County', 'IMAX Hall', '2026-10-16', '19:30', 60, 60, 1200.00, ''),
('SHW00009', 'MOV00005', '2001: A Space Odyssey', 'Hall A', '2026-10-18', '12:00', 80, 80, 900.00, '');

-- ------------------------------------------------------------
-- 4. Bookings Table
-- ------------------------------------------------------------
CREATE TABLE `bookings` (
  `id`            VARCHAR(20)  NOT NULL,
  `user_id`       VARCHAR(20)  NOT NULL,
  `username`      VARCHAR(50)  NOT NULL,
  `showtime_id`   VARCHAR(20)  NOT NULL,
  `movie_id`      VARCHAR(20)  NOT NULL,
  `movie_title`   VARCHAR(200) NOT NULL,
  `seats`         VARCHAR(200) NOT NULL,
  `quantity`      INT          NOT NULL DEFAULT 1,
  `total_amount`  DOUBLE       NOT NULL DEFAULT 0.0,
  `status`        VARCHAR(15)  NOT NULL DEFAULT 'CONFIRMED',
  `booking_date`  VARCHAR(30)  NOT NULL,
  `show_date`     VARCHAR(15)  NOT NULL,
  `show_time`     VARCHAR(10)  NOT NULL,
  `theatre_hall`  VARCHAR(50)  DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- 5. Reviews Table
-- ------------------------------------------------------------
CREATE TABLE `reviews` (
  `id`           VARCHAR(20)  NOT NULL,
  `user_id`      VARCHAR(20)  NOT NULL,
  `username`     VARCHAR(50)  NOT NULL,
  `movie_id`     VARCHAR(20)  NOT NULL,
  `movie_title`  VARCHAR(200) NOT NULL,
  `rating`       DOUBLE       NOT NULL DEFAULT 5.0,
  `comment`      TEXT         NOT NULL,
  `status`       VARCHAR(15)  NOT NULL DEFAULT 'APPROVED',
  `review_type`  VARCHAR(15)  NOT NULL DEFAULT 'PUBLIC',
  `created_at`   VARCHAR(30)  NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- OPTIONAL: if you do NOT want to re-import this whole file
-- (it drops all tables), run only this on your existing DB:
--
--   ALTER TABLE `movies` MODIFY `poster_url` MEDIUMTEXT;
-- ------------------------------------------------------------