package com.studentlife.test;

import com.studentlife.model.Task;
import com.studentlife.service.TaskService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.sql.Date;
import java.time.LocalDate;

import static org.junit.jupiter.api.Assertions.*;

public class TaskValidationAndStatusTest {

    @Test
    @DisplayName("Task overdue and due status calculation works correctly")
    public void testTaskOverdueStatus() {
        Task pastTask = new Task();
        pastTask.setTitle("Old assignment");
        pastTask.setDueDate(Date.valueOf(LocalDate.now().minusDays(3)));
        pastTask.setStatus("PENDING");

        assertTrue(pastTask.isOverdue(), "Past due pending task should be overdue");
        assertEquals("Overdue by 3 days", pastTask.getDueStatusText());

        pastTask.setStatus("COMPLETED");
        assertFalse(pastTask.isOverdue(), "Completed task should never be considered overdue");
        assertEquals("Completed", pastTask.getDueStatusText());
    }

    @Test
    @DisplayName("Task due today detection works accurately")
    public void testTaskDueToday() {
        Task todayTask = new Task();
        todayTask.setTitle("Today Lab");
        todayTask.setDueDate(Date.valueOf(LocalDate.now()));
        todayTask.setStatus("PENDING");

        assertTrue(todayTask.isDueToday(), "Task with today's date should return isDueToday = true");
        assertEquals("Due today", todayTask.getDueStatusText());
    }

    @Test
    @DisplayName("Task validation enforces mandatory title")
    public void testTaskValidation() {
        TaskService service = new TaskService(null);
        Task invalidTask = new Task();
        invalidTask.setTitle("");

        assertThrows(IllegalArgumentException.class, () -> service.createTask(invalidTask));
    }
}
