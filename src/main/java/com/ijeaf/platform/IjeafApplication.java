package com.ijeaf.platform;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;

@SpringBootApplication
@EnableAsync
public class IjeafApplication {
    public static void main(String[] args) {
        SpringApplication.run(IjeafApplication.class, args);
    }
}