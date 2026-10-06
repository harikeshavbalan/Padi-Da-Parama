package com.studentlife.controller;

import com.studentlife.dao.HabitDAO;
import com.studentlife.dao.StudySessionDAO;
import com.studentlife.dao.TaskDAO;
import com.studentlife.model.ProductivityMetrics;
import com.studentlife.service.ProductivityService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Map;

@WebServlet(name = "AnalyticsServlet", urlPatterns = {"/analytics"})
public class AnalyticsServlet extends HttpServlet {
    private final TaskDAO taskDAO = new TaskDAO();
    private final StudySessionDAO studySessionDAO = new StudySessionDAO();
    private final HabitDAO habitDAO = new HabitDAO();
    private final ProductivityService productivityService = new ProductivityService(taskDAO, studySessionDAO, habitDAO);

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        int userId = (int) session.getAttribute("userId");

        int totalTasks = taskDAO.countTotal(userId);
        int completedTasks = taskDAO.countCompleted(userId);
        int pendingTasks = taskDAO.countPending(userId);
        int overdueTasks = taskDAO.countOverdue(userId);

        int completionPercent = totalTasks > 0 ? (int) Math.round((completedTasks * 100.0) / totalTasks) : 0;

        int weekStudyMin = studySessionDAO.getWeekMinutes(userId);
        int monthStudyMin = studySessionDAO.getMonthMinutes(userId);

        int maxStreak = habitDAO.getUserMaxStreak(userId);
        double habitWeeklyRate = habitDAO.calculateWeeklyCompletionRate(userId);

        ProductivityMetrics metrics = productivityService.calculateMetrics(userId);
        int[] weeklyWorkload = taskDAO.getWeeklyWorkload(userId);
        Map<String, Integer> subjectStudy = studySessionDAO.getSubjectWiseStudyMinutes(userId);

        req.setAttribute("totalTasks", totalTasks);
        req.setAttribute("completedTasks", completedTasks);
        req.setAttribute("pendingTasks", pendingTasks);
        req.setAttribute("overdueTasks", overdueTasks);
        req.setAttribute("completionPercent", completionPercent);
        req.setAttribute("weekStudyHours", weekStudyMin / 60);
        req.setAttribute("weekStudyMins", weekStudyMin % 60);
        req.setAttribute("monthStudyHours", monthStudyMin / 60);
        req.setAttribute("maxStreak", maxStreak);
        req.setAttribute("habitWeeklyRate", Math.round(habitWeeklyRate));
        req.setAttribute("metrics", metrics);
        req.setAttribute("weeklyWorkload", weeklyWorkload);
        req.setAttribute("subjectStudy", subjectStudy);
        req.setAttribute("activePage", "analytics");

        req.getRequestDispatcher("/WEB-INF/views/pages/analytics.jsp").forward(req, resp);
    }
}
