package com.jmovie.util;

import com.jmovie.db.DBConnection;
import com.jmovie.db.DatabaseInit;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

/**
 * Application startup listener.
 * Initializes the MySQL / MariaDB database schema and seeds default data.
 */
@WebListener
public class AppInitializer implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("[JMovie] Starting JMovie application...");

        // Initialize MySQL Database tables & seed initial data
        try {
            if (DBConnection.testConnection()) {
                DatabaseInit.init();
                System.out.println("[JMovie] ✅ MySQL Database connected and initialized successfully.");
            } else {
                System.err.println("[JMovie] ❌ Warning: Could not connect to MySQL Database on startup.");
            }
        } catch (Exception e) {
            System.err.println("[JMovie] Database initialization error: " + e.getMessage());
        }

        System.out.println("[JMovie] Application started successfully.");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        System.out.println("[JMovie] Application stopped.");
    }
}
