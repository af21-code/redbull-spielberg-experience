package model.dao;

import model.User;

public interface UserDAO {
    boolean existsByEmail(String email) throws Exception;
    User findByEmail(String email) throws Exception;

    // <- AGGIUNTO: salva un nuovo utente e ritorna l'utente con ID valorizzato
    User save(User user) throws Exception;

    // Aggiunte le operazioni per aggiornare password e disattivare account
    boolean updatePassword(int userId, String hashedPassword) throws Exception;
    boolean deactivateById(int userId) throws Exception;

    // Aggiunto metodo per aggiornare i dati anagrafici del profilo
    boolean updateProfile(int userId, String firstName, String lastName, String phoneNumber) throws Exception;
}