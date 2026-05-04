import { useEffect, useState } from 'react';
import {
  Box,
  Button,
  Card,
  CardContent,
  Chip,
  Container,
  Divider,
  Grid,
  LinearProgress,
  Stack,
  Typography,
} from '@mui/material';
import AdminPanelSettingsIcon from '@mui/icons-material/AdminPanelSettings';
import AnalyticsIcon from '@mui/icons-material/Analytics';
import ArrowForwardIcon from '@mui/icons-material/ArrowForward';
import CategoryIcon from '@mui/icons-material/Category';
import CloudQueueIcon from '@mui/icons-material/CloudQueue';
import Inventory2Icon from '@mui/icons-material/Inventory2';
import SecurityIcon from '@mui/icons-material/Security';
import ShoppingCartCheckoutIcon from '@mui/icons-material/ShoppingCartCheckout';
import StorefrontIcon from '@mui/icons-material/Storefront';
import { useNavigate } from 'react-router-dom';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:8080';

const techStack = [
  'Java 25',
  'Spring Boot',
  'React',
  'TypeScript',
  'PostgreSQL',
  'Docker',
  'Prometheus',
  'Grafana',
];

const modules = [
  {
    icon: <StorefrontIcon />,
    title: 'Storefront',
    text: 'Müşteri ürün listeleme, arama, sepet yönetimi ve checkout akışı.',
  },
  {
    icon: <Inventory2Icon />,
    title: 'Product Operations',
    text: 'Kategori bağlı ürün CRUD, stok, fiyat, status ve fotoğraf yönetimi.',
  },
  {
    icon: <CategoryIcon />,
    title: 'Category Control',
    text: 'Kategori CRUD, slug standardı ve ürün klasör yapısı yönetimi.',
  },
  {
    icon: <SecurityIcon />,
    title: 'JWT / RBAC',
    text: 'Login sonrası role ve permission bilgisiyle route guard ve menü kontrolü.',
  },
  {
    icon: <ShoppingCartCheckoutIcon />,
    title: 'Checkout',
    text: 'Adres, ödeme simülasyonu, sipariş oluşturma ve sipariş geçmişi.',
  },
  {
    icon: <AnalyticsIcon />,
    title: 'Observability',
    text: 'Actuator, Prometheus, Grafana ve Docker tabanlı geliştirme ortamı.',
  },
];

const flow = ['React UI', 'Route Guard', 'Spring API', 'PostgreSQL', 'MailHog', 'Metrics'];

type HomePageProps = {
  health?: string;
  productCount?: number;
  onLoginAsAdmin?: () => void;
};

