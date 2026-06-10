package com.nguyentuanduc.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import com.nguyentuanduc.entity.*;
import com.nguyentuanduc.repository.*;

import java.math.BigDecimal;
import java.util.*;

//@Component
@RequiredArgsConstructor
@Slf4j
public class DataSeederService implements CommandLineRunner {

        private final CategoryRepository categoryRepository;
        private final TagRepository tagRepository;
        private final ProductRepository productRepository;
        private final ProductCategoryRepository productCategoryRepository;
        private final ProductTagRepository productTagRepository;

        @Override
        @Transactional
        public void run(String... args) throws Exception {
                if (categoryRepository.count() == 0) {
                        seedCategoriesAndProducts();
                }
        }

        private void seedCategoriesAndProducts() {
                log.info("Bắt đầu gieo dữ liệu mẫu cho Categories, Products và Tags...");

                // 1. Gieo Categories
                Category women = Category.builder()
                                .categoryName("Women")
                                .slug("women")
                                .imageUrl("https://picsum.photos/seed/women/400/560")
                                .build();
                Category men = Category.builder()
                                .categoryName("Men")
                                .slug("men")
                                .imageUrl("https://picsum.photos/seed/men/400/560")
                                .build();
                Category kids = Category.builder()
                                .categoryName("Kids")
                                .slug("kids")
                                .imageUrl("https://picsum.photos/seed/kids/400/560")
                                .build();

                women = categoryRepository.save(women);
                men = categoryRepository.save(men);
                kids = categoryRepository.save(kids);

                // 2. Gieo Tags
                Tag tagNew = Tag.builder().tagName("New").icon("new_releases").build();
                Tag tagSale = Tag.builder().tagName("Sale").icon("local_offer").build();

                tagNew = tagRepository.save(tagNew);
                tagSale = tagRepository.save(tagSale);

                // 3. Gieo Products
                List<Product> products = new ArrayList<>();

                // p1
                Product p1 = Product.builder()
                                .productName("T-Shirt Sailing")
                                .slug("t-shirt-sailing")
                                .brand("Mango Boy")
                                .salePrice(BigDecimal.valueOf(10))
                                .comparePrice(BigDecimal.valueOf(22))
                                .quantity(50)
                                .shortDescription("Short dress in soft cotton jersey with decorative buttons")
                                .productDescription(
                                                "Short dress in soft cotton jersey with decorative buttons down the front and a wide, frill-trimmed square neckline with concealed elastication.")
                                .productType("simple")
                                .published(true)
                                .imageUrls(List.of("assets/images/6011aa7ae269bb70fd8c136d1d0733c8ce6f245a.png"))
                                .colors(List.of("black", "red", "blue"))
                                .sizes(List.of("S", "M", "L", "XL"))
                                .rating(3.0)
                                .reviewCount(3)
                                .discountPercent(20)
                                .isNew(false)
                                .build();
                products.add(p1);

                // p2
                Product p2 = Product.builder()
                                .productName("Longsleeve Violeta")
                                .slug("longsleeve-violeta")
                                .brand("Longsleeve")
                                .salePrice(BigDecimal.valueOf(46))
                                .quantity(30)
                                .shortDescription("Long-sleeved top in soft, fine-knit fabric")
                                .productDescription(
                                                "Long-sleeved top in soft, fine-knit fabric with a V-neck and narrow ribbing at the cuffs and hem.")
                                .productType("simple")
                                .published(true)
                                .imageUrls(List.of("assets/images/1e614675147da579254b3012302de5304dcb0db0.png"))
                                .colors(List.of("orange", "black", "blue"))
                                .sizes(List.of("S", "M", "L"))
                                .rating(0.0)
                                .reviewCount(0)
                                .isNew(true)
                                .build();
                products.add(p2);

                // p3
                Product p3 = Product.builder()
                                .productName("T-Shirt SPANISH")
                                .slug("t-shirt-spanish")
                                .brand("Mango Boy")
                                .salePrice(BigDecimal.valueOf(9))
                                .comparePrice(BigDecimal.valueOf(21))
                                .quantity(100)
                                .shortDescription("Relaxed-fit T-shirt in soft cotton jersey")
                                .productDescription(
                                                "Relaxed-fit T-shirt in soft cotton jersey with a round neckline and straight-cut hem.")
                                .productType("simple")
                                .published(true)
                                .imageUrls(List.of("assets/images/42ba43af9999902f1278824120c0dec8686180c5.png"))
                                .colors(List.of("grey", "black"))
                                .sizes(List.of("S", "M", "L", "XL"))
                                .rating(4.5)
                                .reviewCount(10)
                                .discountPercent(30)
                                .isNew(false)
                                .build();
                products.add(p3);

                // p4
                Product p4 = Product.builder()
                                .productName("Blouse")
                                .slug("blouse")
                                .brand("Dorothy Perkins")
                                .salePrice(BigDecimal.valueOf(34))
                                .comparePrice(BigDecimal.valueOf(46))
                                .quantity(40)
                                .shortDescription("V-neck blouse in airy crêpe with stand-up collar")
                                .productDescription("V-neck blouse in airy crêpe with a small stand-up collar.")
                                .productType("simple")
                                .published(true)
                                .imageUrls(List.of("assets/images/5e938ec8ffc8353c2e4119cf43ecf6db7e381d9d.png"))
                                .colors(List.of("black", "white", "pink"))
                                .sizes(List.of("XS", "S", "M", "L"))
                                .rating(5.0)
                                .reviewCount(23)
                                .discountPercent(25)
                                .isNew(false)
                                .build();
                products.add(p4);

                // p5
                Product p5 = Product.builder()
                                .productName("Shirt")
                                .slug("shirt")
                                .brand("LIME")
                                .salePrice(BigDecimal.valueOf(12))
                                .comparePrice(BigDecimal.valueOf(18))
                                .quantity(25)
                                .shortDescription("Relaxed-fit shirt in washed linen")
                                .productDescription(
                                                "Relaxed-fit shirt in washed linen with a turn-down collar and classic placket.")
                                .productType("simple")
                                .published(true)
                                .imageUrls(List.of("assets/images/744caf4f8cbe22e0d501d66b730b03c24f793383.png"))
                                .colors(List.of("blue", "white"))
                                .sizes(List.of("S", "M", "L"))
                                .rating(4.0)
                                .reviewCount(7)
                                .discountPercent(30)
                                .isNew(false)
                                .build();
                products.add(p5);

                // p6
                Product p6 = Product.builder()
                                .productName("Short Black Dress")
                                .slug("short-black-dress")
                                .brand("H&M")
                                .salePrice(BigDecimal.valueOf(19))
                                .comparePrice(BigDecimal.valueOf(32))
                                .quantity(15)
                                .shortDescription("Short dress in soft cotton jersey")
                                .productDescription(
                                                "Short dress in soft cotton jersey with decorative buttons down the front.")
                                .productType("simple")
                                .published(true)
                                .imageUrls(List.of("assets/images/6e2a6075d2aebb9b52db31deea621f309362bab4.png"))
                                .colors(List.of("red", "black", "blue"))
                                .sizes(List.of("XS", "S", "M", "L", "XL"))
                                .rating(4.5)
                                .reviewCount(13)
                                .discountPercent(40)
                                .isNew(false)
                                .build();
                products.add(p6);

                // p7
                Product p7 = Product.builder()
                                .productName("Sport Dress")
                                .slug("sport-dress")
                                .brand("Sitlly")
                                .salePrice(BigDecimal.valueOf(19))
                                .comparePrice(BigDecimal.valueOf(22))
                                .quantity(60)
                                .shortDescription("Sport dress in quick-drying fabric")
                                .productDescription("Sport dress in quick-drying fabric with a round neckline.")
                                .productType("simple")
                                .published(true)
                                .imageUrls(List.of("assets/images/01fd466ba394c0eba31d6c693fe12b53b1c01c51.png"))
                                .colors(List.of("green", "black"))
                                .sizes(List.of("S", "M", "L"))
                                .rating(4.0)
                                .reviewCount(10)
                                .discountPercent(15)
                                .isNew(false)
                                .build();
                products.add(p7);

                // p8
                Product p8 = Product.builder()
                                .productName("Evening Dress")
                                .slug("evening-dress")
                                .brand("Dorothy Perkins")
                                .salePrice(BigDecimal.valueOf(12))
                                .comparePrice(BigDecimal.valueOf(15))
                                .quantity(10)
                                .shortDescription("Fitted, calf-length dress in jersey")
                                .productDescription("Fitted, calf-length dress in jersey with a draped cowl neck.")
                                .productType("simple")
                                .published(true)
                                .imageUrls(List.of("assets/images/b694c87f2961d9881ed06f1fd8d506c7100ba82c.png"))
                                .colors(List.of("black", "deepPurple"))
                                .sizes(List.of("S", "M", "L"))
                                .rating(4.5)
                                .reviewCount(10)
                                .discountPercent(20)
                                .isNew(false)
                                .build();
                products.add(p8);

                // p9
                Product p9 = Product.builder()
                                .productName("Pullover")
                                .slug("pullover")
                                .brand("Mango")
                                .salePrice(BigDecimal.valueOf(51))
                                .quantity(12)
                                .shortDescription("Oversized pullover in soft cotton")
                                .productDescription("Oversized pullover in soft, fine-knit cotton fabric.")
                                .productType("simple")
                                .published(true)
                                .imageUrls(List.of("assets/images/d07ce180be1de61431deda2032c364122b021da3.png"))
                                .colors(List.of("brown", "grey", "black"))
                                .sizes(List.of("M", "L", "XL"))
                                .rating(4.5)
                                .reviewCount(8)
                                .isNew(true)
                                .build();
                products.add(p9);

                // p10
                Product p10 = Product.builder()
                                .productName("Light Blouse")
                                .slug("light-blouse")
                                .brand("OVS")
                                .salePrice(BigDecimal.valueOf(30))
                                .quantity(35)
                                .shortDescription("Long-sleeved blouse in airy fabric")
                                .productDescription("Long-sleeved blouse in airy, woven fabric with a round neckline.")
                                .productType("simple")
                                .published(true)
                                .imageUrls(List.of("assets/images/92827a653bcf169c1f1c4b22fc8fc4b86176e01a.png"))
                                .colors(List.of("white", "pink"))
                                .sizes(List.of("XS", "S", "M"))
                                .rating(0.0)
                                .reviewCount(0)
                                .isNew(true)
                                .build();
                products.add(p10);

                // Lưu sản phẩm và thiết lập liên kết
                for (int i = 0; i < products.size(); i++) {
                        Product savedProduct = productRepository.save(products.get(i));

                        // Xác định Category liên kết
                        Category targetCategory = women; // Mặc định liên kết với Women
                        if (savedProduct.getProductName().equals("Pullover")
                                        || savedProduct.getProductName().equals("Shirt")) {
                                targetCategory = men;
                        } else if (i % 3 == 2) {
                                targetCategory = kids;
                        }

                        // Lưu ProductCategory
                        ProductCategory productCategory = ProductCategory.builder()
                                        .product(savedProduct)
                                        .category(targetCategory)
                                        .build();
                        productCategoryRepository.save(productCategory);

                        // Lưu ProductTag cho New và Sale
                        if (Boolean.TRUE.equals(savedProduct.getIsNew())) {
                                ProductTag productTag = ProductTag.builder()
                                                .productId(savedProduct.getId())
                                                .tagId(tagNew.getId())
                                                .build();
                                productTagRepository.save(productTag);
                        }
                        if (savedProduct.getDiscountPercent() != null && savedProduct.getDiscountPercent() > 0) {
                                ProductTag productTag = ProductTag.builder()
                                                .productId(savedProduct.getId())
                                                .tagId(tagSale.getId())
                                                .build();
                                productTagRepository.save(productTag);
                        }
                }

                log.info("Gieo dữ liệu thành công! Tổng số sản phẩm đã chèn: " + productRepository.count());
        }
}
