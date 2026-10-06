package com.studentlife.model;

import java.sql.Timestamp;

public class Habit {
    private int id;
    private int userId;
    private String name;
    private String description;
    private String category;
    private String targetFrequency;
    private String color;
    private Timestamp createdAt;

    // Computed attributes for rich display
    private boolean completedToday;
    private int currentStreak;
    private int longestStreak;
    private double weeklyRate;

    public Habit() {
        this.category = "General";
        this.targetFrequency = "DAILY";
        this.color = "#10b981";
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getTargetFrequency() { return targetFrequency; }
    public void setTargetFrequency(String targetFrequency) { this.targetFrequency = targetFrequency; }

    public String getColor() { return color; }
    public void setColor(String color) { this.color = color; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public boolean isCompletedToday() { return completedToday; }
    public void setCompletedToday(boolean completedToday) { this.completedToday = completedToday; }

    public int getCurrentStreak() { return currentStreak; }
    public void setCurrentStreak(int currentStreak) { this.currentStreak = currentStreak; }

    public int getLongestStreak() { return longestStreak; }
    public void setLongestStreak(int longestStreak) { this.longestStreak = longestStreak; }

    public double getWeeklyRate() { return weeklyRate; }
    public void setWeeklyRate(double weeklyRate) { this.weeklyRate = weeklyRate; }
}
