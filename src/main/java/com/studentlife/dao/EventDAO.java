package com.studentlife.dao;

import com.studentlife.model.Event;
import com.studentlife.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class EventDAO {
    private static final Logger LOGGER = Logger.getLogger(EventDAO.class.getName());

    public List<Event> findAllByUserId(int userId) {
        List<Event> list = new ArrayList<>();
        String sql = "SELECT * FROM events WHERE user_id = ? ORDER BY event_date ASC, start_time ASC";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToEvent(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching events for user: " + userId, e);
        }
        return list;
    }

    public Event findNextEvent(int userId) {
        String sql = "SELECT * FROM events WHERE user_id = ? AND event_date >= CURRENT_DATE " +
                     "ORDER BY event_date ASC, start_time ASC LIMIT 1";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToEvent(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching next event for user: " + userId, e);
        }
        return null;
    }

    public boolean create(Event event) {
        String sql = "INSERT INTO events (user_id, title, description, event_date, start_time, end_time, category, location) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, event.getUserId());
            ps.setString(2, event.getTitle());
            ps.setString(3, event.getDescription());
            ps.setDate(4, event.getEventDate());
            ps.setTime(5, event.getStartTime());
            ps.setTime(6, event.getEndTime());
            ps.setString(7, event.getCategory());
            ps.setString(8, event.getLocation());

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) event.setId(rs.getInt(1));
                }
                return true;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error creating event: " + event.getTitle(), ex);
        }
        return false;
    }

    public boolean update(Event event) {
        String sql = "UPDATE events SET title = ?, description = ?, event_date = ?, start_time = ?, " +
                     "end_time = ?, category = ?, location = ? WHERE id = ? AND user_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, event.getTitle());
            ps.setString(2, event.getDescription());
            ps.setDate(3, event.getEventDate());
            ps.setTime(4, event.getStartTime());
            ps.setTime(5, event.getEndTime());
            ps.setString(6, event.getCategory());
            ps.setString(7, event.getLocation());
            ps.setInt(8, event.getId());
            ps.setInt(9, event.getUserId());
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error updating event id: " + event.getId(), ex);
            return false;
        }
    }

    public boolean delete(int id, int userId) {
        String sql = "DELETE FROM events WHERE id = ? AND user_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error deleting event id: " + id, e);
            return false;
        }
    }

    private Event mapRowToEvent(ResultSet rs) throws SQLException {
        Event e = new Event();
        e.setId(rs.getInt("id"));
        e.setUserId(rs.getInt("user_id"));
        e.setTitle(rs.getString("title"));
        e.setDescription(rs.getString("description"));
        e.setEventDate(rs.getDate("event_date"));
        e.setStartTime(rs.getTime("start_time"));
        e.setEndTime(rs.getTime("end_time"));
        e.setCategory(rs.getString("category"));
        e.setLocation(rs.getString("location"));
        e.setCreatedAt(rs.getTimestamp("created_at"));
        return e;
    }
}
