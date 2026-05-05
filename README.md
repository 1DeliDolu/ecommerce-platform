# Ecommerce Platform Scaffold

TypeScript React frontend, Java 25 Spring Boot backend, PostgreSQL, Prometheus ve Grafana içeren Docker tabanlı modern proje iskeleti.

## Çalıştırma

```bash
chmod +x scripts/dev-up.sh scripts/dev-down.sh
./scripts/dev-up.sh
```

`dev-up.sh` şunları otomatik olarak oluşturur:
- `secrets/postgres_password.txt` — rastgele PostgreSQL şifresi
- `secrets/jwt_private_key.pem` / `secrets/jwt_public_key.pem` — JWT RS256 keypair

## Servisler

| Servis | URL |
|---|---|
| Frontend | http://localhost:3000 |
| Backend API | http://localhost:8080 |
| Backend Health | http://localhost:8080/actuator/health |
| Prometheus | http://localhost:9090 |
| Grafana | http://localhost:3001 (admin/admin) |
| PostgreSQL | localhost:5432 |

## Örnek API

```bash
curl http://localhost:8080/api/health
curl http://localhost:8080/api/products
curl -X POST http://localhost:8080/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"admin@example.com","password":"Admin@123"}'
```

## Doğrulama

```bash
docker run --rm -v "$PWD/backend:/app" -w /app maven:3.9-eclipse-temurin-25 mvn test
npm --prefix frontend run build
docker compose config
```

---

## Güvenlik Checklist

### Kimlik Doğrulama & Yetkilendirme

| # | Kontrol | Durum | Dosya |
|---|---------|-------|-------|
| 1 | JWT RS256 (RSA private/public key) | ✅ | `JwtService.java` |
| 2 | Refresh token rotation (her kullanımda yenileme) | ✅ | `RefreshTokenService.java` |
| 3 | Refresh token hash (SHA-256, plaintext saklanmıyor) | ✅ | `RefreshTokenService.java` |
| 4 | BCrypt password hashing (BCryptPasswordEncoder) | ✅ | `SecurityConfig.java` |
| 5 | RBAC — `ADMIN`, `CUSTOMER`, `SECURITY_AUDITOR` rolleri | ✅ | `SecurityConfig.java` |
| 6 | Admin-only endpoints (`/api/admin/**`) | ✅ | `SecurityConfig.java` |

### Brute Force & Rate Limiting

| # | Kontrol | Durum | Dosya |
|---|---------|-------|-------|
| 7 | IP başına rate limiting (auth endpoints, 20 req/dk) | ✅ | `RateLimitingFilter.java` |
| 8 | Account lockout (5 başarısız denemede 15 dk kilit) | ✅ | `AccountLockoutService.java` |
| 9 | Kilit süresi dolunca otomatik açılma | ✅ | `AccountLockoutService.java` |
| 10 | Başarılı girişte sayaç sıfırlama | ✅ | `AccountLockoutService.java` |

### Şifre Politikası

| # | Kontrol | Durum | Dosya |
|---|---------|-------|-------|
| 11 | Minimum 8 karakter | ✅ | `RegisterRequest.java` |
| 12 | Büyük harf zorunluluğu | ✅ | `RegisterRequest.java` |
| 13 | Küçük harf zorunluluğu | ✅ | `RegisterRequest.java` |
| 14 | Rakam zorunluluğu | ✅ | `RegisterRequest.java` |
| 15 | Özel karakter zorunluluğu (`@$!%*#?&^_-`) | ✅ | `RegisterRequest.java` |

### HTTP Güvenlik Başlıkları

| # | Başlık | Değer | Durum |
|---|--------|-------|-------|
| 16 | `Strict-Transport-Security` | max-age=31536000; includeSubDomains; preload | ✅ |
| 17 | `Content-Security-Policy` | default-src 'self'; ... | ✅ |
| 18 | `X-Frame-Options` | DENY | ✅ |
| 19 | `X-Content-Type-Options` | nosniff | ✅ (Spring Security default) |
| 20 | `Referrer-Policy` | strict-origin-when-cross-origin | ✅ |
| 21 | `Permissions-Policy` | geolocation=(), microphone=(), camera=(), payment=() | ✅ |
| 22 | Frontend Nginx headers | X-Frame-Options, Referrer-Policy, Permissions-Policy | ✅ |

### CORS

| # | Kontrol | Durum |
|---|---------|-------|
| 23 | CORS whitelist (`CORS_ALLOWED_ORIGINS`) | ✅ |
| 24 | Sadece belirli HTTP metodlarına izin | ✅ |
| 25 | `allowCredentials: false` | ✅ |

### Veritabanı Güvenliği

| # | Kontrol | Durum |
|---|---------|-------|
| 26 | PostgreSQL TLS 1.2+ zorunlu | ✅ |
| 27 | SCRAM-SHA-256 kimlik doğrulama | ✅ |
| 28 | Non-SSL TCP bağlantıları reddedilir | ✅ |
| 29 | SQL injection — JPA parametreli sorgular | ✅ |

### Secret Yönetimi

| # | Kontrol | Durum |
|---|---------|-------|
| 30 | JWT private key (`secrets/`) Git'e commit edilmez | ✅ |
| 31 | PostgreSQL şifresi Docker secret olarak mount | ✅ |
| 32 | `secrets/` klasörü `.gitignore`'da | ✅ |

### Denetim & Loglama

| # | Kontrol | Durum |
|---|---------|-------|
| 33 | Login başarısı/başarısızlığı loglanır | ✅ |
| 34 | Email maskeli loglanır (`a***@example.com`) | ✅ |
| 35 | PERMISSION_DENIED audit kaydı | ✅ |
| 36 | Correlation ID her request'te | ✅ |
| 37 | Sensitive veri response'a sızdırılmıyor | ✅ |

### Container Güvenliği

| # | Kontrol | Durum |
|---|---------|-------|
| 38 | Non-root kullanıcı (backend + postgres) | ✅ |
| 39 | Minimal base image (Alpine / Temurin JRE) | ✅ |
| 40 | Backend/frontend ağ segmentasyonu | ✅ |

### Güvenlik Scriptleri

```bash
# Gizli bilgi taraması (gitleaks via Docker)
./scripts/scan-secrets.sh

# Docker image zafiyet taraması (Trivy via Docker)
./scripts/scan-images.sh

# Kapsamlı güvenlik kontrolü
./scripts/security-check.sh

# Veritabanı yedekleme
./scripts/backup-db.sh

# Veritabanı geri yükleme
./scripts/restore-db.sh <backup-file.sql.gz>
```

### Güvenlik Testleri

```bash
# SQL injection, XSS, şifre politikası ve JWT tampering testleri
docker run --rm -v "$PWD/backend:/app" -w /app maven:3.9-eclipse-temurin-25 \
  mvn test -pl . -Dtest=SecurityInputTest,JwtServiceTest
```

---

## Production için Ek Adımlar

- JWT private key'i bir secret manager (Vault, AWS Secrets Manager) ile yönetin.
- `CORS_ALLOWED_ORIGINS` değerini production domain'inizle güncelleyin.
- Grafana varsayılan şifresini değiştirin.
- Rate limit değerini (`RATE_LIMIT_AUTH_RPM`) traffic pattern'e göre ayarlayın.
- WAF (Web Application Firewall) ekleyin.
- Dependency scanning'i CI pipeline'a entegre edin (OWASP Dependency-Check).
- Image scanning'i CI pipeline'a ekleyin (Trivy).
