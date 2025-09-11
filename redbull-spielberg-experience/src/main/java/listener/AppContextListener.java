package listener;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import java.sql.Driver;
import java.sql.DriverManager;
import java.util.Enumeration;
import java.util.logging.Logger;

public class AppContextListener implements ServletContextListener {
    private static final Logger log = Logger.getLogger(AppContextListener.class.getName());

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        log.info("AppContextListener initialized");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        log.info("AppContextListener shutting down...");

        // Chiude il cleanup thread di MySQL (se presente)
        try {
            Class<?> clazz = Class.forName("com.mysql.cj.jdbc.AbandonedConnectionCleanupThread");
            clazz.getMethod("checkedShutdown").invoke(null);
            log.info("MySQL AbandonedConnectionCleanupThread shutdown OK");
        } catch (Throwable t) {
            log.warning("Cleanup MySQL thread: " + t.getMessage());
        }

        // Deregistra i driver JDBC per prevenire memory leaks su reload
        Enumeration<Driver> drivers = DriverManager.getDrivers();
        while (drivers.hasMoreElements()) {
            try {
                Driver d = drivers.nextElement();
                DriverManager.deregisterDriver(d);
                log.info("Deregistered JDBC driver " + d);
            } catch (Throwable t) {
                log.warning("Error deregistering driver: " + t.getMessage());
            }
        }
    }
}