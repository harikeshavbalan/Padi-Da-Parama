package com.studentlife.controller;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.studentlife.dao.HabitDAO;
import com.studentlife.dao.NotificationDAO;
import com.studentlife.dao.TaskDAO;
import com.studentlife.model.CalendarEvent;
import com.studentlife.model.Task;
import com.studentlife.model.User;
import com.studentlife.service.AuthenticationService;
import com.studentlife.service.CalendarService;
import com.studentlife.service.ExamService;
import com.studentlife.service.TaskService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "ApiServlet", urlPatterns = {
        "/api/check-username",
        "/api/tasks/toggle",
        "/api/tasks/filter",
        "/api/habits/toggle",
        "/api/dashboard/stats",
        "/api/calendar/events",
        "/api/notifications/unread",
        "/api/exams/update-prep"
})
public class ApiServlet extends HttpServlet {
    private final Gson gson = new Gson();
    private final AuthenticationService authService = new AuthenticationService();
    private final TaskService taskService = new TaskService();
    private final TaskDAO taskDAO = new TaskDAO();
    private final HabitDAO habitDAO = new HabitDAO();
    private final NotificationDAO notificationDAO = new NotificationDAO();
    private final CalendarService calendarService = new CalendarService();
    private final ExamService examService = new ExamService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        if ("/api/check-username".equals(path)) {
            String username = req.getParameter("username");
            boolean taken = authService.isUsernameTaken(username);
            JsonObject json = new JsonObject();
            json.addProperty("available", !taken);
            json.addProperty("username", username);
            resp.getWriter().write(gson.toJson(json));
            return;
        }

        // Authenticated endpoints
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.getWriter().write("{\"error\": \"Unauthorized\"}");
            return;
        }
        int userId = (int) session.getAttribute("userId");

        if ("/api/calendar/events".equals(path)) {
            List<CalendarEvent> events = calendarService.getEventsForUser(userId);
            resp.getWriter().write(gson.toJson(events));
        } else if ("/api/dashboard/stats".equals(path)) {
            Map<String, Object> stats = new HashMap<>();
            stats.put("todayTasks", taskDAO.countToday(userId));
            stats.put("pendingTasks", taskDAO.countPending(userId));
            stats.put("completedTasks", taskDAO.countCompleted(userId));
            stats.put("overdueTasks", taskDAO.countOverdue(userId));
            stats.put("streak", habitDAO.getUserMaxStreak(userId));
            stats.put("unreadNotifications", notificationDAO.getUnreadCount(userId));
            resp.getWriter().write(gson.toJson(stats));
        } else if ("/api/tasks/filter".equals(path)) {
            String search = req.getParameter("q");
            String cat = req.getParameter("category");
            String pri = req.getParameter("priority");
            String stat = req.getParameter("status");
            String sort = req.getParameter("sort");
            Integer sid = null;
            try {
                if (req.getParameter("subjectId") != null && !req.getParameter("subjectId").isEmpty()) {
                    sid = Integer.parseInt(req.getParameter("subjectId"));
                }
            } catch (NumberFormatException ignored) {}

            List<Task> tasks = taskService.getTasks(userId, search, cat, pri, stat, sid, sort);
            resp.getWriter().write(gson.toJson(tasks));
        } else if ("/api/notifications/unread".equals(path)) {
            int count = notificationDAO.getUnreadCount(userId);
            JsonObject json = new JsonObject();
            json.addProperty("unreadCount", count);
            resp.getWriter().write(gson.toJson(json));
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.getWriter().write("{\"error\": \"Unauthorized\"}");
            return;
        }
        int userId = (int) session.getAttribute("userId");

        JsonObject responseObj = new JsonObject();

        if ("/api/tasks/toggle".equals(path)) {
            try {
                int taskId = Integer.parseInt(req.getParameter("id"));
                boolean ok = taskService.toggleTaskComplete(taskId, userId);
                Task updated = taskService.getTaskById(taskId, userId);
                responseObj.addProperty("success", ok);
                responseObj.addProperty("taskId", taskId);
                responseObj.addProperty("newStatus", updated != null ? updated.getStatus() : "UNKNOWN");
                responseObj.addProperty("isCompleted", updated != null && updated.isCompleted());
            } catch (Exception e) {
                responseObj.addProperty("success", false);
                responseObj.addProperty("error", e.getMessage());
            }
        } else if ("/api/habits/toggle".equals(path)) {
            try {
                int habitId = Integer.parseInt(req.getParameter("id"));
                boolean ok = habitDAO.toggleToday(habitId, userId);
                int streak = habitDAO.getHabitStreak(habitId);
                responseObj.addProperty("success", ok);
                responseObj.addProperty("habitId", habitId);
                responseObj.addProperty("streak", streak);
            } catch (Exception e) {
                responseObj.addProperty("success", false);
                responseObj.addProperty("error", e.getMessage());
            }
        } else if ("/api/exams/update-prep".equals(path)) {
            try {
                int examId = Integer.parseInt(req.getParameter("id"));
                int prep = Integer.parseInt(req.getParameter("percentage"));
                boolean ok = examService.updatePreparation(examId, userId, prep);
                responseObj.addProperty("success", ok);
                responseObj.addProperty("percentage", prep);
            } catch (Exception e) {
                responseObj.addProperty("success", false);
                responseObj.addProperty("error", e.getMessage());
            }
        }

        resp.getWriter().write(gson.toJson(responseObj));
    }
}
