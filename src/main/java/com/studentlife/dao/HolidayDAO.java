package com.studentlife.dao;

import com.studentlife.model.Holiday;
import com.studentlife.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class HolidayDAO {
    private static final Logger LOGGER = Logger.getLogger(HolidayDAO.class.getName());

    public List<Holiday> findAllByUserId(int userId) {
        List<Holiday> list = new ArrayList<>();
        String sql = "SELECT * FROM holidays WHERE user_id = ? ORDER BY holiday_date ASC";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToHoliday(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching holidays for user: " + userId, e);
        }
        return list;
    }

    public Holiday findNextHoliday(int userId) {
        String sql = "SELECT * FROM holidays WHERE user_id = ? AND holiday_date >= CURRENT_DATE " +
                     "ORDER BY holiday_date ASC LIMIT 1";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToHoliday(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching next holiday for user: " + userId, e);
        }
        return null;
    }

    public boolean create(Holiday h) {
        String sql = "INSERT INTO holidays (user_id, title, holiday_date, description, holiday_type) " +
                     "VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, h.getUserId());
            ps.setString(2, h.getTitle());
            ps.setDate(3, h.getHolidayDate());
            ps.setString(4, h.getDescription());
            ps.setString(5, h.getHolidayType());

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) h.setId(rs.getInt(1));
                }
                return true;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error creating holiday: " + h.getTitle(), e);
        }
        return false;
    }

    public boolean update(Holiday h) {
        String sql = "UPDATE holidays SET title = ?, holiday_date = ?, description = ?, holiday_type = ? " +
                     "WHERE id = ? AND user_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, h.getTitle());
            ps.setDate(2, h.getHolidayDate());
            ps.setString(3, h.getDescription());
            ps.setString(4, h.getHolidayType());
            ps.setInt(5, h.getId());
            ps.setInt(6, h.getUserId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating holiday id: " + h.getId(), e);
            return false;
        }
    }

    public boolean delete(int id, int userId) {
        String sql = "DELETE FROM holidays WHERE id = ? AND user_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error deleting holiday id: " + id, e);
            return false;
        }
    }

    private Holiday mapRowToHoliday(ResultSet rs) throws SQLException {
        Holiday h = new Holiday();
        h.setId(rs.getInt("id"));
        h.setUserId(rs.getInt("user_id"));
        h.setTitle(rs.getString("title"));
        h.setHolidayDate(rs.getDate("holiday_date"));
        h.setDescription(rs.getString("description"));
        h.setHolidayType(rs.getString("holiday_type"));
        h.setCreatedAt(rs.getTimestamp("created_at"));
        return h;
    }
}