export default function HomePage({
  health: healthProp,
  productCount: countProp,
  onLoginAsAdmin: loginProp,
}: HomePageProps = {}) {
  const navigate = useNavigate();
  const [health, setHealth] = useState(healthProp ?? 'CHECKING');
  const [productCount, setProductCount] = useState(countProp ?? 0);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let cancelled = false;

    async function loadDashboard() {
      try {
        setLoading(true);
        const [healthResponse, productResponse] = await Promise.allSettled([
          fetch(`${API_BASE_URL}/api/health`).then((response) => response.json()),
          fetch(`${API_BASE_URL}/api/products`).then((response) => response.json()),
        ]);

        if (cancelled) return;

        if (healthResponse.status === 'fulfilled') {
          setHealth(healthResponse.value.status ?? 'UP');
        } else {
          setHealth('DOWN');
        }

        if (productResponse.status === 'fulfilled' && Array.isArray(productResponse.value)) {
          setProductCount(productResponse.value.length);
        }
      } finally {
        if (!cancelled) setLoading(false);
      }
    }

    loadDashboard();
    return () => {
      cancelled = true;
    };
  }, []);

  const onLoginAsAdmin = loginProp ?? (() => navigate('/login'));

  return (
    <Box sx={{ bgcolor: '#f5f7fb', minHeight: '100vh' }}>
      <Box
        component="section"
        sx={{
          bgcolor: '#ffffff',
          borderBottom: '1px solid',
          borderColor: 'divider',
          py: { xs: 6, lg: 9 },
        }}
      >
        <Container maxWidth="xl">
          <Grid container spacing={4} sx={{ alignItems: 'center' }}>
            <Grid size={{ xs: 12, lg: 7 }}>
              <Chip
                icon={<CloudQueueIcon />}
                label="Enterprise E-Commerce Platform"
                color="primary"
                variant="outlined"
                sx={{ mb: 2, fontWeight: 800 }}
              />
              <Typography variant="h2" sx={{ fontWeight: 900, maxWidth: 820, fontSize: { xs: 38, md: 58 } }}>
                Modern admin, storefront ve checkout akışı tek projede.
              </Typography>
              <Typography color="text.secondary" sx={{ mt: 2, maxWidth: 760, fontSize: 18 }}>
                Java 25 Spring Boot backend, React TypeScript frontend, PostgreSQL, Docker,
                JWT permission guard ve gözlemlenebilirlik bileşenleriyle uçtan uca çalışan e-commerce lab.
              </Typography>

              <Stack direction={{ xs: 'column', sm: 'row' }} spacing={1.5} sx={{ mt: 4 }}>
                <Button variant="contained" size="large" endIcon={<ArrowForwardIcon />} onClick={() => navigate('/products')}>
                  Storefront
                </Button>
                <Button variant="outlined" size="large" startIcon={<AdminPanelSettingsIcon />} onClick={onLoginAsAdmin}>
                  Admin Login
                </Button>
              </Stack>

              <Stack direction="row" spacing={1} sx={{ mt: 4, flexWrap: 'wrap', gap: 1 }}>
                {techStack.map((item) => (
                  <Chip key={item} label={item} sx={{ bgcolor: '#eef2f7', fontWeight: 700 }} />
                ))}
              </Stack>
            </Grid>

            <Grid size={{ xs: 12, lg: 5 }}>
              <Card elevation={0} sx={{ borderRadius: 2, border: '1px solid', borderColor: 'divider' }}>
                <CardContent sx={{ p: { xs: 3, md: 4 } }}>
                  <Stack direction="row" sx={{ justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
                    <Box>
                      <Typography variant="h5" sx={{ fontWeight: 900 }}>Platform Status</Typography>
                      <Typography color="text.secondary">Local Docker geliştirme görünümü</Typography>
                    </Box>
                    <Chip label={health} color={health === 'UP' ? 'success' : health === 'DOWN' ? 'error' : 'default'} />
                  </Stack>

                  {loading && <LinearProgress sx={{ mb: 3 }} />}

                  <Grid container spacing={2}>
                    <MetricCard label="Backend" value={health} />
                    <MetricCard label="Catalog" value={`${productCount} products`} />
                    <MetricCard label="Database" value="PostgreSQL" />
                    <MetricCard label="Runtime" value="Java 25" />
                  </Grid>

                  <Divider sx={{ my: 3 }} />
                  <Typography sx={{ fontWeight: 900, mb: 1 }}>Route coverage</Typography>
                  <Stack spacing={1}>
                    {['/products', '/orders', '/admin/products', '/admin/categories', '/login'].map((route) => (
                      <Stack key={route} direction="row" sx={{ justifyContent: 'space-between' }}>
                        <Typography color="text.secondary">{route}</Typography>
                        <Chip label="ready" size="small" color="success" variant="outlined" />
                      </Stack>
                    ))}
                  </Stack>
                </CardContent>
              </Card>
            </Grid>
          </Grid>
        </Container>
      </Box>

      <Container maxWidth="xl" sx={{ py: 5 }}>
        <Grid container spacing={3}>
          {modules.map((module) => (
            <Grid key={module.title} size={{ xs: 12, md: 6, xl: 4 }}>
              <Card elevation={0} sx={{ height: '100%', borderRadius: 2, border: '1px solid', borderColor: 'divider' }}>
                <CardContent sx={{ p: 3 }}>
                  <Box
                    sx={{
                      width: 52,
                      height: 52,
                      borderRadius: 2,
                      bgcolor: '#111827',
                      color: '#ffffff',
                      display: 'grid',
                      placeItems: 'center',
                      mb: 2,
                    }}
                  >
                    {module.icon}
                  </Box>
                  <Typography variant="h6" sx={{ fontWeight: 900 }}>{module.title}</Typography>
                  <Typography color="text.secondary" sx={{ mt: 1 }}>{module.text}</Typography>
                </CardContent>
              </Card>
            </Grid>
          ))}
        </Grid>
      </Container>

      <Box component="section" sx={{ bgcolor: '#111827', color: '#ffffff', py: 5 }}>
        <Container maxWidth="xl">
          <Grid container spacing={4} sx={{ alignItems: 'center' }}>
            <Grid size={{ xs: 12, md: 4 }}>
              <Typography variant="h4" sx={{ fontWeight: 900 }}>Architecture Flow</Typography>
              <Typography sx={{ mt: 1, color: 'rgba(255,255,255,0.7)' }}>
                Frontend route guard ile kullanıcıyı ayırır, backend transactional işlemleri yönetir,
                Postgres kalıcı veri sağlar, MailHog ve metrics servisleri geliştirme ortamını tamamlar.
              </Typography>
            </Grid>
            <Grid size={{ xs: 12, md: 8 }}>
              <Grid container spacing={1.5}>
                {flow.map((step, index) => (
                  <Grid key={step} size={{ xs: 6, md: 4 }}>
                    <Box sx={{ p: 2, borderRadius: 2, bgcolor: 'rgba(255,255,255,0.08)' }}>
                      <Typography variant="caption" sx={{ color: 'rgba(255,255,255,0.55)' }}>
                        Step {index + 1}
                      </Typography>
                      <Typography sx={{ fontWeight: 900 }}>{step}</Typography>
                    </Box>
                  </Grid>
                ))}
              </Grid>
            </Grid>
          </Grid>
        </Container>
      </Box>
    </Box>
  );
}

function MetricCard({ label, value }: { label: string; value: string }) {
  return (
    <Grid size={{ xs: 12, sm: 6 }}>
      <Box sx={{ p: 2, borderRadius: 2, bgcolor: '#f8fafc', border: '1px solid', borderColor: 'divider' }}>
        <Typography variant="body2" color="text.secondary">{label}</Typography>
        <Typography sx={{ fontWeight: 900, mt: 0.5 }}>{value}</Typography>
      </Box>
    </Grid>
  );
}
