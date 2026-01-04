package utils;

import jakarta.servlet.ServletContext;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

public class FileStorage {

    /**
     * Converts an uploaded image to a Base64 string for DB storage.
     *
     * @param input       InputStream of the file
     * @param contentType Content type (e.g. image/jpeg)
     * @return The Base64 Data URI (e.g. "data:image/jpeg;base64,.....")
     * @throws IOException If read fails
     */
    public static String convertToBase64(InputStream input, String contentType) throws IOException {
        java.io.ByteArrayOutputStream buffer = new java.io.ByteArrayOutputStream();
        int nRead;
        byte[] data = new byte[4096];
        while ((nRead = input.read(data, 0, data.length)) != -1) {
            buffer.write(data, 0, nRead);
        }
        buffer.flush();
        byte[] bytes = buffer.toByteArray();

        String base64 = java.util.Base64.getEncoder().encodeToString(bytes);
        return "data:" + contentType + ";base64," + base64;
    }
}
