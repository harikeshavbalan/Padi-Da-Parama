package com.studentlife.controller;

import com.studentlife.model.Subject;
import com.studentlife.model.Task;
import com.studentlife.service.SubjectService;
import com.studentlife.service.TaskService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Date;
import java.sql.Time;
import java.util.List;

@WebServlet(name = "TaskServlet", urlPatterns = {"/tasks"})
public class TaskServlet extends HttpServlet {
    private final TaskService taskService = new TaskService();
    private final SubjectService subjectService = new SubjectService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        int userId = (int) session.getAttribute("userId");

        String search = req.getParameter("q");
        String category = req.getParameter("category");
        String priority = req.getParameter("priority");
        String status = req.getParameter("status");
        String sortBy = req.getParameter("sort");

        Integer subjectId = null;
        String subjParam = req.getParameter("subjectId");
        if (subjParam != null && !subjParam.trim().isEmpty() && !"ALL".equalsIgnoreCase(subjParam)) {
            try {
                subjectId = Integer.parseInt(subjParam.trim());
            } catch (NumberFormatException ignored) {}
        }

        List<Task> tasks = taskService.getTasks(userId, search, category, priority, status, subjectId, sortBy);
        List<Subject> subjects = subjectService.getSubjects(userId);

        req.setAttribute("tasks", tasks);
        req.setAttribute("subjects", subjects);
        req.setAttribute("selectedCategory", category);
        req.setAttribute("selectedPriority", priority);
        req.setAttribute("selectedStatus", status);
        req.setAttribute("selectedSubjectId", subjectId);
        req.setAttribute("searchTerm", search);
        req.setAttribute("sortBy", sortBy);
        req.setAttribute("activePage", "tasks");

        req.getRequestDispatcher("/WEB-INF/views/pages/tasks.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        int userId = (int) session.getAttribute("userId");
        String action = req.getParameter("action");

        try {
            if ("create".equalsIgnoreCase(action)) {
                Task t = parseTaskFromRequest(req, userId);
                taskService.createTask(t);
            } else if ("update".equalsIgnoreCase(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                Task t = parseTaskFromRequest(req, userId);
                t.setId(id);
                taskService.updateTask(t);
            } else if ("delete".equalsIgnoreCase(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                taskService.deleteTask(id, userId);
            } else if ("toggle".equalsIgnoreCase(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                taskService.toggleTaskComplete(id, userId);
            }
        } catch (Exception e) {
            req.getSession().setAttribute("flashError", e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/tasks");
    }

    private Task parseTaskFromRequest(HttpServletRequest req, int userId) {
        Task t = new Task();
        t.setUserId(userId);
        t.setTitle(req.getParameter("title"));
        t.setDescription(req.getParameter("description"));
        t.setCategory(req.getParameter("category"));
        t.setPriority(req.getParameter("priority"));
        t.setStatus(req.getParameter("status") != null ? req.getParameter("status") : "PENDING");
        t.setRecurrence(req.getParameter("recurrence") != null ? req.getParameter("recurrence") : "NONE");

        String subj = req.getParameter("subjectId");
        if (subj != null && !subj.trim().isEmpty()) {
            try {
                t.setSubjectId(Integer.parseInt(subj.trim()));
            } catch (NumberFormatException ignored) {}
        }

        String dueDateStr = req.getParameter("dueDate");
        if (dueDateStr != null && !dueDateStr.trim().isEmpty()) {
            t.setDueDate(Date.valueOf(dueDateStr.trim()));
        }

        String dueTimeStr = req.getParameter("dueTime");
        if (dueTimeStr != null && !dueTimeStr.trim().isEmpty()) {
            try {
                if (dueTimeStr.length() == 5) dueTimeStr += ":00";
                t.setDueTime(Time.valueOf(dueTimeStr.trim()));
            } catch (Exception ignored) {}
        }

        String estMin = req.getParameter("estimatedMinutes");
        if (estMin != null && !estMin.trim().isEmpty()) {
            try {
                t.setEstimatedMinutes(Integer.parseInt(estMin.trim()));
            } catch (NumberFormatException ignored) {}
        }

        return t;
    }
}
