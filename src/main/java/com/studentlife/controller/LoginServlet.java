package com.studentlife.controller;

import com.studentlife.model.User;
import com.studentlife.service.AuthenticationService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "LoginServlet", urlPatterns = {"/login", "/register"})
public class LoginServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(LoginServlet.class.getName());
    private final AuthenticationService authService = new AuthenticationService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("userId") != null) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }

        // Check for remembered username cookie
        Cookie[] cookies = req.getCookies();
        if (cookies != null) {
            for (Cookie c : cookies) {
                if ("rememberUser".equals(c.getName())) {
                    req.setAttribute("rememberedUsername", c.getValue());
                    break;
                }
            }
        }

        req.getRequestDispatcher("/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");

        if ("register".equalsIgnoreCase(action)) {
            handleRegister(req, resp);
        } else {
            handleLogin(req, resp);
        }
    }

    private void handleLogin(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        String username = req.getParameter("username");
        String password = req.getParameter("password");
        String rememberMe = req.getParameter("rememberMe");

        User user = authService.authenticate(username, password);
        if (user != null) {
            HttpSession session = req.getSession(true);
            session.setAttribute("userId", user.getId());
            session.setAttribute("currentUser", user);

            // Handle Remember Username Cookie
            Cookie rememberCookie = new Cookie("rememberUser", user.getUsername());
            if ("on".equalsIgnoreCase(rememberMe) || "true".equalsIgnoreCase(rememberMe)) {
                rememberCookie.setMaxAge(30 * 24 * 60 * 60); // 30 days
                rememberCookie.setPath(req.getContextPath().isEmpty() ? "/" : req.getContextPath());
                rememberCookie.setHttpOnly(true);
                resp.addCookie(rememberCookie);
            } else {
                // Delete cookie if not checked
                rememberCookie.setMaxAge(0);
                rememberCookie.setPath(req.getContextPath().isEmpty() ? "/" : req.getContextPath());
                resp.addCookie(rememberCookie);
            }

            LOGGER.info("Successful login for user: " + user.getUsername());
            resp.sendRedirect(req.getContextPath() + "/dashboard");
        } else {
            LOGGER.log(Level.WARNING, "Failed login attempt for username: {0}", username);
            req.setAttribute("error", "Invalid username or password. Please try again.");
            req.setAttribute("enteredUsername", username);
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
        }
    }

    private void handleRegister(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        String username = req.getParameter("username");
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String fullName = req.getParameter("fullName");

        if (username == null || username.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            password == null || password.trim().isEmpty()) {
            req.setAttribute("error", "All fields are required for registration.");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }

        if (authService.isUsernameTaken(username)) {
            req.setAttribute("error", "Username '" + username + "' is already taken. Please choose another.");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }

        if (authService.isEmailTaken(email)) {
            req.setAttribute("error", "Email '" + email + "' is already registered.");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }

        boolean created = authService.register(username, email, password, fullName);
        if (created) {
            LOGGER.info("Successfully registered new user: " + username);
            resp.sendRedirect(req.getContextPath() + "/login?success=Registration+successful.+Please+log+in.");
        } else {
            req.setAttribute("error", "Registration failed due to a database error. Please try again.");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
        }
    }
}
