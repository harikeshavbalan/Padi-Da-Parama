package com.studentlife.controller;

import com.studentlife.model.DashboardSummary;
import com.studentlife.model.User;
import com.studentlife.service.DashboardService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "DashboardServlet", urlPatterns = {"/dashboard"})
public class DashboardServlet extends HttpServlet {
    private final DashboardService dashboardService = new DashboardService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("currentUser");

        DashboardSummary summary = dashboardService.getDashboardSummary(user);
        req.setAttribute("dashboard", summary);
        req.setAttribute("activePage", "dashboard");

        req.getRequestDispatcher("/WEB-INF/views/pages/dashboard.jsp").forward(req, resp);
    }
}
