package utils;

import jakarta.servlet.http.HttpSession;
import model.User;

public class SecurityUtils {

    /**
     * Checks if the current session has an authenticated ADMIN user.
     * 
     * @param session The HTTP session
     * @return true if the user is logged in and is an ADMIN; false otherwise.
     */
    public static boolean isAdmin(HttpSession session) {
        if (session == null) {
            return false;
        }
        Object authUser = session.getAttribute("authUser");
        if (authUser instanceof User) {
            return ((User) authUser).isAdmin();
        }
        return false;
    }
}
