<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta name="color-scheme" content="light">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Academic Calendar - Padi da Parama!</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css?v=marvel_light_v3">
    <style>
        .calendar-controls {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 1.5rem;
            flex-wrap: wrap;
            gap: 1rem;
        }
        .controls-left, .controls-right {
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }
        .calendar-title {
            font-size: 1.4rem;
            font-weight: 700;
            color: var(--text-primary);
            margin-left: 0.5rem;
        }
        .month-grid {
            background: #ffffff;
            border: 1px solid var(--border-color);
            border-radius: var(--radius-lg);
            overflow: hidden;
            box-shadow: var(--shadow-card);
        }
        .day-names-row {
            display: grid;
            grid-template-columns: repeat(7, 1fr);
            background: #f8fafc;
            border-bottom: 2px solid var(--marvel-red);
            text-align: center;
            font-size: 0.8rem;
            font-weight: 700;
            color: var(--text-primary);
            text-transform: uppercase;
            padding: 0.75rem 0;
            letter-spacing: 0.05em;
        }
        .cells-grid {
            display: grid;
            grid-template-columns: repeat(7, 1fr);
            grid-auto-rows: minmax(110px, auto);
        }
        .cal-cell {
            border-right: 1px solid var(--border-color);
            border-bottom: 1px solid var(--border-color);
            padding: 0.5rem;
            display: flex;
            flex-direction: column;
            gap: 0.25rem;
            background: #ffffff;
            transition: var(--transition);
        }
        .cal-cell:nth-child(7n) { border-right: none; }
        .cal-cell.other-month {
            opacity: 0.4;
            background: #f8fafc;
        }
        .cal-cell.today {
            background: #fff5f5;
        }
        .cal-cell.today .cell-num {
            background: var(--marvel-red);
            color: white;
            border-radius: 50%;
            width: 26px;
            height: 26px;
            border: 1.5px solid var(--marvel-black);
            display: inline-flex;
            align-items: center;
            justify-content: center;
        }
        .cell-num {
            font-size: 0.82rem;
            font-weight: 700;
            color: var(--marvel-black);
        }
        .cal-event-pill {
            font-size: 0.72rem;
            background: var(--bg-input);
            padding: 0.2rem 0.4rem;
            border-radius: var(--radius-sm);
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            cursor: pointer;
        }
        .cal-more {
            font-size: 0.68rem;
            color: var(--text-muted);
            text-align: right;
        }
        /* Week Grid */
        .week-grid {
            display: grid;
            grid-template-columns: repeat(7, 1fr);
            gap: 0.75rem;
        }
        .week-day-col {
            background: var(--bg-card);
            border: 1px solid var(--border-color);
            border-radius: var(--radius-md);
            padding: 0.75rem;
            min-height: 400px;
        }
        .week-day-col.today-col {
            border-color: var(--primary);
        }
        .week-col-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding-bottom: 0.5rem;
            border-bottom: 1px solid var(--border-color);
            margin-bottom: 0.75rem;
        }
        .cal-event-card {
            background: var(--bg-card-hover);
            padding: 0.5rem;
            border-radius: var(--radius-sm);
            margin-bottom: 0.5rem;
            font-size: 0.75rem;
            display: flex;
            flex-direction: column;
            gap: 0.15rem;
        }
        .event-time { font-weight: 700; color: var(--text-muted); font-size: 0.68rem; }
        .event-title { font-weight: 600; color: var(--text-primary); }
        .event-desc { color: var(--text-muted); font-size: 0.7rem; }
        /* Day View */
        .day-view-container {
            background: var(--bg-card);
            border: 1px solid var(--border-color);
            border-radius: var(--radius-lg);
            padding: 1.5rem;
        }
        .day-summary-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 1.5rem;
        }
        .day-event-block {
            background: var(--bg-card-hover);
            border-radius: var(--radius-md);
            padding: 1rem;
            margin-bottom: 1rem;
        }
        .block-top { display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.4rem; }
        .block-time { font-size: 0.8rem; font-weight: 700; color: var(--text-muted); }
        .block-title { font-size: 1rem; font-weight: 700; color: var(--text-primary); }
        .block-details { font-size: 0.82rem; color: var(--text-secondary); margin-top: 0.25rem; }
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
                    <h1 class="page-title">Interactive Academic Calendar</h1>
                    <p class="page-subtitle">Unified timeline of tasks, exams, classes, events, and holidays.</p>
                </div>
                <div style="display:flex; gap:0.5rem;">
                    <a href="${pageContext.request.contextPath}/tasks" class="btn btn-primary btn-sm">+ Add Task</a>
                    <a href="${pageContext.request.contextPath}/events" class="btn btn-secondary btn-sm">+ Add Event</a>
                </div>
            </div>

            <!-- Calendar Container Mount -->
            <div id="calendarContainer"></div>

        </div><!-- /.app-content -->
    </main>
</div>

<jsp:include page="../fragments/footer.jsp" />
<script src="${pageContext.request.contextPath}/assets/js/calendar.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', () => {
        new StudentCalendar('calendarContainer');
    });
</script>
