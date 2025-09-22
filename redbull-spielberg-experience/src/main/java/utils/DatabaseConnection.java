package utils;

import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Preferisce JNDI (pool di Tomcat). Fallback su DriverManager SOLO se JNDI non disponibile.
 * Per il fallback usa variabili d'ambiente (RB_DB_URL, RB_DB_USER, RB_DB_PASS) per evitare segreti nel repo.
 */
public class DatabaseConnection {

    private static final String JNDI_NAME = "java:/comp/env/jdbc/redbull";
    // Valore di default “di sviluppo” per l’URL (user/pass arrivano da env)
    private static final String DEFAULT_URL =
            "jdbc:mysql://localhost:3306/red_bull_spielberg?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Europe/Rome";

    private static DatabaseConnection instance;

    private final DataSource dataSource; // se JNDI va
    private final boolean jndiOk;

    private DatabaseConnection() {
        DataSource ds = null;
        boolean ok = false;
        try {
            ds = (DataSource) new InitialContext().lookup(JNDI_NAME);
            System.out.println("[DB] Using JNDI DataSource 'jdbc/redbull'.");
            ok = true;
        } catch (NamingException e) {
            System.out.println("[DB] JNDI non disponibile: " + e.getMessage() + " — attivo fallback DriverManager con ENV.");
        }
        this.dataSource = ds;
        this.jndiOk = ok;

        // Pre-carica il driver MySQL per il fallback (non errore se fallisce: potrebbe non servire mai)
        if (!jndiOk) {
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
            } catch (ClassNotFoundException ignore) {
                // verrà segnalato al primo getConnection() se davvero serve il fallback
            }
        }
    }

    public static synchronized DatabaseConnection getInstance() {
        if (instance == null) instance = new DatabaseConnection();
        return instance;
    }

    public Connection getConnection() throws SQLException {
        if (jndiOk && dataSource != null) {
            return dataSource.getConnection();
        }
        // --- Fallback: usa ENV ---
        String url  = envOrDefault("RB_DB_URL", DEFAULT_URL);
        String user = envOrDefault("RB_DB_USER", null);
        String pass = envOrDefault("RB_DB_PASS", null);

        if (user == null || pass == null) {
            throw new SQLException("[DB] Fallback attivo ma RB_DB_USER / RB_DB_PASS non sono impostate. " +
                    "Configura le variabili d'ambiente o ripristina il JNDI.");
        }
        System.out.println("[DB] Connected via DriverManager fallback (ENV).");
        return DriverManager.getConnection(url, user, pass);
    }

    public void closeConnection() {
        // no-op: pool JNDI chiude da sé; per fallback viene chiusa dal try-with-resources nei DAO
    }

    private static String envOrDefault(String key, String def) {
        String v = System.getenv(key);
        return (v == null || v.isBlank()) ? def : v.trim();
    }
}