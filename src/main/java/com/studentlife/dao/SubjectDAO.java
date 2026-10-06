package com.studentlife.dao;

import com.studentlife.model.Subject;
import com.studentlife.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class SubjectDAO {
    private static final Logger LOGGER = Logger.getLogger(SubjectDAO.class.getName());

    public List<Subject> findAllByUserId(int userId) {
        List<Subject> list = new ArrayList<>();
        String sql = "SELECT id, user_id, name, course_code, faculty, room, credits, color, created_at, updated_at " +
                     "FROM subjects WHERE user_id = ? ORDER BY name ASC";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToSubject(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching subjects for user: " + userId, e);
        }
        return list;
    }

    public List<Subject> findSummariesWithStats(int userId) {
        List<Subject> list = new ArrayList<>();
        String sql = "SELECT s.id, s.user_id, s.name, s.course_code, s.faculty, s.room, s.credits, s.color, s.created_at, s.updated_at, " +
                     "  (SELECT COUNT(*) FROM tasks t WHERE t.subject_id = s.id AND t.user_id = s.user_id) AS task_count, " +
                     "  (SELECT COUNT(*) FROM tasks t WHERE t.subject_id = s.id AND t.user_id = s.user_id AND t.status = 'COMPLETED') AS completed_task_count, " +
                     "  (SELECT COALESCE(SUM(ss.duration_minutes), 0) FROM study_sessions ss WHERE ss.subject_id = s.id AND ss.user_id = s.user_id) AS study_minutes, " +
                     "  (SELECT MIN(e.exam_date) FROM exams e WHERE e.subject_id = s.id AND e.user_id = s.user_id AND e.exam_date >= CURRENT_DATE) AS next_exam_date " +
                     "FROM subjects s WHERE s.user_id = ? ORDER BY s.name ASC";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Subject s = mapRowToSubject(rs);
                    s.setTaskCount(rs.getInt("task_count"));
                    s.setCompletedTaskCount(rs.getInt("completed_task_count"));
                    s.setStudyMinutes(rs.getInt("study_minutes"));
                    Date nextExam = rs.getDate("next_exam_date");
                    s.setNextExamDate(nextExam != null ? nextExam.toString() : "None upcoming");
                    list.add(s);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching subject summaries for user: " + userId, e);
        }
        return list;
    }

    public Subject findById(int id, int userId) {
        String sql = "SELECT id, user_id, name, course_code, faculty, room, credits, color, created_at, updated_at " +
                     "FROM subjects WHERE id = ? AND user_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToSubject(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error finding subject id: " + id, e);
        }
        return null;
    }

    public Subject findByName(String name, int userId) {
        String sql = "SELECT id, user_id, name, course_code, faculty, room, credits, color, created_at, updated_at " +
                     "FROM subjects WHERE LOWER(TRIM(name)) = LOWER(TRIM(?)) AND user_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToSubject(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error finding subject by name: " + name, e);
        }
        return null;
    }

    public boolean create(Subject subject) {
        String sql = "INSERT INTO subjects (user_id, name, course_code, faculty, room, credits, color) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, subject.getUserId());
            ps.setString(2, subject.getName());
            ps.setString(3, subject.getCourseCode());
            ps.setString(4, subject.getFaculty());
            ps.setString(5, subject.getRoom());
            ps.setInt(6, subject.getCredits());
            ps.setString(7, subject.getColor());
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) subject.setId(rs.getInt(1));
                }
                return true;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error creating subject: " + subject.getName(), e);
        }
        return false;
    }

    public boolean update(Subject subject) {
        String sql = "UPDATE subjects SET name = ?, course_code = ?, faculty = ?, room = ?, credits = ?, color = ? " +
                     "WHERE id = ? AND user_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, subject.getName());
            ps.setString(2, subject.getCourseCode());
            ps.setString(3, subject.getFaculty());
            ps.setString(4, subject.getRoom());
            ps.setInt(5, subject.getCredits());
            ps.setString(6, subject.getColor());
            ps.setInt(7, subject.getId());
            ps.setInt(8, subject.getUserId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating subject id: " + subject.getId(), e);
            return false;
        }
    }

    public boolean delete(int id, int userId) {
        String sql = "DELETE FROM subjects WHERE id = ? AND user_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error deleting subject id: " + id, e);
            return false;
        }
    }

    private Subject mapRowToSubject(ResultSet rs) throws SQLException {
        Subject s = new Subject();
        s.setId(rs.getInt("id"));
        s.setUserId(rs.getInt("user_id"));
        s.setName(rs.getString("name"));
        s.setCourseCode(rs.getString("course_code"));
        s.setFaculty(rs.getString("faculty"));
        s.setRoom(rs.getString("room"));
        s.setCredits(rs.getInt("credits"));
        s.setColor(rs.getString("color"));
        s.setCreatedAt(rs.getTimestamp("created_at"));
        s.setUpdatedAt(rs.getTimestamp("updated_at"));
        return s;
    }
}
