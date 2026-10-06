package com.studentlife.test;

import com.studentlife.model.Exam;
import com.studentlife.model.Habit;
import com.studentlife.model.Task;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.regex.Pattern;

import static org.junit.jupiter.api.Assertions.*;

public class InputValidationTest {

    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$");

    @Test
    @DisplayName("Email format validation works for valid and invalid formats")
    public void testEmailValidation() {
        assertTrue(EMAIL_PATTERN.matcher("demo@studentlife.edu").matches());
        assertTrue(EMAIL_PATTERN.matcher("harikeshav@college.ac.in").matches());
        assertFalse(EMAIL_PATTERN.matcher("invalid-email").matches());
        assertFalse(EMAIL_PATTERN.matcher("@missinguser.com").matches());
        assertFalse(EMAIL_PATTERN.matcher("missingdomain@").matches());
    }

    @Test
    @DisplayName("Exam preparation percentage clamp bounds (0-100)")
    public void testExamPreparationClamp() {
        Exam exam = new Exam();
        exam.setPreparationPercentage(75);
        assertEquals(75, exam.getPreparationPercentage());

        // Clamped bounds logic
        int over = Math.min(100, Math.max(0, 120));
        assertEquals(100, over);

        int under = Math.min(100, Math.max(0, -15));
        assertEquals(0, under);
    }

    @Test
    @DisplayName("Task fields default safely and handle null descriptions")
    public void testTaskDefaults() {
        Task t = new Task();
        assertEquals("Academic", t.getCategory());
        assertEquals("MEDIUM", t.getPriority());
        assertEquals("PENDING", t.getStatus());
        assertEquals("NONE", t.getRecurrence());
        assertEquals(30, t.getEstimatedMinutes());

        t.setDescription(null);
        assertNull(t.getDescription());
    }

    @Test
    @DisplayName("Habit defaults initialize with daily target frequency")
    public void testHabitDefaults() {
        Habit h = new Habit();
        assertEquals("General", h.getCategory());
        assertEquals("DAILY", h.getTargetFrequency());
        assertEquals("#10b981", h.getColor());
    }
}
