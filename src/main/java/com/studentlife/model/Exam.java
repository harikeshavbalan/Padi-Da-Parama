package com.studentlife.model;

import java.sql.Date;
import java.sql.Time;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

public class Exam {
    private int id;
    private int userId;
    private Integer subjectId;
    private String subjectName;
    private String subjectColor;
    private String title;
    private String examType; // CAT-I, CAT-II, Internal Test, Lab Test, Model Exam, Semester Exam, Practical Exam, Viva
    private Date examDate;
    private Time startTime;
    private Time endTime;
    private String venue;
    private String syllabus;
    private int preparationPercentage; // 0 - 100
    private String notes;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public Exam() {
        this.examType = "CAT-I";
        this.preparationPercentage = 0;
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

    public String getExamType() { return examType; }
    public void setExamType(String examType) { this.examType = examType; }

    public Date getExamDate() { return examDate; }
    public void setExamDate(Date examDate) { this.examDate = examDate; }

    public Time getStartTime() { return startTime; }
    public void setStartTime(Time startTime) { this.startTime = startTime; }

    public Time getEndTime() { return endTime; }
    public void setEndTime(Time endTime) { this.endTime = endTime; }

    public String getVenue() { return venue; }
    public void setVenue(String venue) { this.venue = venue; }

    public String getSyllabus() { return syllabus; }
    public void setSyllabus(String syllabus) { this.syllabus = syllabus; }

    public int getPreparationPercentage() { return preparationPercentage; }
    public void setPreparationPercentage(int preparationPercentage) { this.preparationPercentage = preparationPercentage; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public long getDaysUntil() {
        if (examDate == null) return 0;
        return ChronoUnit.DAYS.between(LocalDate.now(), examDate.toLocalDate());
    }

    public String getCountdownText() {
        long days = getDaysUntil();
        if (days == 0) return "Today";
        if (days == 1) return "Tomorrow";
        if (days > 1) return "In " + days + " days";
        return Math.abs(days) + " days ago";
    }
}
