package com.studentlife.test;

import com.studentlife.util.PasswordUtil;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

public class PasswordUtilTest {

    @Test
    @DisplayName("Password hashing produces valid BCrypt string and verifies correctly")
    public void testHashAndVerifySuccess() {
        String raw = "demo123";
        String hash = PasswordUtil.hashPassword(raw);

        assertNotNull(hash, "BCrypt hash should not be null");
        assertTrue(hash.startsWith("$2a$10$"), "BCrypt hash should start with standard prefix $2a$10$");
        assertTrue(PasswordUtil.checkPassword(raw, hash), "Password check should return true for correct password");
        assertFalse(PasswordUtil.checkPassword("wrongpass", hash), "Password check should return false for incorrect password");
    }

    @Test
    @DisplayName("Empty password throws IllegalArgumentException")
    public void testEmptyPasswordThrows() {
        assertThrows(IllegalArgumentException.class, () -> PasswordUtil.hashPassword(""));
        assertThrows(IllegalArgumentException.class, () -> PasswordUtil.hashPassword(null));
    }
}
