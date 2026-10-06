<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta name="color-scheme" content="light">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Account Settings - Padi da Parama!</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css?v=marvel_light_v3">
</head>
<body>
<div class="app-container">
    <jsp:include page="../fragments/sidebar.jsp" />

    <main class="app-main">
        <jsp:include page="../fragments/header.jsp" />

        <div class="app-content">

            <div class="page-header">
                <div>
                    <h1 class="page-title">Settings &amp; Preferences</h1>
                    <p class="page-subtitle">Manage personal profile, authentication credentials, and system defaults.</p>
                </div>
            </div>

            <!-- Alerts -->
            <c:if test="${not empty sessionScope.flashSuccess}">
                <div class="alert alert-success">
                    <span>✓</span>
                    <span>${sessionScope.flashSuccess}</span>
                </div>
                <% session.removeAttribute("flashSuccess"); %>
            </c:if>
            <c:if test="${not empty sessionScope.flashError}">
                <div class="alert alert-danger">
                    <span>⚠️</span>
                    <span>${sessionScope.flashError}</span>
                </div>
                <% session.removeAttribute("flashError"); %>
            </c:if>

            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(340px, 1fr)); gap: 1.5rem;">

                <!-- 1. Profile Information -->
                <div class="card">
                    <div class="card-header">
                        <h2 class="card-title">Profile Information</h2>
                    </div>
                    <form action="${pageContext.request.contextPath}/settings" method="POST">
                        <input type="hidden" name="action" value="updateProfile">
                        <div class="form-group">
                            <label class="form-label" for="profUsername">Username</label>
                            <input type="text" id="profUsername" class="form-control" value="${user.username}" disabled style="opacity: 0.7;">
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="profName">Full Name</label>
                            <input type="text" id="profName" name="fullName" class="form-control" value="${user.fullName}" required>
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="profEmail">Email Address</label>
                            <input type="email" id="profEmail" name="email" class="form-control" value="${user.email}" required>
                        </div>
                        <button type="submit" class="btn btn-primary" style="margin-top: 0.5rem;">Update Profile</button>
                    </form>
                </div>

                <!-- 2. Security & Password -->
                <div class="card">
                    <div class="card-header">
                        <h2 class="card-title">Change Password</h2>
                    </div>
                    <form action="${pageContext.request.contextPath}/settings" method="POST">
                        <input type="hidden" name="action" value="changePassword">
                        <div class="form-group">
                            <label class="form-label" for="currPass">Current Password</label>
                            <input type="password" id="currPass" name="oldPassword" class="form-control" required>
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="newPass">New Password</label>
                            <input type="password" id="newPass" name="newPassword" class="form-control" minlength="6" required>
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="confPass">Confirm New Password</label>
                            <input type="password" id="confPass" name="confirmPassword" class="form-control" minlength="6" required>
                        </div>
                        <button type="submit" class="btn btn-secondary" style="margin-top: 0.5rem;">Change Password</button>
                    </form>
                </div>

                <!-- 3. System Preferences -->
                <div class="card" style="grid-column: 1 / -1;">
                    <div class="card-header">
                        <h2 class="card-title">Application Preferences</h2>
                    </div>
                    <form action="${pageContext.request.contextPath}/settings" method="POST">
                        <input type="hidden" name="action" value="saveSettings">
                        <div class="form-row">
                            <div class="form-group">
                                <label class="form-label" for="prefPriority">Default Task Priority</label>
                                <select id="prefPriority" name="defaultPriority" class="form-control">
                                    <option value="LOW" ${settings.defaultPriority == 'LOW' ? 'selected' : ''}>Low</option>
                                    <option value="MEDIUM" ${settings.defaultPriority == 'MEDIUM' ? 'selected' : ''}>Medium</option>
                                    <option value="HIGH" ${settings.defaultPriority == 'HIGH' ? 'selected' : ''}>High</option>
                                    <option value="URGENT" ${settings.defaultPriority == 'URGENT' ? 'selected' : ''}>Urgent</option>
                                </select>
                            </div>
                            <div class="form-group">
                                <label class="form-label" for="prefWeekStart">Week Start Day</label>
                                <select id="prefWeekStart" name="weekStartDay" class="form-control">
                                    <option value="Monday" ${settings.weekStartDay == 'Monday' ? 'selected' : ''}>Monday</option>
                                    <option value="Sunday" ${settings.weekStartDay == 'Sunday' ? 'selected' : ''}>Sunday</option>
                                </select>
                            </div>
                            <div class="form-group">
                                <label class="form-label" for="prefTheme">Theme Preference</label>
                                <select id="prefTheme" name="themePreference" class="form-control">
                                    <option value="light" ${settings.themePreference == 'light' || empty settings.themePreference ? 'selected' : ''}>Marvel Light Mode (Default)</option>
                                    <option value="dark" ${settings.themePreference == 'dark' ? 'selected' : ''}>Dark Mode</option>
                                </select>
                            </div>
                        </div>

                        <div class="form-group" style="margin-top: 0.5rem;">
                            <label style="display: flex; align-items: center; gap: 0.6rem; cursor: pointer; color: var(--text-secondary); font-size: 0.9rem;">
                                <input type="checkbox" name="remindersEnabled" ${settings.remindersEnabled ? 'checked' : ''}>
                                <span>Enable In-App Upcoming Deadlines &amp; Exam Reminders</span>
                            </label>
                        </div>

                        <button type="submit" class="btn btn-primary" style="margin-top: 1rem;">Save Preferences</button>
                    </form>
                </div>

            </div>

        </div><!-- /.app-content -->
    </main>
</div>

<jsp:include page="../fragments/footer.jsp" />
