package com.studentlife.dao;

import com.studentlife.model.TimetableEntry;
import com.studentlife.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class TimetableDAO {
    private static final Logger LOGGER = Logger.getLogger(TimetableDAO.class.getName());

    public List<TimetableEntry> findAllByUserId(int userId) {
        List<TimetableEntry> list = new ArrayList<>();
        String sql = "SELECT t.*, s.name AS subject_name, s.course_code, s.color AS subject_color " +
                     "FROM timetable t " +
                     "JOIN subjects s ON t.subject_id = s.id " +
                     "WHERE t.user_id = ? " +
                     "ORDER BY CASE t.day_of_week " +
                     "  WHEN 'Monday' THEN 1 " +
                     "  WHEN 'Tuesday' THEN 2 " +
                     "  WHEN 'Wednesday' THEN 3 " +
                     "  WHEN 'Thursday' THEN 4 " +
                     "  WHEN 'Friday' THEN 5 " +
                     "  WHEN 'Saturday' THEN 6 " +
                     "  WHEN 'Sunday' THEN 7 " +
                     "  ELSE 8 END, " +
                     "t.start_time ASC";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToEntry(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching timetable for user: " + userId, e);
        }
        return list;
    }

    public List<TimetableEntry> findByDay(int userId, String dayOfWeek) {
        List<TimetableEntry> list = new ArrayList<>();
        String sql = "SELECT t.*, s.name AS subject_name, s.course_code, s.color AS subject_color " +
                     "FROM timetable t " +
                     "JOIN subjects s ON t.subject_id = s.id " +
                     "WHERE t.user_id = ? AND LOWER(t.day_of_week) = LOWER(?) " +
                     "ORDER BY t.start_time ASC";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, dayOfWeek);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToEntry(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching timetable by day: " + dayOfWeek, e);
        }
        return list;
    }

    public TimetableEntry findNextClass(int userId, String dayOfWeek, Time currentTime) {
        // First check remaining today
        String sqlToday = "SELECT t.*, s.name AS subject_name, s.course_code, s.color AS subject_color " +
                          "FROM timetable t " +
                          "JOIN subjects s ON t.subject_id = s.id " +
                          "WHERE t.user_id = ? AND LOWER(t.day_of_week) = LOWER(?) AND t.start_time >= ? " +
                          "ORDER BY t.start_time ASC LIMIT 1";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlToday)) {
            ps.setInt(1, userId);
            ps.setString(2, dayOfWeek);
            ps.setTime(3, currentTime);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToEntry(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Error finding next class today: " + e.getMessage());
        }

        // If no more classes today, get the first class for tomorrow or upcoming day
        String sqlNext = "SELECT t.*, s.name AS subject_name, s.course_code, s.color AS subject_color " +
                         "FROM timetable t " +
                         "JOIN subjects s ON t.subject_id = s.id " +
                         "WHERE t.user_id = ? " +
                         "ORDER BY CASE t.day_of_week " +
                         "  WHEN 'Monday' THEN 1 " +
                         "  WHEN 'Tuesday' THEN 2 " +
                         "  WHEN 'Wednesday' THEN 3 " +
                         "  WHEN 'Thursday' THEN 4 " +
                         "  WHEN 'Friday' THEN 5 " +
                         "  WHEN 'Saturday' THEN 6 " +
                         "  WHEN 'Sunday' THEN 7 " +
                         "  ELSE 8 END, " +
                         "t.start_time ASC LIMIT 1";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlNext)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToEntry(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error finding upcoming class: " + e.getMessage());
        }
        return null;
    }

    public boolean create(TimetableEntry entry) {
        String sql = "INSERT INTO timetable (user_id, subject_id, day_of_week, start_time, end_time, room, faculty) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, entry.getUserId());
            ps.setInt(2, entry.getSubjectId());
            ps.setString(3, entry.getDayOfWeek());
            ps.setTime(4, entry.getStartTime());
            ps.setTime(5, entry.getEndTime());
            ps.setString(6, entry.getRoom());
            ps.setString(7, entry.getFaculty());
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) entry.setId(rs.getInt(1));
                }
                return true;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error creating timetable entry", e);
        }
        return false;
    }

    public boolean update(TimetableEntry entry) {
        String sql = "UPDATE timetable SET subject_id = ?, day_of_week = ?, start_time = ?, end_time = ?, room = ?, faculty = ? " +
                     "WHERE id = ? AND user_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, entry.getSubjectId());
            ps.setString(2, entry.getDayOfWeek());
            ps.setTime(3, entry.getStartTime());
            ps.setTime(4, entry.getEndTime());
            ps.setString(5, entry.getRoom());
            ps.setString(6, entry.getFaculty());
            ps.setInt(7, entry.getId());
            ps.setInt(8, entry.getUserId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating timetable entry id: " + entry.getId(), e);
            return false;
        }
    }

    public boolean delete(int id, int userId) {
        String sql = "DELETE FROM timetable WHERE id = ? AND user_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error deleting timetable entry id: " + id, e);
            return false;
        }
    }

    private TimetableEntry mapRowToEntry(ResultSet rs) throws SQLException {
        TimetableEntry t = new TimetableEntry();
        t.setId(rs.getInt("id"));
        t.setUserId(rs.getInt("user_id"));
        t.setSubjectId(rs.getInt("subject_id"));
        t.setSubjectName(rs.getString("subject_name"));
        t.setCourseCode(rs.getString("course_code"));
        t.setSubjectColor(rs.getString("subject_color"));
        t.setDayOfWeek(rs.getString("day_of_week"));
        t.setStartTime(rs.getTime("start_time"));
        t.setEndTime(rs.getTime("end_time"));
        t.setRoom(rs.getString("room"));
        t.setFaculty(rs.getString("faculty"));
        t.setCreatedAt(rs.getTimestamp("created_at"));
        return t;
    }
}
