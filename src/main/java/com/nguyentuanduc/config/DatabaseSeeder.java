package com.nguyentuanduc.config;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import com.nguyentuanduc.entity.*;
import com.nguyentuanduc.repository.*;

import java.math.BigDecimal;
import java.util.*;

@Component
@RequiredArgsConstructor
@Slf4j
public class DatabaseSeeder implements CommandLineRunner {

    private final CategoryRepository categoryRepository;
    private final ProductRepository productRepository;
    private final ProductCategoryRepository productCategoryRepository;
    private final TagRepository tagRepository;
    private final ProductTagRepository productTagRepository;
    private final ProductReviewRepository productReviewRepository;
    private final OrderItemRepository orderItemRepository;
    private final OrderRepository orderRepository;
    private final CartItemRepository cartItemRepository;
    private final CartRepository cartRepository;

    @Override
    @Transactional
    public void run(String... args) {
        if (categoryRepository.count() > 0 && productRepository.count() >= 120) {
            log.info("Dữ liệu danh mục và sản phẩm đã đầy đủ (Tops đã được mở rộng), bỏ qua seeding.");
            return;
        }
        log.info("Cơ sở dữ liệu chưa đầy đủ hoặc trống, bắt đầu dọn dẹp dữ liệu cũ để seed mới...");
        orderItemRepository.deleteAll();
        orderRepository.deleteAll();
        cartItemRepository.deleteAll();
        cartRepository.deleteAll();
        productReviewRepository.deleteAll();
        productCategoryRepository.deleteAll();
        productTagRepository.deleteAll();
        productRepository.deleteAll();
        categoryRepository.deleteAll();
        tagRepository.deleteAll();
        
        // Bắt buộc Hibernate thực hiện các câu lệnh DELETE xuống Database trước khi chạy INSERT
        categoryRepository.flush();

        log.info("Bắt đầu khởi tạo dữ liệu mẫu...");
        seedCategories();
        log.info("Hoàn thành khởi tạo dữ liệu mẫu!");
    }

    private void seedCategories() {
        // === Level 1: Root categories ===
        Category women = createCategory("Women", "women", null, null);
        Category men = createCategory("Men", "men", null, null);
        Category kids = createCategory("Kids", "kids", null, null);

        // === Seed Women Category Tree ===
        seedCategoryTree(women, "women");

        // === Seed Men Category Tree ===
        seedCategoryTree(men, "men");

        // === Seed Kids Category Tree ===
        seedCategoryTree(kids, "kids");

        // === Seed Old Products (restores assets/images) ===
        Category tops = categoryRepository.findBySlug("women-clothes-tops").orElse(null);
        Category shirtsBlouses = categoryRepository.findBySlug("women-clothes-shirts-blouses").orElse(null);
        Category knitwear = categoryRepository.findBySlug("women-clothes-knitwear").orElse(null);
        Category dresses = categoryRepository.findBySlug("women-clothes-dresses").orElse(null);

        seedOldProducts(women, men, kids, tops, shirtsBlouses, knitwear, dresses);
    }

