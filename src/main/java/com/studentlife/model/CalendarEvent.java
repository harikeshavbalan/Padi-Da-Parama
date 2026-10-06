package com.studentlife.model;

public class CalendarEvent {
    private String id;
    private String title;
    private String start; // YYYY-MM-DD or YYYY-MM-DDTHH:mm:ss
    private String end;
    private String type;  // task, exam, class, event, holiday
    private String color;
    private String details;

    public CalendarEvent() {}

    public CalendarEvent(String id, String title, String start, String end, String type, String color, String details) {
        this.id = id;
        this.title = title;
        this.start = start;
        this.end = end;
        this.type = type;
        this.color = color;
        this.details = details;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getStart() { return start; }
    public void setStart(String start) { this.start = start; }

    public String getEnd() { return end; }
    public void setEnd(String end) { this.end = end; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getColor() { return color; }
    public void setColor(String color) { this.color = color; }

    public String getDetails() { return details; }
    public void setDetails(String details) { this.details = details; }
}
