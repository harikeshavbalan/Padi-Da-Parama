<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta name="color-scheme" content="light">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Future Plans &amp; Goals - Padi da Parama!</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css?v=marvel_light_v3">
    <style>
        .plans-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
            gap: 1.5rem;
        }
        .plan-card {
            background: #ffffff;
            border: 1px solid var(--border-color);
            border-top: 3px solid var(--marvel-red);
            border-radius: var(--radius-lg);
            padding: 1.5rem;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            box-shadow: var(--shadow-sm);
            transition: var(--transition);
        }
        .plan-card:hover {
            border-color: var(--marvel-red-border);
            border-top-color: var(--marvel-red);
            box-shadow: 0 8px 20px rgba(237, 29, 36, 0.08);
            transform: translateY(-2px);
        }
        .plan-top { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 0.75rem; }
        .plan-title { font-size: 1.25rem; font-weight: 700; color: var(--text-primary); font-family: var(--font-sans); }
        .plan-desc { font-size: 0.9rem; color: var(--text-secondary); margin: 0.5rem 0 1rem; line-height: 1.4; }
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
                    <h1 class="page-title">Future Plans &amp; Career Goals</h1>
                    <p class="page-subtitle">Track long-term academic milestones, skill development, and career preparation.</p>
                </div>
                <button class="btn btn-primary" data-modal-target="addPlanModal">+ New Goal / Plan</button>
            </div>

            <div class="plans-grid">
                <c:choose>
                    <c:when test="${empty plans}">
                        <div class="card" style="grid-column: 1 / -1; text-align: center; padding: 3rem; color: var(--text-muted);">
                            No future plans registered yet. Add a career goal, course, or certification milestone!
                        </div>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="plan" items="${plans}">
                            <div class="plan-card">
                                <div>
                                    <div class="plan-top">
                                        <span class="badge badge-${plan.priority.toLowerCase()}">${plan.priority}</span>
                                        <span class="badge badge-${plan.status.toLowerCase()}">${plan.status}</span>
                                    </div>
                                    <h3 class="plan-title">${plan.title}</h3>
                                    <p class="plan-desc">${plan.description}</p>
                                    <div style="font-size: 0.78rem; color: var(--text-muted); display: flex; gap: 1rem; margin-bottom: 1rem;">
                                        <span>Start: ${plan.startDate != null ? plan.startDate : 'Flexible'}</span>
                                        <span>Target: ${plan.targetDate != null ? plan.targetDate : 'Open'}</span>
                                    </div>
                                </div>

                                <div>
                                    <div style="display:flex; justify-content:space-between; font-size:0.8rem; margin-bottom:0.35rem;">
                                        <span>Progress</span>
                                        <span style="font-weight:700;">${plan.progress}%</span>
                                    </div>
                                    <div class="progress-container">
                                        <div class="progress-bar ${plan.progress >= 80 ? 'progress-bar-success' : 'progress-bar-warning'}"
                                             style="width: ${plan.progress}%;"></div>
                                    </div>

                                    <div style="display:flex; justify-content:space-between; align-items:center; margin-top:1.25rem; border-top:1px solid var(--border-color); padding-top:0.75rem;">
                                        <form action="${pageContext.request.contextPath}/plans" method="POST" style="display:flex; gap:0.4rem; align-items:center;">
                                            <input type="hidden" name="action" value="updateProgress">
                                            <input type="hidden" name="id" value="${plan.id}">
                                            <input type="number" name="progress" value="${plan.progress}" min="0" max="100" step="10" class="form-control" style="width: 70px; padding: 0.25rem 0.5rem; font-size: 0.8rem;">
                                            <select name="status" class="form-control" style="padding: 0.25rem 0.5rem; font-size: 0.8rem; width: 100px;">
                                                <option value="ACTIVE" ${plan.status == 'ACTIVE' ? 'selected' : ''}>Active</option>
                                                <option value="PLANNED" ${plan.status == 'PLANNED' ? 'selected' : ''}>Planned</option>
                                                <option value="COMPLETED" ${plan.status == 'COMPLETED' ? 'selected' : ''}>Completed</option>
                                                <option value="PAUSED" ${plan.status == 'PAUSED' ? 'selected' : ''}>Paused</option>
                                            </select>
                                            <button type="submit" class="btn btn-secondary btn-sm">Update</button>
                                        </form>

                                        <form action="${pageContext.request.contextPath}/plans" method="POST" onsubmit="return confirm('Delete this plan?');">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="id" value="${plan.id}">
                                            <button type="submit" class="btn btn-secondary btn-icon" style="color: var(--danger);" title="Delete Plan">🗑️</button>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </div>

        </div><!-- /.app-content -->
    </main>
</div>

<!-- Modal: Add Plan -->
<div class="modal-overlay" id="addPlanModal">
    <div class="modal-dialog">
        <div class="modal-header">
            <h3 class="modal-title">Create Future Plan / Goal</h3>
            <button class="modal-close" data-modal-close>&times;</button>
        </div>
        <form action="${pageContext.request.contextPath}/plans" method="POST">
            <input type="hidden" name="action" value="create">
            <div class="modal-body">
                <div class="form-group">
                    <label class="form-label" for="planTitle">Goal Title *</label>
                    <input type="text" id="planTitle" name="title" class="form-control" placeholder="e.g. Master Data Structures &amp; Algorithms" required>
                </div>
                <div class="form-group">
                    <label class="form-label" for="planDesc">Description &amp; Action Plan</label>
                    <textarea id="planDesc" name="description" class="form-control" rows="3" placeholder="Outline specific milestones, problem lists, or learning objectives"></textarea>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="planStart">Start Date</label>
                        <input type="date" id="planStart" name="startDate" class="form-control">
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="planTarget">Target Completion Date</label>
                        <input type="date" id="planTarget" name="targetDate" class="form-control">
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="planPriority">Priority</label>
                        <select id="planPriority" name="priority" class="form-control">
                            <option value="URGENT">Urgent</option>
                            <option value="HIGH" selected>High</option>
                            <option value="MEDIUM">Medium</option>
                            <option value="LOW">Low</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="planInitProgress">Current Progress (0-100%)</label>
                        <input type="number" id="planInitProgress" name="progress" value="0" min="0" max="100" class="form-control">
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-modal-close>Cancel</button>
                <button type="submit" class="btn btn-primary">Save Goal</button>
            </div>
        </form>
    </div>
</div>

<jsp:include page="../fragments/footer.jsp" />