    private void seedCategoryTree(Category root, String prefix) {
        Category newCat = createCategory("New", prefix + "-new", root, "assets/images/Pasted image (10).png");
        Category clothes = createCategory("Clothes", prefix + "-clothes", root, "assets/images/Pasted image (11).png");
        Category shoes = createCategory("Shoes", prefix + "-shoes", root, "assets/images/Pasted image (12).png");
        Category accessories = createCategory("Accessories", prefix + "-accessories", root,
                "assets/images/Pasted image (13).png");

        Category tops = createCategory("Tops", prefix + "-clothes-tops", clothes, null);
        Category shirtsBlouses = createCategory("Shirts & Blouses", prefix + "-clothes-shirts-blouses", clothes, null);
        Category cardigansSweaters = createCategory("Cardigans & Sweaters", prefix + "-clothes-cardigans-sweaters",
                clothes, null);
        Category knitwear = createCategory("Knitwear", prefix + "-clothes-knitwear", clothes, null);
        Category blazers = createCategory("Blazers", prefix + "-clothes-blazers", clothes, null);
        Category outerwear = createCategory("Outerwear", prefix + "-clothes-outerwear", clothes, null);
        Category pants = createCategory("Pants", prefix + "-clothes-pants", clothes, null);
        Category jeans = createCategory("Jeans", prefix + "-clothes-jeans", clothes, null);
        Category shorts = createCategory("Shorts", prefix + "-clothes-shorts", clothes, null);
        Category skirts = createCategory("Skirts", prefix + "-clothes-skirts", clothes, null);
        Category dresses = createCategory("Dresses", prefix + "-clothes-dresses", clothes, null);

        // Seed products
        String suffix = prefix.substring(0, 1).toUpperCase() + prefix.substring(1); // e.g. "Women", "Men", "Kids"
        seedBlankProducts(shoes, "Giày " + suffix, "Shoes", 4);
        seedBlankProducts(accessories, "Phụ kiện " + suffix, "Accessories", 4);
        seedBlankProducts(tops, "Áo Tops " + suffix, "Tops", 12);
        seedBlankProducts(shirtsBlouses, "Áo sơ mi/Blouse " + suffix, "Shirts & Blouses", 2);
        seedBlankProducts(cardigansSweaters, "Áo len cardigan " + suffix, "Cardigans & Sweaters", 2);
        seedBlankProducts(knitwear, "Đồ dệt kim " + suffix, "Knitwear", 2);
        seedBlankProducts(blazers, "Áo khoác blazer " + suffix, "Blazers", 2);
        seedBlankProducts(outerwear, "Áo khoác ngoài " + suffix, "Outerwear", 2);
        seedBlankProducts(pants, "Quần dài " + suffix, "Pants", 2);
        seedBlankProducts(jeans, "Quần jeans " + suffix, "Jeans", 2);
        seedBlankProducts(shorts, "Quần shorts " + suffix, "Shorts", 2);
        seedBlankProducts(skirts, "Chân váy " + suffix, "Skirts", 2);
        seedBlankProducts(dresses, "Váy đầm " + suffix, "Dresses", 2);
    }

    private void seedBlankProducts(Category cat, String typeName, String catName, int count) {
        String rootName = typeName.substring(typeName.lastIndexOf(" ") + 1);
        String[] brands = { "Zara", "H&M", "Mango", "UNIQLO", "Adidas", "Dorothy Perkins" };
        double[] prices = { 25.0, 39.0, 45.0, 59.0, 69.0, 89.0 };

        for (int i = 1; i <= count; i++) {
            String name = getProductEnglishName(rootName, catName, i);
            String image = getProductLocalImage(rootName, catName, i);
            String desc = getProductEnglishDescription(rootName, catName, name);

            String brand = brands[(i - 1) % brands.length];
            double price = prices[(i - 1) % prices.length];
            Double comparePrice = null;
            Integer discountPercent = null;

            // Randomly make one sale product and one new product
            if (i == 2) {
                discountPercent = 20;
                comparePrice = Math.round(price / 0.8 * 10.0) / 10.0;
            }
            boolean isNew = (i == 1);

            createProduct(name, brand, price, comparePrice, discountPercent, isNew, image,
                    List.of("black", "white"), List.of("S", "M", "L"), desc, cat);
        }
    }

    private String getProductEnglishName(String rootName, String catName, int index) {
        switch (catName) {
            case "Shoes":
                if (index == 1)
                    return rootName + " Casual Sneakers";
                if (index == 2)
                    return rootName + " Running Shoes";
                if (index == 3)
                    return rootName + " Leather Shoes";
                return rootName + " Winter Boots";
            case "Accessories":
                if (index == 1)
                    return rootName + " Stylish Backpack";
                if (index == 2)
                    return rootName + " Leather Belt";
                if (index == 3)
                    return rootName + " Classic Sunglasses";
                return rootName + " Knit Scarf";
            case "Tops":
                {
                    String[] topNames = {
                        "Summer Tee", "Sport Tank Top", "Casual T-Shirt", "Crop Top",
                        "Sleeveless Top", "V-Neck Tee", "Graphic Tee", "Lace Trim Cami",
                        "Ribbed Tank Top", "Off-Shoulder Top", "Chiffon Cami", "Halter Neck Top"
                    };
                    if (index >= 1 && index <= topNames.length) {
                        return rootName + " " + topNames[index - 1];
                    }
                    return rootName + " Tops Item " + index;
                }
            case "Shirts & Blouses":
                return index == 1 ? rootName + " Cotton Shirt" : rootName + " Silk Blouse";
            case "Cardigans & Sweaters":
                return index == 1 ? rootName + " Knitted Cardigan" : rootName + " Wool Sweater";
            case "Knitwear":
                return index == 1 ? rootName + " Fine Knit Top" : rootName + " Cable Knit Pullover";
            case "Blazers":
                return index == 1 ? rootName + " Modern Fit Blazer" : rootName + " Casual Blazer Jacket";
            case "Outerwear":
                return index == 1 ? rootName + " Classic Trench Coat" : rootName + " Lightweight Windbreaker";
            case "Pants":
                return index == 1 ? rootName + " Slim Chino Pants" : rootName + " Classic Trousers";
            case "Jeans":
                return index == 1 ? rootName + " Denim Skinny Jeans" : rootName + " Straight Fit Jeans";
            case "Shorts":
                return index == 1 ? rootName + " Casual Sweat Shorts" : rootName + " Denim Rolled Shorts";
            case "Skirts":
                return index == 1 ? rootName + " High Waist Skirt" : rootName + " Pleated Midi Skirt";
            case "Dresses":
                return index == 1 ? rootName + " Floral Summer Dress" : rootName + " Evening Slip Dress";
            default:
                return rootName + " " + catName + " Item " + index;
        }
    }

