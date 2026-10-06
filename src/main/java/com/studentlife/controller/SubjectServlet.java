package com.studentlife.controller;

import com.studentlife.model.Subject;
import com.studentlife.service.SubjectService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "SubjectServlet", urlPatterns = {"/subjects"})
public class SubjectServlet extends HttpServlet {
    private final SubjectService subjectService = new SubjectService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        int userId = (int) session.getAttribute("userId");

        List<Subject> subjects = subjectService.getSubjectSummaries(userId);
        req.setAttribute("subjects", subjects);
        req.setAttribute("activePage", "subjects");

        req.getRequestDispatcher("/WEB-INF/views/pages/subjects.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        int userId = (int) session.getAttribute("userId");
        String action = req.getParameter("action");

        try {
            if ("create".equalsIgnoreCase(action)) {
                Subject s = parseSubject(req, userId);
                subjectService.createSubject(s);
            } else if ("update".equalsIgnoreCase(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                Subject s = parseSubject(req, userId);
                s.setId(id);
                subjectService.updateSubject(s);
            } else if ("delete".equalsIgnoreCase(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                subjectService.deleteSubject(id, userId);
            }
        } catch (Exception e) {
            req.getSession().setAttribute("flashError", e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/subjects");
    }

    private Subject parseSubject(HttpServletRequest req, int userId) {
        Subject s = new Subject();
        s.setUserId(userId);
        s.setName(req.getParameter("name"));
        s.setCourseCode(req.getParameter("courseCode"));
        s.setFaculty(req.getParameter("faculty"));
        s.setRoom(req.getParameter("room"));
        String credits = req.getParameter("credits");
        if (credits != null && !credits.trim().isEmpty()) {
            try {
                s.setCredits(Integer.parseInt(credits.trim()));
            } catch (NumberFormatException ignored) {}
        }
        String color = req.getParameter("color");
        if (color != null && !color.trim().isEmpty()) {
            s.setColor(color.trim());
        }
        return s;
    }
}
