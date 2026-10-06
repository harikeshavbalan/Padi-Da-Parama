package com.studentlife.controller;

import com.studentlife.dao.EventDAO;
import com.studentlife.model.Event;
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

@WebServlet(name = "EventServlet", urlPatterns = {"/events"})
public class EventServlet extends HttpServlet {
    private final EventDAO eventDAO = new EventDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        int userId = (int) session.getAttribute("userId");

        List<Event> events = eventDAO.findAllByUserId(userId);
        Event nextEvent = eventDAO.findNextEvent(userId);

        req.setAttribute("events", events);
        req.setAttribute("nextEvent", nextEvent);
        req.setAttribute("activePage", "events");

        req.getRequestDispatcher("/WEB-INF/views/pages/events.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        int userId = (int) session.getAttribute("userId");
        String action = req.getParameter("action");

        try {
            if ("create".equalsIgnoreCase(action)) {
                Event e = new Event();
                e.setUserId(userId);
                e.setTitle(req.getParameter("title"));
                e.setDescription(req.getParameter("description"));
                e.setEventDate(Date.valueOf(req.getParameter("eventDate")));

                String startStr = req.getParameter("startTime");
                if (startStr != null && !startStr.trim().isEmpty()) {
                    if (startStr.length() == 5) startStr += ":00";
                    e.setStartTime(Time.valueOf(startStr));
                }

                String endStr = req.getParameter("endTime");
                if (endStr != null && !endStr.trim().isEmpty()) {
                    if (endStr.length() == 5) endStr += ":00";
                    e.setEndTime(Time.valueOf(endStr));
                }

                e.setCategory(req.getParameter("category"));
                e.setLocation(req.getParameter("location"));
                eventDAO.create(e);
            } else if ("delete".equalsIgnoreCase(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                eventDAO.delete(id, userId);
            }
        } catch (Exception ex) {
            req.getSession().setAttribute("flashError", ex.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/events");
    }
}
