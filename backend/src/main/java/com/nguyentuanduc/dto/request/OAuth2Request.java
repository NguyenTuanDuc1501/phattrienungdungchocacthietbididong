package com.nguyentuanduc.dto.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class OAuth2Request {

    @NotBlank(message = "Token không được để trống")
    private String token; // idToken cho Google, accessToken cho Facebook

    @JsonProperty("isRegister")
    private boolean isRegister; // true nếu đăng ký, false nếu đăng nhập
}
