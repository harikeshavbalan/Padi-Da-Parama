package com.studentlife.controller;

import com.studentlife.dao.TimetableDAO;
import com.studentlife.model.Task;
import com.studentlife.model.TimetableEntry;
import com.studentlife.service.TaskService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet(name = "XmlEndpointServlet", urlPatterns = {"/api/timetable.xml", "/api/tasks.xml"})
public class XmlEndpointServlet extends HttpServlet {
    private final TimetableDAO timetableDAO = new TimetableDAO();
    private final TaskService taskService = new TaskService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        int userId = 1; // Default to demo user if called publicly for syllabus demonstration
        if (session != null && session.getAttribute("userId") != null) {
            userId = (int) session.getAttribute("userId");
        }

        resp.setContentType("application/xml; charset=UTF-8");
        PrintWriter out = resp.getWriter();

        String path = req.getServletPath();
        if ("/api/timetable.xml".equals(path)) {
            generateTimetableXml(out, userId);
        } else if ("/api/tasks.xml".equals(path)) {
            generateTasksXml(out, userId);
        }
    }

    private void generateTimetableXml(PrintWriter out, int userId) {
        List<TimetableEntry> entries = timetableDAO.findAllByUserId(userId);
        out.println("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
        out.println("<timetable>");
        for (TimetableEntry e : entries) {
            out.println("    <class>");
            out.println("        <id>" + e.getId() + "</id>");
            out.println("        <subject>" + escapeXml(e.getSubjectName()) + "</subject>");
            out.println("        <code>" + escapeXml(e.getCourseCode()) + "</code>");
            out.println("        <day>" + escapeXml(e.getDayOfWeek()) + "</day>");
            out.println("        <start>" + (e.getStartTime() != null ? e.getStartTime().toString().substring(0, 5) : "") + "</start>");
            out.println("        <end>" + (e.getEndTime() != null ? e.getEndTime().toString().substring(0, 5) : "") + "</end>");
            out.println("        <room>" + escapeXml(e.getRoom()) + "</room>");
            out.println("        <faculty>" + escapeXml(e.getFaculty()) + "</faculty>");
            out.println("    </class>");
        }
        out.println("</timetable>");
    }

    private void generateTasksXml(PrintWriter out, int userId) {
        List<Task> tasks = taskService.getTasks(userId, null, null, null, null, null, null);
        out.println("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
        out.println("<tasks>");
        for (Task t : tasks) {
            out.println("    <task id=\"" + t.getId() + "\">");
            out.println("        <title>" + escapeXml(t.getTitle()) + "</title>");
            out.println("        <description>" + escapeXml(t.getDescription()) + "</description>");
            out.println("        <category>" + escapeXml(t.getCategory()) + "</category>");
            out.println("        <priority>" + escapeXml(t.getPriority()) + "</priority>");
            out.println("        <status>" + escapeXml(t.getStatus()) + "</status>");
            out.println("        <dueDate>" + (t.getDueDate() != null ? t.getDueDate().toString() : "") + "</dueDate>");
            out.println("        <dueTime>" + (t.getDueTime() != null ? t.getDueTime().toString() : "") + "</dueTime>");
            out.println("        <subject>" + escapeXml(t.getSubjectName()) + "</subject>");
            out.println("        <estimatedMinutes>" + t.getEstimatedMinutes() + "</estimatedMinutes>");
            out.println("        <completed>" + t.isCompleted() + "</completed>");
            out.println("    </task>");
        }
        out.println("</tasks>");
    }

    private String escapeXml(String input) {
        if (input == null) return "";
        return input.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&apos;");
    }
}
