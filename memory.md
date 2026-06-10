# Ký Ức Phát Triển & Vận Hành (memory.md) - Dự án `auth-backend`

Tài liệu này lưu trữ thông tin kỹ thuật, cấu trúc hệ thống, quy trình nghiệp vụ và các sự cố đã giải quyết trong quá trình thiết kế và tích hợp backend Spring Boot (`auth-backend`) với frontend Flutter (`e_commerce_app_design`).

---

## 1. Tổng Quan Kiến Trúc Hệ Thống

* **Framework chính**: Spring Boot 3.x (Java 21/24)
* **Cơ sở dữ liệu**: PostgreSQL (`jdbc:postgresql://localhost:5432/auth_db`)
* **Cơ chế xác thực**: JWT (JSON Web Token) kết hợp OAuth2 (Google & Facebook) cho môi trường di động.
* **Giao thức API**: REST API (dành cho quản lý sản phẩm/danh mục) & GraphQL (`/graphql`) dành cho một số tính năng mở rộng.
* **Cổng kết nối mặc định**: `8080` (Cần lưu ý tránh xung đột khi chạy song song nhiều tiến trình).

---

## 2. Hệ Thống Danh Mục Phân Tầng & Sản Phẩm (Category & Product Schema)

### Cấu Trúc Danh Mục 3 Cấp
Hệ thống danh mục thiết kế theo dạng phân cấp tự liên kết (Self-referencing Hierarchical) để quản lý danh mục động:

1. **Cấp 1 (Root Categories)**: `Women`, `Men`, `Kids` (trường `parent_id` là `null`).
2. **Cấp 2 (Subcategories)**: `New`, `Clothes`, `Shoes`, `Accessories` (có `parent_id` liên kết với Cấp 1).
3. **Cấp 3 (Sub-subcategories dưới Clothes)**: `Tops`, `Shirts & Blouses`, `Cardigans & Sweaters`, `Knitwear`, `Blazers`, `Outerwear`, `Pants`, `Jeans`, `Shorts`, `Skirts`, `Dresses` (có `parent_id` liên kết với `Clothes`).

### Thực Thể Chính
* **`Category`**: 
  * `parent` (`@ManyToOne` tự liên kết, cột `parent_id`)
  * `subcategories` (`@OneToMany` lazy-loaded, ẩn tuần hoàn JSON qua `@JsonIgnore`)
  * `imageUrl` (lưu đường dẫn assets cục bộ của frontend như `assets/images/Pasted image (10).png`)
* **`Product`**:
  * Chứa thông tin sản phẩm: `productName`, `brand`, `salePrice`, `comparePrice`, `discountPercent`, `isNew`, `imageUrls` (danh sách String).
* **`ProductCategory`**:
  * Bảng trung gian ánh xạ quan hệ N-N giữa `Product` và `Category`.

---

## 3. Cơ Chế Tự Động Gieo Dữ Liệu (Database Seeder Workflow)

Tệp tin cấu hình seeder chính nằm tại `com.authbackend.config.DatabaseSeeder.java`.

### Quy Trình Hoạt Động Của Seeder
1. **Kiểm tra dữ liệu**: Nếu bảng `categories` có dữ liệu (`count() > 0`), seeder sẽ tự động bỏ qua để tránh trùng lặp.
2. **Khởi tạo danh mục**:
   * Tạo 3 danh mục gốc `Women`, `Men`, `Kids`.
   * Chạy hàm đệ quy/helper `seedCategoryTree(Category root, String prefix)` để dựng cây danh mục con cấp 2 và cấp 3 tương ứng cho mỗi đối tượng.
3. **Tạo sản phẩm**:
   * Gieo sản phẩm bằng tiếng Anh (`getProductEnglishName`) cho 13 danh mục (Shoes, Accessories, và 11 danh mục con Clothes) với số lượng:
     * **Shoes**: 4 sản phẩm.
     * **Accessories**: 4 sản phẩm.
     * **Clothes Subcategories**: 2 sản phẩm cho mỗi danh mục con (riêng danh mục **Tops** được nâng lên **12 sản phẩm** để đáp ứng nhu cầu hiển thị nhiều mẫu mã).
   * Gán hình ảnh cục bộ (`getProductLocalImage`) lấy từ thư mục `assets/images/` của frontend.
