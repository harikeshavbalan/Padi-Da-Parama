<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta name="color-scheme" content="light">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>500 - Server Error | Padi da Parama!</title>
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
        .error-code { font-size: 6rem; font-weight: 800; color: #ef4444; margin: 0; }
        .error-title { font-size: 1.8rem; margin: 0.5rem 0 1rem; }
        .error-desc { color: #94a3b8; max-width: 520px; margin-bottom: 2rem; }
        .btn-home {
            display: inline-block;
            background: #4f46e5;
            color: white;
            padding: 0.75rem 1.5rem;
            border-radius: 8px;
            text-decoration: none;
            font-weight: 600;
        }
    </style>
</head>
<body>
    <div class="error-container">
        <h1 class="error-code">500</h1>
        <h2 class="error-title">Internal Server Error</h2>
        <p class="error-desc">An unexpected error occurred while processing your request. Please try again later or return to the dashboard.</p>
        <a href="${pageContext.request.contextPath}/dashboard" class="btn-home">Return to Dashboard</a>
    </div>
</body>
</html>
