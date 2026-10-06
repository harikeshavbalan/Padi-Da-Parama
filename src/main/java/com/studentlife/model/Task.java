package com.studentlife.model;

import java.sql.Date;
import java.sql.Time;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

public class Task {
    private int id;
    private int userId;
    private Integer subjectId;
    private String subjectName;
    private String subjectColor;
    private String title;
    private String description;
    private String category; // Academic, Assignment, Lab, Project, Personal, Club, Other
    private String priority; // LOW, MEDIUM, HIGH, URGENT
    private String status;   // PENDING, IN_PROGRESS, COMPLETED, CANCELLED
    private Date dueDate;
    private Time dueTime;
    private int estimatedMinutes;
    private int actualMinutes;
    private String recurrence; // NONE, DAILY, WEEKLY, MONTHLY
    private Timestamp completedAt;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public Task() {
        this.category = "Academic";
        this.priority = "MEDIUM";
        this.status = "PENDING";
        this.recurrence = "NONE";
        this.estimatedMinutes = 30;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public Integer getSubjectId() { return subjectId; }
    public void setSubjectId(Integer subjectId) { this.subjectId = subjectId; }

    public String getSubjectName() { return subjectName; }
    public void setSubjectName(String subjectName) { this.subjectName = subjectName; }

    public String getSubjectColor() { return subjectColor; }
    public void setSubjectColor(String subjectColor) { this.subjectColor = subjectColor; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getPriority() { return priority; }
    public void setPriority(String priority) { this.priority = priority; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Date getDueDate() { return dueDate; }
    public void setDueDate(Date dueDate) { this.dueDate = dueDate; }

    public Time getDueTime() { return dueTime; }
    public void setDueTime(Time dueTime) { this.dueTime = dueTime; }

    public int getEstimatedMinutes() { return estimatedMinutes; }
    public void setEstimatedMinutes(int estimatedMinutes) { this.estimatedMinutes = estimatedMinutes; }

    public int getActualMinutes() { return actualMinutes; }
    public void setActualMinutes(int actualMinutes) { this.actualMinutes = actualMinutes; }

    public String getRecurrence() { return recurrence; }
    public void setRecurrence(String recurrence) { this.recurrence = recurrence; }

    public Timestamp getCompletedAt() { return completedAt; }
    public void setCompletedAt(Timestamp completedAt) { this.completedAt = completedAt; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    // Business helpers
    public boolean isCompleted() {
        return "COMPLETED".equalsIgnoreCase(status);
    }

    public boolean isOverdue() {
        if (isCompleted() || dueDate == null) return false;
        LocalDate today = LocalDate.now();
        LocalDate due = dueDate.toLocalDate();
        return due.isBefore(today);
    }

    public boolean isDueToday() {
        if (dueDate == null) return false;
        return dueDate.toLocalDate().isEqual(LocalDate.now());
    }

    public long getDaysRemaining() {
        if (dueDate == null) return 0;
        return ChronoUnit.DAYS.between(LocalDate.now(), dueDate.toLocalDate());
    }

    public String getDueStatusText() {
        if (isCompleted()) return "Completed";
        if (dueDate == null) return "No due date";
        long days = getDaysRemaining();
        if (days == 0) return "Due today";
        if (days == 1) return "Due tomorrow";
        if (days > 1) return "Due in " + days + " days";
        return "Overdue by " + Math.abs(days) + " day" + (Math.abs(days) > 1 ? "s" : "");
    }
}
