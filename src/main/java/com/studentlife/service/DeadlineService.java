package com.studentlife.service;

import com.studentlife.dao.DeadlineDAO;
import com.studentlife.model.Deadline;

import java.util.List;

public class DeadlineService {
    private final DeadlineDAO deadlineDAO;

    public DeadlineService() {
        this.deadlineDAO = new DeadlineDAO();
    }

    public DeadlineService(DeadlineDAO deadlineDAO) {
        this.deadlineDAO = deadlineDAO;
    }

    public List<Deadline> getDeadlines(int userId) {
        return deadlineDAO.findAllByUserId(userId);
    }

    public Deadline getNextDeadline(int userId) {
        return deadlineDAO.findNextDeadline(userId);
    }

    public boolean createDeadline(Deadline d) {
        if (d.getTitle() == null || d.getTitle().trim().isEmpty()) {
            throw new IllegalArgumentException("Deadline title is required");
        }
        if (d.getDueDate() == null) {
            throw new IllegalArgumentException("Due date is required");
        }
        return deadlineDAO.create(d);
    }

    public boolean deleteDeadline(int id, int userId) {
        return deadlineDAO.delete(id, userId);
    }

    public boolean toggleStatus(int id, int userId) {
        return deadlineDAO.toggleStatus(id, userId);
    }
}
