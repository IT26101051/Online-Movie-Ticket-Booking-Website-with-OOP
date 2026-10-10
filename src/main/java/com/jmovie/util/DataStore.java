package com.jmovie.util;

import java.io.File;

/**
 * Central data store registry.
 * Provides named FileHandler instances for each data file.
 * The data path is set once at application startup by AppInitializer.
 */
public class DataStore {

    private static String dataPath;

    /** Called once at startup by AppInitializer (ServletContextListener) */
    public static void setDataPath(String path) {
        dataPath = path;
        new File(path).mkdirs();
        System.out.println("[JMovie] DataStore initialized at: " + path);
    }

    public static String getDataPath() { return dataPath; }

    private static FileHandler getHandler(String filename) {
        if (dataPath == null) {
            throw new IllegalStateException("DataStore not initialized. AppInitializer may not have run.");
        }
        return new FileHandler(dataPath + File.separator + filename);
    }

    // Named accessors for each entity file
    public static FileHandler users()     { return getHandler("users.txt");     }
    public static FileHandler movies()    { return getHandler("movies.txt");    }
    public static FileHandler showtimes() { return getHandler("showtimes.txt"); }
    public static FileHandler bookings()  { return getHandler("bookings.txt");  }
    public static FileHandler reviews()   { return getHandler("reviews.txt");   }
}
