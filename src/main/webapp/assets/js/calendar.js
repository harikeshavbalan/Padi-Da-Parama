/**
 * STUDENT LIFE MANAGER - INTERACTIVE CALENDAR ENGINE (Vanilla JavaScript)
 * Supports Month, Week, and Day views with AJAX event loading.
 */

class StudentCalendar {
    constructor(containerId) {
        this.container = document.getElementById(containerId);
        if (!this.container) return;

        this.currentDate = new Date();
        this.currentView = 'month'; // 'month', 'week', 'day'
        this.events = [];

        this.init();
    }

    async init() {
        this.renderShell();
        await this.loadEvents();
        this.renderCurrentView();
        this.bindEvents();
    }

    renderShell() {
        this.container.innerHTML = `
            <div class="calendar-controls">
                <div class="controls-left">
                    <button class="btn btn-secondary btn-sm" id="calTodayBtn">Today</button>
                    <div class="btn-group">
                        <button class="btn btn-secondary btn-icon" id="calPrevBtn">◀</button>
                        <button class="btn btn-secondary btn-icon" id="calNextBtn">▶</button>
                    </div>
                    <h2 class="calendar-title" id="calTitle"></h2>
                </div>
                <div class="controls-right">
                    <div class="view-switcher">
                        <button class="btn btn-sm btn-secondary active" data-view="month">Month</button>
                        <button class="btn btn-sm btn-secondary" data-view="week">Week</button>
                        <button class="btn btn-sm btn-secondary" data-view="day">Day</button>
                    </div>
                </div>
            </div>
            <div class="calendar-body" id="calBody"></div>
        `;
    }

    async loadEvents() {
        try {
            const res = await fetch(window.APP_CONTEXT + '/api/calendar/events');
            this.events = await res.json();
        } catch (e) {
            console.error('Failed to load calendar events:', e);
            this.events = [];
        }
    }

    renderCurrentView() {
        const titleEl = document.getElementById('calTitle');
        const bodyEl = document.getElementById('calBody');

        if (this.currentView === 'month') {
            titleEl.textContent = this.currentDate.toLocaleDateString([], { month: 'long', year: 'numeric' });
            this.renderMonthView(bodyEl);
        } else if (this.currentView === 'week') {
            const startOfWeek = this.getStartOfWeek(this.currentDate);
            const endOfWeek = new Date(startOfWeek);
            endOfWeek.setDate(endOfWeek.getDate() + 6);
            titleEl.textContent = `${startOfWeek.toLocaleDateString([], { month: 'short', day: 'numeric' })} – ${endOfWeek.toLocaleDateString([], { month: 'short', day: 'numeric', year: 'numeric' })}`;
            this.renderWeekView(bodyEl, startOfWeek);
        } else if (this.currentView === 'day') {
            titleEl.textContent = this.currentDate.toLocaleDateString([], { weekday: 'long', month: 'long', day: 'numeric', year: 'numeric' });
            this.renderDayView(bodyEl, this.currentDate);
        }
    }

    renderMonthView(bodyEl) {
        const year = this.currentDate.getFullYear();
        const month = this.currentDate.getMonth();

        const firstDayOfMonth = new Date(year, month, 1);
        let startDay = firstDayOfMonth.getDay() - 1; // 0=Mon, 6=Sun
        if (startDay < 0) startDay = 6;

        const daysInMonth = new Date(year, month + 1, 0).getDate();
        const daysInPrevMonth = new Date(year, month, 0).getDate();

        let html = `
            <div class="month-grid">
                <div class="day-names-row">
                    <div>Mon</div><div>Tue</div><div>Wed</div><div>Thu</div><div>Fri</div><div>Sat</div><div>Sun</div>
                </div>
                <div class="cells-grid">
        `;

        // Prev month padding
        for (let i = startDay - 1; i >= 0; i--) {
            const dayNum = daysInPrevMonth - i;
            html += `<div class="cal-cell other-month"><span class="cell-num">${dayNum}</span></div>`;
        }

        // Current month cells
        const today = new Date();
        for (let d = 1; d <= daysInMonth; d++) {
            const cellDate = new Date(year, month, d);
            const isToday = (today.getDate() === d && today.getMonth() === month && today.getFullYear() === year);
            const dateStr = this.formatDateIso(cellDate);

            // Filter events for this day
            const dayEvents = this.events.filter(ev => ev.start.startsWith(dateStr));

            html += `
                <div class="cal-cell ${isToday ? 'today' : ''}" data-date="${dateStr}">
                    <div class="cell-header"><span class="cell-num">${d}</span></div>
                    <div class="cell-events">
                        ${dayEvents.slice(0, 3).map(ev => `
                            <div class="cal-event-pill" style="border-left: 3px solid ${ev.color};" title="${ev.title}">
                                ${ev.title}
                            </div>
                        `).join('')}
                        ${dayEvents.length > 3 ? `<div class="cal-more">+${dayEvents.length - 3} more</div>` : ''}
                    </div>
                </div>
            `;
        }

        html += `</div></div>`;
        bodyEl.innerHTML = html;
    }