4. **Tự động liên kết Tab "New"**:
   * Bất kỳ sản phẩm nào có `isNew = true` (ở đây là sản phẩm đầu tiên của mỗi danh mục) sẽ tự động được chạy qua hàm `linkNewCategoryIfApplicable`.
   * Hàm này tìm ngược lên danh mục gốc (Women/Men/Kids) và liên kết sản phẩm đó vào danh mục `New` tương ứng (`women-new`, `men-new`, `kids-new`) trong bảng `product_categories`.

---

## 4. Nhật Ký Giải Quyết Sự Cố & Kỹ Thuật (Troubleshooting Guide)

### Sự cố 1: Lỗi Cổng 8080 Đã Bị Sử Dụng ("Port 8080 was already in use")
* **Nguyên nhân**: Do máy chủ Spring Boot đã được khởi chạy ngầm bằng công cụ khác (hoặc do tác vụ nền của trợ lý AI trước đó) chưa giải phóng cổng.
* **Cách khắc phục**:
  Chạy lệnh PowerShell sau để kiểm tra ID tiến trình đang giữ cổng và ép buộc tắt nó:
  ```powershell
  # Tìm PID tiến trình bận cổng 8080
  Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue | Select-Object LocalAddress, LocalPort, State, OwningProcess
  
  # Kill tiến trình (Ví dụ PID tìm được là 18864)
  Stop-Process -Id 18864 -Force
  ```

