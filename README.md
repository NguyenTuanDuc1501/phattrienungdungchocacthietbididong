# Auth Backend - Spring Boot

## Thông tin dự án
- **Java**: 21
- **Spring Boot**: 4.0.6
- **Database**: PostgreSQL
- **Client dự kiến**: Flutter
- **API style**: REST + GraphQL
- **Packaging**: JAR

## Yêu cầu cài đặt
- JDK 21+
- Maven 3.8+
- PostgreSQL 14+

---

## Kiến trúc đề xuất
- `controller`: nhận request từ Flutter qua REST hoặc GraphQL.
- `service`: xử lý nghiệp vụ auth, refresh token, OAuth2.
- `repository`: truy cập PostgreSQL qua Spring Data JPA.
- `security`: JWT filter, `AuthenticationManager`, `UserDetailsService`.
- `entity`: `User`, `RefreshToken`.

Luồng chính:
1. Flutter gọi `register/login` hoặc gửi token Google/Facebook lên backend.
2. Backend xác thực thông tin, tìm hoặc tạo `User`.
3. Backend phát `accessToken` JWT và `refreshToken`.
4. Flutter dùng `accessToken` cho API cần đăng nhập, dùng `refreshToken` để làm mới phiên.

## Cấu hình trước khi chạy

### 1. Tạo Database PostgreSQL
```sql
CREATE DATABASE auth_db;
```

### 2. Chỉnh sửa `src/main/resources/application.yml`
```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/auth_db
    username: postgres          # Thay bằng username của bạn
    password: 123456            # Thay bằng password của bạn

app:
  jwt:
    secret: 5367566B59703373367639792F423F4528482B4D6251655468576D5A71347437
  oauth2:
    google:
      client-id: YOUR_GOOGLE_CLIENT_ID  # Lấy từ Google Cloud Console
    facebook:
      app-id: YOUR_FACEBOOK_APP_ID
      app-secret: YOUR_FACEBOOK_APP_SECRET
```

### 3. Lấy Google Client ID
1. Vào https://console.cloud.google.com
2. Tạo project → APIs & Services → Credentials
3. Create Credentials → OAuth 2.0 Client IDs
4. Copy Client ID → dán vào `app.oauth2.google.client-id`

---

## Chạy dự án

```bash
# Cài dependencies và build
mvn clean install -DskipTests

# Chạy ứng dụng
mvn spring-boot:run
```

Hoặc build JAR và chạy:
```bash
mvn clean package -DskipTests
java -jar target/auth-backend-1.0.0.jar
```

Server chạy tại: **http://localhost:8080**

---

## REST API Endpoints

| Method | Endpoint | Mô tả | Auth |
|--------|----------|-------|------|
| POST | `/api/auth/register` | Đăng ký email/password | ❌ |
| POST | `/api/auth/login` | Đăng nhập email/password | ❌ |
| POST | `/api/auth/logout` | Đăng xuất | ❌ |
| POST | `/api/auth/refresh` | Làm mới access token | ❌ |
| POST | `/api/auth/oauth2/google` | Đăng nhập Google | ❌ |
| POST | `/api/auth/oauth2/facebook` | Đăng nhập Facebook | ❌ |
| GET  | `/api/user/me` | Lấy thông tin user | ✅ Bearer |

---

## GraphQL
Endpoint mặc định: `POST /graphql`

Các operation hiện có:
- `mutation register`
- `mutation login`
- `mutation refreshToken`
- `mutation logout`
- `mutation loginWithGoogle`
- `mutation loginWithFacebook`
- `query me`

Ví dụ:
```graphql
mutation {
  login(input: {
    email: "student@example.com",
    password: "123456"
  }) {
    accessToken
    refreshToken
    user {
      id
      email
      fullName
      provider
    }
  }
}
```

## Công nghệ nên dùng
- `Spring Web`: REST API cho Flutter.
- `Spring GraphQL`: hỗ trợ query/mutation nếu bạn muốn app dùng GraphQL.
- `Spring Security`: bảo vệ endpoint và gắn user vào security context.
- `JWT`: access token stateless.
- `Refresh Token`: quản lý phiên đăng nhập và logout.
- `Spring Data JPA`: thao tác DB nhanh, phù hợp đồ án và dự án nhỏ đến vừa.
- `PostgreSQL`: ổn định, mạnh về quan hệ và indexing.
- `OAuth2`: đăng nhập Google/Facebook phía mobile rồi gửi token lên backend để verify.
- `Lombok`: giảm boilerplate.

## Cấu trúc thư mục
```
src/main/java/com/authbackend/
├── AuthBackendApplication.java
├── config/
│   └── SecurityConfig.java
├── controller/
│   ├── AuthController.java
│   ├── AuthGraphqlController.java
│   └── UserController.java
├── dto/
│   ├── request/  (LoginRequest, RegisterRequest, OAuth2Request, RefreshTokenRequest)
│   └── response/ (ApiResponse, AuthResponse, UserResponse)
├── entity/
│   ├── User.java
│   └── RefreshToken.java
├── exception/
│   ├── CustomException.java
│   └── GlobalExceptionHandler.java
├── repository/
│   ├── UserRepository.java
│   └── RefreshTokenRepository.java
├── security/
│   ├── JwtTokenProvider.java
│   ├── JwtAuthFilter.java
│   └── UserDetailsServiceImpl.java
└── service/
    ├── AuthService.java
    ├── OAuth2Service.java
    └── UserService.java
```

---

## Bảo mật
- Password hash bằng **BCrypt (strength=12)**
- JWT Access Token: hết hạn sau **15 phút**
- Refresh Token: hết hạn sau **7 ngày**
- CORS đã được cấu hình cho phép mọi origin (chỉnh lại trong production)

---

## Tích hợp Flutter
```dart
// Gọi API login
final response = await http.post(
  Uri.parse('http://10.0.2.2:8080/api/auth/login'), // Android emulator
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({'email': email, 'password': password}),
);

// Gửi Google idToken
final GoogleSignInAuthentication auth = await googleUser.authentication;
final response = await http.post(
  Uri.parse('http://10.0.2.2:8080/api/auth/oauth2/google'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({'token': auth.idToken}),
);
```

---

## Lưu ý
- Trong production, đổi `ddl-auto: update` → `ddl-auto: validate`
- Bảo mật JWT secret bằng environment variable
- Cấu hình CORS chặt hơn trong production
- Nếu làm đồ án, nên bổ sung `email verification`, `forgot password`, `role/permission`, và `Flyway` để quản lý migration DB
