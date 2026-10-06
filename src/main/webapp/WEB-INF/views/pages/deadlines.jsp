<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta name="color-scheme" content="light">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Deadlines &amp; Reminders - Padi da Parama!</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css?v=marvel_light_v3">
    <style>
        .deadline-section {
            margin-bottom: 2rem;
        }
        .deadline-section-title {
            font-size: 1.15rem;
            font-weight: 700;
            color: var(--text-primary);
            font-family: var(--font-sans);
            display: flex;
            align-items: center;
            gap: 0.5rem;
            margin-bottom: 1rem;
        }
        .deadline-card {
            background: #ffffff;
            border: 1px solid var(--border-color);
            border-radius: var(--radius-md);
            padding: 1rem 1.25rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 0.75rem;
            box-shadow: var(--shadow-sm);
            transition: var(--transition);
        }
        .deadline-card:hover {
            border-color: var(--marvel-red-border);
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(237, 29, 36, 0.08);
        }
        .deadline-card.overdue { border-left: 6px solid var(--marvel-red); }
        .deadline-card.today { border-left: 6px solid var(--warning); }
        .deadline-card.upcoming { border-left: 6px solid var(--info); }
        .deadline-card.completed { border-left: 6px solid var(--success); opacity: 0.75; }
        .dl-title { font-size: 1.05rem; font-weight: 700; color: var(--text-primary); font-family: var(--font-sans); }
        .dl-meta { font-size: 0.82rem; color: var(--text-secondary); display: flex; gap: 0.75rem; margin-top: 0.2rem; }
    </style>
</head>
<body>
<div class="app-container">
    <jsp:include page="../fragments/sidebar.jsp" />

    <main class="app-main">
        <jsp:include page="../fragments/header.jsp" />

        <div class="app-content">

            <div class="page-header">
                <div>
                    <h1 class="page-title">Deadlines &amp; Deliverables</h1>
                    <p class="page-subtitle">Categorized timeline tracking urgent academic submissions and due dates.</p>
                </div>
                <button class="btn btn-primary" data-modal-target="addDeadlineModal">+ Add Deadline</button>
            </div>

            <!-- 1. Overdue Section -->
            <c:if test="${not empty overdue}">
                <div class="deadline-section">
                    <h2 class="deadline-section-title" style="color: var(--danger);">
                        <span>⚠️</span>
                        <span>Overdue Submissions (${overdue.size()})</span>
                    </h2>
                    <c:forEach var="d" items="${overdue}">
                        <div class="deadline-card overdue">
                            <div>
                                <div class="dl-title">${d.title}</div>
                                <div class="dl-meta">
                                    <span style="color: var(--danger); font-weight: 700;">${d.remainingText}</span>
                                    <span>&bull;</span>
                                    <span>Due: ${d.dueDate} ${d.dueTime != null ? d.dueTime.toString().substring(0, 5) : ''}</span>
                                    <c:if test="${not empty d.subjectName}">
                                        <span>&bull;</span>
                                        <span>${d.subjectName}</span>
                                    </c:if>
                                </div>
                            </div>
                            <div style="display:flex; align-items:center; gap:0.5rem;">
                                <form action="${pageContext.request.contextPath}/deadlines" method="POST" style="display:inline;">
                                    <input type="hidden" name="action" value="toggle">
                                    <input type="hidden" name="id" value="${d.id}">
                                    <button type="submit" class="btn btn-success btn-sm">Mark Resolved ✓</button>
                                </form>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:if>

            <!-- 2. Due Today -->
            <div class="deadline-section">
                <h2 class="deadline-section-title" style="color: var(--warning);">
                    <span>🔥</span>
                    <span>Due Today (${dueToday.size()})</span>
                </h2>
                <c:choose>
                    <c:when test="${empty dueToday}">
                        <div style="color: var(--text-muted); font-size: 0.88rem; padding: 0.5rem 0;">No deadlines due today.</div>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="d" items="${dueToday}">
                            <div class="deadline-card today">
                                <div>
                                    <div class="dl-title">${d.title}</div>
                                    <div class="dl-meta">
                                        <span style="color: var(--warning); font-weight: 700;">Due Tonight</span>
                                        <span>&bull;</span>
                                        <span>Time: ${d.dueTime != null ? d.dueTime.toString().substring(0, 5) : 'End of day'}</span>
                                        <c:if test="${not empty d.subjectName}">
                                            <span>&bull;</span>
                                            <span>${d.subjectName}</span>
                                        </c:if>
                                    </div>
                                </div>
                                <form action="${pageContext.request.contextPath}/deadlines" method="POST" style="display:inline;">
                                    <input type="hidden" name="action" value="toggle">
                                    <input type="hidden" name="id" value="${d.id}">
                                    <button type="submit" class="btn btn-success btn-sm">Mark Complete ✓</button>
                                </form>
                            </div>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- 3. Due Tomorrow & This Week -->
            <div class="deadline-section">
                <h2 class="deadline-section-title">
                    <span>📅</span>
                    <span>Upcoming This Week (${dueTomorrow.size() + dueThisWeek.size()})</span>
                </h2>
                <c:forEach var="d" items="${dueTomorrow}">
                    <div class="deadline-card upcoming">
                        <div>
                            <div class="dl-title">${d.title}</div>
                            <div class="dl-meta">
                                <span style="color: #93c5fd; font-weight: 600;">Due Tomorrow</span>
                                <span>&bull;</span>
                                <span>Date: ${d.dueDate}</span>
                                <c:if test="${not empty d.subjectName}"><span>&bull;</span><span>${d.subjectName}</span></c:if>
                            </div>
                        </div>
                        <form action="${pageContext.request.contextPath}/deadlines" method="POST" style="display:inline;">
                            <input type="hidden" name="action" value="toggle">
                            <input type="hidden" name="id" value="${d.id}">
                            <button type="submit" class="btn btn-secondary btn-sm">Done</button>
                        </form>
                    </div>
                </c:forEach>
                <c:forEach var="d" items="${dueThisWeek}">
                    <div class="deadline-card upcoming">
                        <div>
                            <div class="dl-title">${d.title}</div>
                            <div class="dl-meta">
                                <span style="font-weight: 600;">${d.remainingText}</span>
                                <span>&bull;</span>
                                <span>Date: ${d.dueDate}</span>
                                <c:if test="${not empty d.subjectName}"><span>&bull;</span><span>${d.subjectName}</span></c:if>
                            </div>
                        </div>
                        <form action="${pageContext.request.contextPath}/deadlines" method="POST" style="display:inline;">
                            <input type="hidden" name="action" value="toggle">
                            <input type="hidden" name="id" value="${d.id}">
                            <button type="submit" class="btn btn-secondary btn-sm">Done</button>
                        </form>
                    </div>
                </c:forEach>
            </div>

            <!-- 4. Completed Submissions -->
            <c:if test="${not empty completed}">
                <div class="deadline-section">
                    <h2 class="deadline-section-title" style="color: var(--success);">
                        <span>✓</span>
                        <span>Completed Deliverables (${completed.size()})</span>
                    </h2>
                    <c:forEach var="d" items="${completed}">
                        <div class="deadline-card completed">
                            <div>
                                <div class="dl-title" style="text-decoration: line-through;">${d.title}</div>
                                <div class="dl-meta">
                                    <span style="color: var(--success);">Submitted</span>
                                    <span>&bull;</span>
                                    <span>${d.subjectName != null ? d.subjectName : 'Deliverable'}</span>
                                </div>
                            </div>
                            <form action="${pageContext.request.contextPath}/deadlines" method="POST" style="display:inline;">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="id" value="${d.id}">
                                <button type="submit" class="btn btn-secondary btn-icon" style="color: var(--danger);" title="Delete Record">🗑️</button>
                            </form>
                        </div>
                    </c:forEach>
                </div>
            </c:if>

        </div><!-- /.app-content -->
    </main>
