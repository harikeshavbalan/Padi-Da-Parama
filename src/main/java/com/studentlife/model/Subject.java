package com.studentlife.model;

import java.sql.Timestamp;

public class Subject {
    private int id;
    private int userId;
    private String name;
    private String courseCode;
    private String faculty;
    private String room;
    private int credits;
    private String color;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Additional statistics for subject dashboard card
    private int taskCount;
    private int completedTaskCount;
    private int studyMinutes;
    private String nextExamDate;

    public Subject() {
        this.credits = 3;
        this.color = "#4f46e5";
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getCourseCode() { return courseCode; }
    public void setCourseCode(String courseCode) { this.courseCode = courseCode; }

    public String getFaculty() { return faculty; }
    public void setFaculty(String faculty) { this.faculty = faculty; }

    public String getRoom() { return room; }
    public void setRoom(String room) { this.room = room; }

    public int getCredits() { return credits; }
    public void setCredits(int credits) { this.credits = credits; }

    public String getColor() { return color; }
    public void setColor(String color) { this.color = color; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public int getTaskCount() { return taskCount; }
    public void setTaskCount(int taskCount) { this.taskCount = taskCount; }

    public int getCompletedTaskCount() { return completedTaskCount; }
    public void setCompletedTaskCount(int completedTaskCount) { this.completedTaskCount = completedTaskCount; }

    public int getStudyMinutes() { return studyMinutes; }
    public void setStudyMinutes(int studyMinutes) { this.studyMinutes = studyMinutes; }

    public String getNextExamDate() { return nextExamDate; }
    public void setNextExamDate(String nextExamDate) { this.nextExamDate = nextExamDate; }
}
