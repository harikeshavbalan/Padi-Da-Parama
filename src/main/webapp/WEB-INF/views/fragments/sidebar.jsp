<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<aside class="app-sidebar" id="appSidebar">
    <a href="${pageContext.request.contextPath}/dashboard" class="sidebar-brand">
        <span class="brand-badge">PdP</span>
        <span class="brand-text">Padi da Parama!</span>
    </a>

    <nav class="sidebar-nav">
        <div class="nav-section-title">Core Management</div>
        <a href="${pageContext.request.contextPath}/dashboard" class="nav-link ${activePage == 'dashboard' ? 'active' : ''}">
            <span class="nav-icon">📊</span>
            <span>Dashboard</span>
        </a>
        <a href="${pageContext.request.contextPath}/tasks" class="nav-link ${activePage == 'tasks' ? 'active' : ''}">
            <span class="nav-icon">📋</span>
            <span>Tasks</span>
        </a>
        <a href="${pageContext.request.contextPath}/calendar" class="nav-link ${activePage == 'calendar' ? 'active' : ''}">
            <span class="nav-icon">📅</span>
            <span>Calendar</span>
        </a>

        <div class="nav-section-title">Academics</div>
        <a href="${pageContext.request.contextPath}/timetable" class="nav-link ${activePage == 'timetable' ? 'active' : ''}">
            <span class="nav-icon">⏰</span>
            <span>Timetable</span>
        </a>
        <a href="${pageContext.request.contextPath}/deadlines" class="nav-link ${activePage == 'deadlines' ? 'active' : ''}">
            <span class="nav-icon">⏳</span>
            <span>Deadlines</span>
        </a>
        <a href="${pageContext.request.contextPath}/exams" class="nav-link ${activePage == 'exams' ? 'active' : ''}">
            <span class="nav-icon">🎓</span>
            <span>Tests &amp; Exams</span>
        </a>
        <a href="${pageContext.request.contextPath}/subjects" class="nav-link ${activePage == 'subjects' ? 'active' : ''}">
            <span class="nav-icon">📚</span>
            <span>Subjects</span>
        </a>

        <div class="nav-section-title">Personal &amp; Growth</div>
        <a href="${pageContext.request.contextPath}/plans" class="nav-link ${activePage == 'plans' ? 'active' : ''}">
            <span class="nav-icon">🎯</span>
            <span>Plans &amp; Goals</span>
        </a>
        <a href="${pageContext.request.contextPath}/habits" class="nav-link ${activePage == 'habits' ? 'active' : ''}">
            <span class="nav-icon">⚡</span>
            <span>Habits</span>
        </a>
        <a href="${pageContext.request.contextPath}/study-sessions" class="nav-link ${activePage == 'study-sessions' ? 'active' : ''}">
            <span class="nav-icon">⏱️</span>
            <span>Study Sessions</span>
        </a>
        <a href="${pageContext.request.contextPath}/events" class="nav-link ${activePage == 'events' ? 'active' : ''}">
            <span class="nav-icon">🎪</span>
            <span>Events</span>
        </a>
        <a href="${pageContext.request.contextPath}/holidays" class="nav-link ${activePage == 'holidays' ? 'active' : ''}">
            <span class="nav-icon">🏖️</span>
            <span>Holidays</span>
        </a>

        <div class="nav-section-title">Insights &amp; System</div>
        <a href="${pageContext.request.contextPath}/analytics" class="nav-link ${activePage == 'analytics' ? 'active' : ''}">
            <span class="nav-icon">📈</span>
            <span>Analytics</span>
        </a>
        <a href="${pageContext.request.contextPath}/settings" class="nav-link ${activePage == 'settings' ? 'active' : ''}">
            <span class="nav-icon">⚙️</span>
            <span>Settings</span>
        </a>
    </nav>

    <div class="sidebar-footer">
        <a href="${pageContext.request.contextPath}/logout" class="nav-link logout-link">
            <span class="nav-icon">🚪</span>
            <span>Logout</span>
        </a>
    </div>
</aside>
