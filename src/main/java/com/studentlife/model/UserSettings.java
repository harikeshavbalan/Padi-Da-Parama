package com.studentlife.model;

import java.sql.Timestamp;

public class UserSettings {
    private int userId;
    private String defaultPriority;
    private String weekStartDay;
    private boolean remindersEnabled;
    private String themePreference;
    private Timestamp updatedAt;

    public UserSettings() {
        this.defaultPriority = "MEDIUM";
        this.weekStartDay = "Monday";
        this.remindersEnabled = true;
        this.themePreference = "dark";
    }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getDefaultPriority() { return defaultPriority; }
    public void setDefaultPriority(String defaultPriority) { this.defaultPriority = defaultPriority; }

    public String getWeekStartDay() { return weekStartDay; }
    public void setWeekStartDay(String weekStartDay) { this.weekStartDay = weekStartDay; }

    public boolean isRemindersEnabled() { return remindersEnabled; }
    public void setRemindersEnabled(boolean remindersEnabled) { this.remindersEnabled = remindersEnabled; }

    public String getThemePreference() { return themePreference; }
    public void setThemePreference(String themePreference) { this.themePreference = themePreference; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}
