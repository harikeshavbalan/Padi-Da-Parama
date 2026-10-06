<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta name="color-scheme" content="light">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Study Session Tracker - Padi da Parama!</title>
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
                    <h1 class="page-title">Study Sessions &amp; Time Log</h1>
                    <p class="page-subtitle">Record focused study sessions and analyze subject-wise academic investment.</p>
                </div>
                <button class="btn btn-primary" data-modal-target="logSessionModal">+ Log Study Session</button>
            </div>

            <!-- Aggregated Time Cards -->
            <div class="stat-grid" style="margin-bottom: 2rem;">
                <div class="card stat-card">
                    <div class="stat-header">
                        <span>Today's Study Time</span>
                        <div class="stat-icon" style="background: var(--primary-light); color: var(--primary);">⏱️</div>
                    </div>
                    <div class="stat-value">${todayHours}h ${todayMins}m</div>
                    <div class="stat-footer">Daily academic focus</div>
                </div>

                <div class="card stat-card">
                    <div class="stat-header">
                        <span>This Week</span>
                        <div class="stat-icon" style="background: var(--info-light); color: var(--info);">📅</div>
                    </div>
                    <div class="stat-value">${weekHours}h ${weekMins}m</div>
                    <div class="stat-footer">Weekly cumulative time</div>
                </div>

                <div class="card stat-card">
                    <div class="stat-header">
                        <span>This Month</span>
                        <div class="stat-icon" style="background: var(--success-light); color: var(--success);">📈</div>
                    </div>
                    <div class="stat-value">${monthHours}h ${monthMins}m</div>
                    <div class="stat-footer">Monthly total hours</div>
                </div>

                <div class="card stat-card">
                    <div class="stat-header">
                        <span>Logged Sessions</span>
                        <div class="stat-icon" style="background: var(--purple-light); color: var(--purple);">📝</div>
                    </div>
                    <div class="stat-value">${sessions.size()}</div>
                    <div class="stat-footer">Recorded study intervals</div>
                </div>
            </div>

            <!-- Study Sessions History Table -->
            <div class="card" style="margin-bottom: 2rem;">
                <div class="card-header">
                    <h2 class="card-title">Recorded Sessions History</h2>
                </div>
                <div class="table-responsive">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Subject</th>
                                <th>Related Task</th>
                                <th>Duration</th>
                                <th>Date &amp; Time</th>
                                <th>Notes &amp; Topics Studied</th>
                                <th style="text-align: right;">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty sessions}">
                                    <tr>
                                        <td colspan="6" style="text-align: center; padding: 2.5rem; color: var(--text-muted);">
                                            No study sessions recorded yet. Click "+ Log Study Session" to record your first session!
                                        </td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="s" items="${sessions}">
                                        <tr>
                                            <td>
                                                <span style="font-weight: 700; color: var(--primary);">
                                                    ${s.subjectName != null ? s.subjectName : 'General Study'}
                                                </span>
                                            </td>
                                            <td>
                                                <span style="color: var(--text-secondary);">
                                                    ${s.taskTitle != null ? s.taskTitle : '&mdash;'}
                                                </span>
                                            </td>
                                            <td>
                                                <span class="badge badge-medium">${s.formattedDuration}</span>
                                            </td>
                                            <td>
                                                <span style="font-size: 0.82rem; color: var(--text-muted);">${s.startTime}</span>
                                            </td>
                                            <td>
                                                <span style="font-size: 0.85rem; color: var(--text-secondary);">${s.notes}</span>
                                            </td>
                                            <td style="text-align: right;">
                                                <form action="${pageContext.request.contextPath}/study-sessions" method="POST" onsubmit="return confirm('Delete this study session?');">
                                                    <input type="hidden" name="action" value="delete">
                                                    <input type="hidden" name="id" value="${s.id}">
                                                    <button type="submit" class="btn btn-secondary btn-icon" style="color: var(--danger); font-size: 0.8rem;" title="Delete">🗑️</button>
                                                </form>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>

        </div><!-- /.app-content -->
    </main>
</div>

<!-- Modal: Log Study Session -->
<div class="modal-overlay" id="logSessionModal">
    <div class="modal-dialog">
        <div class="modal-header">
            <h3 class="modal-title">Log Study Session</h3>
            <button class="modal-close" data-modal-close>&times;</button>
        </div>
        <form action="${pageContext.request.contextPath}/study-sessions" method="POST">
            <input type="hidden" name="action" value="create">
            <div class="modal-body">
                <div class="form-group">
                    <label class="form-label" for="sessSubject">Subject</label>
                    <select id="sessSubject" name="subjectId" class="form-control">
                        <option value="">None / General Technical Study</option>
                        <c:forEach var="sb" items="${subjects}">
                            <option value="${sb.id}">${sb.name}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label" for="sessTask">Associated Task (Optional)</label>
                    <select id="sessTask" name="taskId" class="form-control">
                        <option value="">None</option>
                        <c:forEach var="tk" items="${tasks}">
                            <option value="${tk.id}">${tk.title}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label" for="sessDuration">Duration (in Minutes) *</label>
                    <input type="number" id="sessDuration" name="durationMinutes" value="60" min="5" step="5" class="form-control" required>
                </div>
                <div class="form-group">
                    <label class="form-label" for="sessNotes">Topics Studied / Key Learnings</label>
                    <textarea id="sessNotes" name="notes" class="form-control" rows="3" placeholder="What concepts or problem sets did you focus on?"></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-modal-close>Cancel</button>
                <button type="submit" class="btn btn-primary">Save Session</button>
            </div>
        </form>
    </div>
</div>

<jsp:include page="../fragments/footer.jsp" />
