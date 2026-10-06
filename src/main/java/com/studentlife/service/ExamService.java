package com.studentlife.service;

import com.studentlife.dao.ExamDAO;
import com.studentlife.model.Exam;

import java.util.List;

public class ExamService {
    private final ExamDAO examDAO;

    public ExamService() {
        this.examDAO = new ExamDAO();
    }

    public ExamService(ExamDAO examDAO) {
        this.examDAO = examDAO;
    }

    public List<Exam> getExams(int userId) {
        return examDAO.findAllByUserId(userId);
    }

    public Exam getNextExam(int userId) {
        return examDAO.findNextExam(userId);
    }

    public Exam getExamById(int id, int userId) {
        return examDAO.findById(id, userId);
    }

    public boolean createExam(Exam exam) {
        if (exam.getTitle() == null || exam.getTitle().trim().isEmpty()) {
            throw new IllegalArgumentException("Exam title is required");
        }
        if (exam.getExamDate() == null) {
            throw new IllegalArgumentException("Exam date is required");
        }
        return examDAO.create(exam);
    }

    public boolean updateExam(Exam exam) {
        if (exam.getTitle() == null || exam.getTitle().trim().isEmpty()) {
            throw new IllegalArgumentException("Exam title is required");
        }
        return examDAO.update(exam);
    }

    public boolean deleteExam(int id, int userId) {
        return examDAO.delete(id, userId);
    }

    public boolean updatePreparation(int id, int userId, int percentage) {
        return examDAO.updatePreparation(id, userId, percentage);
    }
}
