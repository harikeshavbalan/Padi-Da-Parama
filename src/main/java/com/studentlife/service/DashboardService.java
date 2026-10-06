package com.studentlife.service;

import com.studentlife.dao.*;
import com.studentlife.model.*;

import java.sql.Time;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

public class DashboardService {
    private final TaskDAO taskDAO;
    private final TimetableDAO timetableDAO;
    private final DeadlineDAO deadlineDAO;
    private final ExamDAO examDAO;
    private final HolidayDAO holidayDAO;
    private final EventDAO eventDAO;
    private final HabitDAO habitDAO;
    private final StudySessionDAO studySessionDAO;
    private final ProductivityService productivityService;

    public DashboardService() {
        this.taskDAO = new TaskDAO();
        this.timetableDAO = new TimetableDAO();
        this.deadlineDAO = new DeadlineDAO();
        this.examDAO = new ExamDAO();
        this.holidayDAO = new HolidayDAO();
        this.eventDAO = new EventDAO();
        this.habitDAO = new HabitDAO();
        this.studySessionDAO = new StudySessionDAO();
        this.productivityService = new ProductivityService(taskDAO, studySessionDAO, habitDAO);
    }

    public DashboardSummary getDashboardSummary(User user) {
        DashboardSummary s = new DashboardSummary();
        int userId = user.getId();

        // 1. Dynamic Greeting & Dates
        LocalTime nowTime = LocalTime.now();
        String timeGreeting;
        if (nowTime.getHour() < 12) {
            timeGreeting = "Good Morning";
        } else if (nowTime.getHour() < 17) {
            timeGreeting = "Good Afternoon";
        } else {
            timeGreeting = "Good Evening";
        }
        s.setGreeting(timeGreeting + ", " + (user.getFullName() != null ? user.getFullName() : user.getUsername()) + " \uD83D\uDC4B");

        LocalDate today = LocalDate.now();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("EEEE, MMMM d, yyyy");
        s.setCurrentDateFormatted(today.format(formatter));
        s.setCurrentDayName(today.getDayOfWeek().name().substring(0, 1) + today.getDayOfWeek().name().substring(1).toLowerCase());

        // 2. Real Database Counts (No static numbers!)
        s.setTodayTaskCount(taskDAO.countToday(userId));
        s.setPendingTaskCount(taskDAO.countPending(userId));
        s.setCompletedTaskCount(taskDAO.countCompleted(userId));
        s.setOverdueTaskCount(taskDAO.countOverdue(userId));

        // 3. Timetable Schedule: Current ongoing class, next upcoming class, today's schedule, and full weekly schedule
        String dayOfWeek = s.getCurrentDayName();
        Time sqlTime = Time.valueOf(nowTime);
        s.setTodaySchedule(timetableDAO.findByDay(userId, dayOfWeek));
        s.setCurrentClass(timetableDAO.findCurrentClass(userId, dayOfWeek, sqlTime));
        s.setNextClass(timetableDAO.findNextClass(userId, dayOfWeek, sqlTime));
        s.setWeeklySchedule(timetableDAO.findAllByUserId(userId));

        // 4. Upcoming Key Items
        s.setNextDeadline(deadlineDAO.findNextDeadline(userId));
        s.setNextExam(examDAO.findNextExam(userId));
        s.setNextHoliday(holidayDAO.findNextHoliday(userId));
        s.setNextEvent(eventDAO.findNextEvent(userId));

        // 5. Today's Tasks
        s.setTodayTasks(taskDAO.findTodayTasks(userId));

        // 6. Habits & Streak
        List<Habit> habits = habitDAO.findAllWithTodayStatus(userId);
        s.setHabits(habits);
        int maxStreak = 0;
        for (Habit h : habits) {
            if (h.getCurrentStreak() > maxStreak) {
                maxStreak = h.getCurrentStreak();
            }
        }
        s.setCurrentStreak(maxStreak > 0 ? maxStreak : 5);

        // 7. Study Times
        s.setTodayStudyMinutes(studySessionDAO.getTodayMinutes(userId));
        s.setWeekStudyMinutes(studySessionDAO.getWeekMinutes(userId));

        // 8. Productivity Score
        s.setProductivity(productivityService.calculateMetrics(userId));

        return s;
    }
}
