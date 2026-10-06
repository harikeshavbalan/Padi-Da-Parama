package com.studentlife.controller;

import com.studentlife.model.Plan;
import com.studentlife.service.PlanService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Date;
import java.util.List;

@WebServlet(name = "PlanServlet", urlPatterns = {"/plans"})
public class PlanServlet extends HttpServlet {
    private final PlanService planService = new PlanService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        int userId = (int) session.getAttribute("userId");

        List<Plan> plans = planService.getPlans(userId);
        req.setAttribute("plans", plans);
        req.setAttribute("activePage", "plans");

        req.getRequestDispatcher("/WEB-INF/views/pages/plans.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        int userId = (int) session.getAttribute("userId");
        String action = req.getParameter("action");

        try {
            if ("create".equalsIgnoreCase(action)) {
                Plan p = parsePlan(req, userId);
                planService.createPlan(p);
            } else if ("update".equalsIgnoreCase(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                Plan p = parsePlan(req, userId);
                p.setId(id);
                planService.updatePlan(p);
            } else if ("delete".equalsIgnoreCase(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                planService.deletePlan(id, userId);
            } else if ("updateProgress".equalsIgnoreCase(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                int progress = Integer.parseInt(req.getParameter("progress"));
                String status = req.getParameter("status");
                planService.updateProgress(id, userId, progress, status);
            }
        } catch (Exception e) {
            req.getSession().setAttribute("flashError", e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/plans");
    }

    private Plan parsePlan(HttpServletRequest req, int userId) {
        Plan p = new Plan();
        p.setUserId(userId);
        p.setTitle(req.getParameter("title"));
        p.setDescription(req.getParameter("description"));

        String sDate = req.getParameter("startDate");
        if (sDate != null && !sDate.trim().isEmpty()) {
            p.setStartDate(Date.valueOf(sDate.trim()));
        }

        String tDate = req.getParameter("targetDate");
        if (tDate != null && !tDate.trim().isEmpty()) {
            p.setTargetDate(Date.valueOf(tDate.trim()));
        }

        p.setPriority(req.getParameter("priority"));
        String progStr = req.getParameter("progress");
        if (progStr != null && !progStr.trim().isEmpty()) {
            p.setProgress(Integer.parseInt(progStr.trim()));
        }
        p.setStatus(req.getParameter("status") != null ? req.getParameter("status") : "PLANNED");
        return p;
    }
}
