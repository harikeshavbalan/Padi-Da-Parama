<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta name="color-scheme" content="light">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Analytics &amp; Productivity - Padi da Parama!</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css?v=marvel_light_v3">
    <style>
        .analytics-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1.5rem;
            margin-bottom: 2rem;
        }
        @media (max-width: 900px) {
            .analytics-grid { grid-template-columns: 1fr; }
        }
        /* Workload Bar Chart */
        .workload-bars {
            display: flex;
            align-items: flex-end;
            justify-content: space-between;
            height: 200px;
            padding-top: 1.5rem;
            gap: 0.75rem;
        }
        .bar-col {
            flex: 1;
            display: flex;
            flex-direction: column;
            align-items: center;
            height: 100%;
            justify-content: flex-end;
        }
        .bar-val { font-size: 0.8rem; font-weight: 700; color: var(--marvel-red); margin-bottom: 0.35rem; font-family: var(--font-comic); letter-spacing: 0.5px; }
        .bar-track {
            width: 100%;
            max-width: 42px;
            background: #f8fafc;
            border: 1px solid var(--border-color);
            border-radius: var(--radius-sm);
            height: 140px;
            display: flex;
            align-items: flex-end;
            overflow: hidden;
        }
        .bar-fill {
            width: 100%;
            background: linear-gradient(180deg, var(--marvel-red), var(--marvel-crimson));
            border-radius: var(--radius-sm) var(--radius-sm) 0 0;
            transition: height 0.6s cubic-bezier(0.4, 0, 0.2, 1);
        }
        .bar-day { font-size: 0.8rem; font-weight: 700; color: var(--text-primary); margin-top: 0.5rem; font-family: var(--font-sans); }
        /* Subject bars */
        .subject-bars { display: flex; flex-direction: column; gap: 1rem; }
        .subject-stat-row { display: flex; flex-direction: column; gap: 0.35rem; }
        .subject-name-col { display: flex; justify-content: space-between; font-size: 0.85rem; font-weight: 600; }
        .subj-hours { color: var(--text-muted); font-size: 0.78rem; font-weight: 600; }
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
                    <h1 class="page-title">Performance &amp; Productivity Analytics</h1>
                    <p class="page-subtitle">Transparent metric breakdowns and weekly academic workload distribution.</p>
                </div>
            </div>

            <!-- Primary Metrics Row -->
            <div class="stat-grid" style="margin-bottom: 2rem;">
                <div class="card stat-card">
                    <div class="stat-header">
                        <span>Productivity Score</span>
                        <div class="stat-icon" style="background: var(--primary-light); color: var(--primary);">🎯</div>
                    </div>
                    <div class="stat-value" style="color: var(--primary);">${metrics.overallScore} / 100</div>
                    <div class="stat-footer">Algorithmic composite rating</div>
                </div>

                <div class="card stat-card">
                    <div class="stat-header">
                        <span>Task Completion</span>
                        <div class="stat-icon" style="background: var(--success-light); color: var(--success);">✓</div>
                    </div>
                    <div class="stat-value" style="color: var(--success);">${completionPercent}%</div>
                    <div class="stat-footer">${completedTasks} completed of ${totalTasks} total</div>
                </div>

                <div class="card stat-card">
                    <div class="stat-header">
                        <span>Weekly Study Time</span>
                        <div class="stat-icon" style="background: var(--info-light); color: var(--info);">⏱️</div>
                    </div>
                    <div class="stat-value">${weekStudyHours}h ${weekStudyMins}m</div>
                    <div class="stat-footer">Monthly total: ${monthStudyHours} hours</div>
                </div>

                <div class="card stat-card">
                    <div class="stat-header">
                        <span>Habit Consistency</span>
                        <div class="stat-icon" style="background: rgba(251, 146, 60, 0.15); color: #fb923c;">🔥</div>
                    </div>
                    <div class="stat-value" style="color: #fb923c;">${maxStreak} Days</div>
                    <div class="stat-footer">${habitWeeklyRate}% adherence this week</div>
                </div>
            </div>

            <div class="analytics-grid">

                <!-- 1. Weekly Workload Visualizer (Section 24) -->
                <div class="card">
                    <div class="card-header">
                        <h2 class="card-title">
                            <span>📊</span>
                            <span>Weekly Workload Distribution</span>
                        </h2>
                        <span class="badge badge-medium">Current Week</span>
                    </div>
                    <div id="workloadChartContainer"></div>
                </div>

                <!-- 2. Transparent Productivity Formula Breakdown (Section 41) -->
                <div class="card">
                    <div class="card-header">
                        <h2 class="card-title">
                            <span>📐</span>
                            <span>Productivity Score Formula</span>
                        </h2>
                        <span class="badge badge-success">Transparent Metric</span>
                    </div>

                    <p style="font-size: 0.85rem; color: var(--text-muted); margin-bottom: 1.25rem;">
                        The composite score is calculated transparently as an academic productivity indicator:
                    </p>

                    <div style="display: flex; flex-direction: column; gap: 1rem;">
                        <div>
                            <div style="display:flex; justify-content:space-between; font-size:0.85rem; margin-bottom:0.25rem;">
                                <span>1. Task Completion (40% Weight)</span>
                                <strong>${Math.round(metrics.taskCompletionRate)}%</strong>
                            </div>
                            <div class="progress-container">
                                <div class="progress-bar progress-bar-success" style="width: ${metrics.taskCompletionRate}%;"></div>
                            </div>
                        </div>

                        <div>
                            <div style="display:flex; justify-content:space-between; font-size:0.85rem; margin-bottom:0.25rem;">
                                <span>2. Deadline Adherence (25% Weight)</span>
                                <strong>${Math.round(metrics.deadlineAdherenceRate)}%</strong>
                            </div>
                            <div class="progress-container">
                                <div class="progress-bar progress-bar-warning" style="width: ${metrics.deadlineAdherenceRate}%;"></div>
                            </div>
                        </div>

                        <div>
                            <div style="display:flex; justify-content:space-between; font-size:0.85rem; margin-bottom:0.25rem;">
                                <span>3. Study Target Consistency (20% Weight)</span>
                                <strong>${Math.round(metrics.studyTargetRate)}%</strong>
                            </div>
                            <div class="progress-container">
                                <div class="progress-bar" style="width: ${metrics.studyTargetRate}%;"></div>
                            </div>
                        </div>

                        <div>
                            <div style="display:flex; justify-content:space-between; font-size:0.85rem; margin-bottom:0.25rem;">
                                <span>4. Daily Habit Consistency (15% Weight)</span>
                                <strong>${Math.round(metrics.habitCompletionRate)}%</strong>
                            </div>
                            <div class="progress-container">
                                <div class="progress-bar progress-bar-success" style="width: ${metrics.habitCompletionRate}%;"></div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- 3. Subject-Wise Study Investment -->
                <div class="card" style="grid-column: 1 / -1;">
                    <div class="card-header">
                        <h2 class="card-title">
                            <span>📚</span>
                            <span>Subject-Wise Study Investment</span>
                        </h2>
                    </div>
                    <div id="subjectStudyContainer"></div>
                </div>

            </div>

        </div><!-- /.app-content -->
    </main>
</div>

<jsp:include page="../fragments/footer.jsp" />
<script src="${pageContext.request.contextPath}/assets/js/charts.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', () => {
        // Render Workload Chart from Server Data
        const workloadData = [
            ${weeklyWorkload[0]},
            ${weeklyWorkload[1]},
            ${weeklyWorkload[2]},
            ${weeklyWorkload[3]},
            ${weeklyWorkload[4]},
            ${weeklyWorkload[5]},
            ${weeklyWorkload[6]}
        ];
        renderWorkloadChart('workloadChartContainer', workloadData);

        // Render Subject Study Chart
        const subjectStudyData = {
            <c:forEach var="entry" items="${subjectStudy}" varStatus="status">
                "${entry.key}": ${entry.value}${!status.last ? ',' : ''}
            </c:forEach>
        };
        renderSubjectStudyChart('subjectStudyContainer', subjectStudyData);
    });
</script>
