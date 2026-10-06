package com.studentlife.controller;

import com.studentlife.model.Habit;
import com.studentlife.service.HabitService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "HabitServlet", urlPatterns = {"/habits"})
public class HabitServlet extends HttpServlet {
    private final HabitService habitService = new HabitService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        int userId = (int) session.getAttribute("userId");

        List<Habit> habits = habitService.getHabits(userId);
        int maxStreak = habitService.getCurrentStreak(userId);
        double weeklyRate = habitService.getWeeklyRate(userId);

        req.setAttribute("habits", habits);
        req.setAttribute("maxStreak", maxStreak);
        req.setAttribute("weeklyRate", Math.round(weeklyRate));
        req.setAttribute("activePage", "habits");

        req.getRequestDispatcher("/WEB-INF/views/pages/habits.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        int userId = (int) session.getAttribute("userId");
        String action = req.getParameter("action");

        try {
            if ("create".equalsIgnoreCase(action)) {
                Habit h = parseHabit(req, userId);
                habitService.createHabit(h);
            } else if ("update".equalsIgnoreCase(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                Habit h = parseHabit(req, userId);
                h.setId(id);
                habitService.updateHabit(h);
            } else if ("delete".equalsIgnoreCase(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                habitService.deleteHabit(id, userId);
            } else if ("toggle".equalsIgnoreCase(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                habitService.toggleToday(id, userId);
            }
        } catch (Exception e) {
            req.getSession().setAttribute("flashError", e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/habits");
    }

    private Habit parseHabit(HttpServletRequest req, int userId) {
        Habit h = new Habit();
        h.setUserId(userId);
        h.setName(req.getParameter("name"));
        h.setDescription(req.getParameter("description"));
        h.setCategory(req.getParameter("category"));
        h.setTargetFrequency(req.getParameter("targetFrequency"));
        String color = req.getParameter("color");
        if (color != null && !color.trim().isEmpty()) {
            h.setColor(color.trim());
        }
        return h;
    }
}
