<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta name="color-scheme" content="light">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Task Management - Padi da Parama!</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css?v=marvel_light_v3">
    <style>
        .filter-bar {
            background-color: var(--bg-card);
            border: 1px solid var(--border-color);
            border-radius: var(--radius-md);
            padding: 1rem 1.5rem;
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 1rem;
            flex-wrap: wrap;
            box-shadow: var(--shadow-sm);
        }
        .filter-controls {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            flex-wrap: wrap;
        }
        .filter-select {
            background-color: var(--bg-input);
            border: 1px solid var(--border-color);
            color: var(--text-primary);
            border-radius: var(--radius-md);
            padding: 0.45rem 0.75rem;
            font-size: 0.85rem;
            font-family: var(--font-sans);
            font-weight: 500;
            outline: none;
            transition: var(--transition);
        }
        .filter-select:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(237, 29, 36, 0.15);
        }
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
                    <h1 class="page-title">Tasks &amp; Assignments</h1>
                    <p class="page-subtitle">Track academic assignments, lab work, projects, and daily tasks.</p>
                </div>
                <button class="btn btn-primary" data-modal-target="createTaskModal">
                    <span>+</span>
                    <span>New Task</span>
                </button>
            </div>

            <!-- Filter & Search Bar -->
            <form action="${pageContext.request.contextPath}/tasks" method="GET" class="filter-bar">
                <div class="filter-controls">
                    <input type="text" name="q" placeholder="Search tasks..." value="${searchTerm}" class="form-control" style="width: 180px; padding: 0.45rem 0.75rem;">

                    <select name="category" class="filter-select" onchange="this.form.submit()">
                        <option value="ALL">All Categories</option>
                        <option value="Academic" ${selectedCategory == 'Academic' ? 'selected' : ''}>Academic</option>
                        <option value="Assignment" ${selectedCategory == 'Assignment' ? 'selected' : ''}>Assignment</option>
                        <option value="Lab" ${selectedCategory == 'Lab' ? 'selected' : ''}>Lab</option>
                        <option value="Project" ${selectedCategory == 'Project' ? 'selected' : ''}>Project</option>
                        <option value="Personal" ${selectedCategory == 'Personal' ? 'selected' : ''}>Personal</option>
                        <option value="Club" ${selectedCategory == 'Club' ? 'selected' : ''}>Club</option>
                    </select>

                    <select name="priority" class="filter-select" onchange="this.form.submit()">
                        <option value="ALL">All Priorities</option>
                        <option value="URGENT" ${selectedPriority == 'URGENT' ? 'selected' : ''}>Urgent</option>
                        <option value="HIGH" ${selectedPriority == 'HIGH' ? 'selected' : ''}>High</option>
                        <option value="MEDIUM" ${selectedPriority == 'MEDIUM' ? 'selected' : ''}>Medium</option>
                        <option value="LOW" ${selectedPriority == 'LOW' ? 'selected' : ''}>Low</option>
                    </select>

                    <select name="status" class="filter-select" onchange="this.form.submit()">
                        <option value="ALL">All Statuses</option>
                        <option value="PENDING" ${selectedStatus == 'PENDING' ? 'selected' : ''}>Pending</option>
                        <option value="IN_PROGRESS" ${selectedStatus == 'IN_PROGRESS' ? 'selected' : ''}>In Progress</option>
                        <option value="COMPLETED" ${selectedStatus == 'COMPLETED' ? 'selected' : ''}>Completed</option>
                        <option value="OVERDUE" ${selectedStatus == 'OVERDUE' ? 'selected' : ''}>Overdue</option>
                    </select>

                    <select name="subjectId" class="filter-select" onchange="this.form.submit()">
                        <option value="ALL">All Subjects</option>
                        <c:forEach var="s" items="${subjects}">
                            <option value="${s.id}" ${selectedSubjectId == s.id ? 'selected' : ''}>${s.name}</option>
                        </c:forEach>
                    </select>

                    <select name="sort" class="filter-select" onchange="this.form.submit()">
                        <option value="due" ${sortBy == 'due' ? 'selected' : ''}>Sort: Due Date</option>
                        <option value="priority" ${sortBy == 'priority' ? 'selected' : ''}>Sort: Priority</option>
                        <option value="title" ${sortBy == 'title' ? 'selected' : ''}>Sort: Title</option>
                    </select>
                </div>

                <div>
                    <a href="${pageContext.request.contextPath}/tasks" class="btn btn-secondary btn-sm">Reset</a>
                </div>
            </form>

            <!-- Tasks Table -->
            <div class="table-responsive">
                <table class="table">
                    <thead>
                        <tr>
                            <th style="width: 40px;"></th>
                            <th>Task Details</th>
                            <th>Subject</th>
                            <th>Category</th>
                            <th>Priority</th>
                            <th>Due Date</th>
                            <th>Status</th>
                            <th style="text-align: right;">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty tasks}">
                                <tr>
                                    <td colspan="8" style="text-align: center; padding: 3rem; color: var(--text-muted);">
                                        No tasks found matching your filter criteria.
                                    </td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="t" items="${tasks}">
                                    <tr class="${t.completed ? 'completed' : ''}">
                                        <td>
                                            <div class="custom-checkbox ${t.completed ? 'checked' : ''}"
                                                 onclick="toggleTaskAjax(${t.id}, this)">
                                                ${t.completed ? '✓' : ''}
                                            </div>
                                        </td>
                                        <td>
                                            <div class="task-title">${t.title}</div>
                                            <c:if test="${not empty t.description}">
                                                <div style="font-size: 0.78rem; color: var(--text-muted); margin-top: 0.2rem;">
                                                    ${t.description}
                                                </div>
                                            </c:if>
                                            <c:if test="${t.recurrence != 'NONE'}">
                                                <span class="badge" style="background: rgba(99, 102, 241, 0.15); color: var(--primary); font-size: 0.65rem; margin-top: 0.25rem;">
                                                    🔄 ${t.recurrence}
                                                </span>
                                            </c:if>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty t.subjectName}">
                                                    <span style="font-weight: 600; color: ${t.subjectColor != null ? t.subjectColor : 'var(--text-primary)'};">
                                                        ${t.subjectName}
                                                    </span>
                                                </c:when>
                                                <c:otherwise><span style="color: var(--text-muted);">&mdash;</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td><span class="badge" style="background: var(--bg-card); border: 1px solid var(--border-color);">${t.category}</span></td>
                                        <td><span class="badge badge-${t.priority.toLowerCase()}">${t.priority}</span></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty t.dueDate}">
                                                    <div style="font-weight: 500;">${t.dueDate}</div>
                                                    <div style="font-size: 0.75rem; color: ${t.overdue ? 'var(--danger)' : 'var(--text-muted)'}; font-weight: ${t.overdue ? '700' : 'normal'};">
                                                        ${t.dueStatusText}
                                                    </div>
                                                </c:when>
                                                <c:otherwise><span style="color: var(--text-muted);">None</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td><span class="badge badge-${t.status.toLowerCase().replace('_', '-')}">${t.status}</span></td>
                                        <td style="text-align: right;">
                                            <div style="display: inline-flex; gap: 0.4rem;">
                                                <button type="button" class="btn btn-secondary btn-icon"
                                                        onclick='openEditTaskModal(${t.id}, "${t.title}", "${t.description != null ? t.description : ''}", "${t.category}", "${t.priority}", "${t.status}", "${t.dueDate}", "${t.dueTime}", "${t.subjectId}", ${t.estimatedMinutes}, "${t.recurrence}")'
                                                        title="Edit Task">✏️</button>
                                                <form action="${pageContext.request.contextPath}/tasks" method="POST" style="display:inline;" onsubmit="return confirm('Delete this task?');">
                                                    <input type="hidden" name="action" value="delete">
                                                    <input type="hidden" name="id" value="${t.id}">
                                                    <button type="submit" class="btn btn-secondary btn-icon" style="color: var(--danger);" title="Delete Task">🗑️</button>
                                                </form>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>

        </div><!-- /.app-content -->
    </main>