    renderWeekView(bodyEl, startOfWeek) {
        let html = `<div class="week-grid">`;
        for (let i = 0; i < 7; i++) {
            const d = new Date(startOfWeek);
            d.setDate(d.getDate() + i);
            const dateStr = this.formatDateIso(d);
            const isToday = this.formatDateIso(new Date()) === dateStr;
            const dayEvents = this.events.filter(ev => ev.start.startsWith(dateStr));

            html += `
                <div class="week-day-col ${isToday ? 'today-col' : ''}">
                    <div class="week-col-header">
                        <span class="day-title">${d.toLocaleDateString([], { weekday: 'short' })}</span>
                        <span class="day-badge">${d.getDate()}</span>
                    </div>
                    <div class="week-events-list">
                        ${dayEvents.map(ev => `
                            <div class="cal-event-card" style="border-left: 4px solid ${ev.color};">
                                <span class="event-time">${ev.start.includes('T') ? ev.start.split('T')[1].substring(0, 5) : 'All Day'}</span>
                                <span class="event-title">${ev.title}</span>
                                <span class="event-desc">${ev.details || ''}</span>
                            </div>
                        `).join('')}
                    </div>
                </div>
            `;
        }
        html += `</div>`;
        bodyEl.innerHTML = html;
    }

    renderDayView(bodyEl, day) {
        const dateStr = this.formatDateIso(day);
        const dayEvents = this.events.filter(ev => ev.start.startsWith(dateStr));

        let html = `
            <div class="day-view-container">
                <div class="day-summary-header">
                    <h3>Events scheduled for ${day.toLocaleDateString([], { weekday: 'long', month: 'short', day: 'numeric' })}</h3>
                    <span class="badge badge-medium">${dayEvents.length} items</span>
                </div>
                <div class="day-events-vertical">
                    ${dayEvents.length === 0 ? '<div class="empty-state">No tasks or events scheduled for this day.</div>' : ''}
                    ${dayEvents.map(ev => `
                        <div class="day-event-block" style="border-left: 5px solid ${ev.color};">
                            <div class="block-top">
                                <span class="block-time">${ev.start.includes('T') ? ev.start.split('T')[1].substring(0, 5) : 'All Day'}</span>
                                <span class="badge" style="background:${ev.color}22; color:${ev.color};">${ev.type}</span>
                            </div>
                            <h4 class="block-title">${ev.title}</h4>
                            <p class="block-details">${ev.details || ''}</p>
                        </div>
                    `).join('')}
                </div>
            </div>
        `;
        bodyEl.innerHTML = html;
    }

    getStartOfWeek(date) {
        const d = new Date(date);
        const day = d.getDay();
        const diff = d.getDate() - day + (day === 0 ? -6 : 1); // Monday start
        return new Date(d.setDate(diff));
    }

    formatDateIso(date) {
        const y = date.getFullYear();
        const m = String(date.getMonth() + 1).padStart(2, '0');
        const d = String(date.getDate()).padStart(2, '0');
        return `${y}-${m}-${d}`;
    }

    bindEvents() {
        document.getElementById('calPrevBtn').addEventListener('click', () => {
            if (this.currentView === 'month') {
                this.currentDate.setMonth(this.currentDate.getMonth() - 1);
            } else if (this.currentView === 'week') {
                this.currentDate.setDate(this.currentDate.getDate() - 7);
            } else {
                this.currentDate.setDate(this.currentDate.getDate() - 1);
            }
            this.renderCurrentView();
        });

        document.getElementById('calNextBtn').addEventListener('click', () => {
            if (this.currentView === 'month') {
                this.currentDate.setMonth(this.currentDate.getMonth() + 1);
            } else if (this.currentView === 'week') {
                this.currentDate.setDate(this.currentDate.getDate() + 7);
            } else {
                this.currentDate.setDate(this.currentDate.getDate() + 1);
            }
            this.renderCurrentView();
        });

        document.getElementById('calTodayBtn').addEventListener('click', () => {
            this.currentDate = new Date();
            this.renderCurrentView();
        });

        document.querySelectorAll('.view-switcher button').forEach(btn => {
            btn.addEventListener('click', () => {
                document.querySelectorAll('.view-switcher button').forEach(b => b.classList.remove('active'));
                btn.classList.add('active');
                this.currentView = btn.getAttribute('data-view');
                this.renderCurrentView();
            });
        });
    }
}
