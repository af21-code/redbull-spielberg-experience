package utils;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Classe per la gestione della connessione al database
 * Implementa il pattern Singleton per garantire una sola istanza
 */
public class DatabaseConnection {
    
    private static final String URL = "jdbc:mysql://localhost:3306/red_bull_spielberg?useSSL=false&serverTimezone=Europe/Rome&allowPublicKeyRetrieval=true";
    private static final String USERNAME = "root";
    private static final String PASSWORD = "RedBull2025!"; // La tua password MySQL
    private static final String DRIVER = "com.mysql.cj.jdbc.Driver";
    
    private static DatabaseConnection instance;
    private Connection connection;
    
    /**
     * Costruttore privato per implementare Singleton
     */
    private DatabaseConnection() {
        try {
            Class.forName(DRIVER);
            this.connection = DriverManager.getConnection(URL, USERNAME, PASSWORD);
            System.out.println("Connessione al database stabilita con successo!");
        } catch (ClassNotFoundException e) {
            System.err.println("Driver MySQL non trovato: " + e.getMessage());
        } catch (SQLException e) {
            System.err.println("Errore nella connessione al database: " + e.getMessage());
        }
    }
    
    /**
     * Metodo per ottenere l'istanza della connessione (Singleton)
     * @return istanza di DatabaseConnection
     */
    public static synchronized DatabaseConnection getInstance() {
        if (instance == null) {
            instance = new DatabaseConnection();
        }
        return instance;
    }
    
    /**
     * Metodo per ottenere la connessione al database
     * @return Connection object
     * @throws SQLException se la connessione non è disponibile
     */
    public Connection getConnection() throws SQLException {
        if (connection == null || connection.isClosed()) {
            connection = DriverManager.getConnection(URL, USERNAME, PASSWORD);
        }
        return connection;
    }
    
    /**
     * Metodo per chiudere la connessione
     */
    public void closeConnection() {
        try {
            if (connection != null && !connection.isClosed()) {
                connection.close();
                System.out.println("Connessione al database chiusa.");
            }
        } catch (SQLException e) {
            System.err.println("Errore nella chiusura della connessione: " + e.getMessage());
        }
    }
}