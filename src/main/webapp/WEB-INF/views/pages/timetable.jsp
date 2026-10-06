<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta name="color-scheme" content="light">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Weekly Timetable - Padi da Parama!</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css?v=marvel_light_v3">
    <style>
        .timetable-day-card {
            background: #ffffff;
            border: 2px solid var(--marvel-black);
            border-radius: var(--radius-lg);
            padding: 1.25rem;
            margin-bottom: 1.25rem;
            box-shadow: var(--shadow-comic-sm);
        }
        .day-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 1rem;
            padding-bottom: 0.5rem;
            border-bottom: 2px solid var(--border-color);
        }
        .day-name {
            font-size: 1.15rem;
            font-weight: 700;
            color: var(--text-primary);
            font-family: var(--font-sans);
        }
        .slots-list {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 0.75rem;
        }
        .slot-card {
            background: #ffffff;
            border: 1px solid var(--border-color);
            border-radius: var(--radius-md);
            padding: 0.85rem 1rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.04);
            transition: var(--transition);
        }
        .slot-card:hover {
            border-color: var(--marvel-red);
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(237, 29, 36, 0.1);
        }
        .day-pills-selector {
            display: flex;
            gap: 0.5rem;
            flex-wrap: wrap;
        }
        .day-pill {
            cursor: pointer;
            position: relative;
        }
        .day-pill input[type="radio"] {
            position: absolute;
            opacity: 0;
            pointer-events: none;
        }
        .day-pill span {
            display: inline-block;
            padding: 0.4rem 0.8rem;
            border-radius: var(--radius-md);
            border: 1.5px solid var(--border-color);
            background: #ffffff;
            color: var(--text-secondary);
            font-size: 0.85rem;
            font-weight: 600;
            transition: var(--transition);
        }
        .day-pill input[type="radio"]:checked + span {
            background: var(--marvel-red);
            border-color: var(--marvel-red);
            color: #ffffff;
            box-shadow: 0 2px 6px rgba(237, 29, 36, 0.3);
        }
        .slot-time {
            font-size: 0.82rem;
            font-weight: 700;
            color: var(--marvel-red);
        }
        .slot-title {
            font-size: 0.95rem;
            font-weight: 700;
            color: var(--marvel-black);
            margin: 0.15rem 0;
        }
        .slot-meta {
            font-size: 0.8rem;
            color: var(--text-secondary);
            display: flex;
            gap: 0.75rem;
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
                    <h1 class="page-title">Weekly Class Timetable</h1>
                    <p class="page-subtitle">Track lecture slots, classroom locations, and course faculty.</p>
                </div>
                <div style="display:flex; gap:0.5rem;">
                    <a href="${pageContext.request.contextPath}/api/timetable.xml" target="_blank" class="btn btn-secondary btn-sm">Export XML</a>
                    <button class="btn btn-primary btn-sm" data-modal-target="addSlotModal">+ Add Lecture</button>
                </div>
            </div>

            <!-- Next Class Callout - Marvel Light Banner -->
            <c:if test="${not empty nextClass}">
                <div class="card" style="background: #ffffff; border: 1px solid #fee2e2; border-left: 6px solid var(--marvel-red); box-shadow: 0 4px 16px rgba(237, 29, 36, 0.08); margin-bottom: 2rem;">
                    <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 1rem;">
                        <div>
                            <span class="badge" style="background: var(--marvel-light-red); color: var(--marvel-red); border-color: var(--marvel-red); font-weight: 700;">Next Lecture</span>
                            <h2 style="font-size: 1.45rem; color: var(--text-primary); margin: 0.35rem 0; font-family: var(--font-sans); font-weight: 700;">${nextClass.subjectName} (${nextClass.courseCode})</h2>
                            <div style="color: var(--text-secondary); font-size: 0.92rem; display: flex; gap: 1.25rem;">
                                <span>⏰ ${nextClass.startTime.toString().substring(0, 5)} - ${nextClass.endTime.toString().substring(0, 5)}</span>
                                <span>📍 Room: ${nextClass.room}</span>
                                <span>👤 ${nextClass.faculty}</span>
                            </div>
                        </div>
                        <span class="badge" style="font-size: 0.85rem; padding: 0.5rem 1rem; background: #fef3c7; color: #b45309; border-color: #f59e0b;">Day: ${nextClass.dayOfWeek}</span>
                    </div>
                </div>
            </c:if>

            <!-- Timetable by Days -->
            <c:forEach var="day" items="${['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']}">
                <div class="timetable-day-card">
                    <div class="day-header">
                        <span class="day-name">${day}</span>
                        <c:if test="${day == currentDayName}">
                            <span class="badge badge-success">Today</span>
                        </c:if>
                    </div>

                    <div class="slots-list">
                        <c:set var="hasSlots" value="false" />
                        <c:forEach var="entry" items="${allEntries}">
                            <c:if test="${entry.dayOfWeek == day}">
                                <c:set var="hasSlots" value="true" />
                                <div class="slot-card" style="border-left: 4px solid ${entry.subjectColor != null ? entry.subjectColor : 'var(--primary)'};">
                                    <div>
                                        <div class="slot-time">${entry.startTime.toString().substring(0, 5)} - ${entry.endTime.toString().substring(0, 5)}</div>
                                        <div class="slot-title">${entry.subjectName}</div>
                                        <div class="slot-meta">
                                            <span>📍 ${entry.room != null ? entry.room : 'TBA'}</span>
                                            <span>👤 ${entry.faculty != null ? entry.faculty : 'Faculty'}</span>
                                        </div>
                                    </div>
                                    <form action="${pageContext.request.contextPath}/timetable" method="POST" onsubmit="return confirm('Remove this timetable slot?');">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="id" value="${entry.id}">
                                        <button type="submit" class="btn btn-secondary btn-icon" style="color: var(--danger); font-size: 0.8rem;" title="Remove">🗑️</button>
                                    </form>
                                </div>
                            </c:if>
                        </c:forEach>
                        <c:if test="${!hasSlots}">
                            <div style="color: var(--text-muted); font-size: 0.85rem; padding: 0.5rem 0;">No lectures scheduled on ${day}.</div>
                        </c:if>
                    </div>
                </div>
            </c:forEach>

        </div><!-- /.app-content -->
    </main>
</div>

<!-- Modal: Add Lecture Slot (No Select Lists - Direct Typing and Day Pills) -->
<div class="modal-overlay" id="addSlotModal">
    <div class="modal-dialog">
        <div class="modal-header">
            <h3 class="modal-title">Add Timetable Lecture</h3>
            <button class="modal-close" data-modal-close>&times;</button>
        </div>
        <form action="${pageContext.request.contextPath}/timetable" method="POST">
            <input type="hidden" name="action" value="create">
            <div class="modal-body">
                <div class="form-group">
                    <label class="form-label" for="slotSubjectName">Subject Name *</label>
                    <input type="text" id="slotSubjectName" name="subjectName" class="form-control" placeholder="e.g. Computer Networks" required autofocus>
                </div>
                <div class="form-group">
                    <label class="form-label">Day of Week *</label>
                    <div class="day-pills-selector">
                        <label class="day-pill"><input type="radio" name="dayOfWeek" value="Monday" checked> <span>Mon</span></label>
                        <label class="day-pill"><input type="radio" name="dayOfWeek" value="Tuesday"> <span>Tue</span></label>
                        <label class="day-pill"><input type="radio" name="dayOfWeek" value="Wednesday"> <span>Wed</span></label>
                        <label class="day-pill"><input type="radio" name="dayOfWeek" value="Thursday"> <span>Thu</span></label>
                        <label class="day-pill"><input type="radio" name="dayOfWeek" value="Friday"> <span>Fri</span></label>
                        <label class="day-pill"><input type="radio" name="dayOfWeek" value="Saturday"> <span>Sat</span></label>
                        <label class="day-pill"><input type="radio" name="dayOfWeek" value="Sunday"> <span>Sun</span></label>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="slotStart">Start Time *</label>
                        <input type="time" id="slotStart" name="startTime" class="form-control" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="slotEnd">End Time *</label>
                        <input type="time" id="slotEnd" name="endTime" class="form-control" required>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="slotRoom">Room / Lab</label>
                        <input type="text" id="slotRoom" name="room" class="form-control" placeholder="e.g. CS-302">
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="slotFaculty">Faculty Name</label>
                        <input type="text" id="slotFaculty" name="faculty" class="form-control" placeholder="e.g. Prof. R. Sharma">
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-modal-close>Cancel</button>
                <button type="submit" class="btn btn-primary">Save Lecture</button>
            </div>
        </form>
    </div>
</div>

<jsp:include page="../fragments/footer.jsp" />
