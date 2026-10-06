package com.studentlife.service;

import com.studentlife.dao.UserDAO;
import com.studentlife.model.User;
import com.studentlife.util.PasswordUtil;

import java.util.logging.Logger;

public class AuthenticationService {
    private static final Logger LOGGER = Logger.getLogger(AuthenticationService.class.getName());
    private final UserDAO userDAO;

    public AuthenticationService() {
        this.userDAO = new UserDAO();
    }

    public AuthenticationService(UserDAO userDAO) {
        this.userDAO = userDAO;
    }

    public User authenticate(String username, String password) {
        if (username == null || password == null || username.trim().isEmpty() || password.trim().isEmpty()) {
            return null;
        }
        User user = userDAO.findByUsername(username.trim());
        if (user != null && PasswordUtil.checkPassword(password, user.getPasswordHash())) {
            return user;
        }
        return null;
    }

    public boolean isUsernameTaken(String username) {
        if (username == null || username.trim().isEmpty()) return false;
        return userDAO.findByUsername(username.trim()) != null;
    }

    public boolean isEmailTaken(String email) {
        if (email == null || email.trim().isEmpty()) return false;
        return userDAO.findByEmail(email.trim()) != null;
    }

    public boolean register(String username, String email, String password, String fullName) {
        if (isUsernameTaken(username) || isEmailTaken(email)) {
            return false;
        }
        String hashed = PasswordUtil.hashPassword(password);
        User newUser = new User();
        newUser.setUsername(username.trim());
        newUser.setEmail(email.trim());
        newUser.setPasswordHash(hashed);
        newUser.setFullName(fullName != null ? fullName.trim() : username.trim());
        return userDAO.create(newUser);
    }

    public boolean changePassword(int userId, String oldPassword, String newPassword) {
        User user = userDAO.findById(userId);
        if (user == null) return false;
        if (!PasswordUtil.checkPassword(oldPassword, user.getPasswordHash())) {
            return false;
        }
        String newHash = PasswordUtil.hashPassword(newPassword);
        return userDAO.updatePassword(userId, newHash);
    }

    public boolean updateProfile(int userId, String fullName, String email) {
        return userDAO.updateProfile(userId, fullName, email);
    }

    public User getUserById(int userId) {
        return userDAO.findById(userId);
    }
}
