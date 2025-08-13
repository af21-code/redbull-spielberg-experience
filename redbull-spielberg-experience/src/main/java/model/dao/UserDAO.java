package model.dao;

import model.User;

public interface UserDAO {
    boolean existsByEmail(String email) throws Exception;
    User findByEmail(String email) throws Exception;

    // <- AGGIUNTO: salva un nuovo utente e ritorna l'utente con ID valorizzato
    User save(User user) throws Exception;
}