package com.studentlife.test;

import com.studentlife.model.ProductivityMetrics;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

public class ProductivityScoreTest {

    @Test
    @DisplayName("Productivity Score weights are calculated accurately: 40% task, 25% deadline, 20% study, 15% habits")
    public void testProductivityScoreCalculation() {
        // taskRate = 80%, deadlineRate = 100%, studyRate = 75%, habitRate = 80%
        // Weighted = (80 * 0.40) + (100 * 0.25) + (75 * 0.20) + (80 * 0.15)
        //          = 32.0 + 25.0 + 15.0 + 12.0 = 84.0
        ProductivityMetrics metrics = new ProductivityMetrics(80.0, 100.0, 75.0, 80.0);
        assertEquals(84, metrics.getOverallScore(), "Overall productivity score should equal 84");
    }

    @Test
    @DisplayName("Productivity Score caps rates at 100% and min at 0%")
    public void testProductivityScoreClamping() {
        ProductivityMetrics metrics = new ProductivityMetrics(150.0, 120.0, -10.0, 100.0);
        // taskRate clamped to 100, deadline clamped to 100, study clamped to 0, habit clamped to 100
        // Weighted = (100 * 0.4) + (100 * 0.25) + (0 * 0.20) + (100 * 0.15) = 40 + 25 + 0 + 15 = 80
        assertEquals(80, metrics.getOverallScore());
    }
}
