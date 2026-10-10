package com.jmovie.util;

import java.util.UUID;

/**
 * Generates unique IDs for entities.
 * Format: PREFIX + 8-character UUID segment (uppercase)
 * Examples: USR4A3F1B2C, MOV9E8D7C6B
 */
public class IdGenerator {

    public static String generate(String prefix) {
        String uuid = UUID.randomUUID().toString().replace("-", "").toUpperCase();
        return prefix + uuid.substring(0, 8);
    }
}
