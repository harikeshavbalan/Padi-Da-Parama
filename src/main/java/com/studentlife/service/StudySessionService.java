package com.studentlife.service;

import com.studentlife.dao.StudySessionDAO;
import com.studentlife.model.StudySession;

import java.util.List;
import java.util.Map;

public class StudySessionService {
    private final StudySessionDAO studySessionDAO;

    public StudySessionService() {
        this.studySessionDAO = new StudySessionDAO();
    }

    public StudySessionService(StudySessionDAO studySessionDAO) {
        this.studySessionDAO = studySessionDAO;
    }

    public List<StudySession> getSessions(int userId) {
        return studySessionDAO.findAllByUserId(userId);
    }

    public boolean createSession(StudySession session) {
        if (session.getDurationMinutes() <= 0) {
            throw new IllegalArgumentException("Duration must be greater than zero minutes");
        }
        return studySessionDAO.create(session);
    }

    public boolean deleteSession(int id, int userId) {
        return studySessionDAO.delete(id, userId);
    }

    public int getTodayMinutes(int userId) {
        return studySessionDAO.getTodayMinutes(userId);
    }

    public int getWeekMinutes(int userId) {
        return studySessionDAO.getWeekMinutes(userId);
    }

    public int getMonthMinutes(int userId) {
        return studySessionDAO.getMonthMinutes(userId);
    }

    public Map<String, Integer> getSubjectWiseStudyMinutes(int userId) {
        return studySessionDAO.getSubjectWiseStudyMinutes(userId);
    }
}
