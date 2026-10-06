package com.studentlife.model;

import java.util.ArrayList;
import java.util.List;

public class DashboardSummary {
    private String greeting;
    private String currentDateFormatted;
    private String currentDayName;

    // Task counts
    private int todayTaskCount;
    private int pendingTaskCount;
    private int completedTaskCount;
    private int overdueTaskCount;

    // Classes
    private TimetableEntry nextClass;
    private List<TimetableEntry> todaySchedule = new ArrayList<>();

    // Deadlines & Exams
    private Deadline nextDeadline;
    private Exam nextExam;
    private Holiday nextHoliday;
    private Event nextEvent;

    // Lists
    private List<Task> todayTasks = new ArrayList<>();
    private List<Habit> habits = new ArrayList<>();

    // Study time
    private int todayStudyMinutes;
    private int weekStudyMinutes;

    // Streaks & Productivity
    private int currentStreak;
    private ProductivityMetrics productivity;

    public DashboardSummary() {
        this.productivity = new ProductivityMetrics();
    }

    public String getGreeting() { return greeting; }
    public void setGreeting(String greeting) { this.greeting = greeting; }

    public String getCurrentDateFormatted() { return currentDateFormatted; }
    public void setCurrentDateFormatted(String currentDateFormatted) { this.currentDateFormatted = currentDateFormatted; }

    public String getCurrentDayName() { return currentDayName; }
    public void setCurrentDayName(String currentDayName) { this.currentDayName = currentDayName; }

    public int getTodayTaskCount() { return todayTaskCount; }
    public void setTodayTaskCount(int todayTaskCount) { this.todayTaskCount = todayTaskCount; }

    public int getPendingTaskCount() { return pendingTaskCount; }
    public void setPendingTaskCount(int pendingTaskCount) { this.pendingTaskCount = pendingTaskCount; }

    public int getCompletedTaskCount() { return completedTaskCount; }
    public void setCompletedTaskCount(int completedTaskCount) { this.completedTaskCount = completedTaskCount; }

    public int getOverdueTaskCount() { return overdueTaskCount; }
    public void setOverdueTaskCount(int overdueTaskCount) { this.overdueTaskCount = overdueTaskCount; }

    public TimetableEntry getNextClass() { return nextClass; }
    public void setNextClass(TimetableEntry nextClass) { this.nextClass = nextClass; }

    public List<TimetableEntry> getTodaySchedule() { return todaySchedule; }
    public void setTodaySchedule(List<TimetableEntry> todaySchedule) { this.todaySchedule = todaySchedule; }

    public Deadline getNextDeadline() { return nextDeadline; }
    public void setNextDeadline(Deadline nextDeadline) { this.nextDeadline = nextDeadline; }

    public Exam getNextExam() { return nextExam; }
    public void setNextExam(Exam nextExam) { this.nextExam = nextExam; }

    public Holiday getNextHoliday() { return nextHoliday; }
    public void setNextHoliday(Holiday nextHoliday) { this.nextHoliday = nextHoliday; }

    public Event getNextEvent() { return nextEvent; }
    public void setNextEvent(Event nextEvent) { this.nextEvent = nextEvent; }

    public List<Task> getTodayTasks() { return todayTasks; }
    public void setTodayTasks(List<Task> todayTasks) { this.todayTasks = todayTasks; }

    public List<Habit> getHabits() { return habits; }
    public void setHabits(List<Habit> habits) { this.habits = habits; }

    public int getTodayStudyMinutes() { return todayStudyMinutes; }
    public void setTodayStudyMinutes(int todayStudyMinutes) { this.todayStudyMinutes = todayStudyMinutes; }

    public int getWeekStudyMinutes() { return weekStudyMinutes; }
    public void setWeekStudyMinutes(int weekStudyMinutes) { this.weekStudyMinutes = weekStudyMinutes; }

    public int getCurrentStreak() { return currentStreak; }
    public void setCurrentStreak(int currentStreak) { this.currentStreak = currentStreak; }

    public ProductivityMetrics getProductivity() { return productivity; }
    public void setProductivity(ProductivityMetrics productivity) { this.productivity = productivity; }

    public String getFormattedTodayStudy() {
        int h = todayStudyMinutes / 60;
        int m = todayStudyMinutes % 60;
        return h + "h " + m + "m";
    }

    public String getFormattedWeekStudy() {
        int h = weekStudyMinutes / 60;
        int m = weekStudyMinutes % 60;
        return h + "h " + m + "m";
    }
}
