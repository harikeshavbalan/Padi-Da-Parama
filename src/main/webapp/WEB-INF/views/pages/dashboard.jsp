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

            <!-- 2. Class Command Center: Real-Time Day & Time Based Classes Indication -->
            <div class="class-command-center">
                <div class="class-command-header">
                    <div class="class-command-title-group">
                        <h2 class="class-command-title">
                            <span>⚡</span>
                            <span>Class Schedule &amp; Day Tracker</span>
                        </h2>
                        <div class="live-time-indicator">
                            <span>📍 CIT B.E. CSE V-Sem &bull; 📅 ${dashboard.currentDayName} &bull;</span>
                            <span class="live-time-clock" id="liveClockDisplay">--:--:-- --</span>
                        </div>
                    </div>
                    <a href="${pageContext.request.contextPath}/timetable" class="btn btn-secondary btn-sm">Full Timetable View &rarr;</a>
                </div>

                <!-- Spotlight Card: Real-Time Time-Based Indication -->
                <c:choose>
                    <%-- Case A: Class is Happening Right Now --%>
                    <c:when test="${not empty dashboard.currentClass}">
                        <div class="class-spotlight-card spotlight-live" id="spotlightCard">
                            <div>
                                <div class="spotlight-tag-row">
                                    <span class="spotlight-tag tag-live">
                                        <span class="pulse-dot"></span> LIVE NOW &bull; IN SESSION
                                    </span>
                                    <c:if test="${not empty dashboard.currentClass.courseCode}">
                                        <span class="badge badge-primary">${dashboard.currentClass.courseCode}</span>
                                    </c:if>
                                </div>
                                <h3 class="spotlight-title">${dashboard.currentClass.subjectName}</h3>
                                <div class="spotlight-meta-list">
                                    <div class="spotlight-meta-item">
                                        <span>⏰</span>
                                        <span>${dashboard.currentClass.formattedStartTime} - ${dashboard.currentClass.formattedEndTime} (${dashboard.currentClass.durationFormatted})</span>
                                    </div>
                                    <div class="spotlight-meta-item">
                                        <span>📍</span>
                                        <span>Room: <strong>${dashboard.currentClass.room != null ? dashboard.currentClass.room : 'Assigned Lab'}</strong></span>
                                    </div>
                                    <c:if test="${not empty dashboard.currentClass.faculty}">
                                        <div class="spotlight-meta-item">
                                            <span>👤</span>
                                            <span>Faculty: <strong>${dashboard.currentClass.faculty}</strong></span>
                                        </div>
                                    </c:if>
                                </div>
                                <div class="spotlight-progress-wrap">
                                    <div class="spotlight-progress-info">
                                        <span id="spotlightTimeRemaining">Class in progress</span>
                                        <span id="spotlightProgressPercent">--%</span>
                                    </div>
                                    <div class="progress-container">
                                        <div class="progress-bar progress-bar-danger" id="spotlightProgressBar" style="width: 50%;"></div>
                                    </div>
                                </div>
                            </div>
                            <div>
                                <button type="button" class="btn btn-primary btn-sm" onclick="switchScheduleDay('${dashboard.currentClass.dayOfWeek}')">View Today's Flow &darr;</button>
                            </div>
                        </div>
                    </c:when>

                    <%-- Case B: Next Class Upcoming Today --%>
                    <c:when test="${not empty dashboard.nextClass and dashboard.nextClass.dayOfWeek.equalsIgnoreCase(dashboard.currentDayName)}">
                        <div class="class-spotlight-card spotlight-upcoming" id="spotlightCard">
                            <div>
                                <div class="spotlight-tag-row">
                                    <span class="spotlight-tag tag-upcoming">⏰ UPCOMING NEXT TODAY</span>
                                    <c:if test="${not empty dashboard.nextClass.courseCode}">
                                        <span class="badge badge-warning">${dashboard.nextClass.courseCode}</span>
                                    </c:if>
                                </div>
                                <h3 class="spotlight-title">${dashboard.nextClass.subjectName}</h3>
                                <div class="spotlight-meta-list">
                                    <div class="spotlight-meta-item">
                                        <span>⏰</span>
                                        <span>Starts at: <strong>${dashboard.nextClass.formattedStartTime}</strong> - ${dashboard.nextClass.formattedEndTime}</span>
                                    </div>
                                    <div class="spotlight-meta-item">
                                        <span>📍</span>
                                        <span>Room: <strong>${dashboard.nextClass.room != null ? dashboard.nextClass.room : 'Assigned Lab'}</strong></span>
                                    </div>
                                    <c:if test="${not empty dashboard.nextClass.faculty}">
                                        <div class="spotlight-meta-item">
                                            <span>👤</span>
                                            <span>Faculty: <strong>${dashboard.nextClass.faculty}</strong></span>
                                        </div>
                                    </c:if>
                                </div>
                            </div>
                            <div>
                                <button type="button" class="btn btn-secondary btn-sm" onclick="switchScheduleDay('${dashboard.currentDayName}')">View Today's Timeline &darr;</button>
                            </div>
                        </div>
                    </c:when>

                    <%-- Case C: All Classes Finished Today --%>
                    <c:when test="${dashboard.hasClassesToday}">
                        <div class="class-spotlight-card spotlight-completed" id="spotlightCard">
                            <div>
                                <div class="spotlight-tag-row">
                                    <span class="spotlight-tag tag-completed">&check; CLASSES COMPLETED FOR TODAY</span>
                                </div>
                                <h3 class="spotlight-title">All ${dashboard.classesTodayCount} lectures finished for ${dashboard.currentDayName}!</h3>
                                <div class="spotlight-meta-list">
                                    <div class="spotlight-meta-item">
                                        <span>🎉</span>
                                        <span>All scheduled classes for today have concluded.</span>
                                    </div>
                                    <c:if test="${not empty dashboard.nextClass}">
                                        <div class="spotlight-meta-item">
                                            <span>👉 Next upcoming: <strong>${dashboard.nextClass.subjectName}</strong> (${dashboard.nextClass.dayOfWeek} at ${dashboard.nextClass.formattedStartTime})</span>
                                        </div>
                                    </c:if>
                                </div>
                            </div>
                            <div>
                                <button type="button" class="btn btn-secondary btn-sm" onclick="switchScheduleDay('${dashboard.nextClass != null ? dashboard.nextClass.dayOfWeek : 'Monday'}')">Preview Next Day &rarr;</button>
                            </div>
                        </div>
                    </c:when>

                    <%-- Case D: Weekend or No Classes Today --%>
                    <c:otherwise>
                        <div class="class-spotlight-card spotlight-free" id="spotlightCard">
                            <div>
                                <div class="spotlight-tag-row">
                                    <span class="spotlight-tag tag-free">&#127958; NO CLASSES TODAY</span>
                                </div>
                                <h3 class="spotlight-title">No lectures scheduled on ${dashboard.currentDayName}</h3>
                                <div class="spotlight-meta-list">
                                    <div class="spotlight-meta-item">
                                        <span>🌴</span>
                                        <span>Free day! Check the day tabs below to plan or review the week ahead.</span>
                                    </div>
                                    <c:if test="${not empty dashboard.nextClass}">
                                        <div class="spotlight-meta-item">
                                            <span>👉 Next class: <strong>${dashboard.nextClass.subjectName}</strong> on <strong>${dashboard.nextClass.dayOfWeek}</strong> at <strong>${dashboard.nextClass.formattedStartTime}</strong></span>
                                        </div>
                                    </c:if>
                                </div>
                            </div>
                            <div>
                                <button type="button" class="btn btn-secondary btn-sm" onclick="switchScheduleDay('Monday')">View Monday Classes &rarr;</button>
                            </div>
                        </div>
                    </c:otherwise>
                </c:choose>

                <!-- Day Selector Navigation Tabs (Day-Based Indication) -->
                <div class="day-tab-nav" role="tablist">
                    <c:forEach var="dayEntry" items="${dashboard.scheduleByDayMap}">
                        <c:set var="tabDay" value="${dayEntry.key}" />
                        <c:set var="tabClasses" value="${dayEntry.value}" />
                        <c:set var="isTodayTab" value="${tabDay.equalsIgnoreCase(dashboard.currentDayName)}" />
                        <button type="button"
                                class="day-tab-btn ${isTodayTab ? 'active' : ''}"
                                onclick="switchScheduleDay('${tabDay}')"
                                id="tab-btn-${tabDay}">
                            <span>${tabDay}</span>
                            <c:if test="${isTodayTab}">
                                <span class="tab-today-badge">Today</span>
                            </c:if>
                            <span class="tab-count-pill">${tabClasses.size()}</span>
                        </button>
                    </c:forEach>
                </div>

                <!-- Day Schedule Panels (Time-Based Indication for Each Lecture) -->
                <div class="day-panels-container">
                    <c:forEach var="dayEntry" items="${dashboard.scheduleByDayMap}">
                        <c:set var="panelDay" value="${dayEntry.key}" />
                        <c:set var="panelClasses" value="${dayEntry.value}" />
                        <c:set var="isTodayPanel" value="${panelDay.equalsIgnoreCase(dashboard.currentDayName)}" />
                        <div class="day-schedule-panel ${isTodayPanel ? 'active' : ''}" id="day-panel-${panelDay}">
                            <c:choose>
                                <c:when test="${empty panelClasses}">
                                    <div class="class-empty-day-state">
                                        <div class="class-empty-icon">&#127796;</div>
                                        <div class="class-empty-title">No Classes Scheduled for ${panelDay}</div>
                                        <p class="class-empty-desc">No academic lectures or lab sessions scheduled for this day. Free time for revision, self-study, or assignments.</p>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="class-timeline-grid">
                                        <c:forEach var="cls" items="${panelClasses}">
                                            <div class="class-item-card"
                                                 data-day="${cls.dayOfWeek}"
                                                 data-start-mins="${cls.startMinutesOfDay}"
                                                 data-end-mins="${cls.endMinutesOfDay}"
                                                 data-start-str="${cls.formattedStartTime}"
                                                 data-end-str="${cls.formattedEndTime}"
                                                 id="class-card-${cls.id}">
                                                <div>
                                                    <div class="class-item-header">
                                                        <div class="class-time-slot">
                                                            <span>⏰</span>
                                                            <span>${cls.formattedStartTime} - ${cls.formattedEndTime}</span>
                                                            <span class="class-duration-chip">${cls.durationFormatted}</span>
                                                        </div>
                                                        <span class="class-status-pill status-pill-scheduled" id="status-pill-${cls.id}">
                                                            📅 Scheduled
                                                        </span>
                                                    </div>
                                                    <div class="class-subject-title">${cls.subjectName}</div>
                                                    <c:if test="${not empty cls.courseCode}">
                                                        <div class="class-course-code">${cls.courseCode}</div>
                                                    </c:if>
                                                </div>
                                                <div class="class-meta-details">
                                                    <div><span>📍</span> <strong>Room:</strong> ${cls.room != null ? cls.room : 'Assigned Lab'}</div>
                                                    <c:if test="${not empty cls.faculty}">
                                                        <div><span>👤</span> <strong>Faculty:</strong> ${cls.faculty}</div>
                                                    </c:if>
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </c:forEach>
                </div>
            </div>

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

