<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta name="color-scheme" content="light">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Holidays &amp; Breaks - Padi da Parama!</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css?v=marvel_light_v3">
    <style>
        .holiday-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 1.25rem;
        }
        .holiday-card {
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
        .holiday-card:hover {
            border-color: var(--marvel-red-border);
            border-top-color: var(--marvel-red);
            box-shadow: 0 8px 20px rgba(237, 29, 36, 0.08);
            transform: translateY(-2px);
        }
        .h-title { font-size: 1.25rem; font-weight: 700; color: var(--text-primary); margin: 0.25rem 0; font-family: var(--font-sans); }
        .h-desc { font-size: 0.9rem; color: var(--text-secondary); margin-bottom: 1rem; line-height: 1.4; }
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
                    <h1 class="page-title">College Holidays &amp; Vacations</h1>
                    <p class="page-subtitle">Track academic breaks, institutional holidays, and vacation countdowns.</p>
                </div>
                <button class="btn btn-primary" data-modal-target="addHolidayModal">+ Add Holiday</button>
            </div>

            <!-- Next Holiday Callout - Marvel Light Banner -->
            <c:if test="${not empty nextHoliday}">
                <div class="card" style="background: #ffffff; border: 1px solid #fee2e2; border-left: 6px solid var(--marvel-red); box-shadow: 0 4px 16px rgba(237, 29, 36, 0.08); margin-bottom: 2rem;">
                    <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:1rem;">
                        <div>
                            <span class="badge" style="background: var(--marvel-light-red); color: var(--marvel-red); border-color: var(--marvel-red); font-weight: 700;">Next Upcoming Break</span>
                            <h2 style="font-size: 1.45rem; color: var(--text-primary); margin: 0.35rem 0; font-family: var(--font-sans); font-weight: 700;">${nextHoliday.title}</h2>
                            <div style="color: var(--text-secondary); font-size: 0.92rem;">
                                <span>📅 Date: ${nextHoliday.holidayDate} &bull; Type: ${nextHoliday.holidayType}</span>
                            </div>
                        </div>
                        <span class="badge" style="font-size: 0.85rem; padding: 0.5rem 1rem; background: #fef3c7; color: #b45309; border-color: #f59e0b;">${nextHoliday.countdownText}</span>
                    </div>
                </div>
            </c:if>

            <div class="holiday-grid">
                <c:choose>
                    <c:when test="${empty holidays}">
                        <div class="card" style="grid-column: 1 / -1; text-align: center; padding: 3rem; color: var(--text-muted);">
                            No holidays registered. Add semester breaks or official holidays above!
                        </div>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="h" items="${holidays}">
                            <div class="holiday-card">
                                <div>
                                    <div style="display: flex; justify-content: space-between; align-items: center;">
                                        <span class="badge" style="background: rgba(245, 158, 11, 0.15); color: #fbbf24;">
                                            ${h.holidayType}
                                        </span>
                                        <span style="font-size: 0.8rem; font-weight: 700; color: var(--warning);">
                                            ${h.countdownText}
                                        </span>
                                    </div>

                                    <h3 class="h-title">${h.title}</h3>
                                    <div style="font-size: 0.82rem; color: var(--text-muted); margin-bottom: 0.5rem;">
                                        📅 ${h.holidayDate}
                                    </div>
                                    <p class="h-desc">${h.description}</p>
                                </div>

                                <div style="display: flex; justify-content: flex-end; border-top: 1px solid var(--border-color); padding-top: 0.75rem;">
                                    <form action="${pageContext.request.contextPath}/holidays" method="POST" onsubmit="return confirm('Delete this holiday entry?');">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="id" value="${h.id}">
                                        <button type="submit" class="btn btn-secondary btn-icon" style="color: var(--danger);" title="Delete">🗑️</button>
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

<!-- Modal: Add Holiday -->
<div class="modal-overlay" id="addHolidayModal">
    <div class="modal-dialog">
        <div class="modal-header">
            <h3 class="modal-title">Record Academic Holiday</h3>
            <button class="modal-close" data-modal-close>&times;</button>
        </div>
        <form action="${pageContext.request.contextPath}/holidays" method="POST">
            <input type="hidden" name="action" value="create">
            <div class="modal-body">
                <div class="form-group">
                    <label class="form-label" for="hTitle">Holiday Name *</label>
                    <input type="text" id="hTitle" name="title" class="form-control" placeholder="e.g. Mid-Semester Break" required>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="hDate">Holiday Date *</label>
                        <input type="date" id="hDate" name="holidayDate" class="form-control" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="hType">Category Type</label>
                        <select id="hType" name="holidayType" class="form-control">
                            <option value="College Holiday" selected>College Holiday</option>
                            <option value="Public Holiday">Public Holiday</option>
                            <option value="Vacation">Vacation</option>
                            <option value="Event Holiday">Event Holiday</option>
                        </select>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label" for="hDesc">Description</label>
                    <textarea id="hDesc" name="description" class="form-control" rows="2" placeholder="Details or duration of leave"></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-modal-close>Cancel</button>
                <button type="submit" class="btn btn-primary">Save Holiday</button>
            </div>
        </form>
    </div>
</div>

<jsp:include page="../fragments/footer.jsp" />
