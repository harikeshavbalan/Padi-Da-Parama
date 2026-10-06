package com.studentlife.test;

import com.studentlife.util.DatabaseConnection;
import org.junit.jupiter.api.Test;

import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.ResultSet;
import java.sql.Statement;

public class DatabaseConnectivityTest {

    @Test
    public void testSupabaseConnection() {
        try (Connection conn = DatabaseConnection.getConnection()) {
            DatabaseMetaData meta = conn.getMetaData();
            System.out.println(">>> Connected to Supabase: " + meta.getDatabaseProductName() + " " + meta.getDatabaseProductVersion());

            try (Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery("SELECT id, username, full_name FROM users WHERE username = 'demo'")) {
                if (rs.next()) {
                    System.out.println(">>> Demo user confirmed in database: ID=" + rs.getInt("id") + ", Name=" + rs.getString("full_name"));
                } else {
                    System.out.println(">>> Demo user NOT found!");
                }
            }

            com.studentlife.service.AuthenticationService auth = new com.studentlife.service.AuthenticationService();
            com.studentlife.model.User authenticatedUser = auth.authenticate("demo", "demo123");
            org.junit.jupiter.api.Assertions.assertNotNull(authenticatedUser, "Authentication should succeed for demo/demo123");
            System.out.println(">>> Authentication SUCCESS for: " + authenticatedUser.getUsername() + " (" + authenticatedUser.getFullName() + ")");
        } catch (Exception e) {
            e.printStackTrace();
            org.junit.jupiter.api.Assertions.fail("Database connection failed: " + e.getMessage());
        }
    }
}
