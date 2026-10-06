package com.studentlife.dao;

import com.studentlife.model.Task;
import com.studentlife.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class TaskDAO {
    private static final Logger LOGGER = Logger.getLogger(TaskDAO.class.getName());

    public List<Task> findAllByUserId(int userId) {
        return findFiltered(userId, null, null, null, null, null, "due_date ASC");
    }

    public List<Task> findTodayTasks(int userId) {
        List<Task> list = new ArrayList<>();
        String sql = "SELECT t.*, s.name AS subject_name, s.color AS subject_color " +
                     "FROM tasks t " +
                     "LEFT JOIN subjects s ON t.subject_id = s.id " +
                     "WHERE t.user_id = ? AND t.due_date = CURRENT_DATE " +
                     "ORDER BY t.status DESC, t.priority DESC, t.due_time ASC";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToTask(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching today tasks for user: " + userId, e);
        }
        return list;
    }

    public List<Task> findFiltered(int userId, String search, String category, String priority,
                                   String status, Integer subjectId, String sortBy) {
        List<Task> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT t.*, s.name AS subject_name, s.color AS subject_color " +
                "FROM tasks t " +
                "LEFT JOIN subjects s ON t.subject_id = s.id " +
                "WHERE t.user_id = ? "
        );

        List<Object> params = new ArrayList<>();
        params.add(userId);

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (LOWER(t.title) LIKE ? OR LOWER(t.description) LIKE ?) ");
            String term = "%" + search.trim().toLowerCase() + "%";
            params.add(term);
            params.add(term);
        }
        if (category != null && !category.trim().isEmpty() && !"ALL".equalsIgnoreCase(category)) {
            sql.append("AND t.category = ? ");
            params.add(category.trim());
        }
        if (priority != null && !priority.trim().isEmpty() && !"ALL".equalsIgnoreCase(priority)) {
            sql.append("AND t.priority = ? ");
            params.add(priority.trim());
        }
        if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status)) {
            if ("OVERDUE".equalsIgnoreCase(status)) {
                sql.append("AND t.status != 'COMPLETED' AND t.due_date < CURRENT_DATE ");
            } else {
                sql.append("AND t.status = ? ");
                params.add(status.trim());
            }
        }
        if (subjectId != null && subjectId > 0) {
            sql.append("AND t.subject_id = ? ");
            params.add(subjectId);
        }

        // Sorting
        if ("priority".equalsIgnoreCase(sortBy)) {
            sql.append("ORDER BY CASE t.priority " +
                       "WHEN 'URGENT' THEN 1 " +
                       "WHEN 'HIGH' THEN 2 " +
                       "WHEN 'MEDIUM' THEN 3 " +
                       "WHEN 'LOW' THEN 4 " +
                       "ELSE 5 END, t.due_date ASC ");
        } else if ("title".equalsIgnoreCase(sortBy)) {
            sql.append("ORDER BY t.title ASC ");
        } else if ("created".equalsIgnoreCase(sortBy)) {
            sql.append("ORDER BY t.created_at DESC ");
        } else {
            // default by due date
            sql.append("ORDER BY (t.due_date IS NULL), t.due_date ASC, t.due_time ASC ");
        }

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToTask(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error executing findFiltered tasks query", e);
        }
        return list;
    }

    public Task findById(int id, int userId) {
        String sql = "SELECT t.*, s.name AS subject_name, s.color AS subject_color " +
                     "FROM tasks t " +
                     "LEFT JOIN subjects s ON t.subject_id = s.id " +
                     "WHERE t.id = ? AND t.user_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToTask(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error finding task id: " + id, e);
        }
        return null;
    }

    public boolean create(Task task) {
        String sql = "INSERT INTO tasks (user_id, subject_id, title, description, category, priority, status, " +
                     "due_date, due_time, estimated_minutes, actual_minutes, recurrence) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, task.getUserId());
            if (task.getSubjectId() != null && task.getSubjectId() > 0) {
                ps.setInt(2, task.getSubjectId());
            } else {
                ps.setNull(2, Types.INTEGER);
            }
            ps.setString(3, task.getTitle());
            ps.setString(4, task.getDescription());
            ps.setString(5, task.getCategory());
            ps.setString(6, task.getPriority());
            ps.setString(7, task.getStatus());
            ps.setDate(8, task.getDueDate());
            ps.setTime(9, task.getDueTime());
            ps.setInt(10, task.getEstimatedMinutes());
            ps.setInt(11, task.getActualMinutes());
            ps.setString(12, task.getRecurrence());

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) task.setId(rs.getInt(1));
                }
                // Automatically generate a deadline record if due_date is provided
                if (task.getDueDate() != null) {
                    syncDeadlines(task, conn);
                }
                return true;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error creating task: " + task.getTitle(), e);
        }
        return false;
    }

    public boolean update(Task task) {
        String sql = "UPDATE tasks SET subject_id = ?, title = ?, description = ?, category = ?, " +
                     "priority = ?, status = ?, due_date = ?, due_time = ?, estimated_minutes = ?, " +
                     "actual_minutes = ?, recurrence = ?, completed_at = ? WHERE id = ? AND user_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (task.getSubjectId() != null && task.getSubjectId() > 0) {
                ps.setInt(1, task.getSubjectId());
            } else {
                ps.setNull(1, Types.INTEGER);
            }
            ps.setString(2, task.getTitle());
            ps.setString(3, task.getDescription());
            ps.setString(4, task.getCategory());
            ps.setString(5, task.getPriority());
            ps.setString(6, task.getStatus());
            ps.setDate(7, task.getDueDate());
            ps.setTime(8, task.getDueTime());
            ps.setInt(9, task.getEstimatedMinutes());
            ps.setInt(10, task.getActualMinutes());
            ps.setString(11, task.getRecurrence());
            ps.setTimestamp(12, "COMPLETED".equalsIgnoreCase(task.getStatus()) ? new Timestamp(System.currentTimeMillis()) : null);
            ps.setInt(13, task.getId());
            ps.setInt(14, task.getUserId());

            int updated = ps.executeUpdate();
            if (updated > 0) {
                syncDeadlines(task, conn);
                return true;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating task id: " + task.getId(), e);
        }
        return false;
    }

    public boolean delete(int id, int userId) {
        String sql = "DELETE FROM tasks WHERE id = ? AND user_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error deleting task id: " + id, e);
            return false;
        }
    }

    public boolean toggleComplete(int id, int userId) {
        Task current = findById(id, userId);
        if (current == null) return false;

        boolean willBeCompleted = !"COMPLETED".equalsIgnoreCase(current.getStatus());
        String newStatus = willBeCompleted ? "COMPLETED" : "PENDING";
        Timestamp completedAt = willBeCompleted ? new Timestamp(System.currentTimeMillis()) : null;

        String sql = "UPDATE tasks SET status = ?, completed_at = ? WHERE id = ? AND user_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setTimestamp(2, completedAt);
            ps.setInt(3, id);
            ps.setInt(4, userId);
            int updated = ps.executeUpdate();

            // Also update deadline table status if linked
            String dlSql = "UPDATE deadlines SET status = ? WHERE task_id = ? AND user_id = ?";
            try (PreparedStatement dlPs = conn.prepareStatement(dlSql)) {
                dlPs.setString(1, newStatus);
                dlPs.setInt(2, id);
                dlPs.setInt(3, userId);
                dlPs.executeUpdate();
            }

            return updated > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error toggling task complete for id: " + id, e);
            return false;
        }
    }

    public int countToday(int userId) {
        String sql = "SELECT COUNT(*) FROM tasks WHERE user_id = ? AND due_date = CURRENT_DATE";
        return querySingleCount(sql, userId);
    }

    public int countPending(int userId) {
        String sql = "SELECT COUNT(*) FROM tasks WHERE user_id = ? AND status IN ('PENDING', 'IN_PROGRESS')";
        return querySingleCount(sql, userId);
    }

    public int countCompleted(int userId) {
        String sql = "SELECT COUNT(*) FROM tasks WHERE user_id = ? AND status = 'COMPLETED'";
        return querySingleCount(sql, userId);
    }

    public int countOverdue(int userId) {
        String sql = "SELECT COUNT(*) FROM tasks WHERE user_id = ? AND status != 'COMPLETED' AND due_date < CURRENT_DATE";
        return querySingleCount(sql, userId);
    }

    public int countTotal(int userId) {
        String sql = "SELECT COUNT(*) FROM tasks WHERE user_id = ?";
        return querySingleCount(sql, userId);
    }

    public int[] getWeeklyWorkload(int userId) {
        // Returns 7 counts for Monday (index 0) through Sunday (index 6) for current week
        int[] counts = new int[7];
        java.time.LocalDate today = java.time.LocalDate.now();
        java.time.LocalDate monday = today.with(java.time.temporal.TemporalAdjusters.previousOrSame(java.time.DayOfWeek.MONDAY));
        java.time.LocalDate nextMonday = monday.plusDays(7);

        String sql = "SELECT due_date, COUNT(*) AS cnt " +
                     "FROM tasks WHERE user_id = ? AND due_date >= ? AND due_date < ? " +
                     "GROUP BY due_date";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setDate(2, Date.valueOf(monday));
            ps.setDate(3, Date.valueOf(nextMonday));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Date d = rs.getDate("due_date");
                    if (d != null) {
                        int dayIdx = d.toLocalDate().getDayOfWeek().getValue() - 1;
                        if (dayIdx >= 0 && dayIdx < 7) {
                            counts[dayIdx] += rs.getInt("cnt");
                        }
                    }
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error calculating weekly workload for user: " + userId, e);
        }
        return counts;
    }

    private void syncDeadlines(Task task, Connection conn) {
        if (task.getDueDate() == null) return;
        try {
            String checkSql = "SELECT id FROM deadlines WHERE task_id = ? AND user_id = ?";
            try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
                checkPs.setInt(1, task.getId());
                checkPs.setInt(2, task.getUserId());
                try (ResultSet rs = checkPs.executeQuery()) {
                    if (rs.next()) {
                        // Update
                        String updateSql = "UPDATE deadlines SET title = ?, due_date = ?, due_time = ?, priority = ?, status = ? WHERE id = ?";
                        try (PreparedStatement upPs = conn.prepareStatement(updateSql)) {
                            upPs.setString(1, task.getTitle());
                            upPs.setDate(2, task.getDueDate());
                            upPs.setTime(3, task.getDueTime());
                            upPs.setString(4, task.getPriority());
                            upPs.setString(5, task.getStatus());
                            upPs.setInt(6, rs.getInt("id"));
                            upPs.executeUpdate();
                        }
                    } else {
                        // Insert
                        String insertSql = "INSERT INTO deadlines (user_id, subject_id, task_id, title, due_date, due_time, priority, status) " +
                                           "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
                        try (PreparedStatement inPs = conn.prepareStatement(insertSql)) {
                            inPs.setInt(1, task.getUserId());
                            if (task.getSubjectId() != null) inPs.setInt(2, task.getSubjectId());
                            else inPs.setNull(2, Types.INTEGER);
                            inPs.setInt(3, task.getId());
                            inPs.setString(4, task.getTitle());
                            inPs.setDate(5, task.getDueDate());
                            inPs.setTime(6, task.getDueTime());
                            inPs.setString(7, task.getPriority());
                            inPs.setString(8, task.getStatus());
                            inPs.executeUpdate();
                        }
                    }
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Could not sync deadline for task: " + task.getId(), e);
        }
    }

    private int querySingleCount(String sql, int userId) {
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error executing count query: " + sql, e);
        }
        return 0;
    }

    private Task mapRowToTask(ResultSet rs) throws SQLException {
        Task t = new Task();
        t.setId(rs.getInt("id"));
        t.setUserId(rs.getInt("user_id"));
        int subjId = rs.getInt("subject_id");
        if (!rs.wasNull()) {
            t.setSubjectId(subjId);
        }
        try {
            t.setSubjectName(rs.getString("subject_name"));
            t.setSubjectColor(rs.getString("subject_color"));
        } catch (SQLException ignored) {}

        t.setTitle(rs.getString("title"));
        t.setDescription(rs.getString("description"));
        t.setCategory(rs.getString("category"));
        t.setPriority(rs.getString("priority"));
        t.setStatus(rs.getString("status"));
        t.setDueDate(rs.getDate("due_date"));
        t.setDueTime(rs.getTime("due_time"));
        t.setEstimatedMinutes(rs.getInt("estimated_minutes"));
        t.setActualMinutes(rs.getInt("actual_minutes"));
        t.setRecurrence(rs.getString("recurrence"));
        t.setCompletedAt(rs.getTimestamp("completed_at"));
        t.setCreatedAt(rs.getTimestamp("created_at"));
        t.setUpdatedAt(rs.getTimestamp("updated_at"));
        return t;
    }
}
