/**
 * STUDENT LIFE MANAGER - ANALYTICS CHARTS (Vanilla SVG Generator)
 * Renders weekly workload bar charts and score gauges with zero external CDN dependencies.
 */

function renderWorkloadChart(containerId, data) {
    const container = document.getElementById(containerId);
    if (!container || !data || data.length === 0) return;

    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const maxVal = Math.max(...data, 5); // baseline scale

    let html = `<div class="workload-bars">`;
    data.forEach((val, i) => {
        const heightPct = Math.round((val / maxVal) * 100);
        html += `
            <div class="bar-col">
                <div class="bar-val">${val}</div>
                <div class="bar-track">
                    <div class="bar-fill" style="height: ${heightPct}%;"></div>
                </div>
                <div class="bar-day">${days[i]}</div>
            </div>
        `;
    });
    html += `</div>`;
    container.innerHTML = html;
}

function renderSubjectStudyChart(containerId, subjectMap) {
    const container = document.getElementById(containerId);
    if (!container || !subjectMap) return;

    const subjects = Object.keys(subjectMap);
    if (subjects.length === 0) {
        container.innerHTML = '<div class="empty-state">No study sessions recorded yet.</div>';
        return;
    }

    let totalMin = 0;
    subjects.forEach(s => totalMin += subjectMap[s]);

    let html = `<div class="subject-bars">`;
    subjects.forEach(s => {
        const mins = subjectMap[s];
        const pct = totalMin > 0 ? Math.round((mins / totalMin) * 100) : 0;
        const hours = (mins / 60).toFixed(1);
        html += `
            <div class="subject-stat-row">
                <div class="subject-name-col">
                    <span class="subj-title">${s}</span>
                    <span class="subj-hours">${hours} hrs (${pct}%)</span>
                </div>
                <div class="progress-container">
                    <div class="progress-bar" style="width: ${pct}%;"></div>
                </div>
            </div>
        `;
    });
    html += `</div>`;
    container.innerHTML = html;
}
