<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta name="color-scheme" content="light">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Habit Tracker - Padi da Parama!</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css?v=marvel_light_v3">
    <style>
        .habit-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 1.25rem;
        }
        .habit-card {
            background: #ffffff;
            border: 1px solid var(--border-color);
            border-top: 3px solid var(--marvel-red);
            border-radius: var(--radius-lg);
            padding: 1.5rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: var(--shadow-sm);
            transition: var(--transition);
        }
        .habit-card:hover {
            border-color: var(--marvel-red-border);
            border-top-color: var(--marvel-red);
            box-shadow: 0 8px 20px rgba(237, 29, 36, 0.08);
            transform: translateY(-2px);
        }
        .habit-info-col h3 { font-size: 1.2rem; font-weight: 700; color: var(--text-primary); margin-bottom: 0.2rem; font-family: var(--font-sans); }
        .habit-cat-pill { font-size: 0.75rem; color: var(--text-secondary); background: #f8fafc; padding: 0.2rem 0.5rem; border-radius: var(--radius-sm); border: 1px solid var(--border-color); }
        .habit-streak-count { font-size: 0.95rem; font-weight: 700; color: var(--warning); margin-top: 0.5rem; display: flex; align-items: center; gap: 0.35rem; }
        .habit-big-btn {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            border: 2px solid var(--border-color);
            background: #ffffff;
            color: var(--text-muted);
            font-size: 1.3rem;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: var(--shadow-sm);
            transition: var(--transition);
        }
        .habit-big-btn.done {
            background: var(--success);
            border-color: var(--marvel-black);
            color: white;
            box-shadow: var(--shadow-comic-sm);
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
                    <h1 class="page-title">Daily Habit Tracker</h1>
                    <p class="page-subtitle">Build consistent academic discipline, coding routines, and personal wellness.</p>
                </div>
                <button class="btn btn-primary" data-modal-target="addHabitModal">+ Add Habit</button>
            </div>

            <!-- Habit Overview Summary Cards -->
            <div class="stat-grid" style="margin-bottom: 2rem;">
                <div class="card stat-card">
                    <div class="stat-header">
                        <span>Current Streak</span>
                        <div class="stat-icon" style="background: rgba(251, 146, 60, 0.15); color: #fb923c;">🔥</div>
                    </div>
                    <div class="stat-value" style="color: #fb923c;">${maxStreak} Days</div>
                    <div class="stat-footer">Consecutive active streak</div>
                </div>

                <div class="card stat-card">
                    <div class="stat-header">
                        <span>Weekly Consistency</span>
                        <div class="stat-icon" style="background: var(--success-light); color: var(--success);">📈</div>
                    </div>
                    <div class="stat-value" style="color: var(--success);">${weeklyRate}%</div>
                    <div class="stat-footer">7-day completion rate</div>
                </div>

                <div class="card stat-card">
                    <div class="stat-header">
                        <span>Active Habits</span>
                        <div class="stat-icon" style="background: var(--primary-light); color: var(--primary);">⚡</div>
                    </div>
                    <div class="stat-value">${habits.size()}</div>
                    <div class="stat-footer">Routines being tracked</div>
                </div>
            </div>

            <!-- Habits Grid -->
            <div class="habit-grid">
                <c:choose>
                    <c:when test="${empty habits}">
                        <div class="card" style="grid-column: 1 / -1; text-align: center; padding: 3rem; color: var(--text-muted);">
                            No habits tracked yet. Add your daily study or coding routine!
                        </div>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="h" items="${habits}">
                            <div class="habit-card" style="border-left: 5px solid ${h.color != null ? h.color : 'var(--primary)'};">
                                <div class="habit-info-col">
                                    <div style="display:flex; align-items:center; gap:0.5rem; margin-bottom:0.25rem;">
                                        <span class="habit-cat-pill">${h.category}</span>
                                        <span style="font-size:0.75rem; color:var(--text-muted);">${h.targetFrequency}</span>
                                    </div>
                                    <h3>${h.name}</h3>
                                    <c:if test="${not empty h.description}">
                                        <div style="font-size:0.78rem; color:var(--text-muted); margin-bottom:0.35rem;">${h.description}</div>
                                    </c:if>
                                    <div class="habit-streak-count">
                                        <span>🔥</span>
                                        <span>${h.currentStreak} day streak</span>
                                    </div>
                                    <div style="margin-top: 0.75rem;">
                                        <form action="${pageContext.request.contextPath}/habits" method="POST" onsubmit="return confirm('Delete habit?');" style="display:inline;">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="id" value="${h.id}">
                                            <button type="submit" class="btn btn-secondary btn-icon" style="color:var(--danger); font-size:0.75rem;" title="Delete">🗑️</button>
                                        </form>
                                    </div>
                                </div>

                                <div>
                                    <button type="button"
                                            class="habit-big-btn ${h.completedToday ? 'done' : ''}"
                                            onclick="toggleHabitAjax(${h.id}, this)"
                                            title="Click to toggle today">
                                        ${h.completedToday ? '✓' : '○'}
                                    </button>
                                </div>
                            </div>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </div>

        </div><!-- /.app-content -->
    </main>
</div>

<!-- Modal: Add Habit -->
<div class="modal-overlay" id="addHabitModal">
    <div class="modal-dialog">
        <div class="modal-header">
            <h3 class="modal-title">Track New Habit</h3>
            <button class="modal-close" data-modal-close>&times;</button>
        </div>
        <form action="${pageContext.request.contextPath}/habits" method="POST">
            <input type="hidden" name="action" value="create">
            <div class="modal-body">
                <div class="form-group">
                    <label class="form-label" for="habitName">Habit Name *</label>
                    <input type="text" id="habitName" name="name" class="form-control" placeholder="e.g. Coding / Problem Solving" required>
                </div>
                <div class="form-group">
                    <label class="form-label" for="habitDesc">Goal Description</label>
                    <input type="text" id="habitDesc" name="description" class="form-control" placeholder="e.g. Solve at least 1 LeetCode problem">
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="habitCategory">Category</label>
                        <select id="habitCategory" name="category" class="form-control">
                            <option value="Academic">Academic</option>
                            <option value="Productivity">Productivity</option>
                            <option value="Health">Health</option>
                            <option value="Self-growth">Self-growth</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="habitColor">Accent Color</label>
                        <select id="habitColor" name="color" class="form-control">
                            <option value="#3b82f6">Blue</option>
                            <option value="#10b981" selected>Emerald Green</option>
                            <option value="#8b5cf6">Purple</option>
                            <option value="#f59e0b">Amber</option>
                            <option value="#06b6d4">Cyan</option>
                        </select>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-modal-close>Cancel</button>
                <button type="submit" class="btn btn-primary">Start Tracking</button>
            </div>
        </form>
    </div>
</div>

<jsp:include page="../fragments/footer.jsp" />
