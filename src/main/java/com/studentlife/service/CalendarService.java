package com.studentlife.service;

import com.studentlife.dao.*;
import com.studentlife.model.*;

import java.util.ArrayList;
import java.util.List;

public class CalendarService {
    private final TaskDAO taskDAO;
    private final ExamDAO examDAO;
    private final EventDAO eventDAO;
    private final HolidayDAO holidayDAO;

    public CalendarService() {
        this.taskDAO = new TaskDAO();
        this.examDAO = new ExamDAO();
        this.eventDAO = new EventDAO();
        this.holidayDAO = new HolidayDAO();
    }

    public List<CalendarEvent> getEventsForUser(int userId) {
        List<CalendarEvent> events = new ArrayList<>();

        // 1. Tasks with due dates
        List<Task> tasks = taskDAO.findAllByUserId(userId);
        for (Task t : tasks) {
            if (t.getDueDate() != null) {
                String start = t.getDueDate().toString();
                if (t.getDueTime() != null) {
                    start += "T" + t.getDueTime().toString();
                }
                String color = t.isCompleted() ? "#10b981" : (t.isOverdue() ? "#ef4444" : "#3b82f6");
                events.add(new CalendarEvent(
                        "task-" + t.getId(),
                        (t.isCompleted() ? "✓ " : "📋 ") + t.getTitle(),
                        start,
                        null,
                        "task",
                        color,
                        "Priority: " + t.getPriority() + " | Category: " + t.getCategory()
                ));
            }
        }

        // 2. Exams
        List<Exam> exams = examDAO.findAllByUserId(userId);
        for (Exam e : exams) {
            String start = e.getExamDate().toString();
            if (e.getStartTime() != null) start += "T" + e.getStartTime().toString();
            String end = null;
            if (e.getEndTime() != null) end = e.getExamDate().toString() + "T" + e.getEndTime().toString();

            events.add(new CalendarEvent(
                    "exam-" + e.getId(),
                    "🎓 " + e.getTitle() + " (" + e.getExamType() + ")",
                    start,
                    end,
                    "exam",
                    "#dc2626", // Red for exams
                    "Venue: " + (e.getVenue() != null ? e.getVenue() : "TBA") + " | Prep: " + e.getPreparationPercentage() + "%"
            ));
        }

        // 3. Events
        List<Event> evList = eventDAO.findAllByUserId(userId);
        for (Event ev : evList) {
            String start = ev.getEventDate().toString();
            if (ev.getStartTime() != null) start += "T" + ev.getStartTime().toString();
            String end = null;
            if (ev.getEndTime() != null) end = ev.getEventDate().toString() + "T" + ev.getEndTime().toString();

            events.add(new CalendarEvent(
                    "event-" + ev.getId(),
                    "📅 " + ev.getTitle(),
                    start,
                    end,
                    "event",
                    "#8b5cf6", // Purple
                    "Category: " + ev.getCategory() + " | Location: " + (ev.getLocation() != null ? ev.getLocation() : "Campus")
            ));
        }

        // 4. Holidays
        List<Holiday> holidays = holidayDAO.findAllByUserId(userId);
        for (Holiday h : holidays) {
            events.add(new CalendarEvent(
                    "holiday-" + h.getId(),
                    "🎉 " + h.getTitle(),
                    h.getHolidayDate().toString(),
                    null,
                    "holiday",
                    "#f59e0b", // Amber/Gold
                    "Type: " + h.getHolidayType() + " - " + (h.getDescription() != null ? h.getDescription() : "")
            ));
        }

        return events;
    }
}
