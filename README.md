# Ecommerce Platform Scaffold

TypeScript React frontend, Java 25 Spring Boot backend, PostgreSQL, Prometheus ve Grafana içeren Docker tabanlı modern proje iskeleti.

## Çalıştırma

```bash
chmod +x scripts/dev-up.sh scripts/dev-down.sh
./scripts/dev-up.sh
```

## Servisler

- Frontend: http://localhost:3000
- Backend API: http://localhost:8080
- Backend Health: http://localhost:8080/actuator/health
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3001
  - Kullanıcı: `admin`
  - Şifre: `admin`
- PostgreSQL: localhost:5432

## Örnek API

```bash
curl http://localhost:8080/api/health
curl http://localhost:8080/api/products
curl -X POST http://localhost:8080/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"admin@example.com","password":"admin123"}'
```

Demo admin kullanıcısı PostgreSQL init script ile oluşturulur ve BCrypt password hash kullanır. Login akışı kullanıcıyı `app_user` tablosundan okur; geçersiz email veya parola için aynı `401 Unauthorized` yanıtı döner.

## Doğrulama

Yerel makinede Maven yoksa backend testlerini container ile çalıştırabilirsiniz:

```bash
docker run --rm -v "$PWD/backend:/app" -w /app maven:3.9-eclipse-temurin-25 mvn test
npm --prefix frontend run build
docker compose config
```

## Güvenlik Notları

Bu iskelet development içindir. Production için:

- `.env` değerlerini secret manager ile yönetin.
- JWT secret/private key değerlerini repoya commit etmeyin.
- `JWT_SECRET` değerini en az 32 byte, rastgele üretilmiş bir değer olarak sağlayın.
- `CORS_ALLOWED_ORIGINS` değerini yalnızca güvenilen frontend originleriyle sınırlandırın.
- Public actuator yüzeyi development ortamında `health` ve Prometheus scrape için `prometheus` endpointleriyle sınırlıdır.
- Grafana varsayılan şifresini değiştirin.
- PostgreSQL kullanıcılarını least privilege prensibiyle ayırın.
- TLS, rate limiting, WAF ve centralized logging ekleyin.

## Security Checklist

| # | Kontrol | Durum | Notlar |
|---|---------|-------|--------|
| 1 | Security headers (CSP, X-Frame-Options, HSTS, Referrer-Policy, Permissions-Policy, X-Content-Type-Options) | ✅ | `SecurityConfig.java` |
| 2 | CORS whitelist | ✅ | `CORS_ALLOWED_ORIGINS` env var |
| 3 | Rate limiting | ✅ | `RateLimitFilter.java` — auth: 10 req/min, diğerleri: 100 req/min |
| 4 | Brute force protection | ✅ | `LoginAttemptAuditService.isLockedOut()` — 5 başarısız deneme / 15 dk |
| 5 | Account lockout | ✅ | `login_attempts` tablosu üzerinden uygulama katmanında kilitleme |
| 6 | Password policy | ✅ | Min 8 karakter, büyük/küçük harf + rakam + özel karakter |
| 7 | Refresh token rotation | ✅ | `RefreshTokenService.rotateForUser()` |
| 8 | JWT private/public key (RS256) | ✅ | `JwtService` — RSA RS256 veya HMAC-SHA256 mod seçimi |
| 9 | SQL injection testleri | ✅ | JPA/Hibernate parametreli sorgular; `PasswordPolicyTest`, `BruteForceProtectionTest` |
| 10 | XSS testleri | ✅ | CSP header + `X-Content-Type-Options: nosniff`; `RateLimitFilterTest` |
| 11 | Secret scanning | ✅ | `scripts/scan-secrets.sh` (gitleaks / grep fallback) |
| 12 | Dependency scanning | ✅ | `scripts/security-check.sh` (OWASP Dependency Check + npm audit) |
| 13 | Docker image scanning | ✅ | `scripts/scan-images.sh` (Trivy) |
| 14 | PostgreSQL TLS | ✅ | `docker-compose.yml` — `sslmode=verify-full` |
| 15 | Sensitive bilgiler loglanmıyor | ✅ | `maskEmail()` + password hash asla loglanmıyor |

### Güvenlik Scriptleri

```bash
# RSA JWT anahtar çifti oluştur (.env'e yaz)
./scripts/generate-jwt-keys.sh

# Gizli bilgi taraması (gitleaks / grep)
./scripts/scan-secrets.sh

# Docker image CVE taraması (Trivy)
./scripts/scan-images.sh

# Tam güvenlik kontrolü (secret + OWASP + image + npm audit)
./scripts/security-check.sh

# Veritabanı yedeği al
./scripts/backup-db.sh

# Veritabanı yedeğini geri yükle
./scripts/restore-db.sh backups/ecommerce-<timestamp>.pgdump
```

### JWT Anahtar Modu

| Değişken | Açıklama |
|----------|----------|
| `JWT_SECRET` | HMAC-SHA256 (HS256) için simetrik anahtar (en az 32 byte) |
| `JWT_PRIVATE_KEY` | RSA RS256 için özel anahtar (base64 PKCS8) |
| `JWT_PUBLIC_KEY` | RSA RS256 için açık anahtar (base64 X509) |

`JWT_PRIVATE_KEY` ve `JWT_PUBLIC_KEY` ikisi birden ayarlandığında RS256 kullanılır; `JWT_SECRET` görmezden gelinir.
RS256 anahtarlarını oluşturmak için: `./scripts/generate-jwt-keys.sh`

