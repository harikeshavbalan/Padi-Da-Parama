package com.studentlife.util;

import org.mindrot.jbcrypt.BCrypt;

/**
 * PasswordUtil provides secure password hashing and verification
 * using the BCrypt strong cryptographic hash algorithm.
 */
public class PasswordUtil {

    private static final int WORKLOAD = 10;

    /**
     * Hashes a plaintext password using BCrypt.
     *
     * @param plainTextPassword the plaintext password to hash
     * @return the BCrypt hashed string
     */
    public static String hashPassword(String plainTextPassword) {
        if (plainTextPassword == null || plainTextPassword.trim().isEmpty()) {
            throw new IllegalArgumentException("Password cannot be empty");
        }
        return BCrypt.hashpw(plainTextPassword, BCrypt.gensalt(WORKLOAD));
    }

    /**
     * Verifies a plaintext password against a stored BCrypt hash.
     *
     * @param plainTextPassword the plaintext password to test
     * @param hashedPassword    the stored hash to compare against
     * @return true if password matches, false otherwise
     */
    public static boolean checkPassword(String plainTextPassword, String hashedPassword) {
        if (plainTextPassword == null || hashedPassword == null) {
            return false;
        }
        try {
            return BCrypt.checkpw(plainTextPassword, hashedPassword);
        } catch (IllegalArgumentException e) {
            return false;
        }
    }

    public static void main(String[] args) {
        String hash = hashPassword("demo123");
        System.out.println("BCrypt hash for demo123: " + hash);
        System.out.println("Verification check: " + checkPassword("demo123", hash));
    }
}