<!-- Real-time Class & Day Tracker Script -->
<script>
    function switchScheduleDay(targetDay) {
        if (!targetDay) return;
        document.querySelectorAll('.day-tab-btn').forEach(function(btn) {
            btn.classList.remove('active');
        });
        document.querySelectorAll('.day-schedule-panel').forEach(function(panel) {
            panel.classList.remove('active');
        });

        var targetBtn = document.getElementById('tab-btn-' + targetDay);
        var targetPanel = document.getElementById('day-panel-' + targetDay);
        if (targetBtn) targetBtn.classList.add('active');
        if (targetPanel) targetPanel.classList.add('active');
    }

    function updateClassTracker() {
        var now = new Date();

        // 1. Live Clock Display
        var clockEl = document.getElementById('liveClockDisplay');
        if (clockEl) {
            clockEl.textContent = now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', second: '2-digit' });
        }

        var days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
        var currentDayName = days[now.getDay()];
        var currentMins = now.getHours() * 60 + now.getMinutes();

        // 2. Class Cards Dynamic Status Updates
        var cards = document.querySelectorAll('.class-item-card');
        cards.forEach(function(card) {
            var cardDay = card.getAttribute('data-day');
            var startMins = parseInt(card.getAttribute('data-start-mins') || '0', 10);
            var endMins = parseInt(card.getAttribute('data-end-mins') || '0', 10);
            var cardId = card.id.replace('class-card-', '');
            var pill = document.getElementById('status-pill-' + cardId);

            if (cardDay && cardDay.toLowerCase() === currentDayName.toLowerCase()) {
                if (currentMins >= startMins && currentMins < endMins) {
                    // LIVE NOW
                    card.classList.add('is-live');
                    card.classList.remove('is-completed');
                    if (pill) {
                        pill.className = 'class-status-pill status-pill-live';
                        pill.innerHTML = '<span class="pulse-dot"></span> LIVE NOW';
                    }

                    // Update spotlight progress if available
                    var progressBar = document.getElementById('spotlightProgressBar');
                    var progressPercent = document.getElementById('spotlightProgressPercent');
                    var timeRem = document.getElementById('spotlightTimeRemaining');
                    if (progressBar && progressPercent && timeRem) {
                        var elapsed = currentMins - startMins;
                        var total = endMins - startMins;
                        var pct = total > 0 ? Math.min(100, Math.max(0, Math.round((elapsed / total) * 100))) : 50;
                        var remMins = endMins - currentMins;
                        progressBar.style.width = pct + '%';
                        progressPercent.textContent = pct + '% elapsed';
                        timeRem.textContent = remMins + ' min' + (remMins === 1 ? '' : 's') + ' remaining';
                    }
                } else if (currentMins < startMins) {
                    // UPCOMING TODAY
                    card.classList.remove('is-live');
                    card.classList.remove('is-completed');
                    var diff = startMins - currentMins;
                    var text = 'Starts in ' + diff + 'm';
                    if (diff >= 60) {
                        var h = Math.floor(diff / 60);
                        var m = diff % 60;
                        text = 'Starts in ' + h + 'h' + (m > 0 ? ' ' + m + 'm' : '');
                    }
                    if (pill) {
                        pill.className = 'class-status-pill status-pill-upcoming';
                        pill.textContent = '⏰ ' + text;
                    }
                } else {
                    // COMPLETED TODAY
                    card.classList.remove('is-live');
                    card.classList.add('is-completed');
                    if (pill) {
                        pill.className = 'class-status-pill status-pill-completed';
                        pill.textContent = '✓ Finished';
                    }
                }
            } else {
                // OTHER DAYS
                card.classList.remove('is-live');
                card.classList.remove('is-completed');
                if (pill) {
                    pill.className = 'class-status-pill status-pill-scheduled';
                    pill.textContent = '📅 Scheduled';
                }
            }
        });
    }

    document.addEventListener('DOMContentLoaded', function() {
        updateClassTracker();
        setInterval(updateClassTracker, 1000);
    });
</script>

<jsp:include page="../fragments/footer.jsp" />
