import React, { useEffect, useMemo, useState } from 'react';
import {
  Alert,
  Box,
  Button,
  Card,
  CardActions,
  CardContent,
  CardMedia,
  Chip,
  CircularProgress,
  Container,
  Grid,
  Snackbar,
  Stack,
  TextField,
  Typography,
} from '@mui/material';

import AddShoppingCartIcon from '@mui/icons-material/AddShoppingCart';
import SearchIcon from '@mui/icons-material/Search';
import ShoppingCartCheckoutIcon from '@mui/icons-material/ShoppingCartCheckout';

import { CartItem, StoreProduct } from './customerTypes';
import {
  addCartItem,
  getCart,
  getStoreProducts,
  removeCartItem,
  updateCartItem,
} from '../api/customerApi';
import { getUserEmail } from './customerApi';
import CheckoutStepperPage from '../checkout/CheckoutStepperPage';

const PLACEHOLDER_IMG = 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=900';

export default function CustomerProductsPage() {
  const [products, setProducts] = useState<StoreProduct[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [cartItems, setCartItems] = useState<CartItem[]>([]);
  const [cartLoading, setCartLoading] = useState(false);
  const [snack, setSnack] = useState<string | null>(null);
  const [search, setSearch] = useState('');
  const [checkoutOpen, setCheckoutOpen] = useState(false);

  const userEmail = getUserEmail();

  useEffect(() => {
    loadStorefront();
  }, []);

  async function loadStorefront() {
    try {
      setLoading(true);
      const [productData, cartData] = await Promise.all([
        getStoreProducts(),
        getCart(),
      ]);
      setProducts(productData);
      setCartItems(cartData);
    } catch (err: any) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  const filteredProducts = useMemo(() => {
    const q = search.toLowerCase();
    return products.filter(
      (p) =>
        p.name.toLowerCase().includes(q) ||
        (p.categoryName ?? '').toLowerCase().includes(q) ||
        (p.description ?? '').toLowerCase().includes(q)
    );
  }, [products, search]);

  const cartTotal = useMemo(
    () => cartItems.reduce((sum, item) => sum + item.product.price * item.quantity, 0),
    [cartItems]
  );

  const cartItemCount = useMemo(
    () => cartItems.reduce((sum, item) => sum + item.quantity, 0),
    [cartItems]
  );

  const addToCart = async (product: StoreProduct) => {
    if (product.stockQuantity <= 0) return;
    setCartLoading(true);
    try {
      const updatedCart = await addCartItem(product.id, 1);
      setCartItems(updatedCart);
    } catch (err: any) {
      setSnack(err.message);
    } finally {
      setCartLoading(false);
    }
  };

  const increaseQuantity = async (productId: number) => {
    const item = cartItems.find((i) => i.product.id === productId);
    if (!item) return;
    setCartLoading(true);
    try {
      const updatedCart = await updateCartItem(productId, item.quantity + 1);
      setCartItems(updatedCart);
    } catch (err: any) {
      setSnack(err.message);
    } finally {
      setCartLoading(false);
    }
  };

  const decreaseQuantity = async (productId: number) => {
    const item = cartItems.find((i) => i.product.id === productId);
    if (!item) return;
    setCartLoading(true);
    try {
      const updatedCart =
        item.quantity <= 1
          ? await removeCartItem(productId)
          : await updateCartItem(productId, item.quantity - 1);
      setCartItems(updatedCart);
    } catch (err: any) {
      setSnack(err.message);
    } finally {
      setCartLoading(false);
    }
  };

  const removeFromCart = async (productId: number) => {
    setCartLoading(true);
    try {
      const updatedCart = await removeCartItem(productId);
      setCartItems(updatedCart);
    } catch (err: any) {
      setSnack(err.message);
    } finally {
      setCartLoading(false);
    }
  };

  const clearCart = () => {
    setCartItems([]);
    loadStorefront();
  };

  if (checkoutOpen) {
    return (
      <CheckoutStepperPage
        cartItems={cartItems}
        userEmail={userEmail}
        onBackToShop={() => setCheckoutOpen(false)}
        onIncreaseQuantity={increaseQuantity}
        onDecreaseQuantity={decreaseQuantity}
        onRemoveFromCart={removeFromCart}
        onOrderCompleted={clearCart}
      />
    );
  }

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
              Customer Store
            </Typography>
            <Typography color="text.secondary">
              Ürünleri incele, sepete ekle ve satın alma akışını tamamla.
            </Typography>
          </Box>

          <Button
            variant="contained"
            size="large"
            startIcon={<ShoppingCartCheckoutIcon />}
            disabled={cartItems.length === 0}
            onClick={() => setCheckoutOpen(true)}
          >
            Checkout ({cartItemCount}) — ₺{cartTotal.toFixed(2)}
          </Button>
        </Stack>

        {/* Search */}
        <Card elevation={0} sx={{ borderRadius: 4, border: '1px solid', borderColor: 'divider', mb: 4 }}>
          <CardContent>
            <TextField
              fullWidth
              label="Ürün ara"
              placeholder="İsim, kategori veya açıklama..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              slotProps={{
                input: {
                  startAdornment: <SearchIcon sx={{ mr: 1, color: 'text.secondary' }} />,
                },
              }}
            />
          </CardContent>
        </Card>

        {loading && (
          <Box sx={{ display: 'flex', justifyContent: 'center', py: 8 }}>
            <CircularProgress />
          </Box>
        )}

        {error && <Alert severity="error" sx={{ mb: 3 }}>{error}</Alert>}

        {!loading && !error && (
          <Grid container spacing={3}>
            {/* Product Grid */}
            <Grid size={{ xs: 12, lg: 8 }}>
              {filteredProducts.length === 0 ? (
                <Alert severity="info">Arama sonucu bulunamadı.</Alert>
              ) : (
                <Grid container spacing={3}>
                  {filteredProducts.map((product) => {
                    const primaryImage = product.images.find((img) => img.primary) ?? product.images[0];
                    const imgUrl = primaryImage?.url || PLACEHOLDER_IMG;

                    return (
                      <Grid key={product.id} size={{ xs: 12, md: 6, xl: 4 }}>
                        <Card
                          elevation={0}
                          sx={{
                            height: '100%',
                            display: 'flex',
                            flexDirection: 'column',
                            borderRadius: 4,
                            overflow: 'hidden',
                            border: '1px solid',
                            borderColor: 'divider',
                          }}
                        >
                          <CardMedia
                            component="img"
                            height="200"
                            image={imgUrl}
                            alt={product.name}
                            sx={{ objectFit: 'cover' }}
                            onError={(e) => { (e.target as HTMLImageElement).src = PLACEHOLDER_IMG; }}
                          />

                          <CardContent sx={{ flexGrow: 1 }}>
                            <Stack direction="row" sx={{ justifyContent: 'space-between' }} spacing={1}>
                              <Box>
                                <Typography variant="h6" sx={{ fontWeight: 900 }}>
                                  {product.name}
                                </Typography>
                                <Typography variant="body2" color="text.secondary">
                                  {product.categoryName}
                                </Typography>
                              </Box>
                              <Chip
                                label={product.stockQuantity > 0 ? 'Stokta' : 'Tükendi'}
                                color={product.stockQuantity > 0 ? 'success' : 'error'}
                                size="small"
                              />
                            </Stack>

                            <Typography color="text.secondary" sx={{ mt: 1.5, fontSize: 14, minHeight: 40 }}>
                              {product.description ?? ''}
                            </Typography>

                            <Stack direction="row" sx={{ justifyContent: 'space-between', mt: 2 }}>
                              <Typography variant="h6" sx={{ fontWeight: 900 }} color="primary">
                                ₺{product.price.toFixed(2)}
                              </Typography>
                              <Typography variant="body2" color="text.secondary">
                                Stok: {product.stockQuantity}
                              </Typography>
                            </Stack>
                          </CardContent>

                          <CardActions sx={{ p: 2, pt: 0 }}>
                            <Button
                              fullWidth
                              variant="contained"
                              startIcon={<AddShoppingCartIcon />}
                              disabled={product.stockQuantity <= 0 || cartLoading}
                              onClick={() => addToCart(product)}
                            >
                              Sepete Ekle
                            </Button>
                          </CardActions>
                        </Card>
                      </Grid>
                    );
                  })}
                </Grid>
              )}
            </Grid>

            {/* Cart Sidebar */}
            <Grid size={{ xs: 12, lg: 4 }}>
              <CartSummaryCard
                cartItems={cartItems}
                total={cartTotal}
                onCheckout={() => setCheckoutOpen(true)}
                onIncreaseQuantity={increaseQuantity}
                onDecreaseQuantity={decreaseQuantity}
                onRemoveFromCart={removeFromCart}
              />
            </Grid>
          </Grid>
        )}
      </Container>

      <Snackbar
        open={!!snack}
        autoHideDuration={4000}
        onClose={() => setSnack(null)}
        message={snack}
      />
    </Box>
  );
}

