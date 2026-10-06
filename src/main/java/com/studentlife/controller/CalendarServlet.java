package com.studentlife.controller;

import com.studentlife.model.CalendarEvent;
import com.studentlife.service.CalendarService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "CalendarServlet", urlPatterns = {"/calendar"})
public class CalendarServlet extends HttpServlet {
    private final CalendarService calendarService = new CalendarService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        int userId = (int) session.getAttribute("userId");

        List<CalendarEvent> events = calendarService.getEventsForUser(userId);
        req.setAttribute("events", events);
        req.setAttribute("activePage", "calendar");

        req.getRequestDispatcher("/WEB-INF/views/pages/calendar.jsp").forward(req, resp);
    }
}
