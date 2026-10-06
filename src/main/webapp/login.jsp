<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta name="color-scheme" content="light">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Padi da Parama!</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css?v=marvel_light_v3">
    <style>
        .auth-container {
            min-height: 100vh;
            width: 100%;
            display: flex;
            align-items: center;
            justify-content: center;
            background: radial-gradient(circle at top right, rgba(237, 29, 36, 0.08), transparent 60%),
                        radial-gradient(circle at bottom left, rgba(17, 17, 21, 0.05), transparent 50%),
                        #f8fafc;
            padding: 1.5rem;
            font-family: var(--font-sans);
        }

        .auth-card {
            background-color: #ffffff;
            border: 1px solid var(--border-color);
            border-top: 4px solid var(--marvel-red);
            border-radius: var(--radius-lg);
            width: 100%;
            max-width: 440px;
            padding: 2.25rem;
            box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.08), 0 8px 10px -6px rgba(0, 0, 0, 0.04);
            position: relative;
        }

        .auth-header {
            text-align: center;
            margin-bottom: 2rem;
        }

        .auth-badge {
            display: inline-block;
            background: var(--marvel-red);
            color: white;
            font-family: var(--font-comic);
            font-size: 1.3rem;
            padding: 0.35rem 0.9rem;
            border-radius: 4px;
            letter-spacing: 2.5px;
            margin-bottom: 0.75rem;
            box-shadow: 0 2px 8px rgba(237, 29, 36, 0.3);
            line-height: 1;
        }

        .auth-title {
            font-size: 1.7rem;
            font-weight: 700;
            color: var(--text-primary);
            letter-spacing: -0.5px;
            font-family: var(--font-sans);
        }

        .auth-subtitle {
            font-size: 0.95rem;
            color: var(--text-secondary);
            margin-top: 0.35rem;
            font-family: var(--font-sans);
        }

        .auth-tabs {
            display: flex;
            border-bottom: 1px solid var(--border-color);
            margin-bottom: 1.5rem;
        }

        .auth-tab {
            flex: 1;
            text-align: center;
            padding: 0.65rem;
            font-size: 0.95rem;
            font-weight: 600;
            color: var(--text-secondary);
            cursor: pointer;
            border-bottom: 3px solid transparent;
            transition: var(--transition);
        }

        .auth-tab.active {
            color: var(--marvel-red);
            border-bottom-color: var(--marvel-red);
            font-weight: 700;
        }

        .demo-box {
            background: #fff5f5;
            border: 1px dashed var(--marvel-red-border);
            border-radius: var(--radius-md);
            padding: 0.75rem 1rem;
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-size: 0.85rem;
        }

        .demo-info {
            color: var(--text-primary);
        }

        .demo-info code {
            background: #fee2e2;
            color: var(--marvel-crimson);
            padding: 0.1rem 0.35rem;
            border-radius: 4px;
            font-weight: 700;
        }

        .btn-fill-demo {
            background: var(--marvel-red);
            color: white;
            border: 1px solid var(--marvel-red);
            padding: 0.35rem 0.75rem;
            border-radius: var(--radius-sm);
            font-size: 0.8rem;
            cursor: pointer;
            font-weight: 700;
            box-shadow: 0 2px 6px rgba(237, 29, 36, 0.25);
            transition: var(--transition);
        }

        .btn-fill-demo:hover {
            background: var(--marvel-crimson);
        }

        .auth-footer {
            margin-top: 1.5rem;
            text-align: center;
            font-size: 0.85rem;
            font-weight: 500;
            color: var(--text-muted);
        }

        .remember-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 1.25rem;
            font-size: 0.88rem;
            color: var(--text-secondary);
        }

        .checkbox-label {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            cursor: pointer;
            font-weight: 500;
        }

        .checkbox-label input[type="checkbox"] {
            accent-color: var(--marvel-red);
            width: 16px;
            height: 16px;
        }

        .availability-msg {
            font-size: 0.8rem;
            margin-top: 0.25rem;
            font-weight: 600;
        }
    </style>
