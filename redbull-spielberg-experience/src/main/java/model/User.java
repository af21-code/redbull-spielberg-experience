package model;

import java.time.LocalDateTime;

/**
 * Classe modello per rappresentare un utente del sistema
 */
public class User {
    
    private int userId;
    private String email;
    private String password;
    private String firstName;
    private String lastName;
    private String phoneNumber;
    private UserType userType;
    private LocalDateTime registrationDate;
    private boolean isActive;
    
    /**
     * Enum per definire i tipi di utente
     */
    public enum UserType {
        VISITOR,    // Utente non registrato
        REGISTERED, // Utente registrato
        PREMIUM,    // Cliente Premium
        ADMIN       // Amministratore
    }
    
    // Costruttori
    public User() {
        this.registrationDate = LocalDateTime.now();
        this.isActive = true;
        this.userType = UserType.REGISTERED;
    }
    
    public User(String email, String password, String firstName, String lastName) {
        this();
        this.email = email;
        this.password = password;
        this.firstName = firstName;
        this.lastName = lastName;
    }
    
    public User(int userId, String email, String firstName, String lastName, 
                String phoneNumber, UserType userType, LocalDateTime registrationDate, boolean isActive) {
        this.userId = userId;
        this.email = email;
        this.firstName = firstName;
        this.lastName = lastName;
        this.phoneNumber = phoneNumber;
        this.userType = userType;
        this.registrationDate = registrationDate;
        this.isActive = isActive;
    }
    
    // Getter e Setter
    public int getUserId() {
        return userId;
    }
    
    public void setUserId(int userId) {
        this.userId = userId;
    }
    
    public String getEmail() {
        return email;
    }
    
    public void setEmail(String email) {
        this.email = email;
    }
    
    public String getPassword() {
        return password;
    }
    
    public void setPassword(String password) {
        this.password = password;
    }
    
    public String getFirstName() {
        return firstName;
    }
    
    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }
    
    public String getLastName() {
        return lastName;
    }
    
    public void setLastName(String lastName) {
        this.lastName = lastName;
    }
    
    public String getPhoneNumber() {
        return phoneNumber;
    }
    
    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }
    
    public UserType getUserType() {
        return userType;
    }
    
    public void setUserType(UserType userType) {
        this.userType = userType;
    }
    
    public LocalDateTime getRegistrationDate() {
        return registrationDate;
    }
    
    public void setRegistrationDate(LocalDateTime registrationDate) {
        this.registrationDate = registrationDate;
    }
    
    public boolean isActive() {
        return isActive;
    }
    
    public void setActive(boolean active) {
        isActive = active;
    }
    
    // Metodi utility
    public String getFullName() {
        return firstName + " " + lastName;
    }
    
    public boolean isPremium() {
        return userType == UserType.PREMIUM;
    }
    
    public boolean isAdmin() {
        return userType == UserType.ADMIN;
    }
    
    @Override
    public String toString() {
        return "User{" +
                "userId=" + userId +
                ", email='" + email + '\'' +
                ", firstName='" + firstName + '\'' +
                ", lastName='" + lastName + '\'' +
                ", userType=" + userType +
                ", registrationDate=" + registrationDate +
                ", isActive=" + isActive +
                '}';
    }
}