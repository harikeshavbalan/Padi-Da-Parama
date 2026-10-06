package com.studentlife.dao;

import com.studentlife.model.StudySession;
import com.studentlife.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

public class StudySessionDAO {
    private static final Logger LOGGER = Logger.getLogger(StudySessionDAO.class.getName());

    public List<StudySession> findAllByUserId(int userId) {
        List<StudySession> list = new ArrayList<>();
        String sql = "SELECT ss.*, s.name AS subject_name, t.title AS task_title " +
                     "FROM study_sessions ss " +
                     "LEFT JOIN subjects s ON ss.subject_id = s.id " +
                     "LEFT JOIN tasks t ON ss.task_id = t.id " +
                     "WHERE ss.user_id = ? " +
                     "ORDER BY ss.start_time DESC";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToSession(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching study sessions for user: " + userId, e);
        }
        return list;
    }

    public boolean create(StudySession ss) {
        String sql = "INSERT INTO study_sessions (user_id, subject_id, task_id, start_time, end_time, duration_minutes, notes) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, ss.getUserId());
            if (ss.getSubjectId() != null && ss.getSubjectId() > 0) ps.setInt(2, ss.getSubjectId());
            else ps.setNull(2, Types.INTEGER);
            if (ss.getTaskId() != null && ss.getTaskId() > 0) ps.setInt(3, ss.getTaskId());
            else ps.setNull(3, Types.INTEGER);
            ps.setTimestamp(4, ss.getStartTime());
            ps.setTimestamp(5, ss.getEndTime());
            ps.setInt(6, ss.getDurationMinutes());
            ps.setString(7, ss.getNotes());

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) ss.setId(rs.getInt(1));
                }
                // Also add duration to actual_minutes in task if linked
                if (ss.getTaskId() != null && ss.getTaskId() > 0) {
                    String taskSql = "UPDATE tasks SET actual_minutes = actual_minutes + ? WHERE id = ? AND user_id = ?";
                    try (PreparedStatement tPs = conn.prepareStatement(taskSql)) {
                        tPs.setInt(1, ss.getDurationMinutes());
                        tPs.setInt(2, ss.getTaskId());
                        tPs.setInt(3, ss.getUserId());
                        tPs.executeUpdate();
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error creating study session", e);
        }
        return false;
    }

    public boolean delete(int id, int userId) {
        String sql = "DELETE FROM study_sessions WHERE id = ? AND user_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error deleting study session id: " + id, e);
            return false;
        }
    }

    public int getTodayMinutes(int userId) {
        String sql = "SELECT COALESCE(SUM(duration_minutes), 0) FROM study_sessions " +
                     "WHERE user_id = ? AND start_time >= ? AND start_time < ?";
        java.time.LocalDate today = java.time.LocalDate.now();
        Timestamp start = Timestamp.valueOf(today.atStartOfDay());
        Timestamp end = Timestamp.valueOf(today.plusDays(1).atStartOfDay());
        return queryMinutesRange(sql, userId, start, end);
    }

    public int getWeekMinutes(int userId) {
        String sql = "SELECT COALESCE(SUM(duration_minutes), 0) FROM study_sessions " +
                     "WHERE user_id = ? AND start_time >= ? AND start_time < ?";
        java.time.LocalDate today = java.time.LocalDate.now();
        java.time.LocalDate monday = today.with(java.time.temporal.TemporalAdjusters.previousOrSame(java.time.DayOfWeek.MONDAY));
        Timestamp start = Timestamp.valueOf(monday.atStartOfDay());
        Timestamp end = Timestamp.valueOf(monday.plusDays(7).atStartOfDay());
        return queryMinutesRange(sql, userId, start, end);
    }

    public int getMonthMinutes(int userId) {
        String sql = "SELECT COALESCE(SUM(duration_minutes), 0) FROM study_sessions " +
                     "WHERE user_id = ? AND start_time >= ? AND start_time < ?";
        java.time.LocalDate today = java.time.LocalDate.now();
        java.time.LocalDate firstDay = today.withDayOfMonth(1);
        Timestamp start = Timestamp.valueOf(firstDay.atStartOfDay());
        Timestamp end = Timestamp.valueOf(firstDay.plusMonths(1).atStartOfDay());
        return queryMinutesRange(sql, userId, start, end);
    }

    public Map<String, Integer> getSubjectWiseStudyMinutes(int userId) {
        Map<String, Integer> map = new HashMap<>();
        String sql = "SELECT COALESCE(s.name, 'General Study') AS subject_name, SUM(ss.duration_minutes) AS total_min " +
                     "FROM study_sessions ss " +
                     "LEFT JOIN subjects s ON ss.subject_id = s.id " +
                     "WHERE ss.user_id = ? " +
                     "GROUP BY ss.subject_id, s.name";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    map.put(rs.getString("subject_name"), rs.getInt("total_min"));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting subject-wise study time", e);
        }
        return map;
    }

    private int queryMinutesRange(String sql, int userId, Timestamp start, Timestamp end) {
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setTimestamp(2, start);
            ps.setTimestamp(3, end);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error querying minutes range: " + sql, e);
        }
        return 0;
    }

    private StudySession mapRowToSession(ResultSet rs) throws SQLException {
        StudySession ss = new StudySession();
        ss.setId(rs.getInt("id"));
        ss.setUserId(rs.getInt("user_id"));
        int sid = rs.getInt("subject_id");
        if (!rs.wasNull()) ss.setSubjectId(sid);
        int tid = rs.getInt("task_id");
        if (!rs.wasNull()) ss.setTaskId(tid);
        try {
            ss.setSubjectName(rs.getString("subject_name"));
            ss.setTaskTitle(rs.getString("task_title"));
        } catch (SQLException ignored) {}
        ss.setStartTime(rs.getTimestamp("start_time"));
        ss.setEndTime(rs.getTimestamp("end_time"));
        ss.setDurationMinutes(rs.getInt("duration_minutes"));
        ss.setNotes(rs.getString("notes"));
        ss.setCreatedAt(rs.getTimestamp("created_at"));
        return ss;
    }
}
