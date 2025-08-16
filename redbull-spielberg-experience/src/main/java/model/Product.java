package model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class Product {

    private Integer productId;
    private Integer categoryId;
    private String name;
    private String description;
    private String shortDescription;
    private BigDecimal price;
    private ProductType productType;          // EXPERIENCE | MERCHANDISE
    private ExperienceType experienceType;    // BASE | PREMIUM | ELITE | null
    private Integer stockQuantity;            // null per EXPERIENCE
    private String imageUrl;
    private Boolean featured;
    private Boolean active;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public enum ProductType {
        EXPERIENCE, MERCHANDISE
    }

    public enum ExperienceType {
        BASE, PREMIUM, ELITE
    }

    // Getters/Setters
    public Integer getProductId() { return productId; }
    public void setProductId(Integer productId) { this.productId = productId; }

    public Integer getCategoryId() { return categoryId; }
    public void setCategoryId(Integer categoryId) { this.categoryId = categoryId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getShortDescription() { return shortDescription; }
    public void setShortDescription(String shortDescription) { this.shortDescription = shortDescription; }

    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }

    public ProductType getProductType() { return productType; }
    public void setProductType(ProductType productType) { this.productType = productType; }

    public ExperienceType getExperienceType() { return experienceType; }
    public void setExperienceType(ExperienceType experienceType) { this.experienceType = experienceType; }

    public Integer getStockQuantity() { return stockQuantity; }
    public void setStockQuantity(Integer stockQuantity) { this.stockQuantity = stockQuantity; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public Boolean getFeatured() { return featured; }
    public void setFeatured(Boolean featured) { this.featured = featured; }

    public Boolean getActive() { return active; }
    public void setActive(Boolean active) { this.active = active; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}