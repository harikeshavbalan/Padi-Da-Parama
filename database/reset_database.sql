-- ============================================================
-- STUDENT LIFE MANAGER - DATABASE RESET SCRIPT
-- WARNING: This will drop the database and all data!
-- Compatible with MySQL Workbench
-- ============================================================

DROP DATABASE IF EXISTS student_life_manager;
CREATE DATABASE student_life_manager
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE student_life_manager;

-- Now source schema.sql and seed.sql
-- In MySQL Workbench: Run schema.sql followed by seed.sql
