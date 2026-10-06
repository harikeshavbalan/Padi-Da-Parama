<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta name="color-scheme" content="light">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tests &amp; Exams - Padi da Parama!</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css?v=marvel_light_v3">
    <style>
        .exam-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
            gap: 1.5rem;
        }
        .exam-card {
            background: #ffffff;
            border: 1px solid var(--border-color);
            border-top: 3px solid var(--marvel-red);
            border-radius: var(--radius-lg);
            padding: 1.5rem;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            position: relative;
            overflow: hidden;
            box-shadow: var(--shadow-sm);
            transition: var(--transition);
        }
        .exam-card:hover {
            border-color: var(--marvel-red-border);
            border-top-color: var(--marvel-red);
            box-shadow: 0 8px 20px rgba(237, 29, 36, 0.08);
            transform: translateY(-2px);
        }
        .exam-top { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 0.75rem; }
        .exam-title { font-size: 1.25rem; font-weight: 700; color: var(--text-primary); margin-bottom: 0.25rem; font-family: var(--font-sans); }
        .exam-venue { font-size: 0.85rem; color: var(--text-secondary); display: flex; align-items: center; gap: 0.4rem; font-weight: 500; }
        .exam-syllabus {
            background: #fff8f8;
            border: 1px solid var(--marvel-red-border);
            border-radius: var(--radius-md);
            padding: 0.75rem;
            font-size: 0.88rem;
            color: var(--text-secondary);
            margin: 1rem 0;
            line-height: 1.4;
        }
        .prep-section { margin-top: 1rem; }
        .prep-header { display: flex; justify-content: space-between; font-size: 0.85rem; font-weight: 600; margin-bottom: 0.35rem; color: var(--text-primary); }
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
                    <h1 class="page-title">Tests &amp; Examinations</h1>
                    <p class="page-subtitle">Track CAT assessments, lab tests, semester exams, and preparation readiness.</p>
                </div>
                <button class="btn btn-primary" data-modal-target="addExamModal">+ Add Exam</button>
            </div>

            <div class="exam-grid">
                <c:choose>
                    <c:when test="${empty exams}">
                        <div class="card" style="grid-column: 1 / -1; text-align: center; padding: 3rem; color: var(--text-muted);">
                            No exams currently scheduled. Add upcoming CATs or Semester tests above!
                        </div>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="exam" items="${exams}">
                            <div class="exam-card">
                                <div>
                                    <div class="exam-top">
                                        <span class="badge" style="background: rgba(220, 38, 38, 0.15); color: #f87171; border: 1px solid rgba(220, 38, 38, 0.3);">
                                            ${exam.examType}
                                        </span>
                                        <span style="font-size: 0.8rem; font-weight: 700; color: var(--warning);">
                                            ${exam.countdownText}
                                        </span>
                                    </div>

                                    <h3 class="exam-title">${exam.title}</h3>
                                    <div style="font-size: 0.88rem; font-weight: 600; color: ${exam.subjectColor != null ? exam.subjectColor : 'var(--primary)'};">
                                        ${exam.subjectName}
                                    </div>

                                    <div style="display: flex; gap: 1rem; margin-top: 0.5rem; font-size: 0.82rem; color: var(--text-muted);">
                                        <span>📅 ${exam.examDate}</span>
                                        <span>⏰ ${exam.startTime.toString().substring(0, 5)} - ${exam.endTime.toString().substring(0, 5)}</span>
                                    </div>
                                    <div class="exam-venue" style="margin-top: 0.25rem;">
                                        <span>📍 Venue: ${exam.venue != null ? exam.venue : 'TBA'}</span>
                                    </div>

                                    <c:if test="${not empty exam.syllabus}">
                                        <div class="exam-syllabus">
                                            <strong>Syllabus:</strong> ${exam.syllabus}
                                        </div>
                                    </c:if>
                                </div>

                                <!-- Preparation Progress -->
                                <div>
                                    <div class="prep-section">
                                        <div class="prep-header">
                                            <span>Preparation Status</span>
                                            <span style="font-weight: 700; color: var(--text-primary);">${exam.preparationPercentage}%</span>
                                        </div>
                                        <div class="progress-container">
                                            <div class="progress-bar ${exam.preparationPercentage >= 75 ? 'progress-bar-success' : (exam.preparationPercentage >= 50 ? 'progress-bar-warning' : 'progress-bar-danger')}"
                                                 style="width: ${exam.preparationPercentage}%;"></div>
                                        </div>
                                    </div>

                                    <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 1.25rem; border-top: 1px solid var(--border-color); padding-top: 0.75rem;">
                                        <form action="${pageContext.request.contextPath}/exams" method="POST" style="display: flex; gap: 0.4rem; align-items: center;">
                                            <input type="hidden" name="action" value="updatePrep">
                                            <input type="hidden" name="id" value="${exam.id}">
                                            <input type="number" name="preparationPercentage" value="${exam.preparationPercentage}" min="0" max="100" step="5" class="form-control" style="width: 70px; padding: 0.25rem 0.5rem; font-size: 0.8rem;">
                                            <button type="submit" class="btn btn-secondary btn-sm">Update %</button>
                                        </form>

                                        <form action="${pageContext.request.contextPath}/exams" method="POST" onsubmit="return confirm('Delete this examination record?');">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="id" value="${exam.id}">
                                            <button type="submit" class="btn btn-secondary btn-icon" style="color: var(--danger);" title="Delete Exam">🗑️</button>
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

