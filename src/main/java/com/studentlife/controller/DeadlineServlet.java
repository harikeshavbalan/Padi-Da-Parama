package com.studentlife.controller;

import com.studentlife.model.Deadline;
import com.studentlife.model.Subject;
import com.studentlife.service.DeadlineService;
import com.studentlife.service.SubjectService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Date;
import java.sql.Time;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "DeadlineServlet", urlPatterns = {"/deadlines"})
public class DeadlineServlet extends HttpServlet {
    private final DeadlineService deadlineService = new DeadlineService();
    private final SubjectService subjectService = new SubjectService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        int userId = (int) session.getAttribute("userId");

        List<Deadline> all = deadlineService.getDeadlines(userId);
        List<Subject> subjects = subjectService.getSubjects(userId);

        List<Deadline> dueToday = new ArrayList<>();
        List<Deadline> dueTomorrow = new ArrayList<>();
        List<Deadline> dueThisWeek = new ArrayList<>();
        List<Deadline> upcoming = new ArrayList<>();
        List<Deadline> overdue = new ArrayList<>();
        List<Deadline> completed = new ArrayList<>();

        for (Deadline d : all) {
            if ("COMPLETED".equalsIgnoreCase(d.getStatus())) {
                completed.add(d);
            } else {
                long days = d.getDaysRemaining();
                if (days < 0) {
                    overdue.add(d);
                } else if (days == 0) {
                    dueToday.add(d);
                } else if (days == 1) {
                    dueTomorrow.add(d);
                } else if (days <= 7) {
                    dueThisWeek.add(d);
                } else {
                    upcoming.add(d);
                }
            }
        }

        req.setAttribute("allDeadlines", all);
        req.setAttribute("dueToday", dueToday);
        req.setAttribute("dueTomorrow", dueTomorrow);
        req.setAttribute("dueThisWeek", dueThisWeek);
        req.setAttribute("upcoming", upcoming);
        req.setAttribute("overdue", overdue);
        req.setAttribute("completed", completed);
        req.setAttribute("subjects", subjects);
        req.setAttribute("activePage", "deadlines");

        req.getRequestDispatcher("/WEB-INF/views/pages/deadlines.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        int userId = (int) session.getAttribute("userId");
        String action = req.getParameter("action");

        try {
            if ("create".equalsIgnoreCase(action)) {
                Deadline d = new Deadline();
                d.setUserId(userId);
                d.setTitle(req.getParameter("title"));
                String sid = req.getParameter("subjectId");
                if (sid != null && !sid.trim().isEmpty()) {
                    d.setSubjectId(Integer.parseInt(sid.trim()));
                }
                d.setDueDate(Date.valueOf(req.getParameter("dueDate")));
                String timeStr = req.getParameter("dueTime");
                if (timeStr != null && !timeStr.trim().isEmpty()) {
                    if (timeStr.length() == 5) timeStr += ":00";
                    d.setDueTime(Time.valueOf(timeStr));
                }
                d.setPriority(req.getParameter("priority"));
                deadlineService.createDeadline(d);
            } else if ("toggle".equalsIgnoreCase(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                deadlineService.toggleStatus(id, userId);
            } else if ("delete".equalsIgnoreCase(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                deadlineService.deleteDeadline(id, userId);
            }
        } catch (Exception e) {
            req.getSession().setAttribute("flashError", e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/deadlines");
    }
}