</div>

<!-- Modal: Create Task -->
<div class="modal-overlay" id="createTaskModal">
    <div class="modal-dialog">
        <div class="modal-header">
            <h3 class="modal-title">Create New Task</h3>
            <button class="modal-close" data-modal-close>&times;</button>
        </div>
        <form action="${pageContext.request.contextPath}/tasks" method="POST">
            <input type="hidden" name="action" value="create">
            <div class="modal-body">
                <div class="form-group">
                    <label class="form-label" for="taskTitle">Task Title *</label>
                    <input type="text" id="taskTitle" name="title" class="form-control" placeholder="e.g. Finish CN Socket Programming Lab" required>
                </div>
                <div class="form-group">
                    <label class="form-label" for="taskDesc">Description</label>
                    <textarea id="taskDesc" name="description" class="form-control" rows="3" placeholder="Provide notes, references, or instructions"></textarea>
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
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="taskSubject">Subject</label>
                        <select id="taskSubject" name="subjectId" class="form-control">
                            <option value="">None / General</option>
                            <c:forEach var="s" items="${subjects}">
                                <option value="${s.id}">${s.name}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="taskRecurrence">Recurrence</label>
                        <select id="taskRecurrence" name="recurrence" class="form-control">
                            <option value="NONE">None</option>
                            <option value="DAILY">Daily</option>
                            <option value="WEEKLY">Weekly</option>
                            <option value="MONTHLY">Monthly</option>
                        </select>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="taskDueDate">Due Date</label>
                        <input type="date" id="taskDueDate" name="dueDate" class="form-control">
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="taskDueTime">Due Time</label>
                        <input type="time" id="taskDueTime" name="dueTime" class="form-control">
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label" for="taskEst">Estimated Minutes</label>
                    <input type="number" id="taskEst" name="estimatedMinutes" value="45" min="5" step="5" class="form-control">
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-modal-close>Cancel</button>
                <button type="submit" class="btn btn-primary">Create Task</button>
            </div>
        </form>
    </div>