function CartSummaryCard({
  cartItems,
  total,
  onCheckout,
  onIncreaseQuantity,
  onDecreaseQuantity,
  onRemoveFromCart,
}: {
  cartItems: CartItem[];
  total: number;
  onCheckout: () => void;
  onIncreaseQuantity: (productId: number) => void;
  onDecreaseQuantity: (productId: number) => void;
  onRemoveFromCart: (productId: number) => void;
}) {
  return (
    <Card
      elevation={0}
      sx={{
        borderRadius: 4,
        border: '1px solid',
        borderColor: 'divider',
        position: { lg: 'sticky' },
        top: { lg: 24 },
      }}
    >
      <CardContent>
        <Typography variant="h6" sx={{ fontWeight: 900 }} gutterBottom>
          Sepet
        </Typography>

        {cartItems.length === 0 ? (
          <Typography color="text.secondary">Sepetin boş. Ürün ekleyerek devam et.</Typography>
        ) : (
          <Stack spacing={2}>
            {cartItems.map((item) => (
              <Box key={item.product.id}>
                <Stack direction="row" spacing={2}>
                  <Box
                    component="img"
                    src={item.product.images[0]?.url || PLACEHOLDER_IMG}
                    alt={item.product.name}
                    sx={{ width: 64, height: 64, objectFit: 'cover', borderRadius: 2 }}
                    onError={(e) => { (e.target as HTMLImageElement).src = PLACEHOLDER_IMG; }}
                  />
                  <Box sx={{ flexGrow: 1 }}>
                    <Typography sx={{ fontWeight: 800 }} noWrap>{item.product.name}</Typography>
                    <Typography variant="body2" color="text.secondary">
                      ₺{item.product.price.toFixed(2)} × {item.quantity}
                    </Typography>
                    <Stack direction="row" spacing={0.5} sx={{ mt: 1 }}>
                      <Button size="small" variant="outlined" onClick={() => onDecreaseQuantity(item.product.id)} sx={{ minWidth: 32 }}>−</Button>
                      <Button size="small" variant="outlined" disabled sx={{ minWidth: 32 }}>{item.quantity}</Button>
                      <Button size="small" variant="outlined" onClick={() => onIncreaseQuantity(item.product.id)} sx={{ minWidth: 32 }}>+</Button>
                      <Button size="small" color="error" onClick={() => onRemoveFromCart(item.product.id)}>Sil</Button>
                    </Stack>
                  </Box>
                </Stack>
              </Box>
            ))}

            <Box sx={{ borderTop: '1px solid', borderColor: 'divider', pt: 2 }}>
              <Stack direction="row" sx={{ justifyContent: 'space-between' }}>
                <Typography sx={{ fontWeight: 900 }}>Toplam</Typography>
                <Typography sx={{ fontWeight: 900 }}>₺{total.toFixed(2)}</Typography>
              </Stack>
            </Box>

            <Button fullWidth variant="contained" size="large" onClick={onCheckout} startIcon={<ShoppingCartCheckoutIcon />}>
              Ödemeye Geç
            </Button>
          </Stack>
        )}
      </CardContent>
    </Card>
  );
}
