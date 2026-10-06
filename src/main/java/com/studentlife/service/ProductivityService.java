package com.studentlife.service;

import com.studentlife.dao.HabitDAO;
import com.studentlife.dao.StudySessionDAO;
import com.studentlife.dao.TaskDAO;
import com.studentlife.model.ProductivityMetrics;

public class ProductivityService {
    private final TaskDAO taskDAO;
    private final StudySessionDAO studySessionDAO;
    private final HabitDAO habitDAO;

    public ProductivityService() {
        this.taskDAO = new TaskDAO();
        this.studySessionDAO = new StudySessionDAO();
        this.habitDAO = new HabitDAO();
    }

    public ProductivityService(TaskDAO taskDAO, StudySessionDAO studySessionDAO, HabitDAO habitDAO) {
        this.taskDAO = taskDAO;
        this.studySessionDAO = studySessionDAO;
        this.habitDAO = habitDAO;
    }

    /**
     * Computes the 4-component transparent productivity score:
     * 1. Task completion (40% weight)
     * 2. Deadline adherence (25% weight)
     * 3. Study session target (20% weight, baseline target 15 hours / 900 min per week)
     * 4. Habit completion (15% weight)
     */
    public ProductivityMetrics calculateMetrics(int userId) {
        // 1. Task completion
        int totalTasks = taskDAO.countTotal(userId);
        int completedTasks = taskDAO.countCompleted(userId);
        int overdueTasks = taskDAO.countOverdue(userId);

        double taskRate = totalTasks > 0 ? (completedTasks * 100.0) / totalTasks : 85.0;

        // 2. Deadline adherence (penalizes overdue tasks)
        double deadlineRate;
        if (totalTasks == 0) {
            deadlineRate = 90.0;
        } else {
            deadlineRate = Math.max(0.0, 100.0 - (overdueTasks * 15.0));
        }

        // 3. Study target (Target: 14 hours = 840 mins weekly)
        int weekStudyMinutes = studySessionDAO.getWeekMinutes(userId);
        double studyRate = Math.min(100.0, (weekStudyMinutes / 840.0) * 100.0);
        if (weekStudyMinutes == 0 && totalTasks > 0) {
            studyRate = 60.0; // fallback if no sessions recorded yet
        }

        // 4. Habit completion
        double habitRate = habitDAO.calculateWeeklyCompletionRate(userId);

        return new ProductivityMetrics(taskRate, deadlineRate, studyRate, habitRate);
    }
}