    private String getProductLocalImage(String rootName, String catName, int index) {
        switch (catName) {
            case "Shoes":
                if (index == 1)
                    return "assets/images/Pasted image2.png";
                if (index == 2)
                    return "assets/images/Pasted image 1.png";
                if (index == 3)
                    return "assets/images/Pasted image3.png";
                return "assets/images/c8d6cd3c953d61faf9fd666897e97a67e9857028.png";
            case "Accessories":
                return (index % 2 == 1) ? "assets/images/bags.png" : "assets/images/Pasted image (13).png";
            case "Tops":
                {
                    String[] topImages = {
                        "assets/images/6011aa7ae269bb70fd8c136d1d0733c8ce6f245a.png",
                        "assets/images/42ba43af9999902f1278824120c0dec8686180c5.png",
                        "assets/images/1e614675147da579254b3012302de5304dcb0db0.png",
                        "assets/images/d07ce180be1de61431deda2032c364122b021da3.png",
                        "assets/images/744caf4f8cbe22e0d501d66b730b03c24f793383.png",
                        "assets/images/5e938ec8ffc8353c2e4119cf43ecf6db7e381d9d.png",
                        "assets/images/92827a653bcf169c1f1c4b22fc8fc4b86176e01a.png",
                        "assets/images/1770088fbba96a73adb59b4213783033221c4b94.png",
                        "assets/images/538f4b859bcd988842505bc7673b2c97a627a114.png",
                        "assets/images/fcafd16032c84320feb3909ded342aacc494eabc.png",
                        "assets/images/ff48013c2e83ffc52e71ad79aa63042d84df66ea.png",
                        "assets/images/Pasted image (10).png"
                    };
                    if (index >= 1 && index <= topImages.length) {
                        return topImages[index - 1];
                    }
                    return topImages[(index - 1) % topImages.length];
                }
            case "Shirts & Blouses":
                return index == 1 ? "assets/images/744caf4f8cbe22e0d501d66b730b03c24f793383.png"
                        : "assets/images/5e938ec8ffc8353c2e4119cf43ecf6db7e381d9d.png";
            case "Cardigans & Sweaters":
                return index == 1 ? "assets/images/1e614675147da579254b3012302de5304dcb0db0.png"
                        : "assets/images/d07ce180be1de61431deda2032c364122b021da3.png";
            case "Knitwear":
                return index == 1 ? "assets/images/d07ce180be1de61431deda2032c364122b021da3.png"
                        : "assets/images/1e614675147da579254b3012302de5304dcb0db0.png";
            case "Blazers":
                return "assets/images/fcafd16032c84320feb3909ded342aacc494eabc.png";
            case "Outerwear":
                return index == 1 ? "assets/images/fcafd16032c84320feb3909ded342aacc494eabc.png"
                        : "assets/images/e7a1cf4575298675ac8011fa936bb38323557b85.png";
            case "Pants":
            case "Jeans":
                return "assets/images/nu_quandaitrang.png";
            case "Shorts":
                return "assets/images/sport_dress.png";
            case "Skirts":
                return "assets/images/nu_vayden.png";
            case "Dresses":
                return index == 1 ? "assets/images/fa116ce95fe27c6f7b496e811aa346d85d4408ce.png"
                        : "assets/images/b694c87f2961d9881ed06f1fd8d506c7100ba82c.png";
            default:
                return "assets/images/Pasted image (10).png";
        }
    }

    private String getProductEnglishDescription(String rootName, String catName, String name) {
        return "This high-quality " + name + " from our " + rootName
                + " collection features premium materials and a comfortable, modern fit. Perfect for all seasons.";
    }

