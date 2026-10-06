-- ============================================================
-- STUDENT LIFE MANAGER - SUPABASE (POSTGRESQL) COMPLETE SETUP
-- Subtitle: Personal Academic & Productivity Management System
-- Compatible with: Supabase SQL Editor / PostgreSQL 14+
-- 
-- Instructions for Supabase:
-- 1. Open your Supabase Dashboard: https://supabase.com/dashboard
-- 2. Select your project -> SQL Editor -> New Query
-- 3. Paste the entirety of this script and click "RUN"
-- ============================================================

-- Clean Drop of existing tables if re-running
DROP TABLE IF EXISTS user_settings CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS events CASCADE;
DROP TABLE IF EXISTS holidays CASCADE;
DROP TABLE IF EXISTS study_sessions CASCADE;
DROP TABLE IF EXISTS habit_logs CASCADE;
DROP TABLE IF EXISTS habits CASCADE;
DROP TABLE IF EXISTS plans CASCADE;
DROP TABLE IF EXISTS timetable CASCADE;
DROP TABLE IF EXISTS exams CASCADE;
DROP TABLE IF EXISTS deadlines CASCADE;
DROP TABLE IF EXISTS tasks CASCADE;
DROP TABLE IF EXISTS subjects CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Auto-update timestamp function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 1. USERS TABLE
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);

