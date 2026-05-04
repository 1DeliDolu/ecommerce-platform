import { useEffect, useMemo, useState } from 'react';
import { Alert, Box, Button, Card, CardContent, CircularProgress, Container, Stack, Typography } from '@mui/material';
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import { useNavigate } from 'react-router-dom';
import {
  getCart,
  removeCartItem,
  updateCartItem,
} from '../api/customerApi';
import { getUserEmail } from '../shop/customerApi';
import { CartItem } from '../shop/customerTypes';
import CheckoutStepperPage from './CheckoutStepperPage';

export default function CustomerCheckoutPage() {
  const navigate = useNavigate();
  const [cartItems, setCartItems] = useState<CartItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [cartLoading, setCartLoading] = useState(false);

  const itemCount = useMemo(
    () => cartItems.reduce((sum, item) => sum + item.quantity, 0),
    [cartItems]
  );

  useEffect(() => {
    void loadCart();
  }, []);

  async function loadCart() {
    try {
      setLoading(true);
      setError(null);
      setCartItems(await getCart());
    } catch (err: any) {
      setError(err.message || 'Cart could not be loaded.');
    } finally {
      setLoading(false);
    }
  }

  const increaseQuantity = async (productId: number) => {
    const item = cartItems.find((cartItem) => cartItem.product.id === productId);
    if (!item) return;
    setCartLoading(true);
    try {
      setCartItems(await updateCartItem(productId, item.quantity + 1));
    } catch (err: any) {
      setError(err.message || 'Cart update failed.');
    } finally {
      setCartLoading(false);
    }
  };

  const decreaseQuantity = async (productId: number) => {
    const item = cartItems.find((cartItem) => cartItem.product.id === productId);
    if (!item) return;
    setCartLoading(true);
    try {
      setCartItems(
        item.quantity <= 1
          ? await removeCartItem(productId)
          : await updateCartItem(productId, item.quantity - 1)
      );
    } catch (err: any) {
      setError(err.message || 'Cart update failed.');
    } finally {
      setCartLoading(false);
    }
  };

  const removeFromCart = async (productId: number) => {
    setCartLoading(true);
    try {
      setCartItems(await removeCartItem(productId));
    } catch (err: any) {
      setError(err.message || 'Cart update failed.');
    } finally {
      setCartLoading(false);
    }
  };

  if (loading) {
    return (
      <Box sx={{ bgcolor: '#f5f7fb', minHeight: '100vh', py: 6 }}>
        <Container maxWidth="md">
          <Card elevation={0} sx={{ borderRadius: 2, border: '1px solid', borderColor: 'divider' }}>
            <CardContent>
              <Stack direction="row" spacing={2} sx={{ alignItems: 'center' }}>
                <CircularProgress size={24} />
                <Typography>Checkout cart loading...</Typography>
              </Stack>
            </CardContent>
          </Card>
        </Container>
      </Box>
    );
  }

  if (error && cartItems.length === 0) {
    return (
      <Box sx={{ bgcolor: '#f5f7fb', minHeight: '100vh', py: 6 }}>
        <Container maxWidth="md">
          <Alert
            severity="error"
            action={<Button color="inherit" size="small" onClick={loadCart}>Retry</Button>}
          >
            {error}
          </Alert>
        </Container>
      </Box>
    );
  }

  if (cartItems.length === 0) {
    return (
      <Box sx={{ bgcolor: '#f5f7fb', minHeight: '100vh', py: 6 }}>
        <Container maxWidth="md">
          <Card elevation={0} sx={{ borderRadius: 2, border: '1px solid', borderColor: 'divider' }}>
            <CardContent sx={{ p: 4, textAlign: 'center' }}>
              <Typography variant="h4" sx={{ fontWeight: 900 }} gutterBottom>
                Sepetin boş
              </Typography>
              <Typography color="text.secondary" sx={{ mb: 3 }}>
                Checkout akışına devam etmek için önce ürün ekle.
              </Typography>
              <Button variant="contained" startIcon={<ArrowBackIcon />} onClick={() => navigate('/products')}>
                Ürünlere Dön
              </Button>
            </CardContent>
          </Card>
        </Container>
      </Box>
    );
  }

  return (
    <>
      {cartLoading && (
        <Box sx={{ position: 'fixed', left: 0, right: 0, top: 72, zIndex: 1200 }}>
          <CircularProgress size={20} sx={{ m: 1 }} />
        </Box>
      )}
      {error && (
        <Container maxWidth="xl" sx={{ pt: 2 }}>
          <Alert severity="warning" onClose={() => setError(null)}>{error}</Alert>
        </Container>
      )}
      <CheckoutStepperPage
        cartItems={cartItems}
        userEmail={getUserEmail()}
        onBackToShop={() => navigate('/products')}
        onIncreaseQuantity={increaseQuantity}
        onDecreaseQuantity={decreaseQuantity}
        onRemoveFromCart={removeFromCart}
        onOrderCompleted={() => {
          setCartItems([]);
          if (itemCount > 0) setTimeout(() => navigate('/orders'), 1200);
        }}
      />
    </>
  );
}
