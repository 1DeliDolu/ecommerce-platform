import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';

const techStack = [
  'Java 25',
  'Spring Boot 4',
  'React',
  'TypeScript',
  'PostgreSQL',
  'Docker',
  'Prometheus',
  'Grafana',
  'JWT / RBAC',
];

const modules = [
  {
    icon: 'bi-bag-check',
    title: 'E-Commerce Domain',
    text: 'Product, category, inventory, cart, checkout and order-management foundations.',
  },
  {
    icon: 'bi-shield-lock',
    title: 'Security Layer',
    text: 'JWT authentication, role-aware product administration and hardened local configuration.',
  },
  {
    icon: 'bi-database',
    title: 'PostgreSQL Data Store',
    text: 'Relational product and user data with seed records for local development.',
  },
  {
    icon: 'bi-box-seam',
    title: 'Container Workflow',
    text: 'Docker Compose orchestration for frontend, backend, database and observability services.',
  },
  {
    icon: 'bi-activity',
    title: 'Observability',
    text: 'Spring actuator metrics scraped by Prometheus and visualized through Grafana.',
  },
  {
    icon: 'bi-kanban',
    title: 'Admin Operations',
    text: 'Product management UI with images, permissions, filters and CRUD-ready controls.',
  },
];

const architectureSteps = [
  'React Frontend',
  'Spring Boot API',
  'PostgreSQL OLTP',
  'JWT / RBAC',
  'Prometheus Metrics',
  'Grafana Dashboard',
];

type HomePageProps = {
  health?: string;
  productCount?: number;
  onLoginAsAdmin?: () => void;
};

