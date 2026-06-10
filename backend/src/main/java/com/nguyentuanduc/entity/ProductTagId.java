package com.nguyentuanduc.entity;

import java.io.Serializable;
import java.util.Objects;
import java.util.UUID;

public class ProductTagId implements Serializable {
    private UUID tagId;
    private UUID productId;

    public ProductTagId() {
    }

    public ProductTagId(UUID tagId, UUID productId) {
        this.tagId = tagId;
        this.productId = productId;
    }

    public UUID getTagId() {
        return tagId;
    }

    public void setTagId(UUID tagId) {
        this.tagId = tagId;
    }

    public UUID getProductId() {
        return productId;
    }

    public void setProductId(UUID productId) {
        this.productId = productId;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o)
            return true;
        if (o == null || getClass() != o.getClass())
            return false;
        ProductTagId that = (ProductTagId) o;
        return Objects.equals(tagId, that.tagId) && Objects.equals(productId, that.productId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(tagId, productId);
    }
}
