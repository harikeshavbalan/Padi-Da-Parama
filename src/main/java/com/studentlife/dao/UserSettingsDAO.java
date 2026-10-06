package com.studentlife.dao;

import com.studentlife.model.UserSettings;
import com.studentlife.util.DatabaseConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

public class UserSettingsDAO {
    private static final Logger LOGGER = Logger.getLogger(UserSettingsDAO.class.getName());

    public UserSettings findByUserId(int userId) {
        String sql = "SELECT * FROM user_settings WHERE user_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    UserSettings s = new UserSettings();
                    s.setUserId(rs.getInt("user_id"));
                    s.setDefaultPriority(rs.getString("default_priority"));
                    s.setWeekStartDay(rs.getString("week_start_day"));
                    s.setRemindersEnabled(rs.getBoolean("reminders_enabled"));
                    s.setThemePreference(rs.getString("theme_preference"));
                    s.setUpdatedAt(rs.getTimestamp("updated_at"));
                    return s;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching settings for user: " + userId, e);
        }
        // return default instance if not found
        UserSettings def = new UserSettings();
        def.setUserId(userId);
        return def;
    }

    public boolean saveOrUpdate(UserSettings s) {
        String updateSql = "UPDATE user_settings SET default_priority = ?, week_start_day = ?, " +
                           "reminders_enabled = ?, theme_preference = ? WHERE user_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(updateSql)) {
            ps.setString(1, s.getDefaultPriority());
            ps.setString(2, s.getWeekStartDay());
            ps.setBoolean(3, s.isRemindersEnabled());
            ps.setString(4, s.getThemePreference());
            ps.setInt(5, s.getUserId());
            int updated = ps.executeUpdate();
            if (updated > 0) return true;

            String insertSql = "INSERT INTO user_settings (user_id, default_priority, week_start_day, reminders_enabled, theme_preference) " +
                               "VALUES (?, ?, ?, ?, ?)";
            try (PreparedStatement inPs = conn.prepareStatement(insertSql)) {
                inPs.setInt(1, s.getUserId());
                inPs.setString(2, s.getDefaultPriority());
                inPs.setString(3, s.getWeekStartDay());
                inPs.setBoolean(4, s.isRemindersEnabled());
                inPs.setString(5, s.getThemePreference());
                return inPs.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error saving settings for user: " + s.getUserId(), e);
            return false;
        }
    }
}