</head>
<body>
    <div class="auth-container">
        <div class="auth-card">
            <div class="auth-header">
                <span class="auth-badge">PdP</span>
                <h1 class="auth-title">Padi da Parama!</h1>
                <p class="auth-subtitle">Personal Academic &amp; Productivity Management System</p>
            </div>

            <!-- Tabs -->
            <div class="auth-tabs">
                <div class="auth-tab active" id="tabLogin" onclick="switchTab('login')">Sign In</div>
                <div class="auth-tab" id="tabRegister" onclick="switchTab('register')">Create Account</div>
            </div>

            <!-- Demo Login Assistant -->
            <div class="demo-box" id="demoBanner">
                <div class="demo-info">
                    <strong>Demo Student Account:</strong><br>
                    <span>User: <code>demo</code> &nbsp;|&nbsp; Pass: <code>demo123</code></span>
                </div>
                <button type="button" class="btn-fill-demo" onclick="fillDemo()">Auto-Fill</button>
            </div>

            <!-- Alerts -->
            <c:if test="${not empty error || not empty param.error}">
                <div class="alert alert-danger">
                    <span>⚠️</span>
                    <span>${not empty error ? error : param.error}</span>
                </div>
            </c:if>
            <c:if test="${not empty param.success}">
                <div class="alert alert-success">
                    <span>✓</span>
                    <span>${param.success}</span>
                </div>
            </c:if>

            <!-- Login Form -->
            <form action="${pageContext.request.contextPath}/login" method="POST" id="loginForm">
                <input type="hidden" name="action" value="login">

                <div class="form-group">
                    <label class="form-label" for="loginUsername">Username</label>
                    <input type="text" id="loginUsername" name="username" class="form-control"
                           placeholder="Enter your username"
                           value="${not empty rememberedUsername ? rememberedUsername : (not empty enteredUsername ? enteredUsername : '')}"
                           required autofocus>
                </div>

                <div class="form-group">
                    <label class="form-label" for="loginPassword">Password</label>
                    <input type="password" id="loginPassword" name="password" class="form-control"
                           placeholder="Enter your password" required>
                </div>

                <div class="remember-row">
                    <label class="checkbox-label">
                        <input type="checkbox" name="rememberMe" id="rememberMe" ${not empty rememberedUsername ? 'checked' : ''}>
                        <span>Remember username</span>
                    </label>
                    <a href="javascript:void(0)" onclick="alert('Please contact your administrator to reset credentials.')" style="color: var(--primary); text-decoration: none;">Forgot?</a>
                </div>

                <button type="submit" class="btn btn-primary" style="width: 100%;">
                    <span>Sign In to Student OS</span>
                    <span>→</span>
                </button>
            </form>

            <!-- Registration Form -->
            <form action="${pageContext.request.contextPath}/register" method="POST" id="registerForm" style="display: none;">
                <input type="hidden" name="action" value="register">

                <div class="form-group">
                    <label class="form-label" for="regUsername">Desired Username</label>
                    <input type="text" id="regUsername" name="username" class="form-control"
                           placeholder="e.g. harikeshav" required onblur="checkUsernameAvailability()">
                    <div id="usernameCheckMsg" class="availability-msg"></div>
                </div>

                <div class="form-group">
                    <label class="form-label" for="regFullName">Full Name</label>
                    <input type="text" id="regFullName" name="fullName" class="form-control"
                           placeholder="e.g. Harikeshav" required>
                </div>

                <div class="form-group">
                    <label class="form-label" for="regEmail">College Email</label>
                    <input type="email" id="regEmail" name="email" class="form-control"
                           placeholder="e.g. student@college.edu" required>
                </div>

                <div class="form-group">
                    <label class="form-label" for="regPassword">Password</label>
                    <input type="password" id="regPassword" name="password" class="form-control"
                           placeholder="Create a secure password" minlength="6" required>
                </div>

                <button type="submit" class="btn btn-primary" style="width: 100%; margin-top: 0.5rem;">
                    <span>Create My Account</span>
                    <span>→</span>
                </button>
            </form>

            <div class="auth-footer">
                <span>College Web Technology Project &bull; Java Jakarta Servlets &bull; MVC</span>
            </div>
        </div>
    </div>

    <script>
        window.APP_CONTEXT = '${pageContext.request.contextPath}';

        function switchTab(tab) {
            const loginForm = document.getElementById('loginForm');
            const registerForm = document.getElementById('registerForm');
            const tabLogin = document.getElementById('tabLogin');
            const tabRegister = document.getElementById('tabRegister');
            const demoBanner = document.getElementById('demoBanner');

            if (tab === 'register') {
                loginForm.style.display = 'none';
                registerForm.style.display = 'block';
                tabLogin.classList.remove('active');
                tabRegister.classList.add('active');
                demoBanner.style.display = 'none';
            } else {
                loginForm.style.display = 'block';
                registerForm.style.display = 'none';
                tabRegister.classList.remove('active');
                tabLogin.classList.add('active');
                demoBanner.style.display = 'flex';
            }
        }

        function fillDemo() {
            document.getElementById('loginUsername').value = 'demo';
            document.getElementById('loginPassword').value = 'demo123';
        }

        // AJAX Username Availability Check (Demonstrates AJAX requirement)
        async function checkUsernameAvailability() {
            const usernameInput = document.getElementById('regUsername');
            const msgEl = document.getElementById('usernameCheckMsg');
            const val = usernameInput.value.trim();

            if (val.length < 3) {
                msgEl.textContent = '';
                return;
            }

            try {
                const res = await fetch(window.APP_CONTEXT + '/api/check-username?username=' + encodeURIComponent(val));
                const data = await res.json();
                if (data.available) {
                    msgEl.style.color = '#10b981';
                    msgEl.textContent = '✓ Username is available';
                } else {
                    msgEl.style.color = '#ef4444';
                    msgEl.textContent = '✗ Username is already taken';
                }
            } catch (e) {
                msgEl.textContent = '';
            }
        }
    </script>
</body>
</html>