    private void seedOldProducts(Category women, Category men, Category kids, Category tops, Category shirtsBlouses,
            Category knitwear, Category dresses) {
        // T-Shirt Sailing
        createProductWithCategories("T-Shirt Sailing", "Mango Boy", 10.0, 22.0, 20, false,
                "assets/images/6011aa7ae269bb70fd8c136d1d0733c8ce6f245a.png",
                List.of("black", "red", "blue"), List.of("S", "M", "L", "XL"),
                "Short dress in soft cotton jersey with decorative buttons down the front and a wide, frill-trimmed square neckline with concealed elastication.",
                List.of(women, tops));

        // Longsleeve Violeta
        createProductWithCategories("Longsleeve Violeta", "Longsleeve", 46.0, null, null, true,
                "assets/images/1e614675147da579254b3012302de5304dcb0db0.png",
                List.of("orange", "black", "blue"), List.of("S", "M", "L"),
                "Long-sleeved top in soft, fine-knit fabric with a V-neck and narrow ribbing at the cuffs and hem.",
                List.of(women, knitwear));

        // T-Shirt SPANISH
        createProductWithCategories("T-Shirt SPANISH", "Mango Boy", 9.0, 21.0, 30, false,
                "assets/images/42ba43af9999902f1278824120c0dec8686180c5.png",
                List.of("grey", "black"), List.of("S", "M", "L", "XL"),
                "Relaxed-fit T-shirt in soft cotton jersey with a round neckline and straight-cut hem.",
                List.of(women, tops));

        // Blouse
        createProductWithCategories("Blouse", "Dorothy Perkins", 34.0, 46.0, 25, false,
                "assets/images/5e938ec8ffc8353c2e4119cf43ecf6db7e381d9d.png",
                List.of("black", "white", "pink"), List.of("XS", "S", "M", "L"),
                "V-neck blouse in airy crêpe with a small stand-up collar.",
                List.of(women, shirtsBlouses));

        // Shirt
        createProductWithCategories("Shirt", "LIME", 12.0, 18.0, 30, false,
                "assets/images/744caf4f8cbe22e0d501d66b730b03c24f793383.png",
                List.of("blue", "white"), List.of("S", "M", "L"),
                "Relaxed-fit shirt in washed linen with a turn-down collar and classic placket.",
                List.of(men));

        // Short Black Dress
        createProductWithCategories("Short Black Dress", "H&M", 19.0, 32.0, 40, false,
                "assets/images/6e2a6075d2aebb9b52db31deea621f309362bab4.png",
                List.of("red", "black", "blue"), List.of("XS", "S", "M", "L", "XL"),
                "Short dress in soft cotton jersey with decorative buttons down the front.",
                List.of(women, dresses));

        // Sport Dress
        createProductWithCategories("Sport Dress", "Sitlly", 19.0, 22.0, 15, false,
                "assets/images/sport_dress.png",
                List.of("green", "black"), List.of("S", "M", "L"),
                "Sport dress in quick-drying fabric with a round neckline.",
                List.of(kids, dresses));

        // Evening Dress
        createProductWithCategories("Evening Dress", "Dorothy Perkins", 12.0, 15.0, 20, false,
                "assets/images/b694c87f2961d9881ed06f1fd8d506c7100ba82c.png",
                List.of("black", "deepPurple"), List.of("S", "M", "L"),
                "Fitted, calf-length dress in jersey with a draped cowl neck.",
                List.of(women, dresses));

        // Pullover
        createProductWithCategories("Pullover", "Mango", 51.0, null, null, true,
                "assets/images/d07ce180be1de61431deda2032c364122b021da3.png",
                List.of("brown", "grey", "black"), List.of("M", "L", "XL"),
                "Oversized pullover in soft, fine-knit cotton fabric.",
                List.of(men));

        // Light Blouse
        createProductWithCategories("Light Blouse", "OVS", 30.0, null, null, true,
                "assets/images/92827a653bcf169c1f1c4b22fc8fc4b86176e01a.png",
                List.of("white", "pink"), List.of("XS", "S", "M"),
                "Long-sleeved blouse in airy, woven fabric with a round neckline.",
                List.of(women, shirtsBlouses));
    }

    private Category createCategory(String name, String slug, Category parent, String imageUrl) {
        Category category = Category.builder()
                .categoryName(name)
                .slug(slug)
                .parent(parent)
                .imageUrl(imageUrl)
                .active(true)
                .build();
        return categoryRepository.save(category);
    }

