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
