package com.studentlife.model;

import java.sql.Date;
import java.sql.Time;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

public class Event {
    private int id;
    private int userId;
    private String title;
    private String description;
    private Date eventDate;
    private Time startTime;
    private Time endTime;
    private String category; // Club meeting, College event, Presentation, Project review, Seminar, Personal
    private String location;
    private Timestamp createdAt;

    public Event() {
        this.category = "College event";
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Date getEventDate() { return eventDate; }
    public void setEventDate(Date eventDate) { this.eventDate = eventDate; }

    public Time getStartTime() { return startTime; }
    public void setStartTime(Time startTime) { this.startTime = startTime; }

    public Time getEndTime() { return endTime; }
    public void setEndTime(Time endTime) { this.endTime = endTime; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public long getDaysUntil() {
        if (eventDate == null) return 0;
        return ChronoUnit.DAYS.between(LocalDate.now(), eventDate.toLocalDate());
    }

    public String getCountdownText() {
        long days = getDaysUntil();
        if (days == 0) return "Today";
        if (days == 1) return "Tomorrow";
        if (days > 1) return "In " + days + " days";
        return Math.abs(days) + " days ago";
    }
}
