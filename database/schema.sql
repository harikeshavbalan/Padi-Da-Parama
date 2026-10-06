-- ============================================================
-- STUDENT LIFE MANAGER - DATABASE SCHEMA
-- Subtitle: Personal Academic & Productivity Management System
-- Compatible with MySQL 8.0+ / MySQL Workbench
-- ============================================================

CREATE DATABASE IF NOT EXISTS student_life_manager
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE student_life_manager;

-- 1. USERS TABLE
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_users_username (username),
    INDEX idx_users_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. SUBJECTS TABLE
CREATE TABLE IF NOT EXISTS subjects (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    course_code VARCHAR(20),
    faculty VARCHAR(100),
    room VARCHAR(50),
    credits INT DEFAULT 3,
    color VARCHAR(20) DEFAULT '#4f46e5',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_subjects_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. TASKS TABLE
CREATE TABLE IF NOT EXISTS tasks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    subject_id INT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    category VARCHAR(50) NOT NULL DEFAULT 'Academic', -- Academic, Assignment, Lab, Project, Personal, Club, Other
    priority VARCHAR(20) NOT NULL DEFAULT 'MEDIUM',   -- LOW, MEDIUM, HIGH, URGENT
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',    -- PENDING, IN_PROGRESS, COMPLETED, CANCELLED
    due_date DATE NULL,
    due_time TIME NULL,
    estimated_minutes INT DEFAULT 30,
    actual_minutes INT DEFAULT 0,
    recurrence VARCHAR(20) DEFAULT 'NONE',            -- NONE, DAILY, WEEKLY, MONTHLY
    completed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE SET NULL,
    INDEX idx_tasks_user (user_id),
    INDEX idx_tasks_due_date (due_date),
    INDEX idx_tasks_status (status),
    INDEX idx_tasks_priority (priority)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. DEADLINES TABLE
CREATE TABLE IF NOT EXISTS deadlines (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    subject_id INT NULL,
    task_id INT NULL,
    title VARCHAR(200) NOT NULL,
    due_date DATE NOT NULL,
    due_time TIME NULL,
    priority VARCHAR(20) DEFAULT 'HIGH',
    status VARCHAR(20) DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE SET NULL,
    FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE SET NULL,
    INDEX idx_deadlines_user (user_id),
    INDEX idx_deadlines_date (due_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. EXAMS TABLE
CREATE TABLE IF NOT EXISTS exams (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    subject_id INT NULL,
    title VARCHAR(200) NOT NULL,
    exam_type VARCHAR(50) NOT NULL, -- CAT-I, CAT-II, Internal Test, Lab Test, Model Exam, Semester Exam, Practical Exam, Viva
    exam_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    venue VARCHAR(100),
    syllabus TEXT,
    preparation_percentage INT DEFAULT 0, -- 0-100
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE SET NULL,
    INDEX idx_exams_user (user_id),
    INDEX idx_exams_date (exam_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. WEEKLY TIMETABLE TABLE
CREATE TABLE IF NOT EXISTS timetable (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    subject_id INT NOT NULL,
    day_of_week VARCHAR(20) NOT NULL, -- Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    room VARCHAR(50),
    faculty VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE,
    INDEX idx_timetable_user (user_id),
    INDEX idx_timetable_day (day_of_week)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 7. FUTURE PLANS TABLE
CREATE TABLE IF NOT EXISTS plans (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    start_date DATE NULL,
    target_date DATE NULL,
    priority VARCHAR(20) DEFAULT 'MEDIUM',
    progress INT DEFAULT 0, -- 0 to 100
    status VARCHAR(20) DEFAULT 'PLANNED', -- PLANNED, ACTIVE, COMPLETED, PAUSED, CANCELLED
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_plans_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8. HABITS TABLE
CREATE TABLE IF NOT EXISTS habits (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    category VARCHAR(50) DEFAULT 'General',
    target_frequency VARCHAR(50) DEFAULT 'DAILY',
    color VARCHAR(20) DEFAULT '#10b981',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_habits_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 9. HABIT LOGS TABLE
CREATE TABLE IF NOT EXISTS habit_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    habit_id INT NOT NULL,
    log_date DATE NOT NULL,
    completed BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (habit_id) REFERENCES habits(id) ON DELETE CASCADE,
    UNIQUE KEY uq_habit_date (habit_id, log_date),
    INDEX idx_habit_logs_date (log_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 10. STUDY SESSIONS TABLE
CREATE TABLE IF NOT EXISTS study_sessions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    subject_id INT NULL,
    task_id INT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    duration_minutes INT NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE SET NULL,
    FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE SET NULL,
    INDEX idx_study_user (user_id),
    INDEX idx_study_start (start_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 11. HOLIDAYS TABLE
CREATE TABLE IF NOT EXISTS holidays (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(150) NOT NULL,
    holiday_date DATE NOT NULL,
    description TEXT,
    holiday_type VARCHAR(50) NOT NULL, -- College Holiday, Public Holiday, Vacation, Event Holiday
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_holidays_user (user_id),
    INDEX idx_holidays_date (holiday_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 12. EVENTS TABLE
CREATE TABLE IF NOT EXISTS events (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    event_date DATE NOT NULL,
    start_time TIME NULL,
    end_time TIME NULL,
    category VARCHAR(50) NOT NULL, -- Club meeting, College event, Presentation, Project review, Seminar, Personal
    location VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_events_user (user_id),
    INDEX idx_events_date (event_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 13. NOTIFICATIONS TABLE
CREATE TABLE IF NOT EXISTS notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) DEFAULT 'INFO', -- INFO, WARNING, ALERT, SUCCESS
    link VARCHAR(255) NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_notif_user (user_id),
    INDEX idx_notif_read (is_read)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 14. USER SETTINGS TABLE
CREATE TABLE IF NOT EXISTS user_settings (
    user_id INT PRIMARY KEY,
    default_priority VARCHAR(20) DEFAULT 'MEDIUM',
    week_start_day VARCHAR(20) DEFAULT 'Monday',
    reminders_enabled BOOLEAN DEFAULT TRUE,
    theme_preference VARCHAR(20) DEFAULT 'dark',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
