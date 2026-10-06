package com.studentlife.model;

import java.sql.Time;
import java.sql.Timestamp;

public class TimetableEntry {
    private int id;
    private int userId;
    private int subjectId;
    private String subjectName;
    private String courseCode;
    private String subjectColor;
    private String dayOfWeek; // Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday
    private Time startTime;
    private Time endTime;
    private String room;
    private String faculty;
    private Timestamp createdAt;

    public TimetableEntry() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public int getSubjectId() { return subjectId; }
    public void setSubjectId(int subjectId) { this.subjectId = subjectId; }

    public String getSubjectName() { return subjectName; }
    public void setSubjectName(String subjectName) { this.subjectName = subjectName; }

    public String getCourseCode() { return courseCode; }
    public void setCourseCode(String courseCode) { this.courseCode = courseCode; }

    public String getSubjectColor() { return subjectColor; }
    public void setSubjectColor(String subjectColor) { this.subjectColor = subjectColor; }

    public String getDayOfWeek() { return dayOfWeek; }
    public void setDayOfWeek(String dayOfWeek) { this.dayOfWeek = dayOfWeek; }

    public Time getStartTime() { return startTime; }
    public void setStartTime(Time startTime) { this.startTime = startTime; }

    public Time getEndTime() { return endTime; }
    public void setEndTime(Time endTime) { this.endTime = endTime; }

    public String getRoom() { return room; }
    public void setRoom(String room) { this.room = room; }

    public String getFaculty() { return faculty; }
    public void setFaculty(String faculty) { this.faculty = faculty; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
