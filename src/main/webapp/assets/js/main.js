/**
 * STUDENT LIFE MANAGER - CORE APPLICATION JAVASCRIPT
 */

document.addEventListener('DOMContentLoaded', () => {
    initSidebar();
    initClock();
    initModals();
    initNotifications();
});

// Mobile Sidebar Toggle
function initSidebar() {
    const toggleBtn = document.getElementById('sidebarToggleBtn');
    const sidebar = document.getElementById('appSidebar');

    if (toggleBtn && sidebar) {
        toggleBtn.addEventListener('click', (e) => {
            e.stopPropagation();
            sidebar.classList.toggle('show');
        });

        document.addEventListener('click', (e) => {
            if (window.innerWidth <= 768 && sidebar.classList.contains('show')) {
                if (!sidebar.contains(e.target) && e.target !== toggleBtn) {
                    sidebar.classList.remove('show');
                }
            }
        });
    }
}

// Live Header Clock
function initClock() {
    const clockEl = document.getElementById('liveClock');
    if (!clockEl) return;

    function update() {
        const now = new Date();
        const timeStr = now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', second: '2-digit' });
        clockEl.textContent = timeStr;
    }
    update();
    setInterval(update, 1000);
}

// Modal Dialog Helpers
function initModals() {
    // Open buttons
    document.querySelectorAll('[data-modal-target]').forEach(btn => {
        btn.addEventListener('click', (e) => {
            e.preventDefault();
            const targetId = btn.getAttribute('data-modal-target');
            openModal(targetId);
        });
    });

    // Close buttons
    document.querySelectorAll('.modal-close, [data-modal-close]').forEach(btn => {
        btn.addEventListener('click', (e) => {
            e.preventDefault();
            const modal = btn.closest('.modal-overlay');
            if (modal) closeModal(modal.id);
        });
    });

    // Click outside modal content
    document.querySelectorAll('.modal-overlay').forEach(overlay => {
        overlay.addEventListener('click', (e) => {
            if (e.target === overlay) {
                closeModal(overlay.id);
            }
        });
    });
}

function openModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) {
        modal.classList.add('active');
        document.body.style.overflow = 'hidden';
    }
}

function closeModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) {
        modal.classList.remove('active');
        document.body.style.overflow = '';
    }
}

// Notifications Polling
function initNotifications() {
    const badge = document.getElementById('notifBadge');
    if (!badge) return;

    function checkUnread() {
        fetch(window.APP_CONTEXT + '/api/notifications/unread')
            .then(res => res.json())
            .then(data => {
                if (data.unreadCount > 0) {
                    badge.textContent = data.unreadCount;
                    badge.style.display = 'flex';
                } else {
                    badge.style.display = 'none';
                }
            })
            .catch(() => {});
    }

    // Check periodically every 45s
    setInterval(checkUnread, 45000);
}

// Global AJAX Helper with CSRF / Standard headers
async function fetchJson(url, options = {}) {
    options.headers = {
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        ...(options.headers || {})
    };
    const response = await fetch(url, options);
    if (response.status === 401) {
        window.location.href = window.APP_CONTEXT + '/login?error=Session+expired';
        return null;
    }
    return response.json();
}
