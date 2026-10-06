package com.studentlife.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;

/**
 * AuthenticationFilter enforces session authentication.
 * Protects all student productivity modules.
 * Redirects unauthenticated requests to login.jsp with informative context.
 */
@WebFilter(filterName = "AuthenticationFilter", urlPatterns = {"/*"})
public class AuthenticationFilter implements Filter {

    private static final List<String> PUBLIC_PATHS = Arrays.asList(
            "/login",
            "/logout",
            "/register",
            "/login.jsp",
            "/index.jsp",
            "/assets/",
            "/css/",
            "/js/",
            "/images/",
            "/api/check-username",
            "/api/timetable.xml",
            "/api/tasks.xml"
    );

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        // Force UTF-8 Encoding
        req.setCharacterEncoding("UTF-8");
        res.setCharacterEncoding("UTF-8");

        String contextPath = req.getContextPath();
        String path = req.getRequestURI().substring(contextPath.length());

        // Root path is redirected to dashboard or login
        if (path.isEmpty() || "/".equals(path)) {
            HttpSession session = req.getSession(false);
            if (session != null && session.getAttribute("userId") != null) {
                res.sendRedirect(contextPath + "/dashboard");
            } else {
                res.sendRedirect(contextPath + "/login");
            }
            return;
        }

        // Allow public paths
        boolean isPublic = false;
        for (String pub : PUBLIC_PATHS) {
            if (path.startsWith(pub)) {
                isPublic = true;
                break;
            }
        }

        if (isPublic) {
            chain.doFilter(request, response);
            return;
        }

        // Check authentication session
        HttpSession session = req.getSession(false);
        boolean isLoggedIn = (session != null && session.getAttribute("userId") != null);

        if (isLoggedIn) {
            // Prevent caching sensitive authenticated pages
            res.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
            res.setHeader("Pragma", "no-cache"); // HTTP 1.0
            res.setDateHeader("Expires", 0); // Proxies
            chain.doFilter(request, response);
        } else {
            // Check if AJAX request
            String requestedWith = req.getHeader("X-Requested-With");
            if ("XMLHttpRequest".equalsIgnoreCase(requestedWith) || path.startsWith("/api/")) {
                res.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                res.setContentType("application/json");
                res.getWriter().write("{\"error\": \"Unauthorized\", \"redirect\": \"" + contextPath + "/login\"}");
            } else {
                res.sendRedirect(contextPath + "/login?error=Please+login+to+access+the+system");
            }
        }
    }

    @Override
    public void destroy() {}
}
