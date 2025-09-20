package listener;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

import java.sql.Driver;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Enumeration;

@WebListener
public class AppShutdownListener implements ServletContextListener {

  @Override
  public void contextDestroyed(ServletContextEvent sce) {
    // 1) Ferma il thread di cleanup del driver MySQL (se presente)
    try {
      Class<?> cls = Class.forName("com.mysql.cj.jdbc.AbandonedConnectionCleanupThread");
      cls.getMethod("checkedShutdown").invoke(null);
    } catch (ClassNotFoundException e) {
      // driver non in classpath o versione diversa: ignora
    } catch (Throwable t) {
      // log minimale e procedi
      t.printStackTrace();
    }

    // 2) Deregistra i JDBC driver caricati da questo webapp classloader
    ClassLoader cl = Thread.currentThread().getContextClassLoader();
    Enumeration<Driver> drivers = DriverManager.getDrivers();
    while (drivers.hasMoreElements()) {
      Driver d = drivers.nextElement();
      if (d.getClass().getClassLoader() == cl) {
        try { DriverManager.deregisterDriver(d); }
        catch (SQLException ignore) {}
      }
    }
  }
}