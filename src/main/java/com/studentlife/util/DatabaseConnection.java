package com.studentlife.util;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

import java.io.InputStream;
import java.net.URI;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * DatabaseConnection provides centralized JDBC connection management.
 * Fully compatible with Supabase (PostgreSQL) as primary database,
 * with backwards-compatible support for local MySQL.
 *
 * Reads configuration from:
 *  1. Environment Variables (e.g. DATABASE_URL, DB_HOST, DB_PASSWORD)
 *  2. JVM System Properties (-Ddb.host=...)
 *  3. Classpath resource: db.properties
 */
public class DatabaseConnection {

    private static final Logger LOGGER = Logger.getLogger(DatabaseConnection.class.getName());
    private static HikariDataSource dataSource;

    // Defaults configured for Supabase (PostgreSQL)
    private static String dbType = "postgresql";
    private static String host = "localhost";
    private static String port = "5432";
    private static String dbName = "postgres";
    private static String user = "postgres";
    private static String password = "";
    private static String sslMode = "require";
    private static String jdbcUrl;

    static {
        loadConfiguration();
    }

    private static void loadConfiguration() {
        Properties props = new Properties();
        try (InputStream in = DatabaseConnection.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (in != null) {
                props.load(in);
                dbType = props.getProperty("db.type", dbType);
                host = props.getProperty("db.host", host);
                port = props.getProperty("db.port", port);
                dbName = props.getProperty("db.name", dbName);
                user = props.getProperty("db.user", user);
                password = props.getProperty("db.password", password);
                sslMode = props.getProperty("db.sslmode", sslMode);
                jdbcUrl = props.getProperty("db.url", null);
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Could not load db.properties, using defaults/environment: {0}", e.getMessage());
        }

        // Direct database URL from environment (Supabase / Heroku standard: DATABASE_URL)
        String envDbUrl = getEnvOrProperty("DATABASE_URL", "DB_URL", "JDBC_DATABASE_URL", "db.url");

        // Environment variables override properties
        String envType = getEnvOrProperty("DB_TYPE", "db.type");
        if (envType != null && !envType.isEmpty()) dbType = envType;

        String envHost = getEnvOrProperty("DB_HOST", "db.host");
        if (envHost != null && !envHost.isEmpty()) host = envHost;

        String envPort = getEnvOrProperty("DB_PORT", "db.port");
        if (envPort != null && !envPort.isEmpty()) port = envPort;

        String envDb = getEnvOrProperty("DB_NAME", "db.name");
        if (envDb != null && !envDb.isEmpty()) dbName = envDb;

        String envUser = getEnvOrProperty("DB_USER", "db.user");
        if (envUser != null && !envUser.isEmpty()) user = envUser;

        String envPass = getEnvOrProperty("DB_PASSWORD", "db.password");
        if (envPass != null) password = envPass;

        String envSsl = getEnvOrProperty("DB_SSLMODE", "db.sslmode");
        if (envSsl != null && !envSsl.isEmpty()) sslMode = envSsl;

        // If a direct DATABASE_URL / connection string is provided, parse it
        if (envDbUrl != null && !envDbUrl.trim().isEmpty()) {
            parseDirectUrl(envDbUrl.trim());
        } else {
            buildJdbcUrlFromParts();
        }

        // Register JDBC driver according to database type
        registerDriver();

        // Initialize high-performance connection pool
        initDataSource();
    }

    private static synchronized void initDataSource() {
        try {
            if (dataSource != null && !dataSource.isClosed()) {
                dataSource.close();
            }
            HikariConfig config = new HikariConfig();
            config.setJdbcUrl(jdbcUrl);
            config.setUsername(user);
            config.setPassword(password);
            config.setMaximumPoolSize(10);
            config.setMinimumIdle(2);
            config.setIdleTimeout(300000);
            config.setConnectionTimeout(15000);
            config.setMaxLifetime(1200000);
            config.setPoolName("StudentLifeHikariPool");
            dataSource = new HikariDataSource(config);
            LOGGER.info("HikariCP connection pool initialized successfully.");
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Failed to initialize HikariCP pool, fallback to standard DriverManager: {0}", e.getMessage());
            dataSource = null;
        }
    }

    private static String getEnvOrProperty(String... keys) {
        for (String k : keys) {
            String val = System.getenv(k);
            if (val != null && !val.trim().isEmpty()) return val.trim();
            val = System.getProperty(k);
            if (val != null && !val.trim().isEmpty()) return val.trim();
        }
        return null;
    }

    /**
     * Parses standard PostgreSQL connection strings, e.g.:
     *   postgresql://postgres:[password]@db.[ref].supabase.co:5432/postgres
     *   or jdbc:postgresql://...
     */
    private static void parseDirectUrl(String rawUrl) {
        try {
            if (rawUrl.startsWith("jdbc:postgresql:") || rawUrl.startsWith("jdbc:mysql:")) {
                jdbcUrl = rawUrl;
                dbType = rawUrl.startsWith("jdbc:postgresql:") ? "postgresql" : "mysql";
                return;
            }

            if (rawUrl.startsWith("postgres://") || rawUrl.startsWith("postgresql://")) {
                URI uri = new URI(rawUrl);
                dbType = "postgresql";
                host = uri.getHost();
                if (uri.getPort() > 0) {
                    port = String.valueOf(uri.getPort());
                } else {
                    port = "5432";
                }

                String path = uri.getPath();
                if (path != null && path.length() > 1) {
                    dbName = path.substring(1); // strip leading '/'
                }

                String userInfo = uri.getUserInfo();
                if (userInfo != null && !userInfo.isEmpty()) {
                    int colon = userInfo.indexOf(':');
                    if (colon >= 0) {
                        user = userInfo.substring(0, colon);
                        password = userInfo.substring(colon + 1);
                    } else {
                        user = userInfo;
                    }
                }

                String query = uri.getQuery();
                if (query != null && !query.isEmpty()) {
                    jdbcUrl = String.format("jdbc:postgresql://%s:%s/%s?%s", host, port, dbName, query);
                } else {
                    jdbcUrl = String.format("jdbc:postgresql://%s:%s/%s?sslmode=%s", host, port, dbName, sslMode);
                }
                return;
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Failed to parse DATABASE_URL as URI, fallback to standard build: {0}", e.getMessage());
        }

        buildJdbcUrlFromParts();
    }

    private static void buildJdbcUrlFromParts() {
        // Auto-detect dialect if not specified
        if ("3306".equals(port)) {
            dbType = "mysql";
        } else if ("5432".equals(port) || "6543".equals(port) || (host != null && host.contains("supabase"))) {
            dbType = "postgresql";
        }

        if ("postgresql".equalsIgnoreCase(dbType)) {
            // Supabase requires SSL; sslmode=require ensures encrypted traffic to Supabase pooler/direct host
            jdbcUrl = String.format("jdbc:postgresql://%s:%s/%s?sslmode=%s", host, port, dbName, sslMode);
        } else {
            jdbcUrl = String.format("jdbc:mysql://%s:%s/%s?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&characterEncoding=UTF-8",
                    host, port, dbName);
        }
    }

    private static void registerDriver() {
        try {
            if ("postgresql".equalsIgnoreCase(dbType)) {
                Class.forName("org.postgresql.Driver");
                LOGGER.info("Registered PostgreSQL JDBC Driver for Supabase.");
            } else {
                Class.forName("com.mysql.cj.jdbc.Driver");
                LOGGER.info("Registered MySQL JDBC Driver.");
            }
        } catch (ClassNotFoundException e) {
            LOGGER.log(Level.SEVERE, "JDBC Driver class not found for " + dbType + ": {0}", e.getMessage());
        }
    }

    /**
     * Obtains a JDBC Connection from the connection pool.
     *
     * @return Connection object
     * @throws SQLException if a database access error occurs
     */
    public static Connection getConnection() throws SQLException {
        if (dataSource != null && !dataSource.isClosed()) {
            return dataSource.getConnection();
        }
        return DriverManager.getConnection(jdbcUrl, user, password);
    }

    /**
     * Reloads configuration dynamically if needed.
     */
    public static void reload() {
        loadConfiguration();
    }

    public static String getDbType() {
        return dbType;
    }

    public static String getDbName() {
        return dbName;
    }

    public static String getHost() {
        return host;
    }

    public static String getPort() {
        return port;
    }

    public static String getUser() {
        return user;
    }

    public static String getJdbcUrl() {
        return jdbcUrl;
    }
}
