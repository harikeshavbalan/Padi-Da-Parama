<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="color-scheme" content="light">
    <title>Dashboard - Padi da Parama!</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css?v=marvel_light_v3?v=marvel_light_v3">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/dashboard.css?v=marvel_light_v3">
</head>
<body>
<div class="app-container">
    <jsp:include page="../fragments/sidebar.jsp" />

    <main class="app-main">
        <jsp:include page="../fragments/header.jsp" />

        <div class="app-content">

            <!-- Hero Section with Greeting and Transparent Productivity Score -->
            <div class="dashboard-hero">
                <div>
                    <h1 class="hero-greeting">${dashboard.greeting}</h1>
                    <p class="hero-date">
                        <span>📅</span>
                        <span>${dashboard.currentDateFormatted}</span>
                    </p>
                </div>
                <div class="hero-productivity-badge">
                    <div class="hero-score-val">${dashboard.productivity.overallScore}/100</div>
                    <div class="hero-score-label">Productivity Score</div>
                </div>
            </div>

            <!-- Flash Alerts -->
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

            <!-- 1. Four Core Stat Cards (Real MySQL Counts) -->
            <div class="stat-grid">
                <div class="card stat-card">
                    <div class="stat-header">
                        <span>Today's Tasks</span>
                        <div class="stat-icon" style="background: var(--primary-light); color: var(--primary);">📋</div>
                    </div>
                    <div class="stat-value" id="statToday">${dashboard.todayTaskCount}</div>
                    <div class="stat-footer">Tasks scheduled for today</div>
                </div>

                <div class="card stat-card">
                    <div class="stat-header">
                        <span>Pending Tasks</span>
                        <div class="stat-icon" style="background: var(--info-light); color: var(--info);">⏳</div>
                    </div>
                    <div class="stat-value" id="statPending">${dashboard.pendingTaskCount}</div>
                    <div class="stat-footer">Awaiting action</div>
                </div>

                <div class="card stat-card">
                    <div class="stat-header">
                        <span>Completed Tasks</span>
                        <div class="stat-icon" style="background: var(--success-light); color: var(--success);">✓</div>
                    </div>
                    <div class="stat-value" id="statCompleted">${dashboard.completedTaskCount}</div>
                    <div class="stat-footer">Accomplished overall</div>
                </div>

                <div class="card stat-card">
                    <div class="stat-header">
                        <span>Overdue Tasks</span>
                        <div class="stat-icon" style="background: var(--danger-light); color: var(--danger);">⚠️</div>
                    </div>
                    <div class="stat-value" id="statOverdue" style="color: var(--danger);">${dashboard.overdueTaskCount}</div>
                    <div class="stat-footer">Requires immediate attention</div>
                </div>
            </div>

            <!-- 2. Next Class Highlight Card -->
            <c:if test="${not empty dashboard.nextClass}">
                <div class="next-class-card">
                    <div>
                        <div class="class-tag">Next Class &bull; Today</div>
                        <h2 class="class-title">${dashboard.nextClass.subjectName}</h2>
                        <div class="class-meta">
                            <div class="class-meta-item">
                                <span>⏰</span>
                                <span>${dashboard.nextClass.startTime.toString().substring(0, 5)} - ${dashboard.nextClass.endTime.toString().substring(0, 5)}</span>
                            </div>
                            <div class="class-meta-item">
                                <span>📍</span>
                                <span>Room: ${dashboard.nextClass.room != null ? dashboard.nextClass.room : 'Assigned Lab'}</span>
                            </div>
                            <c:if test="${not empty dashboard.nextClass.faculty}">
                                <div class="class-meta-item">
                                    <span>👤</span>
                                    <span>${dashboard.nextClass.faculty}</span>
                                </div>
                            </c:if>
                        </div>
                    </div>
                    <a href="${pageContext.request.contextPath}/timetable" class="btn btn-secondary btn-sm">Full Timetable →</a>
                </div>
            </c:if>

            <!-- 3. Upcoming Quick Status Row -->
            <div class="upcoming-row">
                <!-- Next Deadline -->
                <div class="upcoming-card">
                    <div class="upcoming-icon" style="background: var(--warning-light); color: var(--warning);">⏳</div>
                    <div class="upcoming-info">
                        <h4>Upcoming Deadline</h4>
                        <p>${dashboard.nextDeadline != null ? dashboard.nextDeadline.title : 'No pending deadlines'}</p>
                        <span class="upcoming-meta">
                            ${dashboard.nextDeadline != null ? dashboard.nextDeadline.remainingText : 'All caught up'}
                        </span>
                    </div>
                </div>

                <!-- Next Test / Exam -->
                <div class="upcoming-card">
                    <div class="upcoming-icon" style="background: var(--danger-light); color: var(--danger);">🎓</div>
                    <div class="upcoming-info" style="flex:1;">
                        <h4>Upcoming Test</h4>
                        <p>${dashboard.nextExam != null ? dashboard.nextExam.title : 'No tests scheduled'}</p>
                        <c:if test="${not empty dashboard.nextExam}">
                            <div style="margin-top: 0.35rem;">
                                <div style="display:flex; justify-content:space-between; font-size:0.75rem; margin-bottom:0.2rem;">
                                    <span>Prep: ${dashboard.nextExam.preparationPercentage}%</span>
                                    <span>${dashboard.nextExam.countdownText}</span>
                                </div>
                                <div class="progress-container">
                                    <div class="progress-bar progress-bar-warning" style="width: ${dashboard.nextExam.preparationPercentage}%;"></div>
                                </div>
                            </div>
                        </c:if>
                    </div>
                </div>

                <!-- Next Holiday -->
                <div class="upcoming-card">
                    <div class="upcoming-icon" style="background: var(--purple-light); color: var(--purple);">🏖️</div>
                    <div class="upcoming-info">
                        <h4>Next Holiday</h4>
                        <p>${dashboard.nextHoliday != null ? dashboard.nextHoliday.title : 'None announced'}</p>
                        <span class="upcoming-meta">
                            ${dashboard.nextHoliday != null ? dashboard.nextHoliday.countdownText : 'Regular schedule'}
                        </span>
                    </div>
                </div>

                <!-- Study Time -->
                <div class="upcoming-card">
                    <div class="upcoming-icon" style="background: var(--success-light); color: var(--success);">⏱️</div>
                    <div class="upcoming-info">
                        <h4>Study Time</h4>
                        <p>Today: ${dashboard.formattedTodayStudy}</p>
                        <span class="upcoming-meta">This Week: ${dashboard.formattedWeekStudy}</span>
                    </div>
                </div>
            </div>

            <!-- 4. Two-Column Core Dashboard: Today's Tasks + Habits & Productivity -->
            <div class="dashboard-grid">

                <!-- Left Column: Today's Interactive Tasks Checklist -->
                <div class="card">
                    <div class="card-header">
                        <h2 class="card-title">
                            <span>📋</span>
                            <span>Today's Tasks</span>
                        </h2>
                        <button class="btn btn-primary btn-sm" data-modal-target="quickTaskModal">+ Add Task</button>
                    </div>

                    <c:choose>
                        <c:when test="${empty dashboard.todayTasks}">
                            <div class="empty-state" style="text-align: center; padding: 2.5rem 1rem; color: var(--text-muted);">
                                <p style="font-size: 1.5rem; margin-bottom: 0.5rem;">🎉</p>
                                <p>No tasks scheduled for today! Enjoy your free time or add one above.</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <ul class="task-checklist">
                                <c:forEach var="task" items="${dashboard.todayTasks}">
                                    <li class="task-item ${task.completed ? 'completed' : ''}">
                                        <div class="task-left">
                                            <div class="custom-checkbox ${task.completed ? 'checked' : ''}"
                                                 onclick="toggleTaskAjax(${task.id}, this)">
                                                ${task.completed ? '✓' : ''}
                                            </div>
                                            <div>
                                                <div class="task-title">${task.title}</div>
                                                <div class="task-subtext">
                                                    <c:if test="${not empty task.subjectName}">
                                                        <span style="color: ${task.subjectColor != null ? task.subjectColor : 'var(--primary)'}; font-weight: 600;">
                                                            ${task.subjectName}
                                                        </span>
                                                        <span>&bull;</span>
                                                    </c:if>
                                                    <span>${task.category}</span>
                                                    <span>&bull;</span>
                                                    <span>${task.dueTime != null ? task.dueTime.toString().substring(0, 5) : 'All Day'}</span>
                                                </div>
                                            </div>
                                        </div>
                                        <div>
                                            <span class="badge badge-${task.priority.toLowerCase()}">${task.priority}</span>
                                        </div>
                                    </li>
                                </c:forEach>
                            </ul>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- Right Column: Habits Tracker & Productivity Score Breakdown -->
                <div style="display: flex; flex-direction: column; gap: 1.5rem;">

                    <!-- Habits Tracker -->
                    <div class="card">
                        <div class="card-header">
                            <h2 class="card-title">
                                <span>⚡</span>
                                <span>Habits</span>
                            </h2>
                            <span class="habit-streak-badge">🔥 ${dashboard.currentStreak} Day Streak</span>
                        </div>

                        <div class="habit-list">
                            <c:forEach var="habit" items="${dashboard.habits}">
                                <div class="habit-item">
                                    <div>
                                        <div class="habit-name">${habit.name}</div>
                                        <div style="font-size: 0.72rem; color: var(--text-muted);">${habit.category}</div>
                                    </div>
                                    <button type="button"
                                            class="habit-toggle-btn ${habit.completedToday ? 'done' : 'pending'}"
                                            onclick="toggleHabitAjax(${habit.id}, this)"
                                            title="Click to toggle today's completion">
                                        ${habit.completedToday ? '✓' : '✗'}
                                    </button>
                                </div>
                            </c:forEach>
                        </div>
                    </div>

                    <!-- Transparent Productivity Calculation Breakdown -->
                    <div class="card">
                        <div class="card-header">
                            <h2 class="card-title">
                                <span>📊</span>
                                <span>Productivity Score</span>
                            </h2>
                            <span class="badge badge-medium">${dashboard.productivity.overallScore}%</span>
                        </div>

                        <div class="score-breakdown">
                            <div class="breakdown-row">
                                <div class="breakdown-label">
                                    <span>Task Completion (40%)</span>
                                    <span>${Math.round(dashboard.productivity.taskCompletionRate)}%</span>
                                </div>
                                <div class="progress-container">
                                    <div class="progress-bar progress-bar-success" style="width: ${dashboard.productivity.taskCompletionRate}%;"></div>
                                </div>
                            </div>

                            <div class="breakdown-row">
                                <div class="breakdown-label">
                                    <span>Deadline Adherence (25%)</span>
                                    <span>${Math.round(dashboard.productivity.deadlineAdherenceRate)}%</span>
                                </div>
                                <div class="progress-container">
                                    <div class="progress-bar" style="width: ${dashboard.productivity.deadlineAdherenceRate}%;"></div>
                                </div>
                            </div>

                            <div class="breakdown-row">
                                <div class="breakdown-label">
                                    <span>Study Session Target (20%)</span>
                                    <span>${Math.round(dashboard.productivity.studyTargetRate)}%</span>
                                </div>
                                <div class="progress-container">
                                    <div class="progress-bar progress-bar-warning" style="width: ${dashboard.productivity.studyTargetRate}%;"></div>
                                </div>
                            </div>

                            <div class="breakdown-row">
                                <div class="breakdown-label">
                                    <span>Habit Consistency (15%)</span>
                                    <span>${Math.round(dashboard.productivity.habitCompletionRate)}%</span>
                                </div>
                                <div class="progress-container">
                                    <div class="progress-bar" style="width: ${dashboard.productivity.habitCompletionRate}%;"></div>
                                </div>
                            </div>
                        </div>
                    </div>

                </div>

            </div>

        </div><!-- /.app-content -->
    </main>
