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
import { Link as RouterLink, useNavigate } from 'react-router-dom';

import { useCart } from '../CartContext';
import { StoreProduct } from './customerTypes';
import { getStoreProducts } from '../api/customerApi';

const PLACEHOLDER_IMG = 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=900';

export default function CustomerProductsPage() {
  const navigate = useNavigate();
  const { addToCart, cartItemCount, cartTotal, cartLoading, loadCart } = useCart();

  const [products, setProducts] = useState<StoreProduct[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [snack, setSnack] = useState<string | null>(null);
  const [search, setSearch] = useState('');

  useEffect(() => {
    loadStorefront();
    loadCart();
  }, [loadCart]);

  async function loadStorefront() {
    try {
      setLoading(true);
      const productData = await getStoreProducts();
      setProducts(productData);
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

  const handleAddToCart = async (product: StoreProduct) => {
    try {
      await addToCart(product);
      setSnack(`${product.name} sepete eklendi`);
    } catch (err: any) {
      setSnack(err.message);
    }
  };

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
            disabled={cartItemCount === 0}
            onClick={() => navigate('/checkout')}
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
          filteredProducts.length === 0 ? (
            <Alert severity="info">Arama sonucu bulunamadı.</Alert>
          ) : (
            <Grid container spacing={3}>
              {filteredProducts.map((product) => {
                const primaryImage = product.images.find((img) => img.primary) ?? product.images[0];
                const imgUrl = primaryImage?.url || PLACEHOLDER_IMG;

                return (
                  <Grid key={product.id} size={{ xs: 12, sm: 6, md: 4, xl: 3 }}>
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
                          component={RouterLink}
                          to={`/products/${product.id}`}
                          variant="outlined"
                          sx={{ mr: 1 }}
                        >
                          Detay
                        </Button>
                        <Button
                          variant="contained"
                          startIcon={<AddShoppingCartIcon />}
                          disabled={product.stockQuantity <= 0 || cartLoading}
                          onClick={() => handleAddToCart(product)}
                        >
                          Sepete Ekle
                        </Button>
                      </CardActions>
                    </Card>
                  </Grid>
                );
              })}
            </Grid>
          )
        )}
      </Container>

      <Snackbar
        open={!!snack}
        autoHideDuration={3000}
        onClose={() => setSnack(null)}
        message={snack}
      />
    </Box>
  );
}
