package com.studentlife.model;

import java.sql.Date;
import java.sql.Time;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

public class Deadline {
    private int id;
    private int userId;
    private Integer subjectId;
    private String subjectName;
    private Integer taskId;
    private String title;
    private Date dueDate;
    private Time dueTime;
    private String priority;
    private String status;
    private Timestamp createdAt;

    public Deadline() {
        this.priority = "HIGH";
        this.status = "PENDING";
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public Integer getSubjectId() { return subjectId; }
    public void setSubjectId(Integer subjectId) { this.subjectId = subjectId; }

    public String getSubjectName() { return subjectName; }
    public void setSubjectName(String subjectName) { this.subjectName = subjectName; }

    public Integer getTaskId() { return taskId; }
    public void setTaskId(Integer taskId) { this.taskId = taskId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public Date getDueDate() { return dueDate; }
    public void setDueDate(Date dueDate) { this.dueDate = dueDate; }

    public Time getDueTime() { return dueTime; }
    public void setDueTime(Time dueTime) { this.dueTime = dueTime; }

    public String getPriority() { return priority; }
    public void setPriority(String priority) { this.priority = priority; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public long getDaysRemaining() {
        if (dueDate == null) return 0;
        return ChronoUnit.DAYS.between(LocalDate.now(), dueDate.toLocalDate());
    }

    public String getRemainingText() {
        if ("COMPLETED".equalsIgnoreCase(status)) return "Completed";
        long days = getDaysRemaining();
        if (days == 0) return "Due today";
        if (days == 1) return "Due tomorrow";
        if (days > 1) return "Due in " + days + " days";
        return "Overdue by " + Math.abs(days) + " day" + (Math.abs(days) > 1 ? "s" : "");
    }
}
