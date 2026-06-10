package com.nguyentuanduc.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "app.oauth2")
public record OAuth2Properties(
                Provider google,
                Provider facebook) {
        public record Provider(
                        String clientId,
                        String appId,
                        String appSecret) {
        }
}
