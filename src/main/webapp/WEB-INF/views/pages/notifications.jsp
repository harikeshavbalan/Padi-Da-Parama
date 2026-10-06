<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta name="color-scheme" content="light">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>In-App Notifications - Padi da Parama!</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css?v=marvel_light_v3">
    <style>
        .notif-list { display: flex; flex-direction: column; gap: 0.85rem; }
        .notif-item {
            background: var(--bg-card);
            border: 1px solid var(--border-color);
            border-radius: var(--radius-md);
            padding: 1.1rem 1.35rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
            box-shadow: var(--shadow-sm);
            transition: var(--transition);
        }
        .notif-item.unread {
            background: var(--marvel-light-red);
            border-left: 4px solid var(--marvel-red);
        }
        .notif-icon {
            width: 40px;
            height: 40px;
            border-radius: var(--radius-md);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.2rem;
            flex-shrink: 0;
            margin-right: 1rem;
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
                    <h1 class="page-title">In-App Notifications</h1>
                    <p class="page-subtitle">Automatic alerts for approaching deadlines, upcoming exams, and habit streaks.</p>
                </div>
                <form action="${pageContext.request.contextPath}/notifications" method="POST">
                    <input type="hidden" name="action" value="markAllRead">
                    <button type="submit" class="btn btn-secondary btn-sm">Mark All as Read</button>
                </form>
            </div>

            <div class="notif-list">
                <c:choose>
                    <c:when test="${empty notifications}">
                        <div class="card" style="text-align: center; padding: 3rem; color: var(--text-muted);">
                            You have no notifications at this time. All caught up!
                        </div>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="n" items="${notifications}">
                            <div class="notif-item ${!n.read ? 'unread' : ''}">
                                <div style="display: flex; align-items: center;">
                                    <div class="notif-icon" style="background: ${n.type == 'ALERT' ? 'var(--danger-light)' : (n.type == 'WARNING' ? 'var(--warning-light)' : (n.type == 'SUCCESS' ? 'var(--success-light)' : 'var(--primary-light)'))};">
                                        ${n.type == 'ALERT' ? '⚠️' : (n.type == 'WARNING' ? '🔔' : (n.type == 'SUCCESS' ? '🎉' : 'ℹ️'))}
                                    </div>
                                    <div>
                                        <div style="font-weight: 700; color: var(--text-primary); font-size: 0.95rem;">
                                            ${n.title}
                                        </div>
                                        <div style="font-size: 0.85rem; color: var(--text-secondary); margin-top: 0.2rem;">
                                            ${n.message}
                                        </div>
                                        <div style="font-size: 0.72rem; color: var(--text-muted); margin-top: 0.25rem;">
                                            ${n.createdAt}
                                        </div>
                                    </div>
                                </div>

                                <div style="display: flex; align-items: center; gap: 0.75rem;">
                                    <c:if test="${not empty n.link}">
                                        <a href="${pageContext.request.contextPath}/${n.link}" class="btn btn-secondary btn-sm">View →</a>
                                    </c:if>
                                    <c:if test="${!n.read}">
                                        <form action="${pageContext.request.contextPath}/notifications" method="POST" style="display:inline;">
                                            <input type="hidden" name="action" value="markRead">
                                            <input type="hidden" name="id" value="${n.id}">
                                            <button type="submit" class="btn btn-secondary btn-sm" title="Mark as read">✓</button>
                                        </form>
                                    </c:if>
                                </div>
                            </div>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </div>

        </div><!-- /.app-content -->
    </main>
</div>

<jsp:include page="../fragments/footer.jsp" />
