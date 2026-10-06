package com.studentlife.model;

/**
 * ProductivityMetrics holds the component weights and transparent calculation
 * for the student's productivity score.
 * Formula:
 * - Task completion = 40%
 * - Deadline adherence = 25%
 * - Study session consistency = 20%
 * - Habit completion = 15%
 */
public class ProductivityMetrics {
    private double taskCompletionRate;      // 0 - 100
    private double deadlineAdherenceRate;   // 0 - 100
    private double studyTargetRate;         // 0 - 100
    private double habitCompletionRate;     // 0 - 100
    private int overallScore;               // 0 - 100

    public ProductivityMetrics() {}

    public ProductivityMetrics(double taskRate, double deadlineRate, double studyRate, double habitRate) {
        this.taskCompletionRate = Math.min(100.0, Math.max(0.0, taskRate));
        this.deadlineAdherenceRate = Math.min(100.0, Math.max(0.0, deadlineRate));
        this.studyTargetRate = Math.min(100.0, Math.max(0.0, studyRate));
        this.habitCompletionRate = Math.min(100.0, Math.max(0.0, habitRate));
        calculateOverallScore();
    }

    public void calculateOverallScore() {
        double weighted = (taskCompletionRate * 0.40) +
                          (deadlineAdherenceRate * 0.25) +
                          (studyTargetRate * 0.20) +
                          (habitCompletionRate * 0.15);
        this.overallScore = (int) Math.round(weighted);
    }

    public double getTaskCompletionRate() { return taskCompletionRate; }
    public void setTaskCompletionRate(double taskCompletionRate) { this.taskCompletionRate = taskCompletionRate; }

    public double getDeadlineAdherenceRate() { return deadlineAdherenceRate; }
    public void setDeadlineAdherenceRate(double deadlineAdherenceRate) { this.deadlineAdherenceRate = deadlineAdherenceRate; }

    public double getStudyTargetRate() { return studyTargetRate; }
    public void setStudyTargetRate(double studyTargetRate) { this.studyTargetRate = studyTargetRate; }

    public double getHabitCompletionRate() { return habitCompletionRate; }
    public void setHabitCompletionRate(double habitCompletionRate) { this.habitCompletionRate = habitCompletionRate; }

    public int getOverallScore() { return overallScore; }
    public void setOverallScore(int overallScore) { this.overallScore = overallScore; }
}
