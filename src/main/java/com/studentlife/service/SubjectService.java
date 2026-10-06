package com.studentlife.service;

import com.studentlife.dao.SubjectDAO;
import com.studentlife.model.Subject;

import java.util.List;

public class SubjectService {
    private final SubjectDAO subjectDAO;

    public SubjectService() {
        this.subjectDAO = new SubjectDAO();
    }

    public SubjectService(SubjectDAO subjectDAO) {
        this.subjectDAO = subjectDAO;
    }

    public List<Subject> getSubjects(int userId) {
        return subjectDAO.findAllByUserId(userId);
    }

    public List<Subject> getSubjectSummaries(int userId) {
        return subjectDAO.findSummariesWithStats(userId);
    }

    public Subject getSubjectById(int id, int userId) {
        return subjectDAO.findById(id, userId);
    }

    public Subject getSubjectByName(String name, int userId) {
        return subjectDAO.findByName(name, userId);
    }

    public boolean createSubject(Subject s) {
        if (s.getName() == null || s.getName().trim().isEmpty()) {
            throw new IllegalArgumentException("Subject name is required");
        }
        return subjectDAO.create(s);
    }

    public boolean updateSubject(Subject s) {
        if (s.getName() == null || s.getName().trim().isEmpty()) {
            throw new IllegalArgumentException("Subject name is required");
        }
        return subjectDAO.update(s);
    }

    public boolean deleteSubject(int id, int userId) {
        return subjectDAO.delete(id, userId);
    }
}
