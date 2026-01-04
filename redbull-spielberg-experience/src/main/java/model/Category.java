package model;

import java.time.LocalDateTime;

public class Category {
    private int categoryId;
    private String name;
    private String description;
    private boolean isActive;
    private LocalDateTime createdAt;

    public Category() {
        this.isActive = true;
        this.createdAt = LocalDateTime.now();
    }

    public Category(int categoryId, String name, String description, boolean isActive, LocalDateTime createdAt) {
        this.categoryId = categoryId;
        this.name = name;
        this.description = description;
        this.isActive = isActive;
        this.createdAt = createdAt;
    }

    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public boolean isActive() {
        return isActive;
    }

    public void setActive(boolean active) {
        isActive = active;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
