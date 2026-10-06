package com.studentlife.model;

import java.sql.Date;
import java.sql.Timestamp;

public class Plan {
    private int id;
    private int userId;
    private String title;
    private String description;
    private Date startDate;
    private Date targetDate;
    private String priority; // LOW, MEDIUM, HIGH, URGENT
    private int progress;    // 0 - 100
    private String status;   // PLANNED, ACTIVE, COMPLETED, PAUSED, CANCELLED
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public Plan() {
        this.priority = "MEDIUM";
        this.progress = 0;
        this.status = "PLANNED";
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Date getStartDate() { return startDate; }
    public void setStartDate(Date startDate) { this.startDate = startDate; }

    public Date getTargetDate() { return targetDate; }
    public void setTargetDate(Date targetDate) { this.targetDate = targetDate; }

    public String getPriority() { return priority; }
    public void setPriority(String priority) { this.priority = priority; }

    public int getProgress() { return progress; }
    public void setProgress(int progress) { this.progress = progress; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}
