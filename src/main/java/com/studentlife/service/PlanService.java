package com.studentlife.service;

import com.studentlife.dao.PlanDAO;
import com.studentlife.model.Plan;

import java.util.List;

public class PlanService {
    private final PlanDAO planDAO;

    public PlanService() {
        this.planDAO = new PlanDAO();
    }

    public PlanService(PlanDAO planDAO) {
        this.planDAO = planDAO;
    }

    public List<Plan> getPlans(int userId) {
        return planDAO.findAllByUserId(userId);
    }

    public Plan getPlanById(int id, int userId) {
        return planDAO.findById(id, userId);
    }

    public boolean createPlan(Plan plan) {
        if (plan.getTitle() == null || plan.getTitle().trim().isEmpty()) {
            throw new IllegalArgumentException("Plan title is required");
        }
        return planDAO.create(plan);
    }

    public boolean updatePlan(Plan plan) {
        if (plan.getTitle() == null || plan.getTitle().trim().isEmpty()) {
            throw new IllegalArgumentException("Plan title is required");
        }
        return planDAO.update(plan);
    }

    public boolean deletePlan(int id, int userId) {
        return planDAO.delete(id, userId);
    }

    public boolean updateProgress(int id, int userId, int progress, String status) {
        return planDAO.updateProgress(id, userId, progress, status);
    }
}
