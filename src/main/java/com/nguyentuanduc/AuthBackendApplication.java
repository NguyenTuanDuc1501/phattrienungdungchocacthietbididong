package com.nguyentuanduc;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;

import com.nguyentuanduc.config.JwtProperties;
import com.nguyentuanduc.config.OAuth2Properties;

@SpringBootApplication
@EnableConfigurationProperties({ JwtProperties.class, OAuth2Properties.class })
public class AuthBackendApplication {
    public static void main(String[] args) {
        SpringApplication.run(AuthBackendApplication.class, args);
    }
}
