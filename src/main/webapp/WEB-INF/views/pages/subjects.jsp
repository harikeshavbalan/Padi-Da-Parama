<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta name="color-scheme" content="light">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Course Subjects - Padi da Parama!</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css?v=marvel_light_v3">
    <style>
        .subjects-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
            gap: 1.5rem;
        }
        .subject-card {
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
        .subject-card:hover {
            border-color: var(--marvel-red-border);
            border-top-color: var(--marvel-red);
            box-shadow: 0 8px 20px rgba(237, 29, 36, 0.08);
            transform: translateY(-2px);
        }
        .subj-code-pill {
            font-size: 0.78rem;
            font-weight: 700;
            padding: 0.2rem 0.6rem;
            border-radius: var(--radius-sm);
            color: white;
            box-shadow: var(--shadow-sm);
        }
        .subj-name { font-size: 1.25rem; font-weight: 700; color: var(--text-primary); margin: 0.35rem 0 0.2rem; font-family: var(--font-sans); }
        .subj-faculty { font-size: 0.88rem; color: var(--text-secondary); font-weight: 500; }
        .subj-stat-box {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 0.75rem;
            background: #fff8f8;
            border: 1px solid var(--marvel-red-border);
            border-radius: var(--radius-md);
            padding: 0.85rem;
            margin: 1rem 0;
            font-size: 0.85rem;
        }
        .stat-field { display: flex; flex-direction: column; }
        .stat-field-val { font-size: 1.1rem; font-weight: 700; color: var(--text-primary); }
        .stat-field-lbl { font-size: 0.75rem; color: var(--text-muted); }
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
                    <h1 class="page-title">Enrolled Subjects &amp; Courses</h1>
                    <p class="page-subtitle">Academic subject dashboards with task progress, faculty info, and study investments.</p>
                </div>
                <button class="btn btn-primary" data-modal-target="addSubjectModal">+ Add Subject</button>
            </div>

            <div class="subjects-grid">
                <c:choose>
                    <c:when test="${empty subjects}">
                        <div class="card" style="grid-column: 1 / -1; text-align: center; padding: 3rem; color: var(--text-muted);">
                            No subjects configured. Add your academic courses above!
                        </div>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="s" items="${subjects}">
                            <div class="subject-card" style="border-top: 4px solid ${s.color};">
                                <div>
                                    <div style="display: flex; justify-content: space-between; align-items: center;">
                                        <span class="subj-code-pill" style="background: ${s.color};">
                                            ${s.courseCode != null ? s.courseCode : 'COURSE'}
                                        </span>
                                        <span class="badge" style="background: var(--bg-input);">${s.credits} Credits</span>
                                    </div>

                                    <h3 class="subj-name">${s.name}</h3>
                                    <div class="subj-faculty">
                                        <span>👤 ${s.faculty != null ? s.faculty : 'Faculty TBA'}</span>
                                        <c:if test="${not empty s.room}">
                                            <span>&bull; Room: ${s.room}</span>
                                        </c:if>
                                    </div>

                                    <!-- Subject Dashboard Summary Box -->
                                    <div class="subj-stat-box">
                                        <div class="stat-field">
                                            <span class="stat-field-val">${s.completedTaskCount} / ${s.taskCount}</span>
                                            <span class="stat-field-lbl">Tasks Done</span>
                                        </div>
                                        <div class="stat-field">
                                            <span class="stat-field-val">${s.studyMinutes / 60}h ${s.studyMinutes % 60}m</span>
                                            <span class="stat-field-lbl">Study Invested</span>
                                        </div>
                                        <div class="stat-field" style="grid-column: 1 / -1; margin-top: 0.25rem;">
                                            <span class="stat-field-lbl">Next Exam:</span>
                                            <span style="font-weight: 600; color: var(--warning);">${s.nextExamDate}</span>
                                        </div>
                                    </div>
                                </div>

                                <div style="display: flex; justify-content: space-between; align-items: center; border-top: 1px solid var(--border-color); padding-top: 0.75rem;">
                                    <a href="${pageContext.request.contextPath}/tasks?subjectId=${s.id}" class="btn btn-secondary btn-sm">
                                        View Tasks →
                                    </a>
                                    <form action="${pageContext.request.contextPath}/subjects" method="POST" onsubmit="return confirm('Delete this subject and related timetable entries?');">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="id" value="${s.id}">
                                        <button type="submit" class="btn btn-secondary btn-icon" style="color: var(--danger);" title="Delete Subject">🗑️</button>
                                    </form>
                                </div>
                            </div>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </div>

        </div><!-- /.app-content -->
    </main>
</div>

<!-- Modal: Add Subject -->
<div class="modal-overlay" id="addSubjectModal">
    <div class="modal-dialog">
        <div class="modal-header">
            <h3 class="modal-title">Add Academic Subject</h3>
            <button class="modal-close" data-modal-close>&times;</button>
        </div>
        <form action="${pageContext.request.contextPath}/subjects" method="POST">
            <input type="hidden" name="action" value="create">
            <div class="modal-body">
                <div class="form-group">
                    <label class="form-label" for="subjName">Subject Name *</label>
                    <input type="text" id="subjName" name="name" class="form-control" placeholder="e.g. Distributed Computing" required>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="subjCode">Course Code</label>
                        <input type="text" id="subjCode" name="courseCode" class="form-control" placeholder="e.g. CS401">
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="subjCredits">Credits</label>
                        <input type="number" id="subjCredits" name="credits" value="4" min="1" max="10" class="form-control">
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="subjFac">Faculty Name</label>
                        <input type="text" id="subjFac" name="faculty" class="form-control" placeholder="e.g. Dr. A. Sharma">
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="subjRoom">Room / Lab</label>
                        <input type="text" id="subjRoom" name="room" class="form-control" placeholder="e.g. Lab-3">
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label" for="subColor">Color Accent</label>
                    <select id="subColor" name="color" class="form-control">
                        <option value="#3b82f6" selected>Blue</option>
                        <option value="#8b5cf6">Purple</option>
                        <option value="#10b981">Green</option>
                        <option value="#f59e0b">Amber</option>
                        <option value="#ef4444">Red</option>
                        <option value="#06b6d4">Cyan</option>
                    </select>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-modal-close>Cancel</button>
                <button type="submit" class="btn btn-primary">Save Course</button>
            </div>
        </form>
    </div>
</div>

<jsp:include page="../fragments/footer.jsp" />
