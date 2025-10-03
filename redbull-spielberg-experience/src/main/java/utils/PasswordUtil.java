package utils;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.Base64;

/**
 * PasswordUtil
 * - Hash sicuro con PBKDF2WithHmacSHA256 (JDK 17+, nessuna libreria esterna).
 * - Formato hash: $PBKDF2$<iterations>$<salt_b64>$<hash_b64>
 * - Compatibilità retro: valida anche hash SHA-256 hex (64 char) o password in chiaro (solo per dati legacy).
 *   I nuovi hash vengono sempre prodotti in PBKDF2.
 */
public final class PasswordUtil {

    // Parametri PBKDF2 (sicuri e ragionevoli per JDK attuali)
    private static final String PBKDF2_ALGO = "PBKDF2WithHmacSHA256";
    private static final int PBKDF2_ITERATIONS = 120_000;
    private static final int SALT_LEN_BYTES = 16;
    private static final int KEY_LEN_BITS = 256; // 32 byte

    private static final SecureRandom RANDOM = new SecureRandom();

    private PasswordUtil() {
        // utility class
    }

    /**
     * Genera un hash PBKDF2 per la password in chiaro.
     * @param plainPassword password in chiaro (non null)
     * @return stringa nel formato $PBKDF2$<iters>$<salt_b64>$<hash_b64>
     */
    public static String hash(String plainPassword) {
        if (plainPassword == null) throw new IllegalArgumentException("plainPassword cannot be null");
        byte[] salt = new byte[SALT_LEN_BYTES];
        RANDOM.nextBytes(salt);
        byte[] derived = pbkdf2(plainPassword.getBytes(StandardCharsets.UTF_8), salt, PBKDF2_ITERATIONS, KEY_LEN_BITS);
        return "$PBKDF2$" + PBKDF2_ITERATIONS + "$"
                + Base64.getEncoder().encodeToString(salt) + "$"
                + Base64.getEncoder().encodeToString(derived);
    }

    /**
     * Verifica che la password in chiaro corrisponda all'hash memorizzato.
     * Supporta:
     * - PBKDF2 ($PBKDF2$...)
     * - SHA-256 hex (64 char)
     * - Fallback chiaro (legacy)
     */
    public static boolean matches(String plainPassword, String storedPassword) {
        if (plainPassword == null || storedPassword == null) return false;

        if (isPbkdf2(storedPassword)) {
            String[] parts = storedPassword.split("\\$");
            // formato atteso: "", "PBKDF2", "<iters>", "<salt_b64>", "<hash_b64>"
            if (parts.length != 5) return false;
            final int iters;
            try {
                iters = Integer.parseInt(parts[2]);
            } catch (NumberFormatException e) {
                return false;
            }
            byte[] salt = Base64.getDecoder().decode(parts[3]);
            byte[] expected = Base64.getDecoder().decode(parts[4]);
            byte[] derived = pbkdf2(plainPassword.getBytes(StandardCharsets.UTF_8), salt, iters, expected.length * 8);
            return constantTimeEquals(expected, derived);
        }

        if (isHexSha256(storedPassword)) {
            return sha256(plainPassword).equalsIgnoreCase(storedPassword);
        }

        // Legacy chiaro (sconsigliato, solo compatibilità)
        return plainPassword.equals(storedPassword);
    }

    // ===== Helpers =====

    private static boolean isPbkdf2(String s) {
        return s.startsWith("$PBKDF2$");
    }

    // Hash semplice SHA-256 (legacy only)
    private static String sha256(String plain) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] digest = md.digest(plain.getBytes(StandardCharsets.UTF_8));
            return toHex(digest);
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("SHA-256 not available", e);
        }
    }

    private static boolean isHexSha256(String s) {
        if (s.length() != 64) return false;
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            boolean hex = (c >= '0' && c <= '9')
                    || (c >= 'a' && c <= 'f')
                    || (c >= 'A' && c <= 'F');
            if (!hex) return false;
        }
        return true;
    }

    private static String toHex(byte[] bytes) {
        StringBuilder sb = new StringBuilder(bytes.length * 2);
        for (byte b : bytes) sb.append(String.format("%02x", b));
        return sb.toString();
    }

    private static byte[] pbkdf2(byte[] password, byte[] salt, int iterations, int keyLenBits) {
        try {
            javax.crypto.SecretKeyFactory skf = javax.crypto.SecretKeyFactory.getInstance(PBKDF2_ALGO);
            javax.crypto.spec.PBEKeySpec spec = new javax.crypto.spec.PBEKeySpec(
                    new String(password, StandardCharsets.UTF_8).toCharArray(),
                    salt,
                    iterations,
                    keyLenBits
            );
            return skf.generateSecret(spec).getEncoded();
        } catch (Exception e) {
            throw new IllegalStateException("PBKDF2 not available", e);
        }
    }

    private static boolean constantTimeEquals(byte[] a, byte[] b) {
        if (a == null || b == null) return false;
        if (a.length != b.length) return false;
        int result = 0;
        for (int i = 0; i < a.length; i++) {
            result |= a[i] ^ b[i];
        }
        return result == 0;
    }
}