</div>

<!-- Modal: Edit Task -->
<div class="modal-overlay" id="editTaskModal">
    <div class="modal-dialog">
        <div class="modal-header">
            <h3 class="modal-title">Edit Task</h3>
            <button class="modal-close" data-modal-close>&times;</button>
        </div>
        <form action="${pageContext.request.contextPath}/tasks" method="POST">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="id" id="editTaskId">
            <div class="modal-body">
                <div class="form-group">
                    <label class="form-label" for="editTaskTitle">Task Title *</label>
                    <input type="text" id="editTaskTitle" name="title" class="form-control" required>
                </div>
                <div class="form-group">
                    <label class="form-label" for="editTaskDesc">Description</label>
                    <textarea id="editTaskDesc" name="description" class="form-control" rows="3"></textarea>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="editTaskCategory">Category</label>
                        <select id="editTaskCategory" name="category" class="form-control">
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
                        <label class="form-label" for="editTaskPriority">Priority</label>
                        <select id="editTaskPriority" name="priority" class="form-control">
                            <option value="LOW">Low</option>
                            <option value="MEDIUM">Medium</option>
                            <option value="HIGH">High</option>
                            <option value="URGENT">Urgent</option>
                        </select>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="editTaskStatus">Status</label>
                        <select id="editTaskStatus" name="status" class="form-control">
                            <option value="PENDING">Pending</option>
                            <option value="IN_PROGRESS">In Progress</option>
                            <option value="COMPLETED">Completed</option>
                            <option value="CANCELLED">Cancelled</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="editTaskSubject">Subject</label>
                        <select id="editTaskSubject" name="subjectId" class="form-control">
                            <option value="">None / General</option>
                            <c:forEach var="s" items="${subjects}">
                                <option value="${s.id}">${s.name}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="editTaskDueDate">Due Date</label>
                        <input type="date" id="editTaskDueDate" name="dueDate" class="form-control">
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="editTaskDueTime">Due Time</label>
                        <input type="time" id="editTaskDueTime" name="dueTime" class="form-control">
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="editTaskEst">Estimated Minutes</label>
                        <input type="number" id="editTaskEst" name="estimatedMinutes" min="5" step="5" class="form-control">
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="editTaskRecurrence">Recurrence</label>
                        <select id="editTaskRecurrence" name="recurrence" class="form-control">
                            <option value="NONE">None</option>
                            <option value="DAILY">Daily</option>
                            <option value="WEEKLY">Weekly</option>
                            <option value="MONTHLY">Monthly</option>
                        </select>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-modal-close>Cancel</button>
                <button type="submit" class="btn btn-primary">Save Changes</button>
            </div>
        </form>
    </div>
</div>

<script>
function openEditTaskModal(id, title, desc, cat, pri, stat, due, time, subId, est, rec) {
    document.getElementById('editTaskId').value = id;
    document.getElementById('editTaskTitle').value = title;
    document.getElementById('editTaskDesc').value = desc || '';
    document.getElementById('editTaskCategory').value = cat;
    document.getElementById('editTaskPriority').value = pri;
    document.getElementById('editTaskStatus').value = stat;
    document.getElementById('editTaskDueDate').value = due !== 'null' ? due : '';
    document.getElementById('editTaskDueTime').value = time !== 'null' ? time : '';
    document.getElementById('editTaskSubject').value = subId !== 'null' ? subId : '';
    document.getElementById('editTaskEst').value = est || 30;
    document.getElementById('editTaskRecurrence').value = rec || 'NONE';
    openModal('editTaskModal');
}
</script>

<jsp:include page="../fragments/footer.jsp" />