</div>

<!-- Modal: Quick Add Task -->
<div class="modal-overlay" id="quickTaskModal">
    <div class="modal-dialog">
        <div class="modal-header">
            <h3 class="modal-title">Add Today's Task</h3>
            <button class="modal-close" data-modal-close>&times;</button>
        </div>
        <form action="${pageContext.request.contextPath}/tasks" method="POST">
            <input type="hidden" name="action" value="create">
            <input type="hidden" name="dueDate" value="${dashboard.currentDateFormatted}">
            <div class="modal-body">
                <div class="form-group">
                    <label class="form-label" for="taskTitle">Task Title *</label>
                    <input type="text" id="taskTitle" name="title" class="form-control" placeholder="e.g. Study Web Technology Unit 1" required>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="taskCategory">Category</label>
                        <select id="taskCategory" name="category" class="form-control">
                            <option value="Academic">Academic</option>
                            <option value="Assignment">Assignment</option>
                            <option value="Lab">Lab</option>
                            <option value="Project">Project</option>
                            <option value="Personal">Personal</option>
                            <option value="Club">Club</option>
                            <option value="Other">Other</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="taskPriority">Priority</label>
                        <select id="taskPriority" name="priority" class="form-control">
                            <option value="LOW">Low</option>
                            <option value="MEDIUM" selected>Medium</option>
                            <option value="HIGH">High</option>
                            <option value="URGENT">Urgent</option>
                        </select>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-modal-close>Cancel</button>
                <button type="submit" class="btn btn-primary">Save Task</button>
            </div>
        </form>
    </div>
</div>

<jsp:include page="../fragments/footer.jsp" />
