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
                 ResultSet rs = stmt.executeQuery("SELECT t.id, t.day_of_week, t.start_time, t.end_time, t.room, t.faculty, s.name as subject_name " +
                                                  "FROM timetable t JOIN subjects s ON t.subject_id = s.id " +
                                                  "WHERE t.user_id = 1 ORDER BY t.day_of_week, t.start_time")) {
                System.out.println(">>> Existing Timetable entries for user 1:");
                int count = 0;
                while (rs.next()) {
                    count++;
                    System.out.println("    " + rs.getString("day_of_week") + " | " + rs.getTime("start_time") + " - " + rs.getTime("end_time") + " | " + rs.getString("subject_name") + " | Room: " + rs.getString("room") + " | " + rs.getString("faculty"));
                }
                System.out.println(">>> Total timetable entries: " + count);
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
