package com.studentlife.model;

import java.sql.Date;
import java.sql.Timestamp;

public class HabitLog {
    private int id;
    private int habitId;
    private Date logDate;
    private boolean completed;
    private Timestamp createdAt;

    public HabitLog() {}

    public HabitLog(int habitId, Date logDate, boolean completed) {
        this.habitId = habitId;
        this.logDate = logDate;
        this.completed = completed;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getHabitId() { return habitId; }
    public void setHabitId(int habitId) { this.habitId = habitId; }

    public Date getLogDate() { return logDate; }
    public void setLogDate(Date logDate) { this.logDate = logDate; }

    public boolean isCompleted() { return completed; }
    public void setCompleted(boolean completed) { this.completed = completed; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
