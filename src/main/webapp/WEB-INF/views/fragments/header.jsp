<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<header class="app-header">
    <div class="header-left">
        <button class="sidebar-toggle-btn" id="sidebarToggleBtn" aria-label="Toggle Sidebar">☰</button>
        <form action="${pageContext.request.contextPath}/tasks" method="GET" class="header-search">
            <span class="search-icon">🔍</span>
            <input type="text" name="q" placeholder="Search tasks, exams, subjects..." value="${param.q}">
        </form>
    </div>

    <div class="header-right">
        <div class="header-date-badge">
            <span>⏱️</span>
            <span id="liveClock" class="font-mono">--:--:--</span>
        </div>

        <a href="${pageContext.request.contextPath}/api/timetable.xml" target="_blank" class="btn btn-sm btn-secondary" title="View XML Syllabus Feed">
            <span>XML Feed</span>
        </a>

        <a href="${pageContext.request.contextPath}/notifications" class="header-action-btn" title="Notifications">
            <span>🔔</span>
            <span class="notif-badge" id="notifBadge" style="display: none;">0</span>
        </a>

        <a href="${pageContext.request.contextPath}/settings" class="user-profile-menu">
            <div class="user-avatar">
                ${sessionScope.currentUser.fullName != null ? sessionScope.currentUser.fullName.substring(0, 1) : 'U'}
            </div>
            <div class="user-details">
                <span class="user-name">${sessionScope.currentUser.fullName != null ? sessionScope.currentUser.fullName : sessionScope.currentUser.username}</span>
                <span class="user-role">Student</span>
            </div>
        </a>
    </div>
</header>
