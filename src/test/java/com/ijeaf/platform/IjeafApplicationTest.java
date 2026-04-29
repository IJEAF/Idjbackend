package com.ijeaf.platform;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.TestPropertySource;

/**
 * Test de démarrage du contexte Spring Boot.
 * Vérifie que l'application démarre sans erreur.
 * Chaque développeur doit s'assurer que ce test passe avant de pousser.
 */
@SpringBootTest
@ActiveProfiles("test")
@TestPropertySource(properties = {
        "spring.flyway.enabled=false",
        "spring.jpa.hibernate.ddl-auto=none",
        "spring.datasource.url=jdbc:h2:mem:testdb",
        "spring.datasource.driver-class-name=org.h2.Driver",
        "jwt.secret=test_secret_key_256_bits_long_for_unit_tests_only_do_not_use_in_prod",
        "jwt.access-expiration=900000",
        "jwt.refresh-expiration=604800000",
        "spring.mail.host=localhost",
        "spring.mail.port=25",
        "firebase.credentials-path=",
        "aws.access-key=test",
        "aws.secret-key=test",
        "aws.bucket-name=test",
        "aws.region=eu-west-1",
        "afriksms.api-key=test",
        "fedapay.api-key=test"
})
class IjeafApplicationTest {

    @Test
    void contextLoads() {
        // Le contexte Spring doit démarrer sans erreur
    }
}

