package com.studentlife.controller;

import com.studentlife.dao.NotificationDAO;
import com.studentlife.model.Notification;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "NotificationServlet", urlPatterns = {"/notifications"})
public class NotificationServlet extends HttpServlet {
    private final NotificationDAO notificationDAO = new NotificationDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        int userId = (int) session.getAttribute("userId");

        List<Notification> notifications = notificationDAO.findAllByUserId(userId);
        req.setAttribute("notifications", notifications);
        req.setAttribute("activePage", "notifications");

        req.getRequestDispatcher("/WEB-INF/views/pages/notifications.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        int userId = (int) session.getAttribute("userId");
        String action = req.getParameter("action");

        if ("markAllRead".equalsIgnoreCase(action)) {
            notificationDAO.markAllAsRead(userId);
        } else if ("markRead".equalsIgnoreCase(action)) {
            int id = Integer.parseInt(req.getParameter("id"));
            notificationDAO.markAsRead(id, userId);
        }

        resp.sendRedirect(req.getContextPath() + "/notifications");
    }
}
