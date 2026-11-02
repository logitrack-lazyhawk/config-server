package com.logitrack.configserver;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest(properties = {
        "spring.profiles.active=native",
        "spring.cloud.config.server.native.search-locations=classpath:/",
        "management.tracing.export.zipkin.enabled=false"
})
class ConfigServerApplicationTests {

    @Test
    void contextLoads() {
    }

}
