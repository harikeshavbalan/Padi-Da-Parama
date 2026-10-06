/**
 * STUDENT LIFE MANAGER - TASKS & HABITS AJAX HANDLERS
 */

// Toggle Task Completion asynchronously without page reload
async function toggleTaskAjax(taskId, element) {
    try {
        const formData = new URLSearchParams();
        formData.append('id', taskId);

        const res = await fetch(window.APP_CONTEXT + '/api/tasks/toggle', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'X-Requested-With': 'XMLHttpRequest'
            },
            body: formData
        });

        const data = await res.json();
        if (data.success) {
            // Update UI element visually
            const item = element.closest('.task-item') || element.closest('tr');
            if (item) {
                if (data.isCompleted) {
                    item.classList.add('completed');
                    element.classList.add('checked');
                    element.innerHTML = '✓';
                } else {
                    item.classList.remove('completed');
                    element.classList.remove('checked');
                    element.innerHTML = '';
                }
            }
            refreshDashboardStats();
        }
    } catch (err) {
        console.error('Error toggling task:', err);
    }
}

// Toggle Habit Completion asynchronously
async function toggleHabitAjax(habitId, element) {
    try {
        const formData = new URLSearchParams();
        formData.append('id', habitId);

        const res = await fetch(window.APP_CONTEXT + '/api/habits/toggle', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'X-Requested-With': 'XMLHttpRequest'
            },
            body: formData
        });

        const data = await res.json();
        if (data.success) {
            const isDone = element.classList.contains('done');
            if (isDone) {
                element.classList.remove('done');
                element.classList.add('pending');
                element.textContent = '✗';
            } else {
                element.classList.remove('pending');
                element.classList.add('done');
                element.textContent = '✓';
            }

            // Update streak text if badge present
            const habitRow = element.closest('.habit-item');
            if (habitRow) {
                const streakBadge = habitRow.querySelector('.habit-streak-badge');
                if (streakBadge) {
                    streakBadge.textContent = '🔥 ' + data.streak + 'd';
                }
            }
        }
    } catch (err) {
        console.error('Error toggling habit:', err);
    }
}

// Refresh Dashboard Stats Counter
async function refreshDashboardStats() {
    try {
        const res = await fetch(window.APP_CONTEXT + '/api/dashboard/stats');
        const stats = await res.json();
        if (stats) {
            const elToday = document.getElementById('statToday');
            const elPending = document.getElementById('statPending');
            const elCompleted = document.getElementById('statCompleted');
            const elOverdue = document.getElementById('statOverdue');

            if (elToday) elToday.textContent = stats.todayTasks;
            if (elPending) elPending.textContent = stats.pendingTasks;
            if (elCompleted) elCompleted.textContent = stats.completedTasks;
            if (elOverdue) elOverdue.textContent = stats.overdueTasks;
        }
    } catch (ignored) {}
}

// Edit Task Modal Loader
function openEditTaskModal(task) {
    document.getElementById('editTaskId').value = task.id;
    document.getElementById('editTaskTitle').value = task.title;
    document.getElementById('editTaskDesc').value = task.description || '';
    document.getElementById('editTaskCategory').value = task.category;
    document.getElementById('editTaskPriority').value = task.priority;
    document.getElementById('editTaskStatus').value = task.status;
    document.getElementById('editTaskDueDate').value = task.dueDate || '';
    document.getElementById('editTaskDueTime').value = task.dueTime || '';
    document.getElementById('editTaskSubject').value = task.subjectId || '';
    document.getElementById('editTaskEstMin').value = task.estimatedMinutes || 30;
    document.getElementById('editTaskRecurrence').value = task.recurrence || 'NONE';

    openModal('editTaskModal');
}
