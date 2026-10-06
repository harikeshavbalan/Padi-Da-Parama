package com.studentlife.controller;

import com.studentlife.model.Exam;
import com.studentlife.model.Subject;
import com.studentlife.service.ExamService;
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
import java.util.List;

@WebServlet(name = "ExamServlet", urlPatterns = {"/exams"})
public class ExamServlet extends HttpServlet {
    private final ExamService examService = new ExamService();
    private final SubjectService subjectService = new SubjectService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        int userId = (int) session.getAttribute("userId");

        List<Exam> exams = examService.getExams(userId);
        List<Subject> subjects = subjectService.getSubjects(userId);

        req.setAttribute("exams", exams);
        req.setAttribute("subjects", subjects);
        req.setAttribute("activePage", "exams");

        req.getRequestDispatcher("/WEB-INF/views/pages/exams.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        int userId = (int) session.getAttribute("userId");
        String action = req.getParameter("action");

        try {
            if ("create".equalsIgnoreCase(action)) {
                Exam e = parseExam(req, userId);
                examService.createExam(e);
            } else if ("update".equalsIgnoreCase(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                Exam e = parseExam(req, userId);
                e.setId(id);
                examService.updateExam(e);
            } else if ("delete".equalsIgnoreCase(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                examService.deleteExam(id, userId);
            } else if ("updatePrep".equalsIgnoreCase(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                int prep = Integer.parseInt(req.getParameter("preparationPercentage"));
                examService.updatePreparation(id, userId, prep);
            }
        } catch (Exception e) {
            req.getSession().setAttribute("flashError", e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/exams");
    }

    private Exam parseExam(HttpServletRequest req, int userId) {
        Exam e = new Exam();
        e.setUserId(userId);
        e.setTitle(req.getParameter("title"));
        e.setExamType(req.getParameter("examType"));

        String sid = req.getParameter("subjectId");
        if (sid != null && !sid.trim().isEmpty()) {
            e.setSubjectId(Integer.parseInt(sid.trim()));
        }

        e.setExamDate(Date.valueOf(req.getParameter("examDate")));

        String startStr = req.getParameter("startTime");
        if (startStr != null && startStr.length() == 5) startStr += ":00";
        e.setStartTime(Time.valueOf(startStr));

        String endStr = req.getParameter("endTime");
        if (endStr != null && endStr.length() == 5) endStr += ":00";
        e.setEndTime(Time.valueOf(endStr));

        e.setVenue(req.getParameter("venue"));
        e.setSyllabus(req.getParameter("syllabus"));
        String prepStr = req.getParameter("preparationPercentage");
        if (prepStr != null && !prepStr.trim().isEmpty()) {
            e.setPreparationPercentage(Integer.parseInt(prepStr.trim()));
        }
        e.setNotes(req.getParameter("notes"));
        return e;
    }
}
