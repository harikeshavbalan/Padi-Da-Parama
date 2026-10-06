package com.studentlife.controller;

import com.studentlife.dao.HolidayDAO;
import com.studentlife.model.Holiday;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Date;
import java.util.List;

@WebServlet(name = "HolidayServlet", urlPatterns = {"/holidays"})
public class HolidayServlet extends HttpServlet {
    private final HolidayDAO holidayDAO = new HolidayDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        int userId = (int) session.getAttribute("userId");

        List<Holiday> holidays = holidayDAO.findAllByUserId(userId);
        Holiday nextHoliday = holidayDAO.findNextHoliday(userId);

        req.setAttribute("holidays", holidays);
        req.setAttribute("nextHoliday", nextHoliday);
        req.setAttribute("activePage", "holidays");

        req.getRequestDispatcher("/WEB-INF/views/pages/holidays.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        int userId = (int) session.getAttribute("userId");
        String action = req.getParameter("action");

        try {
            if ("create".equalsIgnoreCase(action)) {
                Holiday h = new Holiday();
                h.setUserId(userId);
                h.setTitle(req.getParameter("title"));
                h.setHolidayDate(Date.valueOf(req.getParameter("holidayDate")));
                h.setDescription(req.getParameter("description"));
                h.setHolidayType(req.getParameter("holidayType"));
                holidayDAO.create(h);
            } else if ("delete".equalsIgnoreCase(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                holidayDAO.delete(id, userId);
            }
        } catch (Exception e) {
            req.getSession().setAttribute("flashError", e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/holidays");
    }
}
