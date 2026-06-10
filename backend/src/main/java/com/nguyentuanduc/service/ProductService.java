package com.nguyentuanduc.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.nguyentuanduc.dto.request.ProductCreateRequest;
import com.nguyentuanduc.dto.request.ProductUpdateRequest;
import com.nguyentuanduc.dto.response.ProductResponse;
import com.nguyentuanduc.entity.Category;
import com.nguyentuanduc.entity.Product;
import com.nguyentuanduc.entity.ProductCategory;
import com.nguyentuanduc.entity.ProductTag;
import com.nguyentuanduc.entity.Tag;
import com.nguyentuanduc.repository.CategoryRepository;
import com.nguyentuanduc.repository.ProductCategoryRepository;
import com.nguyentuanduc.repository.ProductRepository;
import com.nguyentuanduc.repository.ProductTagRepository;
import com.nguyentuanduc.repository.TagRepository;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ProductService {

    private final ProductRepository productRepository;
    private final ProductCategoryRepository productCategoryRepository;
    private final TagRepository tagRepository;
    private final ProductTagRepository productTagRepository;
    private final CategoryRepository categoryRepository;

    public List<ProductResponse> getAllProducts() {
        return productRepository.findAll().stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    public List<ProductResponse> getNewProducts() {
        return productRepository.findByIsNewTrue().stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    public List<ProductResponse> getSaleProducts() {
        return productRepository.findSaleProducts().stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    public List<ProductResponse> getProductsByCategoryId(UUID categoryId) {
        List<UUID> categoryIds = new java.util.ArrayList<>();
        collectCategoryIdsRecursively(categoryId, categoryIds);
        if (categoryIds.isEmpty()) {
            return new java.util.ArrayList<>();
        }
        return productRepository.findByCategoryIds(categoryIds).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    private void collectCategoryIdsRecursively(UUID categoryId, List<UUID> categoryIds) {
        categoryIds.add(categoryId);
        List<Category> children = categoryRepository.findByParentIdAndActiveTrue(categoryId);
        for (Category child : children) {
            collectCategoryIdsRecursively(child.getId(), categoryIds);
        }
    }

    public List<ProductResponse> getProductsByCategory(String categoryName) {
        return productRepository.findByCategoryName(categoryName).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    public ProductResponse getProductById(UUID id) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy sản phẩm với ID: " + id));
        return mapToResponse(product);
    }

    @Transactional
    public ProductResponse updateProduct(UUID id, ProductUpdateRequest request) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy sản phẩm với ID: " + id));

        // 1. Cập nhật thông tin cơ bản
        if (request.getProductName() != null)
            product.setProductName(request.getProductName());
        if (request.getBrand() != null)
            product.setBrand(request.getBrand());
        if (request.getSalePrice() != null)
            product.setSalePrice(request.getSalePrice());
        if (request.getComparePrice() != null)
            product.setComparePrice(request.getComparePrice());
        if (request.getShortDescription() != null)
            product.setShortDescription(request.getShortDescription());
        if (request.getProductDescription() != null)
            product.setProductDescription(request.getProductDescription());

        // 2. Xử lý cập nhật Tags & thuộc tính New/Sale đi kèm
        if (request.getTags() != null) {
            // Xóa hết tags cũ của sản phẩm này trong database
            productTagRepository.deleteByProductId(product.getId());

            List<String> newTags = request.getTags();
            boolean isNew = false;
            boolean isSale = false;

            for (String tagName : newTags) {
                if ("New".equalsIgnoreCase(tagName)) {
                    isNew = true;
                }
                if ("Sale".equalsIgnoreCase(tagName)) {
                    isSale = true;
                }

                // Tìm hoặc tạo Tag tương ứng
                Tag tag = tagRepository.findByTagNameIgnoreCase(tagName)
                        .orElseGet(() -> tagRepository.save(Tag.builder().tagName(tagName).build()));

                // Lưu mối quan hệ ProductTag mới
                ProductTag productTag = ProductTag.builder()
                        .productId(product.getId())
                        .tagId(tag.getId())
                        .build();
                productTagRepository.save(productTag);
            }

            // Đồng bộ hoá thuộc tính New
            product.setIsNew(isNew);

            // Đồng bộ hoá thuộc tính Sale (discountPercent & comparePrice)
            if (isSale) {
                Integer disc = request.getDiscountPercent();
                if (disc == null || disc <= 0) {
                    disc = 20; // Mặc định giảm giá 20%
                }
                product.setDiscountPercent(disc);

                // Tự động tính toán comparePrice (giá cũ trước khi giảm) nếu không truyền vào
                if (request.getComparePrice() == null
                        || request.getComparePrice().compareTo(java.math.BigDecimal.ZERO) == 0) {
                    double factor = 1.0 - (disc / 100.0);
                    if (factor > 0 && product.getSalePrice() != null) {
                        double calculatedComparePrice = product.getSalePrice().doubleValue() / factor;
                        product.setComparePrice(java.math.BigDecimal.valueOf(Math.round(calculatedComparePrice)));
                    }
                }
            } else {
                product.setDiscountPercent(null);
                product.setComparePrice(java.math.BigDecimal.ZERO); // Đặt về 0 phù hợp ràng buộc CHECK
            }
        } else if (request.getDiscountPercent() != null) {
            // Trường hợp không truyền tags nhưng có truyền discountPercent
            product.setDiscountPercent(request.getDiscountPercent());
        }

        Product savedProduct = productRepository.save(product);
        return mapToResponse(savedProduct);
    }

    @Transactional
    public ProductResponse createProduct(ProductCreateRequest request) {
        // 1. Tạo slug ngẫu nhiên từ tên sản phẩm để tránh trùng lặp
        String baseSlug = request.getProductName().toLowerCase()
                .replaceAll("[^a-z0-9\\s]", "")
                .replaceAll("\\s+", "-");
        String slug = baseSlug + "-" + UUID.randomUUID().toString().substring(0, 8);

        // 2. Tạo đối tượng Product
        Product product = Product.builder()
                .productName(request.getProductName())
                .slug(slug)
                .brand(request.getBrand())
                .salePrice(request.getSalePrice())
                .comparePrice(request.getComparePrice())
                .quantity(100) // mặc định có sẵn 100 sản phẩm
                .shortDescription(request.getShortDescription())
                .productDescription(request.getProductDescription())
                .imageUrls(request.getImageUrls() != null ? request.getImageUrls() : new java.util.ArrayList<>())
                .colors(request.getColors() != null ? request.getColors() : new java.util.ArrayList<>())
                .sizes(request.getSizes() != null ? request.getSizes() : new java.util.ArrayList<>())
                .productType("simple")
                .published(true)
                .disableOutOfStock(true)
                .build();

        // 3. Xử lý logic nhãn dán tags (New/Sale)
        boolean isNew = false;
        boolean isSale = false;
        List<Tag> associatedTags = new java.util.ArrayList<>();

        if (request.getTags() != null) {
            for (String tagName : request.getTags()) {
                if ("New".equalsIgnoreCase(tagName))
                    isNew = true;
                if ("Sale".equalsIgnoreCase(tagName))
                    isSale = true;

                Tag tag = tagRepository.findByTagNameIgnoreCase(tagName)
                        .orElseGet(() -> tagRepository.save(Tag.builder().tagName(tagName).build()));
                associatedTags.add(tag);
            }
        }

        product.setIsNew(isNew);

        if (isSale) {
            Integer disc = request.getDiscountPercent();
            if (disc == null || disc <= 0)
                disc = 20; // Mặc định 20%
            product.setDiscountPercent(disc);

            if (request.getComparePrice() == null
                    || request.getComparePrice().compareTo(java.math.BigDecimal.ZERO) == 0) {
                double factor = 1.0 - (disc / 100.0);
                if (factor > 0 && product.getSalePrice() != null) {
                    double calculatedComparePrice = product.getSalePrice().doubleValue() / factor;
                    product.setComparePrice(java.math.BigDecimal.valueOf(Math.round(calculatedComparePrice)));
                }
            }
        } else {
            product.setDiscountPercent(null);
            product.setComparePrice(java.math.BigDecimal.ZERO);
        }

        Product savedProduct = productRepository.save(product);

        // 4. Lưu liên kết Danh mục (ProductCategory)
        String catName = request.getCategoryName();
        if (catName != null && !catName.isEmpty()) {
            Category category = categoryRepository.findByCategoryNameIgnoreCase(catName)
                    .orElseGet(() -> categoryRepository.save(
                            Category.builder()
                                    .categoryName(catName)
                                    .slug(catName.toLowerCase().replaceAll("\\s+", "-"))
                                    .build()));
            ProductCategory productCategory = ProductCategory.builder()
                    .product(savedProduct)
                    .category(category)
                    .build();
            productCategoryRepository.save(productCategory);
        }

        // 5. Lưu các liên kết nhãn dán (ProductTag)
        for (Tag tag : associatedTags) {
            ProductTag productTag = ProductTag.builder()
                    .productId(savedProduct.getId())
                    .tagId(tag.getId())
                    .build();
            productTagRepository.save(productTag);
        }

        return mapToResponse(savedProduct);
    }

    private ProductResponse mapToResponse(Product product) {
        String categoryName = productCategoryRepository.findByProductId(product.getId()).stream()
                .findFirst()
                .map(pc -> pc.getCategory().getCategoryName())
                .orElse("");

        return ProductResponse.builder()
                .id(product.getId().toString())
                .name(product.getProductName())
                .brand(product.getBrand())
                .price(product.getSalePrice() != null ? product.getSalePrice().doubleValue() : 0.0)
                .originalPrice(product.getComparePrice() != null ? product.getComparePrice().doubleValue() : null)
                .imageUrls(product.getImageUrls())
                .colors(product.getColors())
                .sizes(product.getSizes())
                .rating(product.getRating())
                .reviewCount(product.getReviewCount())
                .isNew(product.getIsNew())
                .discountPercent(product.getDiscountPercent())
                .category(categoryName)
                .description(product.getProductDescription())
                .isFavorite(false) // Mặc định false, logic yêu thích sẽ xử lý ở client hoặc bảng riêng sau
                .build();
    }
}
