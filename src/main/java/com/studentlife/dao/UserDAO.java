package com.studentlife.dao;

import com.studentlife.model.User;
import com.studentlife.util.DatabaseConnection;

import java.sql.*;
import java.util.logging.Level;
import java.util.logging.Logger;

public class UserDAO {
    private static final Logger LOGGER = Logger.getLogger(UserDAO.class.getName());

    public User findByUsername(String username) {
        String sql = "SELECT id, username, email, password_hash, full_name, created_at, updated_at " +
                     "FROM users WHERE username = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToUser(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error finding user by username: " + username, e);
        }
        return null;
    }

    public User findById(int id) {
        String sql = "SELECT id, username, email, password_hash, full_name, created_at, updated_at " +
                     "FROM users WHERE id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToUser(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error finding user by id: " + id, e);
        }
        return null;
    }

    public User findByEmail(String email) {
        String sql = "SELECT id, username, email, password_hash, full_name, created_at, updated_at " +
                     "FROM users WHERE email = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToUser(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error finding user by email: " + email, e);
        }
        return null;
    }

    public boolean create(User user) {
        String sql = "INSERT INTO users (username, email, password_hash, full_name) VALUES (?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, user.getUsername());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPasswordHash());
            ps.setString(4, user.getFullName());
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        user.setId(rs.getInt(1));
                    }
                }
                // Also create default settings for this user
                initDefaultSettings(user.getId(), conn);
                return true;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error creating user: " + user.getUsername(), e);
        }
        return false;
    }

    public boolean updateProfile(int userId, String fullName, String email) {
        String sql = "UPDATE users SET full_name = ?, email = ? WHERE id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, fullName);
            ps.setString(2, email);
            ps.setInt(3, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating profile for user id: " + userId, e);
            return false;
        }
    }

    public boolean updatePassword(int userId, String newPasswordHash) {
        String sql = "UPDATE users SET password_hash = ? WHERE id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newPasswordHash);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating password for user id: " + userId, e);
            return false;
        }
    }

    private void initDefaultSettings(int userId, Connection conn) {
        String checkSql = "SELECT 1 FROM user_settings WHERE user_id = ?";
        try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
            checkPs.setInt(1, userId);
            try (ResultSet rs = checkPs.executeQuery()) {
                if (!rs.next()) {
                    String sql = "INSERT INTO user_settings (user_id, default_priority, week_start_day, reminders_enabled, theme_preference) " +
                                 "VALUES (?, 'MEDIUM', 'Monday', TRUE, 'dark')";
                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                        ps.setInt(1, userId);
                        ps.executeUpdate();
                    }
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Could not initialize default settings for user " + userId, e);
        }
    }

    private User mapRowToUser(ResultSet rs) throws SQLException {
        User u = new User();
        u.setId(rs.getInt("id"));
        u.setUsername(rs.getString("username"));
        u.setEmail(rs.getString("email"));
        u.setPasswordHash(rs.getString("password_hash"));
        u.setFullName(rs.getString("full_name"));
        u.setCreatedAt(rs.getTimestamp("created_at"));
        u.setUpdatedAt(rs.getTimestamp("updated_at"));
        return u;
    }
}