    private Product createProduct(String name, String brand, double price, Double comparePrice,
            Integer discountPercent, boolean isNew, String imageUrl,
            List<String> colors, List<String> sizes, String description,
            Category category) {
        String slug = name.toLowerCase().replaceAll("[^a-z0-9\\s]", "").replaceAll("\\s+", "-")
                + "-" + UUID.randomUUID().toString().substring(0, 8);

        Product product = Product.builder()
                .productName(name)
                .slug(slug)
                .brand(brand)
                .salePrice(BigDecimal.valueOf(price))
                .comparePrice(comparePrice != null ? BigDecimal.valueOf(comparePrice) : BigDecimal.ZERO)
                .quantity(100)
                .shortDescription(description.length() > 160 ? description.substring(0, 160) : description)
                .productDescription(description)
                .imageUrls(imageUrl != null ? List.of(imageUrl) : List.of()) // sets to empty list if null
                .colors(colors)
                .sizes(sizes)
                .rating(3.0 + Math.random() * 2.0)
                .reviewCount((int) (Math.random() * 30) + 1)
                .isNew(isNew)
                .discountPercent(discountPercent)
                .productType("simple")
                .published(true)
                .disableOutOfStock(true)
                .build();

        Product saved = productRepository.save(product);

        // Link product to category
        ProductCategory pc = ProductCategory.builder()
                .product(saved)
                .category(category)
                .build();
        productCategoryRepository.save(pc);

        linkNewCategoryIfApplicable(saved, category);

        // Add tags
        if (isNew) {
            Tag newTag = tagRepository.findByTagNameIgnoreCase("New")
                    .orElseGet(() -> tagRepository.save(Tag.builder().tagName("New").build()));
            productTagRepository.save(ProductTag.builder().productId(saved.getId()).tagId(newTag.getId()).build());
        }
        if (discountPercent != null && discountPercent > 0) {
            Tag saleTag = tagRepository.findByTagNameIgnoreCase("Sale")
                    .orElseGet(() -> tagRepository.save(Tag.builder().tagName("Sale").build()));
            productTagRepository.save(ProductTag.builder().productId(saved.getId()).tagId(saleTag.getId()).build());
        }

        return saved;
    }

    private Product createProductWithCategories(String name, String brand, double price, Double comparePrice,
            Integer discountPercent, boolean isNew, String imageUrl,
            List<String> colors, List<String> sizes, String description,
            List<Category> categories) {
        String slug = name.toLowerCase().replaceAll("[^a-z0-9\\s]", "").replaceAll("\\s+", "-")
                + "-" + UUID.randomUUID().toString().substring(0, 8);

        Product product = Product.builder()
                .productName(name)
                .slug(slug)
                .brand(brand)
                .salePrice(BigDecimal.valueOf(price))
                .comparePrice(comparePrice != null ? BigDecimal.valueOf(comparePrice) : BigDecimal.ZERO)
                .quantity(100)
                .shortDescription(description.length() > 160 ? description.substring(0, 160) : description)
                .productDescription(description)
                .imageUrls(imageUrl != null ? List.of(imageUrl) : List.of())
                .colors(colors)
                .sizes(sizes)
                .rating(3.0 + Math.random() * 2.0)
                .reviewCount((int) (Math.random() * 30) + 1)
                .isNew(isNew)
                .discountPercent(discountPercent)
                .productType("simple")
                .published(true)
                .disableOutOfStock(true)
                .build();

        Product saved = productRepository.save(product);

        for (Category category : categories) {
            ProductCategory pc = ProductCategory.builder()
                    .product(saved)
                    .category(category)
                    .build();
            productCategoryRepository.save(pc);
        }

        if (!categories.isEmpty()) {
            linkNewCategoryIfApplicable(saved, categories.get(0));
        }

        if (isNew) {
            Tag newTag = tagRepository.findByTagNameIgnoreCase("New")
                    .orElseGet(() -> tagRepository.save(Tag.builder().tagName("New").build()));
            productTagRepository.save(ProductTag.builder().productId(saved.getId()).tagId(newTag.getId()).build());
        }
        if (discountPercent != null && discountPercent > 0) {
            Tag saleTag = tagRepository.findByTagNameIgnoreCase("Sale")
                    .orElseGet(() -> tagRepository.save(Tag.builder().tagName("Sale").build()));
            productTagRepository.save(ProductTag.builder().productId(saved.getId()).tagId(saleTag.getId()).build());
        }

        return saved;
    }

    private void linkNewCategoryIfApplicable(Product product, Category category) {
        if (Boolean.TRUE.equals(product.getIsNew())) {
            Category root = category;
            while (root.getParent() != null) {
                root = root.getParent();
            }
            String newSlug = root.getSlug() + "-new";
            categoryRepository.findBySlug(newSlug).ifPresent(newCat -> {
                ProductCategory pc = ProductCategory.builder()
                        .product(product)
                        .category(newCat)
                        .build();
                productCategoryRepository.save(pc);
            });
        }
    }
}
