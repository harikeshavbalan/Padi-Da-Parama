package com.studentlife.controller;

import com.studentlife.model.StudySession;
import com.studentlife.model.Subject;
import com.studentlife.model.Task;
import com.studentlife.service.StudySessionService;
import com.studentlife.service.SubjectService;
import com.studentlife.service.TaskService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@WebServlet(name = "StudySessionServlet", urlPatterns = {"/study-sessions"})
public class StudySessionServlet extends HttpServlet {
    private final StudySessionService studySessionService = new StudySessionService();
    private final SubjectService subjectService = new SubjectService();
    private final TaskService taskService = new TaskService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        int userId = (int) session.getAttribute("userId");

        List<StudySession> sessions = studySessionService.getSessions(userId);
        List<Subject> subjects = subjectService.getSubjects(userId);
        List<Task> tasks = taskService.getTasks(userId, null, null, null, null, null, null);

        int todayMin = studySessionService.getTodayMinutes(userId);
        int weekMin = studySessionService.getWeekMinutes(userId);
        int monthMin = studySessionService.getMonthMinutes(userId);
        Map<String, Integer> subjectWise = studySessionService.getSubjectWiseStudyMinutes(userId);

        req.setAttribute("sessions", sessions);
        req.setAttribute("subjects", subjects);
        req.setAttribute("tasks", tasks);
        req.setAttribute("todayHours", todayMin / 60);
        req.setAttribute("todayMins", todayMin % 60);
        req.setAttribute("weekHours", weekMin / 60);
        req.setAttribute("weekMins", weekMin % 60);
        req.setAttribute("monthHours", monthMin / 60);
        req.setAttribute("monthMins", monthMin % 60);
        req.setAttribute("subjectWise", subjectWise);
        req.setAttribute("activePage", "study-sessions");

        req.getRequestDispatcher("/WEB-INF/views/pages/study-sessions.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        int userId = (int) session.getAttribute("userId");
        String action = req.getParameter("action");

        try {
            if ("create".equalsIgnoreCase(action)) {
                StudySession s = new StudySession();
                s.setUserId(userId);

                String sid = req.getParameter("subjectId");
                if (sid != null && !sid.trim().isEmpty()) {
                    s.setSubjectId(Integer.parseInt(sid.trim()));
                }

                String tid = req.getParameter("taskId");
                if (tid != null && !tid.trim().isEmpty()) {
                    s.setTaskId(Integer.parseInt(tid.trim()));
                }

                int duration = Integer.parseInt(req.getParameter("durationMinutes"));
                s.setDurationMinutes(duration);
                s.setNotes(req.getParameter("notes"));

                // Automatic start/end timestamps based on duration
                LocalDateTime end = LocalDateTime.now();
                LocalDateTime start = end.minusMinutes(duration);
                s.setStartTime(Timestamp.valueOf(start));
                s.setEndTime(Timestamp.valueOf(end));

                studySessionService.createSession(s);
            } else if ("delete".equalsIgnoreCase(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                studySessionService.deleteSession(id, userId);
            }
        } catch (Exception e) {
            req.getSession().setAttribute("flashError", e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/study-sessions");
    }
}
