package com.studentlife.dao;

import com.studentlife.model.Exam;
import com.studentlife.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class ExamDAO {
    private static final Logger LOGGER = Logger.getLogger(ExamDAO.class.getName());

    public List<Exam> findAllByUserId(int userId) {
        List<Exam> list = new ArrayList<>();
        String sql = "SELECT e.*, s.name AS subject_name, s.color AS subject_color " +
                     "FROM exams e " +
                     "LEFT JOIN subjects s ON e.subject_id = s.id " +
                     "WHERE e.user_id = ? " +
                     "ORDER BY e.exam_date ASC, e.start_time ASC";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToExam(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching exams for user: " + userId, e);
        }
        return list;
    }

    public Exam findNextExam(int userId) {
        String sql = "SELECT e.*, s.name AS subject_name, s.color AS subject_color " +
                     "FROM exams e " +
                     "LEFT JOIN subjects s ON e.subject_id = s.id " +
                     "WHERE e.user_id = ? AND e.exam_date >= CURRENT_DATE " +
                     "ORDER BY e.exam_date ASC, e.start_time ASC LIMIT 1";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToExam(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching next exam for user: " + userId, e);
        }
        return null;
    }

    public Exam findById(int id, int userId) {
        String sql = "SELECT e.*, s.name AS subject_name, s.color AS subject_color " +
                     "FROM exams e " +
                     "LEFT JOIN subjects s ON e.subject_id = s.id " +
                     "WHERE e.id = ? AND e.user_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToExam(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching exam id: " + id, e);
        }
        return null;
    }

    public boolean create(Exam exam) {
        String sql = "INSERT INTO exams (user_id, subject_id, title, exam_type, exam_date, start_time, end_time, " +
                     "venue, syllabus, preparation_percentage, notes) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, exam.getUserId());
            if (exam.getSubjectId() != null && exam.getSubjectId() > 0) ps.setInt(2, exam.getSubjectId());
            else ps.setNull(2, Types.INTEGER);
            ps.setString(3, exam.getTitle());
            ps.setString(4, exam.getExamType());
            ps.setDate(5, exam.getExamDate());
            ps.setTime(6, exam.getStartTime());
            ps.setTime(7, exam.getEndTime());
            ps.setString(8, exam.getVenue());
            ps.setString(9, exam.getSyllabus());
            ps.setInt(10, exam.getPreparationPercentage());
            ps.setString(11, exam.getNotes());

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) exam.setId(rs.getInt(1));
                }
                return true;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error creating exam: " + exam.getTitle(), e);
        }
        return false;
    }

    public boolean update(Exam exam) {
        String sql = "UPDATE exams SET subject_id = ?, title = ?, exam_type = ?, exam_date = ?, start_time = ?, " +
                     "end_time = ?, venue = ?, syllabus = ?, preparation_percentage = ?, notes = ? " +
                     "WHERE id = ? AND user_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (exam.getSubjectId() != null && exam.getSubjectId() > 0) ps.setInt(1, exam.getSubjectId());
            else ps.setNull(1, Types.INTEGER);
            ps.setString(2, exam.getTitle());
            ps.setString(3, exam.getExamType());
            ps.setDate(4, exam.getExamDate());
            ps.setTime(5, exam.getStartTime());
            ps.setTime(6, exam.getEndTime());
            ps.setString(7, exam.getVenue());
            ps.setString(8, exam.getSyllabus());
            ps.setInt(9, exam.getPreparationPercentage());
            ps.setString(10, exam.getNotes());
            ps.setInt(11, exam.getId());
            ps.setInt(12, exam.getUserId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating exam id: " + exam.getId(), e);
            return false;
        }
    }

    public boolean delete(int id, int userId) {
        String sql = "DELETE FROM exams WHERE id = ? AND user_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error deleting exam id: " + id, e);
            return false;
        }
    }

    public boolean updatePreparation(int id, int userId, int percentage) {
        String sql = "UPDATE exams SET preparation_percentage = ? WHERE id = ? AND user_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, Math.min(100, Math.max(0, percentage)));
            ps.setInt(2, id);
            ps.setInt(3, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating preparation percentage for exam: " + id, e);
            return false;
        }
    }

    private Exam mapRowToExam(ResultSet rs) throws SQLException {
        Exam e = new Exam();
        e.setId(rs.getInt("id"));
        e.setUserId(rs.getInt("user_id"));
        int sid = rs.getInt("subject_id");
        if (!rs.wasNull()) e.setSubjectId(sid);
        try {
            e.setSubjectName(rs.getString("subject_name"));
            e.setSubjectColor(rs.getString("subject_color"));
        } catch (SQLException ignored) {}
        e.setTitle(rs.getString("title"));
        e.setExamType(rs.getString("exam_type"));
        e.setExamDate(rs.getDate("exam_date"));
        e.setStartTime(rs.getTime("start_time"));
        e.setEndTime(rs.getTime("end_time"));
        e.setVenue(rs.getString("venue"));
        e.setSyllabus(rs.getString("syllabus"));
        e.setPreparationPercentage(rs.getInt("preparation_percentage"));
        e.setNotes(rs.getString("notes"));
        e.setCreatedAt(rs.getTimestamp("created_at"));
        e.setUpdatedAt(rs.getTimestamp("updated_at"));
        return e;
    }
}
