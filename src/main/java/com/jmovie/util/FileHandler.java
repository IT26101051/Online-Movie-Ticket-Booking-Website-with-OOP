package com.jmovie.util;

import java.io.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Generic file I/O handler for reading and writing pipe-delimited records.
 * Used for all data storage (users.txt, movies.txt, bookings.txt, etc.)
 */
public class FileHandler {

    private final String filePath;

    public FileHandler(String filePath) {
        this.filePath = filePath;
        File file = new File(filePath);
        if (file.getParentFile() != null) {
            file.getParentFile().mkdirs();
        }
        if (!file.exists()) {
            try {
                file.createNewFile();
            } catch (IOException e) {
                System.err.println("[JMovie] Error creating file: " + filePath + " - " + e.getMessage());
            }
        }
    }

    /** Read all non-empty lines from the file */
    public synchronized List<String> readAll() {
        List<String> lines = new ArrayList<>();
        try (BufferedReader reader = new BufferedReader(new FileReader(filePath))) {
            String line;
            while ((line = reader.readLine()) != null) {
                line = line.trim();
                if (!line.isEmpty()) {
                    lines.add(line);
                }
            }
        } catch (IOException e) {
            System.err.println("[JMovie] Error reading: " + filePath);
        }
        return lines;
    }

    /** Overwrite the file with the given list of lines (UPDATE / DELETE) */
    public synchronized void writeAll(List<String> lines) {
        try (PrintWriter writer = new PrintWriter(new FileWriter(filePath, false))) {
            for (String line : lines) {
                if (line != null && !line.trim().isEmpty()) {
                    writer.println(line.trim());
                }
            }
        } catch (IOException e) {
            System.err.println("[JMovie] Error writing: " + filePath);
        }
    }

    /** Append a new line to the file (CREATE) */
    public synchronized void appendLine(String line) {
        if (line == null || line.trim().isEmpty()) return;
        try (PrintWriter writer = new PrintWriter(new FileWriter(filePath, true))) {
            writer.println(line.trim());
        } catch (IOException e) {
            System.err.println("[JMovie] Error appending to: " + filePath);
        }
    }

    /** Delete the line starting with the given ID (DELETE) */
    public synchronized boolean deleteLine(String id) {
        List<String> lines = readAll();
        boolean removed = lines.removeIf(line -> line.startsWith(id + "|"));
        if (removed) writeAll(lines);
        return removed;
    }

    /** Update the line that starts with the given ID (UPDATE) */
    public synchronized boolean updateLine(String id, String newLine) {
        List<String> lines = readAll();
        boolean found = false;
        for (int i = 0; i < lines.size(); i++) {
            if (lines.get(i).startsWith(id + "|")) {
                lines.set(i, newLine.trim());
                found = true;
                break;
            }
        }
        if (found) writeAll(lines);
        return found;
    }

    /** Find a single line by ID (READ) */
    public String findById(String id) {
        for (String line : readAll()) {
            if (line.startsWith(id + "|")) return line;
        }
        return null;
    }

    /** Check if a record with the given ID exists */
    public boolean exists(String id) {
        return findById(id) != null;
    }
}
