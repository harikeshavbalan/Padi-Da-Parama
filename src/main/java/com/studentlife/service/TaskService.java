package com.studentlife.service;

import com.studentlife.dao.TaskDAO;
import com.studentlife.model.Task;

import java.util.List;

public class TaskService {
    private final TaskDAO taskDAO;

    public TaskService() {
        this.taskDAO = new TaskDAO();
    }

    public TaskService(TaskDAO taskDAO) {
        this.taskDAO = taskDAO;
    }

    public List<Task> getTasks(int userId, String search, String category, String priority,
                                String status, Integer subjectId, String sortBy) {
        return taskDAO.findFiltered(userId, search, category, priority, status, subjectId, sortBy);
    }

    public Task getTaskById(int id, int userId) {
        return taskDAO.findById(id, userId);
    }

    public boolean createTask(Task task) {
        validateTask(task);
        return taskDAO.create(task);
    }

    public boolean updateTask(Task task) {
        validateTask(task);
        return taskDAO.update(task);
    }

    public boolean deleteTask(int id, int userId) {
        return taskDAO.delete(id, userId);
    }

    public boolean toggleTaskComplete(int id, int userId) {
        return taskDAO.toggleComplete(id, userId);
    }

    public int[] getWeeklyWorkload(int userId) {
        return taskDAO.getWeeklyWorkload(userId);
    }

    private void validateTask(Task task) {
        if (task.getTitle() == null || task.getTitle().trim().isEmpty()) {
            throw new IllegalArgumentException("Task title is required");
        }
        if (task.getTitle().length() > 200) {
            task.setTitle(task.getTitle().substring(0, 200));
        }
        if (task.getPriority() == null) {
            task.setPriority("MEDIUM");
        }
        if (task.getStatus() == null) {
            task.setStatus("PENDING");
        }
        if (task.getCategory() == null) {
            task.setCategory("Academic");
        }
    }
}
