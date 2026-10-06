package com.studentlife.dao;

import com.studentlife.model.Plan;
import com.studentlife.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class PlanDAO {
    private static final Logger LOGGER = Logger.getLogger(PlanDAO.class.getName());

    public List<Plan> findAllByUserId(int userId) {
        List<Plan> list = new ArrayList<>();
        String sql = "SELECT * FROM plans WHERE user_id = ? " +
                     "ORDER BY CASE status " +
                     "  WHEN 'ACTIVE' THEN 1 " +
                     "  WHEN 'PLANNED' THEN 2 " +
                     "  WHEN 'PAUSED' THEN 3 " +
                     "  WHEN 'COMPLETED' THEN 4 " +
                     "  WHEN 'CANCELLED' THEN 5 " +
                     "  ELSE 6 END, target_date ASC";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToPlan(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching plans for user: " + userId, e);
        }
        return list;
    }

    public Plan findById(int id, int userId) {
        String sql = "SELECT * FROM plans WHERE id = ? AND user_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToPlan(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error finding plan id: " + id, e);
        }
        return null;
    }

    public boolean create(Plan p) {
        String sql = "INSERT INTO plans (user_id, title, description, start_date, target_date, priority, progress, status) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, p.getUserId());
            ps.setString(2, p.getTitle());
            ps.setString(3, p.getDescription());
            ps.setDate(4, p.getStartDate());
            ps.setDate(5, p.getTargetDate());
            ps.setString(6, p.getPriority());
            ps.setInt(7, p.getProgress());
            ps.setString(8, p.getStatus());

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) p.setId(rs.getInt(1));
                }
                return true;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error creating plan: " + p.getTitle(), e);
        }
        return false;
    }

    public boolean update(Plan p) {
        String sql = "UPDATE plans SET title = ?, description = ?, start_date = ?, target_date = ?, " +
                     "priority = ?, progress = ?, status = ? WHERE id = ? AND user_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, p.getTitle());
            ps.setString(2, p.getDescription());
            ps.setDate(3, p.getStartDate());
            ps.setDate(4, p.getTargetDate());
            ps.setString(5, p.getPriority());
            ps.setInt(6, p.getProgress());
            ps.setString(7, p.getStatus());
            ps.setInt(8, p.getId());
            ps.setInt(9, p.getUserId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating plan id: " + p.getId(), e);
            return false;
        }
    }

    public boolean delete(int id, int userId) {
        String sql = "DELETE FROM plans WHERE id = ? AND user_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error deleting plan id: " + id, e);
            return false;
        }
    }

    public boolean updateProgress(int id, int userId, int progress, String status) {
        String sql = "UPDATE plans SET progress = ?, status = ? WHERE id = ? AND user_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, Math.min(100, Math.max(0, progress)));
            ps.setString(2, status != null ? status : (progress >= 100 ? "COMPLETED" : "ACTIVE"));
            ps.setInt(3, id);
            ps.setInt(4, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating plan progress id: " + id, e);
            return false;
        }
    }

    private Plan mapRowToPlan(ResultSet rs) throws SQLException {
        Plan p = new Plan();
        p.setId(rs.getInt("id"));
        p.setUserId(rs.getInt("user_id"));
        p.setTitle(rs.getString("title"));
        p.setDescription(rs.getString("description"));
        p.setStartDate(rs.getDate("start_date"));
        p.setTargetDate(rs.getDate("target_date"));
        p.setPriority(rs.getString("priority"));
        p.setProgress(rs.getInt("progress"));
        p.setStatus(rs.getString("status"));
        p.setCreatedAt(rs.getTimestamp("created_at"));
        p.setUpdatedAt(rs.getTimestamp("updated_at"));
        return p;
    }
}
