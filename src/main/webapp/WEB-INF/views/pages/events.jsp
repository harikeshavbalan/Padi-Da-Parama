<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta name="color-scheme" content="light">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>College &amp; Personal Events - Padi da Parama!</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css?v=marvel_light_v3">
    <style>
        .events-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
            gap: 1.5rem;
        }
        .event-card {
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
        .event-card:hover {
            border-color: var(--marvel-red-border);
            border-top-color: var(--marvel-red);
            box-shadow: 0 8px 20px rgba(237, 29, 36, 0.08);
            transform: translateY(-2px);
        }
        .event-top { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 0.5rem; }
        .event-title { font-size: 1.25rem; font-weight: 700; color: var(--text-primary); font-family: var(--font-sans); }
        .event-desc { font-size: 0.9rem; color: var(--text-secondary); margin: 0.5rem 0 1rem; line-height: 1.4; }
        .event-meta { font-size: 0.82rem; color: var(--text-muted); display: flex; flex-direction: column; gap: 0.25rem; }
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
                    <h1 class="page-title">Campus &amp; Personal Events</h1>
                    <p class="page-subtitle">Track hackathons, club meetings, project reviews, seminars, and deadlines.</p>
                </div>
                <button class="btn btn-primary btn-sm" data-modal-target="addEventModal">+ Add Event</button>
            </div>

            <!-- Next Event Callout - Marvel Light Banner -->
            <c:if test="${not empty nextEvent}">
                <div class="card" style="background: #ffffff; border: 1px solid #fee2e2; border-left: 6px solid var(--marvel-red); box-shadow: 0 4px 16px rgba(237, 29, 36, 0.08); margin-bottom: 2rem;">
                    <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:1rem;">
                        <div>
                            <span class="badge" style="background: var(--marvel-light-red); color: var(--marvel-red); border-color: var(--marvel-red); font-weight: 700;">Next Upcoming Event</span>
                            <h2 style="font-size: 1.45rem; color: var(--text-primary); margin: 0.35rem 0; font-family: var(--font-sans); font-weight: 700;">${nextEvent.title}</h2>
                            <div style="color: var(--text-secondary); font-size: 0.92rem; display: flex; gap: 1.25rem;">
                                <span>📅 Date: ${nextEvent.eventDate}</span>
                                <span>⏰ Time: ${nextEvent.startTime != null ? nextEvent.startTime.toString().substring(0, 5) : 'All Day'}</span>
                                <span>📍 Location: ${nextEvent.location}</span>
                            </div>
                        </div>
                        <span class="badge" style="background: #fef3c7; color: #b45309; border-color: #f59e0b; font-size: 0.85rem; padding: 0.5rem 1rem;">${nextEvent.countdownText}</span>
                    </div>
                </div>
            </c:if>

            <div class="events-grid">
                <c:choose>
                    <c:when test="${empty events}">
                        <div class="card" style="grid-column: 1 / -1; text-align: center; padding: 3rem; color: var(--text-muted);">
                            No events scheduled. Add a club meeting, seminar, or project evaluation above!
                        </div>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="ev" items="${events}">
                            <div class="event-card">
                                <div>
                                    <div class="event-top">
                                        <span class="badge" style="background: var(--purple-light); color: var(--purple); border: 1px solid rgba(139, 92, 246, 0.3);">
                                            ${ev.category}
                                        </span>
                                        <span style="font-size: 0.8rem; font-weight: 700; color: var(--warning);">
                                            ${ev.countdownText}
                                        </span>
                                    </div>

                                    <h3 class="event-title">${ev.title}</h3>
                                    <p class="event-desc">${ev.description}</p>

                                    <div class="event-meta">
                                        <span>📅 ${ev.eventDate}</span>
                                        <c:if test="${not empty ev.startTime}">
                                            <span>⏰ ${ev.startTime.toString().substring(0, 5)}<c:if test="${not empty ev.endTime}"> - ${ev.endTime.toString().substring(0, 5)}</c:if></span>
                                        </c:if>
                                        <c:if test="${not empty ev.location}">
                                            <span>📍 ${ev.location}</span>
                                        </c:if>
                                    </div>
                                </div>

                                <div style="display: flex; justify-content: flex-end; margin-top: 1rem; border-top: 1px solid var(--border-color); padding-top: 0.75rem;">
                                    <form action="${pageContext.request.contextPath}/events" method="POST" onsubmit="return confirm('Delete this event?');">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="id" value="${ev.id}">
                                        <button type="submit" class="btn btn-secondary btn-icon" style="color: var(--danger);" title="Delete Event">🗑️</button>
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

<!-- Modal: Add Event -->
<div class="modal-overlay" id="addEventModal">
    <div class="modal-dialog">
        <div class="modal-header">
            <h3 class="modal-title">Schedule New Event</h3>
            <button class="modal-close" data-modal-close>&times;</button>
        </div>
        <form action="${pageContext.request.contextPath}/events" method="POST">
            <input type="hidden" name="action" value="create">
            <div class="modal-body">
                <div class="form-group">
                    <label class="form-label" for="evTitle">Event Title *</label>
                    <input type="text" id="evTitle" name="title" class="form-control" placeholder="e.g. Annual Hackathon 2026" required>
                </div>
                <div class="form-group">
                    <label class="form-label" for="evDesc">Description</label>
                    <textarea id="evDesc" name="description" class="form-control" rows="2" placeholder="Event details, registration info, or deliverables"></textarea>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="evDate">Event Date *</label>
                        <input type="date" id="evDate" name="eventDate" class="form-control" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="evCategory">Category</label>
                        <select id="evCategory" name="category" class="form-control">
                            <option value="Club meeting">Club meeting</option>
                            <option value="College event" selected>College event</option>
                            <option value="Presentation">Presentation</option>
                            <option value="Project review">Project review</option>
                            <option value="Seminar">Seminar</option>
                            <option value="Personal">Personal</option>
                        </select>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="evStart">Start Time</label>
                        <input type="time" id="evStart" name="startTime" class="form-control" value="10:00">
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="evEnd">End Time</label>
                        <input type="time" id="evEnd" name="endTime" class="form-control" value="12:00">
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label" for="evLoc">Location / Venue</label>
                    <input type="text" id="evLoc" name="location" class="form-control" placeholder="e.g. Auditorium Block A">
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-modal-close>Cancel</button>
                <button type="submit" class="btn btn-primary">Schedule Event</button>
            </div>
        </form>
    </div>
</div>

<jsp:include page="../fragments/footer.jsp" />
