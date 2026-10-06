package com.studentlife.dao;

import com.studentlife.model.Notification;
import com.studentlife.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class NotificationDAO {
    private static final Logger LOGGER = Logger.getLogger(NotificationDAO.class.getName());

    public List<Notification> findAllByUserId(int userId) {
        List<Notification> list = new ArrayList<>();
        String sql = "SELECT * FROM notifications WHERE user_id = ? ORDER BY is_read ASC, created_at DESC LIMIT 20";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToNotification(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching notifications for user: " + userId, e);
        }
        return list;
    }

    public int getUnreadCount(int userId) {
        String sql = "SELECT COUNT(*) FROM notifications WHERE user_id = ? AND is_read = FALSE";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching unread notification count", e);
        }
        return 0;
    }

    public boolean markAsRead(int id, int userId) {
        String sql = "UPDATE notifications SET is_read = TRUE WHERE id = ? AND user_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error marking notification as read: " + id, e);
            return false;
        }
    }

    public boolean markAllAsRead(int userId) {
        String sql = "UPDATE notifications SET is_read = TRUE WHERE user_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error marking all notifications as read for user: " + userId, e);
            return false;
        }
    }

    public boolean create(Notification n) {
        String sql = "INSERT INTO notifications (user_id, title, message, type, link, is_read) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, n.getUserId());
            ps.setString(2, n.getTitle());
            ps.setString(3, n.getMessage());
            ps.setString(4, n.getType());
            ps.setString(5, n.getLink());
            ps.setBoolean(6, n.isRead());
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) n.setId(rs.getInt(1));
                }
                return true;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error creating notification: " + n.getTitle(), e);
        }
        return false;
    }

    private Notification mapRowToNotification(ResultSet rs) throws SQLException {
        Notification n = new Notification();
        n.setId(rs.getInt("id"));
        n.setUserId(rs.getInt("user_id"));
        n.setTitle(rs.getString("title"));
        n.setMessage(rs.getString("message"));
        n.setType(rs.getString("type"));
        n.setLink(rs.getString("link"));
        n.setRead(rs.getBoolean("is_read"));
        n.setCreatedAt(rs.getTimestamp("created_at"));
        return n;
    }
}
