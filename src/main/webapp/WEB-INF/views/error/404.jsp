<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta name="color-scheme" content="light">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>404 - Page Not Found | Padi da Parama!</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css?v=marvel_light_v3">
    <style>
        .error-container {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-direction: column;
            text-align: center;
            padding: 2rem;
            background: #0b0f19;
            color: #f8fafc;
        }
        .error-code { font-size: 6rem; font-weight: 800; color: #6366f1; margin: 0; }
        .error-title { font-size: 1.8rem; margin: 0.5rem 0 1rem; }
        .error-desc { color: #94a3b8; max-width: 480px; margin-bottom: 2rem; }
        .btn-home {
            display: inline-block;
            background: #4f46e5;
            color: white;
            padding: 0.75rem 1.5rem;
            border-radius: 8px;
            text-decoration: none;
            font-weight: 600;
            transition: background 0.2s;
        }
        .btn-home:hover { background: #4338ca; }
    </style>
</head>
<body>
    <div class="error-container">
        <h1 class="error-code">404</h1>
        <h2 class="error-title">Page Not Found</h2>
        <p class="error-desc">The requested resource could not be found on the server. Please check the URL or navigate back to the dashboard.</p>
        <a href="${pageContext.request.contextPath}/dashboard" class="btn-home">Return to Dashboard</a>
    </div>
</body>
</html>