export default function HomePage({ health: healthProp, productCount: countProp, onLoginAsAdmin: loginProp }: HomePageProps = {}) {
  const navigate = useNavigate();
  const [health, setHealth] = useState(healthProp ?? 'CHECKING...');
  const [productCount, setProductCount] = useState(countProp ?? 0);

  useEffect(() => {
    fetch('/api/health').then(r => r.json()).then(d => setHealth(d.status ?? 'UP')).catch(() => setHealth('DOWN'));
    fetch('/api/products').then(r => r.json()).then(d => setProductCount(Array.isArray(d) ? d.length : 0)).catch(() => {});
  }, []);

  const onLoginAsAdmin = loginProp ?? (() => navigate('/login'));

  return (
    <main className="home-page">
      <section className="home-hero">
        <div className="container-xl">
          <div className="row align-items-center g-5">
            <div className="col-12 col-lg-7">
              <span className="badge text-bg-warning fw-bold mb-3">Enterprise Capstone Project</span>
              <h1 className="display-4 fw-black mb-3">Enterprise E-Commerce Data Architecture Platform</h1>
              <p className="lead text-secondary mb-4">
                Full-stack, security-focused e-commerce platform built with Java 25 Spring Boot,
                React TypeScript, PostgreSQL, Docker, Prometheus and Grafana.
              </p>

              <div className="d-flex flex-wrap gap-2 mb-4">
                {techStack.map((item) => (
                  <span className="badge rounded-pill text-bg-light border px-3 py-2" key={item}>
                    {item}
                  </span>
                ))}
              </div>

              <div className="d-flex flex-column flex-sm-row gap-2">
                <a className="btn btn-dark btn-lg" href="#admin-products">
                  <i className="bi bi-grid-3x3-gap me-2" aria-hidden="true"></i>
                  Manage Products
                </a>
                <button className="btn btn-outline-dark btn-lg" type="button" onClick={onLoginAsAdmin}>
                  <i className="bi bi-shield-check me-2" aria-hidden="true"></i>
                  Demo Admin JWT
                </button>
              </div>
            </div>

            <div className="col-12 col-lg-5">
              <div className="platform-status-panel">
                <div className="d-flex justify-content-between align-items-start mb-4">
                  <div>
                    <h2 className="h4 fw-bold mb-1">Platform Status</h2>
                    <p className="text-secondary mb-0">Dockerized local enterprise lab</p>
                  </div>
                  <span className={`badge ${health === 'UP' ? 'text-bg-success' : 'text-bg-secondary'}`}>
                    {health}
                  </span>
                </div>

                <div className="status-metrics">
                  <MetricCard icon="bi-hdd-network" label="Backend" value={health} />
                  <MetricCard icon="bi-bag" label="Catalog API" value={`${productCount}`} />
                  <MetricCard icon="bi-database-check" label="Database" value="Postgres" />
                  <MetricCard icon="bi-graph-up" label="Metrics" value="Grafana" />
                </div>

                <div className="border-top pt-4 mt-4">
                  <h3 className="h6 fw-bold">Learning goal</h3>
                  <p className="text-secondary mb-0">
                    Practice backend engineering, secure configuration, product administration,
                    database design and observability in one runnable project.
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section className="container-xl py-5">
        <div className="row g-4">
          <div className="col-12 col-lg-4">
            <h2 className="fw-bold">Genel Açıklama</h2>
            <p className="text-secondary">
              Bu proje klasik bir alışveriş sitesi değil; backend, frontend, database,
              monitoring ve security katmanlarını birlikte çalıştıran portfolyo odaklı
              bir enterprise lab uygulamasıdır.
            </p>
          </div>
          <div className="col-12 col-lg-8">
            <div className="row g-3">
              <InfoCard title="Amaç" text="Java 25, Spring Boot, React ve PostgreSQL ile uçtan uca çalışan e-commerce mimarisi geliştirmek." />
              <InfoCard title="Kapsam" text="Product admin, image management, JWT login, Docker workflow, metrics and dashboard assets." />
              <InfoCard title="Portfolyo Değeri" text="Mülakatta anlatılabilir mimari, çalışan Docker ortamı ve üretime yaklaşan geliştirme disiplini." />
            </div>
          </div>
        </div>
      </section>

      <section className="home-modules py-5">
        <div className="container-xl">
          <div className="text-center mb-4">
            <h2 className="fw-bold">Core Modules</h2>
            <p className="text-secondary mb-0">Her modül gerçek bir enterprise geliştirme problemini temsil eder.</p>
          </div>

          <div className="row g-4">
            {modules.map((module) => (
              <div className="col-12 col-md-6 col-xl-4" key={module.title}>
                <article className="module-card h-100">
                  <div className="module-icon">
                    <i className={`bi ${module.icon}`} aria-hidden="true"></i>
                  </div>
                  <h3 className="h5 fw-bold">{module.title}</h3>
                  <p className="text-secondary mb-0">{module.text}</p>
                </article>
              </div>
            ))}
          </div>
        </div>
      </section>

      <section className="architecture-section py-5">
        <div className="container-xl">
          <div className="row align-items-center g-5">
            <div className="col-12 col-lg-4">
              <h2 className="fw-bold">Architecture Flow</h2>
              <p className="mb-0">
                Kullanıcı isteği frontend’den backend API’ye gider. Transactional data
                PostgreSQL’e yazılır. Actuator metrikleri Prometheus tarafından toplanır
                ve Grafana dashboardlarıyla izlenir.
              </p>
            </div>
            <div className="col-12 col-lg-8">
              <div className="architecture-grid">
                {architectureSteps.map((step, index) => (
                  <div className="architecture-step" key={step}>
                    <span>Step {index + 1}</span>
                    <strong>{step}</strong>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </section>

      <section className="container-xl py-5">
        <div className="row g-4">
          <div className="col-12 col-lg-5">
            <h2 className="fw-bold">Contact / Feedback</h2>
            <p className="text-secondary">
              Proje hakkında demo isteği, teknik soru veya portfolyo geri bildirimi için
              kullanılabilecek örnek iletişim alanı.
            </p>

            <ContactLine icon="bi-envelope" title="Email" text="musta@example.com" />
            <ContactLine icon="bi-github" title="Repository" text="enterprise-ecommerce-data-platform" />
            <ContactLine icon="bi-speedometer2" title="Monitoring" text="Prometheus + Grafana dashboards" />
          </div>

          <div className="col-12 col-lg-7">
            <form className="contact-card">
              <div className="row g-3">
                <div className="col-12 col-md-6">
                  <label className="form-label">Name</label>
                  <input className="form-control" placeholder="Your name" />
                </div>
                <div className="col-12 col-md-6">
                  <label className="form-label">Email</label>
                  <input className="form-control" type="email" placeholder="your@email.com" />
                </div>
                <div className="col-12">
                  <label className="form-label">Subject</label>
                  <input className="form-control" placeholder="Project feedback" />
                </div>
                <div className="col-12">
                  <label className="form-label">Message</label>
                  <textarea className="form-control" rows={5} placeholder="Write your message..." />
                </div>
                <div className="col-12">
                  <button className="btn btn-dark btn-lg" type="button">
                    Send Message
                    <i className="bi bi-send ms-2" aria-hidden="true"></i>
                  </button>
                </div>
              </div>
            </form>
          </div>
        </div>
      </section>
    </main>
  );
}

function MetricCard({ icon, label, value }: { icon: string; label: string; value: string }) {
  return (
    <div className="metric-card">
      <i className={`bi ${icon}`} aria-hidden="true"></i>
      <strong>{value}</strong>
      <span>{label}</span>
    </div>
  );
}

function InfoCard({ title, text }: { title: string; text: string }) {
  return (
    <div className="col-12 col-md-4">
      <article className="info-card h-100">
        <h3 className="h5 fw-bold">{title}</h3>
        <p className="text-secondary mb-0">{text}</p>
      </article>
    </div>
  );
}

function ContactLine({ icon, title, text }: { icon: string; title: string; text: string }) {
  return (
    <div className="contact-line">
      <span>
        <i className={`bi ${icon}`} aria-hidden="true"></i>
      </span>
      <div>
        <strong>{title}</strong>
        <p className="text-secondary mb-0">{text}</p>
      </div>
    </div>
  );
}