### Sự cố 2: Seeder Không Chạy Lại Khi Sửa Đổi Dữ Liệu Mẫu
* **Nguyên nhân**: Do điều kiện `if (categoryRepository.count() > 0)` chặn không cho seeder chạy lại khi dữ liệu cũ vẫn tồn tại trong database.
* **Cách khắc phục**:
  Thực hiện làm sạch triệt để cơ sở dữ liệu trước khi chạy lại ứng dụng bằng cách chạy file kiểm thử JDBC [DatabaseTest.java](file:///C:/Users/HOANG%20VIET/.gemini/antigravity/brain/274f2cef-ce1a-4e09-bad4-5968a7f8e58a/scratch/DatabaseTest.java):
  ```sql
  TRUNCATE TABLE product_categories, product_tags, products, categories, tags CASCADE;
  ```

### Sự cố 3: Lỗi Phân Tích Cú Pháp Khi Dùng ID `-mock` Trên Frontend
* **Nguyên nhân**: Khi chạy offline, frontend trả về các ID có hậu tố `-mock`. Backend không nhận dạng được các ID giả lập này nên gây lỗi API.
* **Cách khắc phục**:
  Cập nhật logic ở `CategoryListScreen._fetchProducts()` của Flutter. Nếu `categoryId` chứa `-mock`, ứng dụng sẽ tự động chuyển sang cơ chế lọc dữ liệu local theo tên (`categoryName`) thay vì gửi request API lên server.

### Sự cố 4: Lỗi Inconsistent JVM-target compatibility khi build Android
* **Nguyên nhân**: Tác vụ biên dịch Java (`compileDebugJavaWithJavac`) của các plugin phụ thuộc (như `image_picker_android`) yêu cầu Java 17 nhưng tác vụ biên dịch Kotlin (`compileDebugKotlin`) lại mặc định chạy trên JVM Target 1.8. 
* **Cách khắc phục**: Cập nhật file `android/build.gradle.kts` của frontend Flutter, cấu hình trong block `subprojects` để tự động đọc `targetCompatibility` đã cấu hình của Java cho từng dự án con rồi gán động cho Kotlin `jvmTarget`. Cách này tránh việc gán cứng làm lỗi `finalized` compileOptions của Java.

---

## 5. Hướng Dẫn Vận Hành Tiếp Theo (Next Steps / Future TO-DOs)

1. **Cập Nhật Hình Ảnh Mới**:
   * Khi bạn muốn bổ sung thêm ảnh thời trang thực tế, hãy sao chép các tệp ảnh (`.png`, `.jpg`) vào thư mục `assets/images/` của frontend.
   * Cập nhật đường dẫn ảnh tương ứng trong hàm `getProductLocalImage` trong lớp `DatabaseSeeder.java` của backend.
2. **Cấu Hình Môi Trường Thực Tế (Production Config)**:
   * Hiện tại, API Endpoints đang trỏ cứng tới IP cục bộ `10.160.46.236`. Khi đổi mạng Wi-Fi khác, bạn cần cập nhật lại trường `baseUrl` trong tệp `lib/core/network/api_endpoints.dart` của Flutter theo IP mới của máy tính để điện thoại thật/giả lập kết nối được.
3. **Mở Rộng Quản Lý Giỏ Hàng & Yêu Thích**:
   * Đồng bộ hóa danh sách `Giỏ hàng (Bag)` và `Yêu thích (Favorites)` từ bộ nhớ máy điện thoại (SQLite/SharedPreferences) lên cơ sở dữ liệu PostgreSQL thông qua tài khoản đăng nhập để lưu trữ vĩnh viễn.

---

## 6. Hệ Thống Đánh Giá & Nhận Xét Sản Phẩm (Product Reviews & Rating System)

Hệ thống được thiết kế đầy đủ từ backend database đến giao diện frontend để quản lý và hiển thị đánh giá của khách hàng:

### Thiết Kế Thực Thể & Cơ Sở Dữ Liệu
* **`ProductReview`**:
  * Liên kết trực tiếp với sản phẩm (`Product`) và người dùng đang đăng nhập (`StaffAccount` - đóng vai trò User trong hệ thống).
  * Chứa các thông tin: `rating` (1-5), `title`, `comment` (TEXT), `helpfulCount` và `isApproved`.
  * Có cấu hình `@UniqueConstraint` cho cặp khóa `(product_id, user_id)` để đảm bảo mỗi khách hàng chỉ gửi tối đa một đánh giá cho một sản phẩm.
* **`ReviewImage`**:
  * Lưu trữ các URL hình ảnh đính kèm theo bài đánh giá, liên kết `@ManyToOne` với `ProductReview`.

### Logic Xử Lý Nghiệp Vụ (ReviewService)
* **Tính toán động**: Khi có đánh giá mới được gửi lên hoặc một đánh giá cũ bị xóa, hệ thống sẽ tự động gọi truy vấn `COALESCE(AVG(rating), 0.0)` và `count()` để tính toán lại điểm rating trung bình cũng như số lượt đánh giá của sản phẩm, sau đó cập nhật trực tiếp vào bảng `products`.

### Cấu Hình Bảo Mật (SecurityConfig)
* Cho phép truy cập công khai (public) đối với tác vụ đọc danh sách đánh giá của sản phẩm: `GET /api/reviews/product/**`.
* Yêu cầu xác thực JWT (authenticated) đối với tác vụ gửi đánh giá: `POST /api/reviews` và xóa đánh giá: `DELETE /api/reviews/**`.

### Tích Hợp Frontend (Flutter - e_commerce_app_design)
* **`Review` Model**: Bổ sung `fromJson` và `toJson` để khớp với API payload, thêm các trường liên kết `customerId` và `productId`.
* **`ReviewApiService`**: Service chịu trách nhiệm gọi API tải danh sách đánh giá và gửi đánh giá mới lên máy chủ qua thư viện `Dio`.
  * **ReviewsScreen**:
    * Tải đánh giá động theo `productId` từ database.
    * **Đánh giá mẫu cục bộ**: Tích hợp sẵn 3 đánh giá mẫu (2 có hình ảnh local và 1 không có hình ảnh) làm dữ liệu nền và hiển thị trực tiếp khi mở trang.
    * **Chọn ảnh đa nguồn (Camera + Assets)**: Sửa đổi nút "Add your photos" khi viết đánh giá. Khi khách hàng bấm chọn, một hộp thoại sẽ hiện lên cho phép chọn chụp ảnh trực tiếp từ **Camera của điện thoại** (sử dụng thư viện `image_picker`) hoặc chọn hình ảnh từ thư viện assets nội bộ (`assets/images/`).
    * **Giao diện chuẩn Figma**: Chuyển đổi nút "Write a review" từ Bottom Navigation Bar cũ thành nút Floating Action Button (FAB) lơ lửng màu đỏ có bóng đổ ở góc dưới bên phải màn hình đúng với layout Figma.
    * **Ràng buộc đánh giá một lần**: Tự động so sánh ID người dùng đang đăng nhập (`currentUserId` lấy từ `AuthProvider`) với danh sách các đánh giá. Nếu người dùng đã từng đánh giá sản phẩm này rồi, nút "Write a review" sẽ tự động ẩn đi, ngăn chặn việc đánh giá trùng lặp.
    * Tự động tính toán điểm trung bình thực tế và bảng phân phối biểu đồ sao (Rating Breakdown) từ toàn bộ danh sách đánh giá.
    * Cho phép người dùng viết nhận xét, chọn số sao và gửi đánh giá lên server.
* **`AppRouter` & `ProductDetailScreen`**: Cấu hình truyền tham số `productId` một cách chính xác khi chuyển hướng sang trang đánh giá.
