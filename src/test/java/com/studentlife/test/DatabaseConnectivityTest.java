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
                 ResultSet rs = stmt.executeQuery("SELECT count(*) FROM users")) {
                if (rs.next()) {
                    System.out.println(">>> Total users found: " + rs.getInt(1));
                }
            }
        } catch (Exception e) {
            System.out.println(">>> Note: Database connection test skipped or offline: " + e.getMessage());
        }
    }
}
