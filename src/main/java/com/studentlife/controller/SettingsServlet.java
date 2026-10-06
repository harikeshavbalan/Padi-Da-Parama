package com.studentlife.controller;

import com.studentlife.dao.UserSettingsDAO;
import com.studentlife.model.User;
import com.studentlife.model.UserSettings;
import com.studentlife.service.AuthenticationService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "SettingsServlet", urlPatterns = {"/settings"})
public class SettingsServlet extends HttpServlet {
    private final UserSettingsDAO settingsDAO = new UserSettingsDAO();
    private final AuthenticationService authService = new AuthenticationService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        int userId = (int) session.getAttribute("userId");

        User user = authService.getUserById(userId);
        UserSettings settings = settingsDAO.findByUserId(userId);

        req.setAttribute("user", user);
        req.setAttribute("settings", settings);
        req.setAttribute("activePage", "settings");

        req.getRequestDispatcher("/WEB-INF/views/pages/settings.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        int userId = (int) session.getAttribute("userId");
        String action = req.getParameter("action");

        try {
            if ("updateProfile".equalsIgnoreCase(action)) {
                String fullName = req.getParameter("fullName");
                String email = req.getParameter("email");
                boolean updated = authService.updateProfile(userId, fullName, email);
                if (updated) {
                    User refreshed = authService.getUserById(userId);
                    session.setAttribute("currentUser", refreshed);
                    req.getSession().setAttribute("flashSuccess", "Profile updated successfully!");
                } else {
                    req.getSession().setAttribute("flashError", "Failed to update profile.");
                }
            } else if ("changePassword".equalsIgnoreCase(action)) {
                String oldPass = req.getParameter("oldPassword");
                String newPass = req.getParameter("newPassword");
                String confirmPass = req.getParameter("confirmPassword");

                if (!newPass.equals(confirmPass)) {
                    req.getSession().setAttribute("flashError", "New passwords do not match.");
                } else {
                    boolean changed = authService.changePassword(userId, oldPass, newPass);
                    if (changed) {
                        req.getSession().setAttribute("flashSuccess", "Password changed successfully!");
                    } else {
                        req.getSession().setAttribute("flashError", "Incorrect current password.");
                    }
                }
            } else if ("saveSettings".equalsIgnoreCase(action)) {
                UserSettings s = new UserSettings();
                s.setUserId(userId);
                s.setDefaultPriority(req.getParameter("defaultPriority"));
                s.setWeekStartDay(req.getParameter("weekStartDay"));
                s.setRemindersEnabled("on".equalsIgnoreCase(req.getParameter("remindersEnabled")) || "true".equalsIgnoreCase(req.getParameter("remindersEnabled")));
                s.setThemePreference(req.getParameter("themePreference"));
                settingsDAO.saveOrUpdate(s);
                req.getSession().setAttribute("flashSuccess", "Preferences saved successfully!");
            }
        } catch (Exception e) {
            req.getSession().setAttribute("flashError", e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/settings");
    }
}