</div>

<!-- Modal: Add Deadline -->
<div class="modal-overlay" id="addDeadlineModal">
    <div class="modal-dialog">
        <div class="modal-header">
            <h3 class="modal-title">New Academic Deadline</h3>
            <button class="modal-close" data-modal-close>&times;</button>
        </div>
        <form action="${pageContext.request.contextPath}/deadlines" method="POST">
            <input type="hidden" name="action" value="create">
            <div class="modal-body">
                <div class="form-group">
                    <label class="form-label" for="dlTitle">Title / Assignment Name *</label>
                    <input type="text" id="dlTitle" name="title" class="form-control" placeholder="e.g. DBMS Normalization Assignment" required>
                </div>
                <div class="form-group">
                    <label class="form-label" for="dlSubject">Subject</label>
                    <select id="dlSubject" name="subjectId" class="form-control">
                        <option value="">None / General</option>
                        <c:forEach var="s" items="${subjects}">
                            <option value="${s.id}">${s.name}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="dlDate">Due Date *</label>
                        <input type="date" id="dlDate" name="dueDate" class="form-control" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="dlTime">Due Time</label>
                        <input type="time" id="dlTime" name="dueTime" class="form-control" value="23:59">
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label" for="dlPriority">Priority</label>
                    <select id="dlPriority" name="priority" class="form-control">
                        <option value="URGENT">Urgent</option>
                        <option value="HIGH" selected>High</option>
                        <option value="MEDIUM">Medium</option>
                        <option value="LOW">Low</option>
                    </select>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-modal-close>Cancel</button>
                <button type="submit" class="btn btn-primary">Save Deadline</button>
            </div>
        </form>
    </div>
</div>

<jsp:include page="../fragments/footer.jsp" />
