package com.studentlife.controller;

import com.studentlife.dao.TimetableDAO;
import com.studentlife.model.Subject;
import com.studentlife.model.TimetableEntry;
import com.studentlife.service.SubjectService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Time;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

@WebServlet(name = "TimetableServlet", urlPatterns = {"/timetable"})
public class TimetableServlet extends HttpServlet {
    private final TimetableDAO timetableDAO = new TimetableDAO();
    private final SubjectService subjectService = new SubjectService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        int userId = (int) session.getAttribute("userId");

        LocalDate today = LocalDate.now();
        String dayOfWeek = today.getDayOfWeek().name().substring(0, 1) + today.getDayOfWeek().name().substring(1).toLowerCase();
        LocalTime now = LocalTime.now();

        List<TimetableEntry> allEntries = timetableDAO.findAllByUserId(userId);
        List<TimetableEntry> todaySchedule = timetableDAO.findByDay(userId, dayOfWeek);
        TimetableEntry nextClass = timetableDAO.findNextClass(userId, dayOfWeek, Time.valueOf(now));
        List<Subject> subjects = subjectService.getSubjects(userId);

        req.setAttribute("allEntries", allEntries);
        req.setAttribute("todaySchedule", todaySchedule);
        req.setAttribute("nextClass", nextClass);
        req.setAttribute("currentDayName", dayOfWeek);
        req.setAttribute("subjects", subjects);
        req.setAttribute("activePage", "timetable");

        req.getRequestDispatcher("/WEB-INF/views/pages/timetable.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        int userId = (int) session.getAttribute("userId");
        String action = req.getParameter("action");

        try {
            if ("create".equalsIgnoreCase(action)) {
                TimetableEntry entry = parseEntry(req, userId);
                timetableDAO.create(entry);
            } else if ("update".equalsIgnoreCase(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                TimetableEntry entry = parseEntry(req, userId);
                entry.setId(id);
                timetableDAO.update(entry);
            } else if ("delete".equalsIgnoreCase(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                timetableDAO.delete(id, userId);
            }
        } catch (Exception e) {
            req.getSession().setAttribute("flashError", e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/timetable");
    }

    private TimetableEntry parseEntry(HttpServletRequest req, int userId) {
        TimetableEntry t = new TimetableEntry();
        t.setUserId(userId);

        int subjectId = 0;
        String subjectIdParam = req.getParameter("subjectId");
        String subjectNameParam = req.getParameter("subjectName");

        if (subjectNameParam != null && !subjectNameParam.trim().isEmpty()) {
            String name = subjectNameParam.trim();
            Subject existing = subjectService.getSubjectByName(name, userId);
            if (existing != null) {
                subjectId = existing.getId();
            } else {
                Subject newSubj = new Subject();
                newSubj.setUserId(userId);
                newSubj.setName(name);

                StringBuilder code = new StringBuilder();
                for (String w : name.split("\\s+")) {
                    if (!w.isEmpty()) code.append(Character.toUpperCase(w.charAt(0)));
                }
                newSubj.setCourseCode(code.length() > 0 ? code.toString() : "SUB");
                newSubj.setFaculty(req.getParameter("faculty") != null && !req.getParameter("faculty").trim().isEmpty() ? req.getParameter("faculty").trim() : "Faculty");
                newSubj.setRoom(req.getParameter("room") != null && !req.getParameter("room").trim().isEmpty() ? req.getParameter("room").trim() : "TBA");
                newSubj.setCredits(3);
                newSubj.setColor("#ed1d24");
                subjectService.createSubject(newSubj);
                subjectId = newSubj.getId();
            }
        } else if (subjectIdParam != null && !subjectIdParam.trim().isEmpty()) {
            subjectId = Integer.parseInt(subjectIdParam.trim());
        }

        t.setSubjectId(subjectId);
        t.setDayOfWeek(req.getParameter("dayOfWeek"));

        String startStr = req.getParameter("startTime");
        if (startStr != null && startStr.length() == 5) startStr += ":00";
        t.setStartTime(Time.valueOf(startStr));

        String endStr = req.getParameter("endTime");
        if (endStr != null && endStr.length() == 5) endStr += ":00";
        t.setEndTime(Time.valueOf(endStr));

        t.setRoom(req.getParameter("room"));
        t.setFaculty(req.getParameter("faculty"));
        return t;
    }
}
