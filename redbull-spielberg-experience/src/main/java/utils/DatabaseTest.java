package utils;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

/**
 * Classe per testare la connessione al database
 */
public class DatabaseTest {
    
    public static void main(String[] args) {
        System.out.println("Testing database connection...");
        
        try {
            // Test connessione usando DatabaseConnection
            DatabaseConnection dbConnection = DatabaseConnection.getInstance();
            Connection connection = dbConnection.getConnection();
            
            if (connection != null && !connection.isClosed()) {
                System.out.println("✅ Connessione al database stabilita con successo!");
                
                // Test query
                Statement statement = connection.createStatement();
                ResultSet resultSet = statement.executeQuery("SELECT COUNT(*) as count FROM users");
                
                if (resultSet.next()) {
                    int userCount = resultSet.getInt("count");
                    System.out.println("✅ Query test eseguita: trovati " + userCount + " utenti nel database");
                }
                
                // Test dati di esempio
                resultSet = statement.executeQuery("SELECT name, price FROM products LIMIT 3");
                System.out.println("\n📦 Prodotti di esempio:");
                while (resultSet.next()) {
                    String name = resultSet.getString("name");
                    double price = resultSet.getDouble("price");
                    System.out.println("- " + name + " - €" + price);
                }
                
                resultSet.close();
                statement.close();
                
            } else {
                System.out.println("❌ Errore: connessione al database non disponibile");
            }
            
        } catch (Exception e) {
            System.out.println("❌ Errore durante il test della connessione:");
            e.printStackTrace();
        }
        
        System.out.println("\nTest completato!");
    }
}