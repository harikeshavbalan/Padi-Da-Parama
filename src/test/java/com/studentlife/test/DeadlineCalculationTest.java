package com.studentlife.test;

import com.studentlife.model.Deadline;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.sql.Date;
import java.time.LocalDate;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

public class DeadlineCalculationTest {

    @Test
    @DisplayName("Deadline Due Today correctly identified")
    public void testDeadlineDueToday() {
        Deadline d = new Deadline();
        d.setTitle("DBMS Assignment Submission");
        d.setDueDate(Date.valueOf(LocalDate.now()));
        d.setStatus("PENDING");

        assertEquals(0, d.getDaysRemaining());
        assertEquals("Due today", d.getRemainingText());
    }

    @Test
    @DisplayName("Deadline Due Tomorrow correctly identified")
    public void testDeadlineDueTomorrow() {
        Deadline d = new Deadline();
        d.setTitle("CN Socket Lab Upload");
        d.setDueDate(Date.valueOf(LocalDate.now().plusDays(1)));
        d.setStatus("PENDING");

        assertEquals(1, d.getDaysRemaining());
        assertEquals("Due tomorrow", d.getRemainingText());
    }

    @Test
    @DisplayName("Upcoming Deadline calculates remaining days correctly")
    public void testUpcomingDeadline() {
        Deadline d = new Deadline();
        d.setTitle("Web Tech Project Milestone 1");
        d.setDueDate(Date.valueOf(LocalDate.now().plusDays(5)));
        d.setStatus("PENDING");

        assertEquals(5, d.getDaysRemaining());
        assertEquals("Due in 5 days", d.getRemainingText());
    }

    @Test
    @DisplayName("Overdue Deadline calculates overdue days correctly")
    public void testOverdueDeadline() {
        Deadline d = new Deadline();
        d.setTitle("CN Chapter 3 Quiz Overdue");
        d.setDueDate(Date.valueOf(LocalDate.now().minusDays(3)));
        d.setStatus("PENDING");

        assertTrue(d.getDaysRemaining() < 0);
        assertEquals("Overdue by 3 days", d.getRemainingText());
    }

    @Test
    @DisplayName("Completed Deadline displays Completed status")
    public void testCompletedDeadline() {
        Deadline d = new Deadline();
        d.setTitle("Past Assignment");
        d.setDueDate(Date.valueOf(LocalDate.now().minusDays(5)));
        d.setStatus("COMPLETED");

        assertEquals("Completed", d.getRemainingText());
    }
}