<!-- Modal: Add Exam -->
<div class="modal-overlay" id="addExamModal">
    <div class="modal-dialog">
        <div class="modal-header">
            <h3 class="modal-title">Schedule Test / Exam</h3>
            <button class="modal-close" data-modal-close>&times;</button>
        </div>
        <form action="${pageContext.request.contextPath}/exams" method="POST">
            <input type="hidden" name="action" value="create">
            <div class="modal-body">
                <div class="form-group">
                    <label class="form-label" for="examTitle">Exam Title *</label>
                    <input type="text" id="examTitle" name="title" class="form-control" placeholder="e.g. Web Technology CAT-I" required>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="examType">Exam Type *</label>
                        <select id="examType" name="examType" class="form-control" required>
                            <option value="CAT-I">CAT-I</option>
                            <option value="CAT-II">CAT-II</option>
                            <option value="Internal Test">Internal Test</option>
                            <option value="Lab Test">Lab Test</option>
                            <option value="Model Exam">Model Exam</option>
                            <option value="Semester Exam">Semester Exam</option>
                            <option value="Practical Exam">Practical Exam</option>
                            <option value="Viva">Viva</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="examSubject">Subject</label>
                        <select id="examSubject" name="subjectId" class="form-control">
                            <option value="">None / General</option>
                            <c:forEach var="s" items="${subjects}">
                                <option value="${s.id}">${s.name}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="examDate">Exam Date *</label>
                        <input type="date" id="examDate" name="examDate" class="form-control" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="examVenue">Venue / Hall</label>
                        <input type="text" id="examVenue" name="venue" class="form-control" placeholder="e.g. LH-201">
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="examStart">Start Time *</label>
                        <input type="time" id="examStart" name="startTime" class="form-control" value="09:30" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="examEnd">End Time *</label>
                        <input type="time" id="examEnd" name="endTime" class="form-control" value="11:00" required>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label" for="examSyllabus">Syllabus Coverage</label>
                    <textarea id="examSyllabus" name="syllabus" class="form-control" rows="2" placeholder="List units or chapters included"></textarea>
                </div>
                <div class="form-group">
                    <label class="form-label" for="examPrep">Initial Preparation Readiness (0-100%)</label>
                    <input type="number" id="examPrep" name="preparationPercentage" value="50" min="0" max="100" class="form-control">
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-modal-close>Cancel</button>
                <button type="submit" class="btn btn-primary">Schedule Exam</button>
            </div>
        </form>
    </div>
</div>

<jsp:include page="../fragments/footer.jsp" />
