package com.vocabrehearse.word_sync_service.security;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .cors(Customizer.withDefaults())
                .csrf(csrf -> csrf.disable()) // Disable CSRF for local API testing
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/api/v1/words/**").permitAll() // Allow your new file sync
                        .requestMatchers("/v3/api-docs/**", "/swagger-ui/**").permitAll() // Allow Swagger
                        .anyRequest().authenticated()
                );
        return http.build();
    }

//    @Bean
//    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
//        http
//                .csrf(csrf -> csrf.disable()) // Disable for development
//                .authorizeHttpRequests(auth -> auth
//                        .requestMatchers("/swagger-ui/**", "/v3/api-docs/**", "/h2-console/**").permitAll()
//                        .anyRequest().authenticated()
//                )
//                .oauth2Login(Customizer.withDefaults())
//                .headers(headers -> headers.frameOptions(frame -> frame.sameOrigin())); // Allow H2 Console
//
//
//
//        return http.build();
//    }
}
