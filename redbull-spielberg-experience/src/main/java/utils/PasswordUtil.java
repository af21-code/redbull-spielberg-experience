package utils;

import java.security.MessageDigest;
import java.nio.charset.StandardCharsets;

/**
 * Utility per hashing e verifica password senza librerie esterne.
 * - matches(): accetta sia hash SHA-256 (64 hex) sia password in chiaro (fallback).
 */
public class PasswordUtil {

    // Hash semplice SHA-256 -> 64 char hex
    public static String sha256(String plain) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] digest = md.digest(plain.getBytes(StandardCharsets.UTF_8));
            return toHex(digest);
        } catch (Exception e) {
            throw new RuntimeException("SHA-256 not available", e);
        }
    }

    public static boolean matches(String plainPassword, String storedPassword) {
        if (storedPassword == null) return false;

        // Se stored è un hash SHA-256 (64 hex), confronto hash(plain) con stored
        if (isHexSha256(storedPassword)) {
            return sha256(plainPassword).equalsIgnoreCase(storedPassword);
        }

        // Fallback: confronto in chiaro per compatibilità con dati esistenti (es. admin 'admin123')
        return plainPassword.equals(storedPassword);
    }

    public static String hash(String plainPassword) {
        // Usa SHA-256 (nessun sale per semplicità; puoi aggiungerlo più avanti)
        return sha256(plainPassword);
    }

    private static boolean isHexSha256(String s) {
        if (s.length() != 64) return false;
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            boolean hex = (c >= '0' && c <= '9') ||
                          (c >= 'a' && c <= 'f') ||
                          (c >= 'A' && c <= 'F');
            if (!hex) return false;
        }
        return true;
    }

    private static String toHex(byte[] bytes) {
        StringBuilder sb = new StringBuilder(bytes.length * 2);
        for (byte b : bytes) sb.append(String.format("%02x", b));
        return sb.toString();
    }
}