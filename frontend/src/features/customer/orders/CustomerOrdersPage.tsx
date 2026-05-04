import React, { useEffect, useMemo, useState } from 'react';
import {
  Alert,
  Box,
  Button,
  Card,
  CardContent,
  Chip,
  Collapse,
  Container,
  Divider,
  Grid,
  IconButton,
  Stack,
  Typography,
} from '@mui/material';

import ExpandMoreIcon from '@mui/icons-material/ExpandMore';
import ReceiptLongIcon from '@mui/icons-material/ReceiptLong';
import RefreshIcon from '@mui/icons-material/Refresh';
import ShoppingBagIcon from '@mui/icons-material/ShoppingBag';

import { getMyOrders } from '../api/customerApi';
import { CustomerOrder } from '../shop/customerTypes';

export default function CustomerOrdersPage() {
  const [orders, setOrders] = useState<CustomerOrder[]>([]);
  const [expandedOrderId, setExpandedOrderId] = useState<number | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    loadOrders();
  }, []);

  async function loadOrders() {
    try {
      setLoading(true);
      setError(null);
      const data = await getMyOrders();
      setOrders(data);
    } catch (err: any) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  const totalSpent = useMemo(
    () => orders.reduce((sum, o) => sum + o.totalAmount, 0),
    [orders]
  );

  const totalItems = useMemo(
    () =>
      orders.reduce(
        (sum, o) => sum + o.items.reduce((s, i) => s + i.quantity, 0),
        0
      ),
    [orders]
  );

  const toggleOrder = (orderId: number) =>
    setExpandedOrderId((cur) => (cur === orderId ? null : orderId));

  return (
    <Box sx={{ bgcolor: '#f5f7fb', minHeight: '100vh', py: 4 }}>
      <Container maxWidth="xl">
        {/* Header */}
        <Stack
          direction={{ xs: 'column', md: 'row' }}
          sx={{ justifyContent: 'space-between', alignItems: { xs: 'stretch', md: 'center' }, mb: 4 }}
          spacing={2}
        >
          <Box>
            <Typography variant="h4" sx={{ fontWeight: 900 }}>
              My Orders
            </Typography>
            <Typography color="text.secondary">
              Satın alma geçmişi, ödeme özeti ve sipariş detayları.
            </Typography>
          </Box>

          <Button
            variant="outlined"
            startIcon={<RefreshIcon />}
            onClick={loadOrders}
            disabled={loading}
          >
            Refresh
          </Button>
        </Stack>

        {/* Summary cards */}
        <Grid container spacing={3} sx={{ mb: 4 }}>
          <SummaryCard title="Total Orders" value={String(orders.length)} icon={<ReceiptLongIcon />} />
          <SummaryCard title="Total Items" value={String(totalItems)} icon={<ShoppingBagIcon />} />
          <SummaryCard title="Total Spent" value={`₺${totalSpent.toFixed(2)}`} icon={<ReceiptLongIcon />} />
        </Grid>

        {error && <Alert severity="error" sx={{ mb: 3 }}>{error}</Alert>}

        {loading && (
          <Card elevation={0} sx={{ borderRadius: 4, border: '1px solid', borderColor: 'divider' }}>
            <CardContent>
              <Typography>Orders loading...</Typography>
            </CardContent>
          </Card>
        )}

        {!loading && !error && orders.length === 0 && (
          <Alert severity="info" sx={{ borderRadius: 3 }}>
            Henüz siparişin yok. Ürün sayfasından alışveriş yaparak ilk siparişini oluşturabilirsin.
          </Alert>
        )}

        {/* Order list */}
        <Stack spacing={3}>
          {orders.map((order) => {
            const expanded = expandedOrderId === order.id;
            const itemCount = order.items.reduce((s, i) => s + i.quantity, 0);

            return (
              <Card
                key={order.id}
                elevation={0}
                sx={{ borderRadius: 4, border: '1px solid', borderColor: 'divider' }}
              >
                <CardContent>
                  {/* Order header row */}
                  <Stack
                    direction={{ xs: 'column', md: 'row' }}
                    sx={{ justifyContent: 'space-between', alignItems: { xs: 'flex-start', md: 'center' } }}
                    spacing={2}
                  >
                    <Box>
                      <Stack direction="row" spacing={1} sx={{ alignItems: 'center', flexWrap: 'wrap' }}>
                        <Typography variant="h6" sx={{ fontWeight: 900 }}>
                          {order.orderNumber}
                        </Typography>
                        <Chip
                          label={order.status}
                          color={order.status === 'PAID' ? 'success' : 'default'}
                          size="small"
                        />
                      </Stack>
                      <Typography color="text.secondary">
                        {formatDate(order.createdAt)} · {itemCount} item(s)
                      </Typography>
                    </Box>

                    <Stack direction="row" spacing={2} sx={{ alignItems: 'center' }}>
                      <Box sx={{ textAlign: 'right' }}>
                        <Typography color="text.secondary" variant="body2">Total</Typography>
                        <Typography sx={{ fontWeight: 900 }}>₺{order.totalAmount.toFixed(2)}</Typography>
                      </Box>
                      <IconButton onClick={() => toggleOrder(order.id)}>
                        <ExpandMoreIcon
                          sx={{
                            transform: expanded ? 'rotate(180deg)' : 'rotate(0deg)',
                            transition: 'transform 0.2s ease',
                          }}
                        />
                      </IconButton>
                    </Stack>
                  </Stack>

                  {/* Expandable detail */}
                  <Collapse in={expanded} timeout="auto" unmountOnExit>
                    <Divider sx={{ my: 3 }} />

                    <Grid container spacing={3}>
                      <Grid size={{ xs: 12, md: 6 }}>
                        <Typography sx={{ fontWeight: 900 }} gutterBottom>Shipping</Typography>
                        <Typography>{order.shippingFullName}</Typography>
                        <Typography color="text.secondary">{order.shippingEmail}</Typography>
                        <Typography color="text.secondary">
                          {order.shippingCity}, {order.shippingCountry}
                        </Typography>
                      </Grid>

                      <Grid size={{ xs: 12, md: 6 }}>
                        <Typography sx={{ fontWeight: 900 }} gutterBottom>Payment</Typography>
                        <Typography>{order.paymentMethod}</Typography>
                        <Typography color="text.secondary" sx={{ wordBreak: 'break-all' }}>
                          {order.paymentReference}
                        </Typography>
                      </Grid>

                      <Grid size={{ xs: 12 }}>
                        <Typography sx={{ fontWeight: 900 }} gutterBottom>Items</Typography>
                        <Stack spacing={2}>
                          {order.items.map((item) => (
                            <Card key={item.id} variant="outlined" sx={{ borderRadius: 3 }}>
                              <CardContent>
                                <Stack
                                  direction={{ xs: 'column', sm: 'row' }}
                                  sx={{ justifyContent: 'space-between' }}
                                  spacing={2}
                                >
                                  <Box>
                                    <Typography sx={{ fontWeight: 900 }}>{item.productName}</Typography>
                                    <Typography color="text.secondary">/{item.productSlug}</Typography>
                                  </Box>
                                  <Box sx={{ textAlign: { xs: 'left', sm: 'right' } }}>
                                    <Typography>₺{item.unitPrice.toFixed(2)} × {item.quantity}</Typography>
                                    <Typography sx={{ fontWeight: 900 }}>₺{item.lineTotal.toFixed(2)}</Typography>
                                  </Box>
                                </Stack>
                              </CardContent>
                            </Card>
                          ))}
                        </Stack>
                      </Grid>

                      <Grid size={{ xs: 12 }}>
                        <Card variant="outlined" sx={{ borderRadius: 3 }}>
                          <CardContent>
                            <Stack spacing={1}>
                              <SummaryRow label="Subtotal" value={order.subtotal} />
                              <SummaryRow label="Shipping" value={order.shippingCost} />
                              <SummaryRow label="Tax (KDV 18%)" value={order.tax} />
                              <Divider />
                              <SummaryRow label="Total" value={order.totalAmount} bold />
                            </Stack>
                          </CardContent>
                        </Card>
                      </Grid>
                    </Grid>
                  </Collapse>
                </CardContent>
              </Card>
            );
          })}
        </Stack>
      </Container>
    </Box>
  );
}

