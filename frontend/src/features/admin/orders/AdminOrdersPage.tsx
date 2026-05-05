import { useEffect, useState } from 'react';
import { Alert, Box, Card, CardContent, CircularProgress, Container, Stack, Typography } from '@mui/material';
import { tokenStorage } from '../../../security/token-storage';
import { CustomerOrder } from '../../customer/shop/customerTypes';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:8080';

export default function AdminOrdersPage() {
  const [orders, setOrders] = useState<CustomerOrder[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function loadOrders() {
      try {
        const response = await fetch(`${API_BASE_URL}/api/admin/orders`, { headers: tokenStorage.authHeader() });
        if (!response.ok) throw new Error(`Admin orders endpoint returned ${response.status}`);
        setOrders(await response.json());
      } catch (err: any) {
        setError(err.message || 'Admin orders could not be loaded.');
      } finally {
        setLoading(false);
      }
    }
    loadOrders();
  }, []);

  return (
    <Container maxWidth="xl">
      <Card elevation={0} sx={{ border: '1px solid', borderColor: 'divider', borderRadius: 3 }}>
        <CardContent>
          <Stack spacing={2}>
            <Typography variant="h5" sx={{ fontWeight: 900 }}>Admin Orders</Typography>
            {loading && <Box><CircularProgress /></Box>}
            {error && <Alert severity="error">{error}</Alert>}
            {!loading && !error && orders.length === 0 && <Alert severity="info">No orders yet.</Alert>}
            {orders.map((order) => (
              <Card key={order.id} variant="outlined">
                <CardContent>
                  <Stack direction={{ xs: 'column', md: 'row' }} sx={{ justifyContent: 'space-between' }} spacing={1}>
                    <Box>
                      <Typography sx={{ fontWeight: 900 }}>{order.orderNumber}</Typography>
                      <Typography color="text.secondary">{order.shippingEmail} · {order.status}</Typography>
                    </Box>
                    <Typography sx={{ fontWeight: 900 }}>₺{Number(order.totalAmount).toFixed(2)}</Typography>
                  </Stack>
                </CardContent>
              </Card>
            ))}
          </Stack>
        </CardContent>
      </Card>
    </Container>
  );
}
