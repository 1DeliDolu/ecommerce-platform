import React, { useState } from 'react';
import {
  Alert,
  Box,
  Button,
  Card,
  CardContent,
  CircularProgress,
  Container,
  Stack,
  TextField,
  Typography,
} from '@mui/material';
import PersonAddIcon from '@mui/icons-material/PersonAdd';
import { Link as RouterLink, useNavigate } from 'react-router-dom';
import { useAuth } from './AuthContext';

export default function RegisterPage() {
  const auth = useAuth();
  const navigate = useNavigate();
  const [fullName, setFullName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleSubmit(event: React.FormEvent) {
    event.preventDefault();
    setError(null);
    try {
      setSubmitting(true);
      await auth.register({ fullName, email, password });
      navigate('/products');
    } catch (err: any) {
      setError(err.message || 'Register failed.');
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <Box sx={{ bgcolor: '#f5f7fb', minHeight: '100vh', py: 8 }}>
      <Container maxWidth="sm">
        <Card elevation={0} sx={{ borderRadius: 4, border: '1px solid', borderColor: 'divider' }}>
          <CardContent sx={{ p: { xs: 3, md: 5 } }}>
            <Typography variant="h4" sx={{ fontWeight: 900 }} gutterBottom>
              Register
            </Typography>
            <Typography color="text.secondary" sx={{ mb: 3 }}>
              Yeni müşteri hesabı oluştur.
            </Typography>

            {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}

            <Box component="form" onSubmit={handleSubmit}>
              <Stack spacing={2.5}>
                <TextField label="Full name" value={fullName} onChange={(e) => setFullName(e.target.value)} required />
                <TextField label="Email" type="email" value={email} onChange={(e) => setEmail(e.target.value)} required />
                <TextField label="Password" type="password" value={password} onChange={(e) => setPassword(e.target.value)} required />
                <Button
                  type="submit"
                  size="large"
                  variant="contained"
                  startIcon={submitting ? <CircularProgress size={18} color="inherit" /> : <PersonAddIcon />}
                  disabled={submitting}
                >
                  {submitting ? 'Creating...' : 'Create Account'}
                </Button>
                <Button component={RouterLink} to="/login">
                  Already have an account?
                </Button>
              </Stack>
            </Box>
          </CardContent>
        </Card>
      </Container>
    </Box>
  );
}
