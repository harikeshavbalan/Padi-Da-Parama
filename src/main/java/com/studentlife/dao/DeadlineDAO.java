package com.studentlife.dao;

import com.studentlife.model.Deadline;
import com.studentlife.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class DeadlineDAO {
    private static final Logger LOGGER = Logger.getLogger(DeadlineDAO.class.getName());

    public List<Deadline> findAllByUserId(int userId) {
        List<Deadline> list = new ArrayList<>();
        String sql = "SELECT d.*, s.name AS subject_name " +
                     "FROM deadlines d " +
                     "LEFT JOIN subjects s ON d.subject_id = s.id " +
                     "WHERE d.user_id = ? " +
                     "ORDER BY d.status ASC, d.due_date ASC, d.due_time ASC";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToDeadline(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching deadlines for user: " + userId, e);
        }
        return list;
    }

    public Deadline findNextDeadline(int userId) {
        String sql = "SELECT d.*, s.name AS subject_name " +
                     "FROM deadlines d " +
                     "LEFT JOIN subjects s ON d.subject_id = s.id " +
                     "WHERE d.user_id = ? AND d.status = 'PENDING' AND d.due_date >= CURRENT_DATE " +
                     "ORDER BY d.due_date ASC, d.due_time ASC LIMIT 1";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToDeadline(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching next deadline for user: " + userId, e);
        }
        return null;
    }

    public boolean create(Deadline d) {
        String sql = "INSERT INTO deadlines (user_id, subject_id, task_id, title, due_date, due_time, priority, status) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, d.getUserId());
            if (d.getSubjectId() != null && d.getSubjectId() > 0) ps.setInt(2, d.getSubjectId());
            else ps.setNull(2, Types.INTEGER);
            if (d.getTaskId() != null && d.getTaskId() > 0) ps.setInt(3, d.getTaskId());
            else ps.setNull(3, Types.INTEGER);
            ps.setString(4, d.getTitle());
            ps.setDate(5, d.getDueDate());
            ps.setTime(6, d.getDueTime());
            ps.setString(7, d.getPriority());
            ps.setString(8, d.getStatus());
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) d.setId(rs.getInt(1));
                }
                return true;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error creating deadline: " + d.getTitle(), e);
        }
        return false;
    }

    public boolean delete(int id, int userId) {
        String sql = "DELETE FROM deadlines WHERE id = ? AND user_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error deleting deadline id: " + id, e);
            return false;
        }
    }

    public boolean toggleStatus(int id, int userId) {
        String sql = "UPDATE deadlines SET status = CASE WHEN status = 'COMPLETED' THEN 'PENDING' ELSE 'COMPLETED' END " +
                     "WHERE id = ? AND user_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error toggling deadline id: " + id, e);
            return false;
        }
    }

    private Deadline mapRowToDeadline(ResultSet rs) throws SQLException {
        Deadline d = new Deadline();
        d.setId(rs.getInt("id"));
        d.setUserId(rs.getInt("user_id"));
        int sid = rs.getInt("subject_id");
        if (!rs.wasNull()) d.setSubjectId(sid);
        int tid = rs.getInt("task_id");
        if (!rs.wasNull()) d.setTaskId(tid);
        try {
            d.setSubjectName(rs.getString("subject_name"));
        } catch (SQLException ignored) {}
        d.setTitle(rs.getString("title"));
        d.setDueDate(rs.getDate("due_date"));
        d.setDueTime(rs.getTime("due_time"));
        d.setPriority(rs.getString("priority"));
        d.setStatus(rs.getString("status"));
        d.setCreatedAt(rs.getTimestamp("created_at"));
        return d;
    }
}
