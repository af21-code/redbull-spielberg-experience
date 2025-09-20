package utils;

import javax.naming.InitialContext;
import javax.naming.Context;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConnection {
    private static final DatabaseConnection INSTANCE = new DatabaseConnection();
    private DataSource ds;

    private DatabaseConnection() {
        try {
            Context ic = new InitialContext();
            // cerca il DataSource definito in context.xml
            ds = (DataSource) ic.lookup("java:comp/env/jdbc/redbull");
        } catch (Exception e) {
            ds = null; // fallback a DriverManager
        }
    }

    public static DatabaseConnection getInstance() {
        return INSTANCE;
    }

    public Connection getConnection() throws SQLException {
        if (ds != null) {
            return ds.getConnection();
        }
        // Fallback: usa i parametri attuali (adatta user/pass/URL ai tuoi)
        String url = "jdbc:mysql://localhost:3306/red_bull_spielberg?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
        String user = "root";
        String pass = "";
        return DriverManager.getConnection(url, user, pass);
    }
}