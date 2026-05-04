import React, { useState } from 'react';
import {
  Alert,
  Box,
  Button,
  Card,
  CardContent,
  CircularProgress,
  Container,
  Divider,
  Stack,
  TextField,
  Typography,
} from '@mui/material';
import LoginIcon from '@mui/icons-material/Login';
import { useNavigate } from 'react-router-dom';
import { useAuth } from './AuthContext';

export default function LoginPage() {
  const navigate = useNavigate();
  const auth = useAuth();

  const [email, setEmail] = useState('admin@ecommerce.local');
  const [password, setPassword] = useState('admin123');
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleSubmit(event: React.FormEvent) {
    event.preventDefault();
    setError(null);
    try {
      setSubmitting(true);
      await auth.login({ email, password });
      navigate(auth.hasAnyPermission(['ADMIN_PANEL_ACCESS']) ? '/admin/products' : '/');
    } catch (err: any) {
      setError(err.message || 'Login failed.');
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <Box sx={{ bgcolor: '#f5f7fb', minHeight: '100vh', py: 8 }}>
      <Container maxWidth="sm">
        <Card elevation={0} sx={{ borderRadius: 5, border: '1px solid', borderColor: 'divider' }}>
          <CardContent sx={{ p: { xs: 3, md: 5 } }}>
            <Typography variant="h4" sx={{ fontWeight: 900 }} gutterBottom>
              Login
            </Typography>

            <Typography color="text.secondary" sx={{ mb: 3 }}>
              Role ve permission kontrollü frontend alanlarını test etmek için giriş yap.
            </Typography>

            <Alert severity="info" sx={{ mb: 3 }}>
              <strong>Real backend:</strong> admin@ecommerce.local / admin123<br />
              <strong>Demo admin:</strong> admin@example.com / (any)<br />
              <strong>Demo employee:</strong> employee@example.com / (any)
            </Alert>

            {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}

            <Box component="form" onSubmit={handleSubmit}>
              <Stack spacing={3}>
                <TextField
                  fullWidth
                  label="Email"
                  type="email"
                  autoFocus
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                />
                <TextField
                  fullWidth
                  label="Password"
                  type="password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                />
                <Button
                  type="submit"
                  size="large"
                  variant="contained"
                  startIcon={submitting ? <CircularProgress size={18} color="inherit" /> : <LoginIcon />}
                  disabled={submitting}
                >
                  {submitting ? 'Signing in...' : 'Sign In'}
                </Button>
              </Stack>
            </Box>

            <Divider sx={{ my: 3 }} />

            <Stack spacing={0.5}>
              <Typography variant="body2" color="text.secondary">
                <strong>Admin:</strong> full category/product CRUD, all orders
              </Typography>
              <Typography variant="body2" color="text.secondary">
                <strong>Employee:</strong> limited product/category CRUD
              </Typography>
              <Typography variant="body2" color="text.secondary">
                <strong>Customer:</strong> products, cart and own orders
              </Typography>
            </Stack>
          </CardContent>
        </Card>
      </Container>
    </Box>
  );
}
