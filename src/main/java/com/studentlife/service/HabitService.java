package com.studentlife.service;

import com.studentlife.dao.HabitDAO;
import com.studentlife.model.Habit;

import java.util.List;

public class HabitService {
    private final HabitDAO habitDAO;

    public HabitService() {
        this.habitDAO = new HabitDAO();
    }

    public HabitService(HabitDAO habitDAO) {
        this.habitDAO = habitDAO;
    }

    public List<Habit> getHabits(int userId) {
        return habitDAO.findAllWithTodayStatus(userId);
    }

    public Habit getHabitById(int id, int userId) {
        return habitDAO.findById(id, userId);
    }

    public boolean createHabit(Habit h) {
        if (h.getName() == null || h.getName().trim().isEmpty()) {
            throw new IllegalArgumentException("Habit name is required");
        }
        return habitDAO.create(h);
    }

    public boolean updateHabit(Habit h) {
        if (h.getName() == null || h.getName().trim().isEmpty()) {
            throw new IllegalArgumentException("Habit name is required");
        }
        return habitDAO.update(h);
    }

    public boolean deleteHabit(int id, int userId) {
        return habitDAO.delete(id, userId);
    }

    public boolean toggleToday(int habitId, int userId) {
        return habitDAO.toggleToday(habitId, userId);
    }

    public int getCurrentStreak(int userId) {
        return habitDAO.getUserMaxStreak(userId);
    }

    public double getWeeklyRate(int userId) {
        return habitDAO.calculateWeeklyCompletionRate(userId);
    }
}