CREATE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 2. SUBJECTS TABLE
CREATE TABLE subjects (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    course_code VARCHAR(20),
    faculty VARCHAR(100),
    room VARCHAR(50),
    credits INT DEFAULT 3,
    color VARCHAR(20) DEFAULT '#4f46e5',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_subjects_user ON subjects(user_id);

CREATE TRIGGER trg_subjects_updated_at
    BEFORE UPDATE ON subjects
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 3. TASKS TABLE
CREATE TABLE tasks (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    subject_id INT NULL REFERENCES subjects(id) ON DELETE SET NULL,
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
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_tasks_user ON tasks(user_id);
CREATE INDEX idx_tasks_due_date ON tasks(due_date);
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_tasks_priority ON tasks(priority);

CREATE TRIGGER trg_tasks_updated_at
    BEFORE UPDATE ON tasks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 4. DEADLINES TABLE
CREATE TABLE deadlines (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    subject_id INT NULL REFERENCES subjects(id) ON DELETE SET NULL,
    task_id INT NULL REFERENCES tasks(id) ON DELETE SET NULL,
    title VARCHAR(200) NOT NULL,
    due_date DATE NOT NULL,
    due_time TIME NULL,
    priority VARCHAR(20) DEFAULT 'HIGH',
    status VARCHAR(20) DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_deadlines_user ON deadlines(user_id);
CREATE INDEX idx_deadlines_date ON deadlines(due_date);

-- 5. EXAMS TABLE
CREATE TABLE exams (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    subject_id INT NULL REFERENCES subjects(id) ON DELETE SET NULL,
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
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_exams_user ON exams(user_id);
CREATE INDEX idx_exams_date ON exams(exam_date);

CREATE TRIGGER trg_exams_updated_at
    BEFORE UPDATE ON exams
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 6. WEEKLY TIMETABLE TABLE
CREATE TABLE timetable (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    subject_id INT NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
    day_of_week VARCHAR(20) NOT NULL, -- Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    room VARCHAR(50),
    faculty VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_timetable_user ON timetable(user_id);
CREATE INDEX idx_timetable_day ON timetable(day_of_week);

-- 7. FUTURE PLANS TABLE
CREATE TABLE plans (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    start_date DATE NULL,
    target_date DATE NULL,
    priority VARCHAR(20) DEFAULT 'MEDIUM',
    progress INT DEFAULT 0, -- 0 to 100
    status VARCHAR(20) DEFAULT 'PLANNED', -- PLANNED, ACTIVE, COMPLETED, PAUSED, CANCELLED
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_plans_user ON plans(user_id);

CREATE TRIGGER trg_plans_updated_at
    BEFORE UPDATE ON plans
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 8. HABITS TABLE
CREATE TABLE habits (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    category VARCHAR(50) DEFAULT 'General',
    target_frequency VARCHAR(50) DEFAULT 'DAILY',
    color VARCHAR(20) DEFAULT '#10b981',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_habits_user ON habits(user_id);

-- 9. HABIT LOGS TABLE
CREATE TABLE habit_logs (
    id SERIAL PRIMARY KEY,
    habit_id INT NOT NULL REFERENCES habits(id) ON DELETE CASCADE,
    log_date DATE NOT NULL,
    completed BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_habit_date UNIQUE (habit_id, log_date)
);

CREATE INDEX idx_habit_logs_date ON habit_logs(log_date);

-- 10. STUDY SESSIONS TABLE
CREATE TABLE study_sessions (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    subject_id INT NULL REFERENCES subjects(id) ON DELETE SET NULL,
    task_id INT NULL REFERENCES tasks(id) ON DELETE SET NULL,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    duration_minutes INT NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_study_user ON study_sessions(user_id);
CREATE INDEX idx_study_start ON study_sessions(start_time);

-- 11. HOLIDAYS TABLE
CREATE TABLE holidays (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(150) NOT NULL,
    holiday_date DATE NOT NULL,
    description TEXT,
    holiday_type VARCHAR(50) NOT NULL, -- College Holiday, Public Holiday, Vacation, Event Holiday
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_holidays_user ON holidays(user_id);
CREATE INDEX idx_holidays_date ON holidays(holiday_date);

-- 12. EVENTS TABLE
CREATE TABLE events (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    event_date DATE NOT NULL,
    start_time TIME NULL,
    end_time TIME NULL,
    category VARCHAR(50) NOT NULL, -- Club meeting, College event, Presentation, Project review, Seminar, Personal
    location VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_events_user ON events(user_id);
CREATE INDEX idx_events_date ON events(event_date);

-- 13. NOTIFICATIONS TABLE
CREATE TABLE notifications (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) DEFAULT 'INFO', -- INFO, WARNING, ALERT, SUCCESS
    link VARCHAR(255) NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notif_user ON notifications(user_id);
CREATE INDEX idx_notif_read ON notifications(is_read);

-- 14. USER SETTINGS TABLE
CREATE TABLE user_settings (
    user_id INT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    default_priority VARCHAR(20) DEFAULT 'MEDIUM',
    week_start_day VARCHAR(20) DEFAULT 'Monday',
    reminders_enabled BOOLEAN DEFAULT TRUE,
    theme_preference VARCHAR(20) DEFAULT 'dark',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER trg_user_settings_updated_at
    BEFORE UPDATE ON user_settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


-- ============================================================
-- SEED DATA INSERTION
-- Generates dynamic relative dates around CURRENT_DATE so
-- today's schedule, deadlines, and streaks are always active.
-- ============================================================

-- 1. SEED USER
-- Demo Account: username: demo / password: demo123 (BCrypt hash)
INSERT INTO users (id, username, email, password_hash, full_name, created_at)
VALUES (
    1,
    'demo',
    'demo@studentlife.edu',
    '$2a$10$678cKvyTfXrwKIaTZ5zVnucFRELmUMqgXKC5/9sH1zvaCzWa7P1hS',
    'Harikeshav',
    NOW()
);

-- Default User Settings
INSERT INTO user_settings (user_id, default_priority, week_start_day, reminders_enabled, theme_preference)
VALUES (1, 'MEDIUM', 'Monday', TRUE, 'dark');

-- 2. SEED SUBJECTS
INSERT INTO subjects (id, user_id, name, course_code, faculty, room, credits, color) VALUES
(1, 1, 'Computer Networks', 'CS302', 'Prof. R. Sharma', 'CS-302', 4, '#3b82f6'),
(2, 1, 'Web Technology', 'CS305', 'Dr. K. Raman', 'Lab-2', 4, '#8b5cf6'),
(3, 1, 'Database Management Systems', 'CS301', 'Prof. A. Verma', 'CS-204', 4, '#10b981'),
(4, 1, 'Operating Systems', 'CS304', 'Dr. S. Mukherjee', 'CS-105', 4, '#f59e0b'),
(5, 1, 'Design and Analysis of Algorithms', 'CS303', 'Prof. V. Nair', 'CS-301', 4, '#ef4444'),
(6, 1, 'Java Programming', 'CS306', 'Prof. M. Gupta', 'Lab-4', 3, '#06b6d4');

-- 3. SEED TASKS
INSERT INTO tasks (id, user_id, subject_id, title, description, category, priority, status, due_date, due_time, estimated_minutes, actual_minutes, recurrence, completed_at) VALUES
-- Today's tasks (due CURRENT_DATE)
(1, 1, 4, 'Complete OS Record', 'Finish write-up for CPU scheduling algorithms and memory management', 'Lab', 'HIGH', 'COMPLETED', CURRENT_DATE, '17:00:00', 90, 85, 'NONE', NOW()),
(2, 1, 3, 'Finish DBMS Assignment', 'Write SQL queries for normalization and indexing exercises', 'Assignment', 'URGENT', 'PENDING', CURRENT_DATE, '23:59:00', 60, 0, 'NONE', NULL),
(3, 1, 2, 'Study Web Technology Unit 1', 'Revise HTTP protocol, Servlets lifecycle, and JSP expressions', 'Academic', 'MEDIUM', 'PENDING', CURRENT_DATE, '20:00:00', 75, 0, 'NONE', NULL),
(4, 1, 2, 'Work on Mini Project', 'Set up MVC architecture and implement authentication flow', 'Project', 'HIGH', 'IN_PROGRESS', CURRENT_DATE, '22:00:00', 120, 45, 'DAILY', NULL),

-- Upcoming tasks
(5, 1, 1, 'CN Socket Programming Lab', 'Implement multi-client TCP echo server and chat room', 'Lab', 'MEDIUM', 'PENDING', CURRENT_DATE + INTERVAL '1 day', '14:00:00', 90, 0, 'WEEKLY', NULL),
(6, 1, 5, 'DAA Dynamic Programming Problems', 'Solve 0/1 Knapsack and Longest Common Subsequence problems', 'Academic', 'HIGH', 'PENDING', CURRENT_DATE + INTERVAL '2 day', '18:00:00', 120, 0, 'NONE', NULL),
(7, 1, 6, 'Java Multithreading Practice', 'Producer-Consumer problem using synchronization and locks', 'Assignment', 'LOW', 'PENDING', CURRENT_DATE + INTERVAL '4 day', '23:59:00', 60, 0, 'NONE', NULL),
(8, 1, NULL, 'Club Tech Fest Meeting', 'Prepare agenda for upcoming hackathon and workshop sessions', 'Club', 'MEDIUM', 'PENDING', CURRENT_DATE + INTERVAL '3 day', '16:30:00', 45, 0, 'WEEKLY', NULL),

-- Overdue task
(9, 1, 1, 'Submit CN Quiz Review', 'Review wire protocol analysis report for Chapter 3', 'Academic', 'HIGH', 'PENDING', CURRENT_DATE - INTERVAL '2 day', '12:00:00', 40, 0, 'NONE', NULL),

-- Already Completed tasks
(10, 1, 3, 'DBMS ER Diagram Exercise', 'Constructed hospital management ER diagram and mapped to tables', 'Assignment', 'MEDIUM', 'COMPLETED', CURRENT_DATE - INTERVAL '3 day', '18:00:00', 60, 55, 'NONE', NOW() - INTERVAL '3 day'),
(11, 1, 5, 'DAA Divide and Conquer Analysis', 'Analyzed Merge Sort and Quick Sort recurrences using Master Theorem', 'Academic', 'HIGH', 'COMPLETED', CURRENT_DATE - INTERVAL '4 day', '19:00:00', 80, 80, 'NONE', NOW() - INTERVAL '4 day'),
(12, 1, 4, 'OS Process Synchronization Lab', 'Implemented Dining Philosophers semaphore solution in C', 'Lab', 'MEDIUM', 'COMPLETED', CURRENT_DATE - INTERVAL '1 day', '16:00:00', 90, 95, 'NONE', NOW() - INTERVAL '1 day'),
(13, 1, 2, 'HTML5 Semantic Layout Wireframe', 'Created initial responsive layout wireframes and navigation', 'Project', 'LOW', 'COMPLETED', CURRENT_DATE - INTERVAL '1 day', '21:00:00', 45, 40, 'NONE', NOW() - INTERVAL '1 day');

-- 4. SEED DEADLINES
INSERT INTO deadlines (id, user_id, subject_id, task_id, title, due_date, due_time, priority, status) VALUES
(1, 1, 3, 2, 'DBMS Assignment Submission', CURRENT_DATE, '23:59:00', 'URGENT', 'PENDING'),
(2, 1, 1, 5, 'CN Socket Lab Upload', CURRENT_DATE + INTERVAL '1 day', '14:00:00', 'HIGH', 'PENDING'),
(3, 1, 5, 6, 'DAA Homework Deadline', CURRENT_DATE + INTERVAL '2 day', '18:00:00', 'HIGH', 'PENDING'),
(4, 1, 2, 4, 'Web Tech Project Milestone 1', CURRENT_DATE + INTERVAL '5 day', '23:59:00', 'URGENT', 'PENDING'),
(5, 1, 1, 9, 'CN Chapter 3 Quiz Overdue', CURRENT_DATE - INTERVAL '2 day', '12:00:00', 'HIGH', 'PENDING');

-- 5. SEED TESTS & EXAMS
INSERT INTO exams (id, user_id, subject_id, title, exam_type, exam_date, start_time, end_time, venue, syllabus, preparation_percentage, notes) VALUES
(1, 1, 2, 'Web Technology CAT-I', 'CAT-I', CURRENT_DATE + INTERVAL '3 day', '09:30:00', '11:00:00', 'LH-201', 'Unit 1: HTML5, CSS3, JavaScript basics, DOM manipulation. Unit 2: Servlets, JSP lifecycle, Request/Response architecture.', 72, 'Focus on Servlet lifecycle diagrams and state management.'),
(2, 1, 1, 'Computer Networks CAT-I', 'CAT-I', CURRENT_DATE + INTERVAL '7 day', '14:00:00', '15:30:00', 'LH-202', 'Physical layer, Data link layer framing, Error correction, Flow control protocols (Go-Back-N, Selective Repeat).', 55, 'Revise Hamming codes and sliding window throughput calculations.'),
(3, 1, 3, 'DBMS Internal Test', 'Internal Test', CURRENT_DATE + INTERVAL '12 day', '10:00:00', '11:30:00', 'CS-204', 'Relational Algebra, SQL queries (Joins, Subqueries), Normalization (1NF, 2NF, 3NF, BCNF).', 40, 'Practice BCNF decomposition proofs.'),
(4, 1, 4, 'Operating Systems Lab Exam', 'Lab Exam', CURRENT_DATE + INTERVAL '18 day', '09:00:00', '12:00:00', 'Lab-3', 'UNIX system calls (fork, exec, wait), Semaphore IPC, Thread synchronization in C/Java.', 65, 'Review mutex lock examples.');

-- 6. SEED WEEKLY TIMETABLE
INSERT INTO timetable (user_id, subject_id, day_of_week, start_time, end_time, room, faculty) VALUES
(1, 1, 'Monday', '09:00:00', '10:00:00', 'CS-302', 'Prof. R. Sharma'),
(1, 2, 'Monday', '10:00:00', '11:00:00', 'Lab-2', 'Dr. K. Raman'),
(1, 3, 'Monday', '11:15:00', '12:15:00', 'CS-204', 'Prof. A. Verma'),
(1, 4, 'Monday', '13:15:00', '14:15:00', 'CS-105', 'Dr. S. Mukherjee'),
(1, 5, 'Monday', '14:15:00', '15:15:00', 'CS-301', 'Prof. V. Nair'),

(1, 2, 'Tuesday', '09:00:00', '10:00:00', 'Lab-2', 'Dr. K. Raman'),
(1, 1, 'Tuesday', '10:00:00', '11:00:00', 'CS-302', 'Prof. R. Sharma'),
(1, 6, 'Tuesday', '11:15:00', '13:15:00', 'Lab-4', 'Prof. M. Gupta'),
(1, 3, 'Tuesday', '14:15:00', '15:15:00', 'CS-204', 'Prof. A. Verma'),

(1, 5, 'Wednesday', '09:00:00', '10:00:00', 'CS-301', 'Prof. V. Nair'),
(1, 4, 'Wednesday', '10:00:00', '11:00:00', 'CS-105', 'Dr. S. Mukherjee'),
(1, 2, 'Wednesday', '11:15:00', '12:15:00', 'Lab-2', 'Dr. K. Raman'),
(1, 1, 'Wednesday', '13:15:00', '15:15:00', 'Lab-1', 'Prof. R. Sharma'),

(1, 3, 'Thursday', '09:00:00', '10:00:00', 'CS-204', 'Prof. A. Verma'),
(1, 5, 'Thursday', '10:00:00', '11:00:00', 'CS-301', 'Prof. V. Nair'),
(1, 6, 'Thursday', '11:15:00', '12:15:00', 'Lab-4', 'Prof. M. Gupta'),
(1, 4, 'Thursday', '13:15:00', '15:15:00', 'Lab-3', 'Dr. S. Mukherjee'),

(1, 1, 'Friday', '09:00:00', '10:00:00', 'CS-302', 'Prof. R. Sharma'),
(1, 2, 'Friday', '10:00:00', '11:00:00', 'Lab-2', 'Dr. K. Raman'),
(1, 3, 'Friday', '11:15:00', '12:15:00', 'CS-204', 'Prof. A. Verma'),
(1, 5, 'Friday', '13:15:00', '14:15:00', 'CS-301', 'Prof. V. Nair');

-- 7. SEED FUTURE PLANS
INSERT INTO plans (id, user_id, title, description, start_date, target_date, priority, progress, status) VALUES
(1, 1, 'Master Data Structures & Algorithms', 'Solve 150 LeetCode problems covering Trees, Graphs, DP, and Heaps', CURRENT_DATE - INTERVAL '30 day', CURRENT_DATE + INTERVAL '60 day', 'HIGH', 68, 'ACTIVE'),
(2, 1, 'Full-Stack Web Development Project', 'Build Student Life Manager with Java Servlets, JSP, JDBC, and modern UI', CURRENT_DATE - INTERVAL '14 day', CURRENT_DATE + INTERVAL '14 day', 'URGENT', 85, 'ACTIVE'),
(3, 1, 'Prepare for Summer Internship', 'Resume optimization, mock interviews, system design fundamentals', CURRENT_DATE - INTERVAL '10 day', CURRENT_DATE + INTERVAL '45 day', 'HIGH', 40, 'ACTIVE'),
(4, 1, 'Cloud Practitioner Certification', 'Complete AWS Cloud Practitioner course and practice tests', CURRENT_DATE + INTERVAL '10 day', CURRENT_DATE + INTERVAL '90 day', 'MEDIUM', 10, 'PLANNED'),
(5, 1, 'Learn Docker & Containerization', 'Learn Dockerfiles, multi-stage builds, and docker-compose', CURRENT_DATE - INTERVAL '60 day', CURRENT_DATE - INTERVAL '10 day', 'LOW', 100, 'COMPLETED');

-- 8. SEED HABITS
INSERT INTO habits (id, user_id, name, description, category, target_frequency, color) VALUES
(1, 1, 'Study', 'At least 2 hours focused technical study daily', 'Academic', 'DAILY', '#3b82f6'),
(2, 1, 'Coding', 'Solve minimum 1 algorithm or project feature', 'Productivity', 'DAILY', '#10b981'),
(3, 1, 'Workout / Fitness', '30 minutes physical training or running', 'Health', 'DAILY', '#f59e0b'),
(4, 1, 'Reading Technical Docs', 'Read specifications, RFCs, or book chapters', 'Academic', 'DAILY', '#8b5cf6'),
(5, 1, 'Sleep Before 11:30 PM', 'Maintain regular circadian sleep schedule', 'Health', 'DAILY', '#06b6d4');

-- 9. SEED HABIT LOGS (Continuous 5-day active streak)
INSERT INTO habit_logs (habit_id, log_date, completed) VALUES
(1, CURRENT_DATE, TRUE),
(1, CURRENT_DATE - INTERVAL '1 day', TRUE),
(1, CURRENT_DATE - INTERVAL '2 day', TRUE),
(1, CURRENT_DATE - INTERVAL '3 day', TRUE),
(1, CURRENT_DATE - INTERVAL '4 day', TRUE),
(1, CURRENT_DATE - INTERVAL '5 day', TRUE),

(2, CURRENT_DATE, TRUE),
(2, CURRENT_DATE - INTERVAL '1 day', TRUE),
(2, CURRENT_DATE - INTERVAL '2 day', TRUE),
(2, CURRENT_DATE - INTERVAL '3 day', TRUE),

(3, CURRENT_DATE, FALSE),
(3, CURRENT_DATE - INTERVAL '1 day', TRUE),
(3, CURRENT_DATE - INTERVAL '2 day', TRUE),

(4, CURRENT_DATE, TRUE),
(4, CURRENT_DATE - INTERVAL '1 day', TRUE),

(5, CURRENT_DATE - INTERVAL '1 day', TRUE),
(5, CURRENT_DATE - INTERVAL '2 day', TRUE);

-- 10. SEED STUDY SESSIONS
INSERT INTO study_sessions (id, user_id, subject_id, task_id, start_time, end_time, duration_minutes, notes) VALUES
(1, 1, 4, 1, NOW() - INTERVAL '4 hour', NOW() - INTERVAL '2 hour 35 minute', 85, 'Read round robin and priority preemptive scheduling chapters'),
(2, 1, 3, 2, NOW() - INTERVAL '1 day 3 hour', NOW() - INTERVAL '1 day 2 hour', 60, 'Practiced SQL window functions and indexing strategies'),
(3, 1, 2, 4, NOW() - INTERVAL '2 day 4 hour', NOW() - INTERVAL '2 day 2 hour 30 minute', 90, 'Built JSP navigation components and JSTL custom formatters'),
(4, 1, 1, 5, NOW() - INTERVAL '3 day 5 hour', NOW() - INTERVAL '3 day 4 hour', 60, 'Studied TCP slow start, sliding window, and Congestion Avoidance algorithms'),
(5, 1, 5, 6, NOW() - INTERVAL '4 day 6 hour', NOW() - INTERVAL '4 day 4 hour 30 minute', 90, 'Solved DP matrix chain multiplication problems');

-- 11. SEED HOLIDAYS
INSERT INTO holidays (id, user_id, title, holiday_date, description, holiday_type) VALUES
(1, 1, 'College Founder Day', CURRENT_DATE + INTERVAL '14 day', 'Annual campus commemoration celebrations and exhibitions', 'College Holiday'),
(2, 1, 'Mid-Semester Break', CURRENT_DATE + INTERVAL '35 day', 'Institutional recess between terms', 'Vacation'),
(3, 1, 'National Youth Day', CURRENT_DATE + INTERVAL '50 day', 'Declared public holiday', 'Public Holiday');

-- 12. SEED EVENTS
INSERT INTO events (id, user_id, title, description, event_date, start_time, end_time, category, location) VALUES
(1, 1, 'Coding Club Hackathon Orientation', 'Briefing on team formation, problem statements, and evaluation criteria', CURRENT_DATE + INTERVAL '2 day', '16:00:00', '17:30:00', 'Club meeting', 'Auditorium-2'),
(2, 1, 'Web Tech Mini-Project Review 1', 'Component architecture demo, database schema review, and code walk-through', CURRENT_DATE + INTERVAL '5 day', '10:00:00', '11:00:00', 'Project review', 'Lab-2'),
(3, 1, 'Guest Lecture: Cloud Microservices', 'Industry session by Principal Architect on Kubernetes & Distributed Systems', CURRENT_DATE + INTERVAL '9 day', '14:00:00', '16:00:00', 'Seminar', 'Seminar Hall 1');

-- 13. SEED NOTIFICATIONS
INSERT INTO notifications (id, user_id, title, message, type, link, is_read) VALUES
(1, 1, 'Urgent: DBMS Assignment due tonight', 'Assignment submission portal closes at 23:59 tonight.', 'WARNING', 'tasks?action=list', FALSE),
(2, 1, 'Upcoming Exam: Web Technology CAT-I', 'Scheduled in 3 days (09:30 AM at LH-201).', 'ALERT', 'exams', FALSE),
(3, 1, 'Great Job on OS Record!', 'Completed task marked done with 85 study minutes logged.', 'SUCCESS', 'tasks?action=list', TRUE),
(4, 1, 'Weekly Timetable synchronized', 'Active lecture routine loaded for the current semester.', 'INFO', 'timetable', TRUE);

-- ============================================================
-- ADVANCE SERIAL SEQUENCES
-- Ensures subsequent INSERT statements generated by JDBC
-- don't collide with seed primary keys.
-- ============================================================
SELECT setval(pg_get_serial_sequence('users', 'id'), coalesce(max(id), 1)) FROM users;
SELECT setval(pg_get_serial_sequence('subjects', 'id'), coalesce(max(id), 1)) FROM subjects;
SELECT setval(pg_get_serial_sequence('tasks', 'id'), coalesce(max(id), 1)) FROM tasks;
SELECT setval(pg_get_serial_sequence('deadlines', 'id'), coalesce(max(id), 1)) FROM deadlines;
SELECT setval(pg_get_serial_sequence('exams', 'id'), coalesce(max(id), 1)) FROM exams;
SELECT setval(pg_get_serial_sequence('timetable', 'id'), coalesce(max(id), 1)) FROM timetable;
SELECT setval(pg_get_serial_sequence('plans', 'id'), coalesce(max(id), 1)) FROM plans;
SELECT setval(pg_get_serial_sequence('habits', 'id'), coalesce(max(id), 1)) FROM habits;
SELECT setval(pg_get_serial_sequence('habit_logs', 'id'), coalesce(max(id), 1)) FROM habit_logs;
SELECT setval(pg_get_serial_sequence('study_sessions', 'id'), coalesce(max(id), 1)) FROM study_sessions;
SELECT setval(pg_get_serial_sequence('holidays', 'id'), coalesce(max(id), 1)) FROM holidays;
SELECT setval(pg_get_serial_sequence('events', 'id'), coalesce(max(id), 1)) FROM events;
SELECT setval(pg_get_serial_sequence('notifications', 'id'), coalesce(max(id), 1)) FROM notifications;
