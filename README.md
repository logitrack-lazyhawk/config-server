# LogiTrack - Config Server

Microservicio de **Servidor de Configuración Centralizada** para la plataforma **LogiTrack**, correspondiente al **Sprint 2** de la materia *Desarrollo y Arquitecturas Avanzadas de Software* (DAAS).

Implementado con **Spring Cloud Config Server** sobre **Spring Boot (Java 25)** y **Maven**, permitiendo desacoplar la configuración de los microservicios del ciclo de vida del código fuente mediante un repositorio Git externo.

---

## 🚀 Características Principales

- **Gestión Centralizada**: Provee configuraciones unificadas para todos los microservicios del ecosistema LogiTrack (`shipment-service`, `courier-service`, etc.).
- **Backend Git Remoto**: Conectado a repositorio remoto con rama por defecto `main`.
- **Parametrizable vía Variables de Entorno**: Compatible con contenedores Docker y orquestadores mediante fallbacks configurables.
- **Observabilidad con Spring Boot Actuator**: Endpoints expuestos de salud (`health`), métricas (`metrics`) e información (`info`).
- **Arquitectura Liviana (Stateless)**: Sin base de datos relacional, JPA ni drivers SQL innecesarios.
- **Docker Multi-Stage Build**: Imagen contenerizada optimizada para Java 25 (Temurin JRE) con usuario no root por seguridad.

---

## 🛠️ Stack Tecnológico

| Componente | Tecnología | Versión |
| :--- | :--- | :--- |
| Lenguaje | Java | 25 (LTS) |
| Framework | Spring Boot | 4.1.2 |
| Cloud Ecosystem | Spring Cloud (BOM) | 2025.1.4 |
| Config Server | Spring Cloud Config Server | 5.0.6 |
| Build Tool | Apache Maven (Wrapper incluido) | 3.10.0 |
| Observabilidad | Spring Boot Actuator | 4.1.2 |
| Testing | Spring Boot Starter Test (JUnit Jupiter) | 4.1.2 |
| Base Image Docker | Eclipse Temurin (JDK/JRE) | 25 |

---

## ⚙️ Configuración (`application.yml`)

El microservicio se ejecuta en el puerto **`8085`** y define las siguientes propiedades:

```yaml
server:
  port: 8085

spring:
  application:
    name: config-server
  cloud:
    config:
      server:
        git:
          uri: ${CONFIG_REPO_URI:https://github.com/logitrack-lazyhawk/logitrack-config.git}
          default-label: ${CONFIG_REPO_BRANCH:main}
          clone-on-start: ${CONFIG_REPO_CLONE_ON_START:false}
          force-pull: true
          timeout: 5

management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics
  endpoint:
    health:
      show-details: always
  info:
    env:
      enabled: true
```

### Variables de Entorno Disponibles

| Variable | Descripción | Valor por Defecto |
| :--- | :--- | :--- |
| `CONFIG_REPO_URI` | URL del repositorio Git que almacena los YAML de configuración | `https://github.com/logitrack-lazyhawk/logitrack-config.git` |
| `CONFIG_REPO_BRANCH` | Rama o etiqueta Git a consultar | `main` |
| `CONFIG_REPO_CLONE_ON_START` | Clona el repositorio al arrancar (`true`) o de forma perezosa (`false`) | `false` |

---

## 💻 Ejecución Local

### Prerrequisitos
- JDK 25 instalado y configurado en el PATH.
- Git instalado.

### 1. Compilación y Pruebas
Utilizando el Maven Wrapper incluido en el proyecto:

```bash
# En Windows (PowerShell / CMD)
.\mvnw.cmd clean test

# En Linux / macOS
./mvnw clean test
```

### 2. Ejecutar la Aplicación
```bash
# En Windows
.\mvnw.cmd spring-boot:run

# En Linux / macOS
./mvnw spring-boot:run
```

Una vez levantado, estará escuchando en: `http://localhost:8085`

---

## 🐳 Despliegue con Docker

El proyecto incluye un `Dockerfile` con **Multi-Stage Build** para minimizar el tamaño final de la imagen y maximizar la seguridad (ejecuta con usuario `appuser` sin privilegios).

### 1. Construir la Imagen
```bash
docker build -t logitrack/config-server:latest .
```

### 2. Ejecutar el Contenedor
```bash
docker run -d \
  --name logitrack-config-server \
  -p 8085:8085 \
  -e CONFIG_REPO_URI="https://github.com/logitrack-lazyhawk/logitrack-config.git" \
  -e CONFIG_REPO_BRANCH="main" \
  logitrack/config-server:latest
```

---

## 🔍 Endpoints de Verificación

Una vez que el servicio esté corriendo:

### 1. Actuator Health Check
Verifica el estado del servicio y la conectividad con el repositorio Git:
```http
GET http://localhost:8085/actuator/health
```

Respuesta esperada:
```json
{
  "status": "UP",
  "components": {
    "discoveryComposite": { "status": "UP" },
    "ping": { "status": "UP" }
  }
}
```

### 2. Consulta de Configuración de Microservicios
Para consultar la configuración servida a un microservicio cliente (por ejemplo, `orders-service` en perfil `default` o `prod`):

```http
# Sintaxis: /{application}/{profile}[/{label}]
GET http://localhost:8085/orders-service/default
GET http://localhost:8085/orders-service/prod
GET http://localhost:8085/orders-service.yml
```

---

## 📁 Estructura del Proyecto

```text
Config-Server/
├── .mvn/wrapper/
│   └── maven-wrapper.properties
├── src/
│   ├── main/
│   │   ├── java/com/logitrack/configserver/
│   │   │   └── ConfigServerApplication.java    # Anotada con @SpringBootApplication y @EnableConfigServer
│   │   └── resources/
│   │       └── application.yml                 # Configuración del servidor y backend Git
│   └── test/
│       └── java/com/logitrack/configserver/
│           └── ConfigServerApplicationTests.java
├── .dockerignore
├── Dockerfile                                 # Multi-stage build optimizado para Java 25
├── mvnw / mvnw.cmd                            # Maven Wrapper
├── pom.xml                                    # Dependencias y Spring Cloud BOM
└── README.md
```