function SummaryCard({ title, value, icon }: { title: string; value: string; icon: React.ReactNode }) {
  return (
    <Grid size={{ xs: 12, sm: 4 }}>
      <Card elevation={0} sx={{ borderRadius: 4, border: '1px solid', borderColor: 'divider', height: '100%' }}>
        <CardContent>
          <Stack direction="row" sx={{ justifyContent: 'space-between', alignItems: 'center' }}>
            <Box>
              <Typography color="text.secondary" variant="body2">{title}</Typography>
              <Typography variant="h5" sx={{ fontWeight: 900 }}>{value}</Typography>
            </Box>
            <Box
              sx={{
                width: 52,
                height: 52,
                borderRadius: 3,
                bgcolor: 'primary.main',
                color: 'white',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              {icon}
            </Box>
          </Stack>
        </CardContent>
      </Card>
    </Grid>
  );
}

function SummaryRow({ label, value, bold = false }: { label: string; value: number; bold?: boolean }) {
  return (
    <Stack direction="row" sx={{ justifyContent: 'space-between' }}>
      <Typography sx={{ fontWeight: bold ? 900 : 400 }}>{label}</Typography>
      <Typography sx={{ fontWeight: bold ? 900 : 700 }}>₺{value.toFixed(2)}</Typography>
    </Stack>
  );
}

function formatDate(value: string): string {
  if (!value) return '-';
  return new Date(value).toLocaleString('tr-TR', { dateStyle: 'medium', timeStyle: 'short' });
}
