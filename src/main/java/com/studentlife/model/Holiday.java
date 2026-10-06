package com.studentlife.model;

import java.sql.Date;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

public class Holiday {
    private int id;
    private int userId;
    private String title;
    private Date holidayDate;
    private String description;
    private String holidayType; // College Holiday, Public Holiday, Vacation, Event Holiday
    private Timestamp createdAt;

    public Holiday() {
        this.holidayType = "College Holiday";
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public Date getHolidayDate() { return holidayDate; }
    public void setHolidayDate(Date holidayDate) { this.holidayDate = holidayDate; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getHolidayType() { return holidayType; }
    public void setHolidayType(String holidayType) { this.holidayType = holidayType; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public long getDaysRemaining() {
        if (holidayDate == null) return 0;
        return ChronoUnit.DAYS.between(LocalDate.now(), holidayDate.toLocalDate());
    }

    public String getCountdownText() {
        long days = getDaysRemaining();
        if (days == 0) return "Today!";
        if (days == 1) return "Tomorrow";
        if (days > 1) return "In " + days + " days";
        return Math.abs(days) + " days ago";
    }
}
